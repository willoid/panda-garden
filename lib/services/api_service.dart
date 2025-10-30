import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class ApiService {
  static const String baseUrl = 'https://willyc38.sg-host.com/api';
  static const Duration timeout = Duration(seconds: 30);

  // Singleton instance
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _authToken;

  // Initialize and load saved token
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
  }

  // Save token locally
  Future<void> _saveToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Clear token
  Future<void> _clearToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Get headers with auth token
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  // Convert snake_case to camelCase for user data
  Map<String, dynamic> _convertUserData(Map<String, dynamic> data) {
    return {
      'id': data['id']?.toString() ?? '',
      'name': data['name'] ?? '',
      'email': data['email'] ?? '',
      'type': data['user_type'] ?? data['type'] ?? 'visitor',
      'createdAt': data['created_at'] ?? DateTime.now().toIso8601String(),
      'status': _convertStatusFromDb(data['garden_status'] ?? data['status']),
      'statusUpdatedAt': data['status_updated_at'],
    };
  }

  // Convert database status to app status
  String? _convertStatusFromDb(String? status) {
    if (status == null) return null;
    switch (status) {
      case 'not_in_garden':
        return 'notInGarden';
      case 'going_to_garden':
        return 'goingToGarden';
      case 'in_garden':
        return 'inGarden';
      default:
        return status;
    }
  }

  // Convert app status to database status
  String _convertStatusToDb(GardenStatus status) {
    switch (status) {
      case GardenStatus.notInGarden:
        return 'not_in_garden';
      case GardenStatus.goingToGarden:
        return 'going_to_garden';
      case GardenStatus.inGarden:
        return 'in_garden';
    }
  }

  // Generic HTTP request handler
  Future<Map<String, dynamic>> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) async {
    try {
      // Build URL with query parameters
      Uri url = Uri.parse('$baseUrl/$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        url = url.replace(queryParameters: queryParams);
      }

      print('Making $method request to: $url'); // Debug log

      // Make request based on method
      http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(url, headers: _headers).timeout(timeout);
          break;
        case 'POST':
          response = await http.post(
            url,
            headers: _headers,
            body: body != null ? json.encode(body) : null,
          ).timeout(timeout);
          break;
        case 'PUT':
          response = await http.put(
            url,
            headers: _headers,
            body: body != null ? json.encode(body) : null,
          ).timeout(timeout);
          break;
        case 'DELETE':
          response = await http.delete(url, headers: _headers).timeout(timeout);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      // Parse response
      final Map<String, dynamic> data = json.decode(response.body);

      // Check for errors
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        throw ApiException(
          data['error'] ?? 'An error occurred',
          response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      print('Network error: ${e.message}'); // Debug log
      throw ApiException('Network error: ${e.message}', 0);
    } on TimeoutException {
      print('Request timed out'); // Debug log
      throw ApiException('Request timed out', 0);
    } catch (e) {
      print('Unexpected error: $e'); // Debug log
      if (e is ApiException) rethrow;
      throw ApiException('An unexpected error occurred: $e', 0);
    }
  }

  // Authentication APIs

  Future<AuthResponse> login(String email, String password) async {
    final response = await _makeRequest(
      'POST',
      'auth/login',
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response['success'] == true) {
      await _saveToken(response['token']);
      return AuthResponse(
        success: true,
        token: response['token'],
        user: User.fromJson(_convertUserData(response['user'])),
      );
    }

    throw ApiException(response['message'] ?? 'Login failed', 401);
  }

  Future<AuthResponse> register(String name, String email, String password) async {
    final response = await _makeRequest(
      'POST',
      'auth/register',
      body: {
        'name': name,
        'email': email,
        'password': password,
      },
    );

    if (response['success'] == true) {
      await _saveToken(response['token']);
      return AuthResponse(
        success: true,
        token: response['token'],
        user: User.fromJson(_convertUserData(response['user'])),
      );
    }

    throw ApiException(response['message'] ?? 'Registration failed', 400);
  }

  Future<void> logout() async {
    try {
      await _makeRequest('POST', 'auth/logout');
    } finally {
      await _clearToken();
    }
  }

  Future<User> getCurrentUser() async {
    final response = await _makeRequest('GET', 'auth/me');
    return User.fromJson(_convertUserData(response['user']));
  }

  Future<String> refreshToken() async {
    final response = await _makeRequest('POST', 'auth/refresh');
    final newToken = response['token'];
    await _saveToken(newToken);
    return newToken;
  }

  // Status APIs

  Future<User> getPandaStatus() async {
    final response = await _makeRequest('GET', 'status');
    return User.fromJson(_convertUserData(response['panda']));
  }

  Future<void> updateMyStatus(GardenStatus status) async {
    await _makeRequest(
      'PUT',
      'status',
      body: {
        'status': _convertStatusToDb(status),
      },
    );
  }

  // User APIs

  Future<void> updateUserStatus(String userId, GardenStatus status) async {
    await _makeRequest(
      'PUT',
      'users/$userId',
      body: {
        'status': _convertStatusToDb(status),
      },
    );
  }

  // Visitor APIs

  Future<List<User>> getVisitors() async {
    final response = await _makeRequest('GET', 'visitors');
    return (response['visitors'] as List)
        .map((json) => User.fromJson(_convertUserData(json)))
        .toList();
  }
}

// Response models

class AuthResponse {
  final bool success;
  final String token;
  final User user;

  AuthResponse({
    required this.success,
    required this.token,
    required this.user,
  });
}

// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}