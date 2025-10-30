import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/visitor_request.dart';
import 'database_service.dart';
import 'notification_service.dart';

class GardenService extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  
  User? _pandaUser;
  List<User> _visitors = [];
  List<VisitorRequest> _pendingRequests = [];
  List<VisitorRequest> _allRequests = [];

  User? get pandaUser => _pandaUser;
  List<User> get visitors => _visitors;
  List<VisitorRequest> get pendingRequests => _pendingRequests;
  List<VisitorRequest> get allRequests => _allRequests;

  List<User> get approvedVisitors =>
      _visitors.where((v) => v.isApproved).toList();

  List<User> get unapprovedVisitors =>
      _visitors.where((v) => !v.isApproved).toList();

  List<User> get visitorsInGarden =>
      _visitors.where((v) => v.status == GardenStatus.inGarden && v.isApproved).toList();

  List<User> get visitorsGoingToGarden =>
      _visitors.where((v) => v.status == GardenStatus.goingToGarden && v.isApproved).toList();

  GardenService() {
    loadData();
  }

  Future<void> loadData() async {
    await loadPandaUser();
    await loadVisitors();
    await loadRequests();
    notifyListeners();
  }

  Future<void> loadPandaUser() async {
    _pandaUser = await _db.getPandaUser();
    notifyListeners();
  }

  Future<void> loadVisitors() async {
    _visitors = await _db.getAllVisitors();
    notifyListeners();
  }

  Future<void> loadRequests() async {
    _pendingRequests = await _db.getPendingRequests();
    _allRequests = await _db.getAllRequests();
    notifyListeners();
  }

  Future<void> updatePandaStatus(GardenStatus status) async {
    if (_pandaUser == null) return;

    _pandaUser = _pandaUser!.copyWith(
      status: status,
      statusUpdatedAt: DateTime.now(),
    );

    await _db.updateUser(_pandaUser!);
    notifyListeners();
  }
  Future<void> createVisitorRequest(
      String visitorId,
      String visitorName,
      {GardenStatus? requestedStatus} // NEW: optional status change
      ) async {
    final request = VisitorRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      visitorId: visitorId,
      visitorName: visitorName,
      requestedAt: DateTime.now(),
      requestedStatus: requestedStatus, // NEW
      status: RequestStatus.pending,
    );

    await _db.createRequest(request);

    // Send push notification to panda
    final notificationBody = requestedStatus != null
        ? '$visitorName wants to change status to ${requestedStatus.displayName}'
        : '$visitorName wants to visit the garden';

    await NotificationService.instance.showNotification(
      title: '🐼 New Visitor Request',
      body: notificationBody,
    );

    await loadRequests();
  }

  Future<void> approveRequest(String requestId) async {
    final request = _pendingRequests.firstWhere((r) => r.id == requestId);
    final updatedRequest = request.copyWith(
      status: RequestStatus.approved,
      respondedAt: DateTime.now(),
    );

    await _db.updateRequest(updatedRequest);

    // Approve the visitor if not already approved
    final visitor = _visitors.firstWhere((v) => v.id == request.visitorId);
    if (!visitor.isApproved) {
      await _db.approveVisitor(request.visitorId);
    }

    // Update visitor status if this was a status change request
    if (request.requestedStatus != null) {
      final updatedVisitor = visitor.copyWith(
        isApproved: true,
        status: request.requestedStatus, // Apply the requested status
        statusUpdatedAt: DateTime.now(),
      );
      await _db.updateUser(updatedVisitor);
    }

    await loadData();
  }

  Future<void> denyRequest(String requestId) async {
    final request = _pendingRequests.firstWhere((r) => r.id == requestId);
    final updatedRequest = request.copyWith(
      status: RequestStatus.denied,
      respondedAt: DateTime.now(),
    );

    await _db.updateRequest(updatedRequest);
    await loadRequests();
  }

  Future<void> updateVisitorStatus(String visitorId, GardenStatus status) async {
    final visitor = _visitors.firstWhere((v) => v.id == visitorId);
    final updatedVisitor = visitor.copyWith(
      status: status,
      statusUpdatedAt: DateTime.now(),
    );

    await _db.updateUser(updatedVisitor);
    await loadVisitors();
  }

  Future<void> toggleVisitorApproval(String visitorId) async {
    final visitor = _visitors.firstWhere((v) => v.id == visitorId);
    if (visitor.isApproved) {
      await _db.denyVisitor(visitorId);
    } else {
      await _db.approveVisitor(visitorId);
    }
    await loadVisitors();
  }

  Future<List<VisitorRequest>> getVisitorRequests(String visitorId) async {
    return await _db.getVisitorRequests(visitorId);
  }
}
