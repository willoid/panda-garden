import '../models/user.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static DatabaseService get instance => _instance;

  DatabaseService._internal() {
    _initializeData();
  }

  final Map<String, User> _users = {};
  final Map<String, String> _passwords = {};

  void _initializeData() {
    final pandaUser = User(
      id: 'panda_001',
      name: 'Panda Master',
      email: 'panda@garden.com',
      type: UserType.panda,
      createdAt: DateTime.now(),
      status: GardenStatus.notInGarden,
    );
    _users[pandaUser.id] = pandaUser;
    _passwords[pandaUser.email] = 'panda123';

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
        status: GardenStatus.notInGarden,
      ),
      User(
        id: 'visitor_002',
        name: 'Bob Smith',
        email: 'bob@example.com',
        type: UserType.visitor,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        status: GardenStatus.notInGarden,
      ),
    ];

    for (var visitor in visitors) {
      _users[visitor.id] = visitor;
      _passwords[visitor.email] = 'visitor123';
    }
  }

  Future<User?> authenticateUser(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (_passwords[email] == password) {
      return _users.values.firstWhere(
            (user) => user.email == email,
        orElse: () => throw Exception('User not found'),
      );
    }
    return null;
  }

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
}