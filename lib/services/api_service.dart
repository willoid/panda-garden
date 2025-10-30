import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/visitor_request.dart';

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
      throw ApiException('Network error: ${e.message}', 0);
    } on TimeoutException {
      throw ApiException('Request timed out', 0);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('An unexpected error occurred', 0);
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
        user: User.fromJson(response['user']),
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
        user: User.fromJson(response['user']),
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
    return User.fromJson(response['user']);
  }

  Future<String> refreshToken() async {
    final response = await _makeRequest('POST', 'auth/refresh');
    final newToken = response['token'];
    await _saveToken(newToken);
    return newToken;
  }

  // User APIs
  
  Future<List<User>> getAllUsers() async {
    final response = await _makeRequest('GET', 'users');
    return (response['users'] as List)
        .map((json) => User.fromJson(json))
        .toList();
  }

  Future<void> updateUserStatus(String userId, GardenStatus status) async {
    await _makeRequest(
      'PUT',
      'users/$userId',
      body: {
        'status': status.toString().split('.').last,
      },
    );
  }

  // Status APIs
  
  Future<User> getPandaStatus() async {
    final response = await _makeRequest('GET', 'status');
    return User.fromJson(response['panda']);
  }

  Future<void> updateMyStatus(GardenStatus status) async {
    await _makeRequest(
      'PUT',
      'status',
      body: {
        'status': status.toString().split('.').last,
      },
    );
  }

  // Request APIs
  
  Future<List<VisitorRequest>> getRequests() async {
    final response = await _makeRequest('GET', 'requests');
    return (response['requests'] as List)
        .map((json) => VisitorRequest.fromJson(json))
        .toList();
  }

  Future<void> createRequest({
    DateTime? plannedVisitTime,
    String? notes,
  }) async {
    await _makeRequest(
      'POST',
      'requests',
      body: {
        if (plannedVisitTime != null) 
          'plannedVisitTime': plannedVisitTime.toIso8601String(),
        if (notes != null) 'notes': notes,
      },
    );
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    await _makeRequest(
      'PUT',
      'requests/$requestId',
      body: {
        'status': status,
      },
    );
  }

  // Visitor APIs
  
  Future<List<User>> getVisitors() async {
    final response = await _makeRequest('GET', 'visitors');
    return (response['visitors'] as List)
        .map((json) => User.fromJson(json))
        .toList();
  }

  Future<void> updateVisitorApproval(String visitorId, bool approved) async {
    await _makeRequest(
      'PUT',
      'visitors/$visitorId',
      body: {
        'approved': approved,
      },
    );
  }

  // Statistics API
  
  Future<GardenStats> getStats() async {
    final response = await _makeRequest('GET', 'stats');
    return GardenStats.fromJson(response['stats']);
  }

  // FCM Token Update
  
  Future<void> updateFcmToken(String token) async {
    await _makeRequest(
      'POST',
      'auth/fcm-token',
      body: {
        'token': token,
      },
    );
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

class GardenStats {
  final int visitorsInGarden;
  final int visitorsGoing;
  final int pendingRequests;
  final int approvedVisitors;
  final String? pandaStatus;

  GardenStats({
    required this.visitorsInGarden,
    required this.visitorsGoing,
    required this.pendingRequests,
    required this.approvedVisitors,
    this.pandaStatus,
  });

  factory GardenStats.fromJson(Map<String, dynamic> json) {
    return GardenStats(
      visitorsInGarden: json['visitors_in_garden'] ?? 0,
      visitorsGoing: json['visitors_going'] ?? 0,
      pendingRequests: json['pending_requests'] ?? 0,
      approvedVisitors: json['approved_visitors'] ?? 0,
      pandaStatus: json['panda_status'],
    );
  }
}

// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}
