import 'package:flutter/foundation.dart';
import '../models/user.dart';
import 'api_service.dart';

class GardenService extends ChangeNotifier {
  final ApiService _api = ApiService();

  User? _pandaUser;
  List<User> _visitors = [];

  User? get pandaUser => _pandaUser;
  List<User> get visitors => _visitors;

  List<User> get visitorsInGarden =>
      _visitors.where((v) => v.status == GardenStatus.inGarden).toList();

  List<User> get visitorsGoingToGarden =>
      _visitors.where((v) => v.status == GardenStatus.goingToGarden).toList();

  GardenService() {
    loadData();
  }

  Future<void> loadData() async {
    try {
      await loadPandaUser();
      await loadVisitors();
      notifyListeners();
    } catch (e) {
      print('Load data error: $e');
    }
  }

  Future<void> loadPandaUser() async {
    try {
      _pandaUser = await _api.getPandaStatus();
      notifyListeners();
    } catch (e) {
      print('Load panda user error: $e');
    }
  }

  Future<void> loadVisitors() async {
    try {
      _visitors = await _api.getVisitors();
      notifyListeners();
    } catch (e) {
      print('Load visitors error: $e');
    }
  }

  Future<void> updatePandaStatus(GardenStatus status) async {
    if (_pandaUser == null) return;

    try {
      await _api.updateMyStatus(status);
      _pandaUser = _pandaUser!.copyWith(
        status: status,
        statusUpdatedAt: DateTime.now(),
      );
      notifyListeners();
    } catch (e) {
      print('Update panda status error: $e');
      rethrow;
    }
  }

  Future<void> updateVisitorStatus(String visitorId, GardenStatus status) async {
    try {
      await _api.updateUserStatus(visitorId, status);
      await loadVisitors();
    } catch (e) {
      print('Update visitor status error: $e');
      rethrow;
    }
  }
}