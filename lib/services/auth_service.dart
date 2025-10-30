import 'package:flutter/foundation.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  final ApiService _api = ApiService();

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isPanda => _currentUser?.type == UserType.panda;

  // Initialize and try to restore session
  Future<void> init() async {
    await _api.init();
    try {
      _currentUser = await _api.getCurrentUser();
      notifyListeners();
    } catch (e) {
      // No valid session
      _currentUser = null;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await _api.login(email, password);
      _currentUser = response.user;
      notifyListeners();
      return true;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<bool> registerVisitor({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.register(name, email, password);
      _currentUser = response.user;
      notifyListeners();
      return true;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _api.logout();
    } catch (e) {
      print('Logout error: $e');
    }
    _currentUser = null;
    notifyListeners();
  }

  Future<void> updateUserStatus(GardenStatus status) async {
    if (_currentUser == null) return;

    try {
      await _api.updateMyStatus(status);
      _currentUser = _currentUser!.copyWith(
        status: status,
        statusUpdatedAt: DateTime.now(),
      );
      notifyListeners();
    } catch (e) {
      print('Update status error: $e');
      rethrow;
    }
  }

  Future<void> refreshCurrentUser() async {
    if (_currentUser == null) return;

    try {
      _currentUser = await _api.getCurrentUser();
      notifyListeners();
    } catch (e) {
      print('Refresh user error: $e');
    }
  }
}