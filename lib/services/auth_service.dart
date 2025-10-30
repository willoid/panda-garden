import 'package:flutter/foundation.dart';
import '../models/user.dart';
import 'database_service.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  final DatabaseService _db = DatabaseService.instance;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isPanda => _currentUser?.type == UserType.panda;

  Future<bool> login(String email, String password) async {
    try {
      // Simulate authentication
      final user = await _db.authenticateUser(email, password);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
      return false;
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
      // Check if email already exists
      final existingUser = await _db.getUserByEmail(email);
      if (existingUser != null) {
        throw Exception('Email already registered');
      }

      // Create new visitor user
      final newUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        type: UserType.visitor,
        createdAt: DateTime.now(),
        isApproved: false,
        status: GardenStatus.notInGarden,
      );

      // Save to database
      await _db.createUser(newUser, password);
      
      // Auto login after registration
      _currentUser = newUser;
      notifyListeners();
      return true;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  Future<void> updateUserStatus(GardenStatus status) async {
    if (_currentUser == null) return;

    _currentUser = _currentUser!.copyWith(
      status: status,
      statusUpdatedAt: DateTime.now(),
    );
    
    await _db.updateUser(_currentUser!);
    notifyListeners();
  }

  Future<void> refreshCurrentUser() async {
    if (_currentUser == null) return;
    
    final updatedUser = await _db.getUserById(_currentUser!.id);
    if (updatedUser != null) {
      _currentUser = updatedUser;
      notifyListeners();
    }
  }
}
