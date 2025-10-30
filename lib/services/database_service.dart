import '../models/user.dart';
import '../models/visitor_request.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static DatabaseService get instance => _instance;

  DatabaseService._internal() {
    _initializeData();
  }

  // Mock database storage
  final Map<String, User> _users = {};
  final Map<String, String> _passwords = {};
  final List<VisitorRequest> _requests = [];

  void _initializeData() {
    // Add the panda user (you)
    final pandaUser = User(
      id: 'panda_001',
      name: 'Panda Master',
      email: 'panda@garden.com',
      type: UserType.panda,
      createdAt: DateTime.now(),
      isApproved: true,
      status: GardenStatus.notInGarden,
    );
    _users[pandaUser.id] = pandaUser;
    _passwords[pandaUser.email] = 'panda123'; // Default password

    // Add some sample visitors for testing
    _addSampleVisitors();
  }

  void _addSampleVisitors() {
    final visitors = [
      User(
        id: 'visitor_001',
        name: 'Alice Walker',
        email: 'alice@example.com',
        type: UserType.visitor,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        isApproved: true,
        status: GardenStatus.notInGarden,
      ),
      User(
        id: 'visitor_002',
        name: 'Bob Smith',
        email: 'bob@example.com',
        type: UserType.visitor,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        isApproved: false,
        status: GardenStatus.notInGarden,
      ),
    ];

    for (var visitor in visitors) {
      _users[visitor.id] = visitor;
      _passwords[visitor.email] = 'visitor123';
    }

    _requests.add(VisitorRequest(
      id: 'req_001',
      visitorId: 'visitor_002',
      visitorName: 'Bob Smith',
      requestedAt: DateTime.now().subtract(const Duration(hours: 2)),
      requestedStatus: GardenStatus.inGarden, // NEW: Bob wants to go to garden
      status: RequestStatus.pending,
    ));
  }

  // Authentication
  Future<User?> authenticateUser(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    
    if (_passwords[email] == password) {
      return _users.values.firstWhere(
        (user) => user.email == email,
        orElse: () => throw Exception('User not found'),
      );
    }
    return null;
  }

  // User operations
  Future<User?> getUserById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _users[id];
  }

  Future<User?> getUserByEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _users.values.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  Future<void> createUser(User user, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _users[user.id] = user;
    _passwords[user.email] = password;
  }

  Future<void> updateUser(User user) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _users[user.id] = user;
  }

  Future<List<User>> getAllVisitors() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _users.values
        .where((user) => user.type == UserType.visitor)
        .toList();
  }

  Future<User?> getPandaUser() async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _users.values.firstWhere((user) => user.type == UserType.panda);
    } catch (e) {
      return null;
    }
  }

  // Request operations
  Future<void> createRequest(VisitorRequest request) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _requests.add(request);
  }

  Future<void> updateRequest(VisitorRequest request) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _requests.indexWhere((r) => r.id == request.id);
    if (index != -1) {
      _requests[index] = request;
    }
  }

  Future<List<VisitorRequest>> getPendingRequests() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _requests
        .where((request) => request.status == RequestStatus.pending)
        .toList();
  }

  Future<List<VisitorRequest>> getAllRequests() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_requests);
  }

  Future<List<VisitorRequest>> getVisitorRequests(String visitorId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _requests
        .where((request) => request.visitorId == visitorId)
        .toList();
  }

  // Visitor approval
  Future<void> approveVisitor(String visitorId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final user = _users[visitorId];
    if (user != null) {
      _users[visitorId] = user.copyWith(isApproved: true);
    }
  }

  Future<void> denyVisitor(String visitorId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final user = _users[visitorId];
    if (user != null) {
      _users[visitorId] = user.copyWith(isApproved: false);
    }
  }
}
