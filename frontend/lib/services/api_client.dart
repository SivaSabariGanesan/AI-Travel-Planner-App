import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_model.dart';
import '../models/recipe_model.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiClient {
  // TODO: Update with your actual backend URL
  static const String baseUrl = 'http://localhost:5000/api';
  String? _authToken;

  ApiClient({String? authToken}) : _authToken = authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (includeAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // ===== AUTH ENDPOINTS =====

  Future<Map<String, dynamic>> signup({required String name, required String email}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: _getHeaders(includeAuth: false),
        body: jsonEncode({'name': name, 'email': email}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw ApiException(
          jsonDecode(response.body)['message'] ?? 'Signup failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> signin({required String email}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signin'),
        headers: _getHeaders(includeAuth: false),
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw ApiException(
          jsonDecode(response.body)['message'] ?? 'Signin failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<AuthResponse> verifyOtp({
    required String email,
    required String otp,
    required String purpose, // 'signup' or 'signin'
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: _getHeaders(includeAuth: false),
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'purpose': purpose,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponse.fromJson(jsonDecode(response.body));
      } else {
        throw ApiException(
          jsonDecode(response.body)['message'] ?? 'OTP verification failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  // ===== USER ENDPOINTS =====

  Future<User> getMe() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/me'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw ApiException('Unauthorized', statusCode: 401);
      } else {
        throw ApiException(
          jsonDecode(response.body)['message'] ?? 'Failed to fetch user',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<UserPreferences> updatePreferences(UserPreferences preferences) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/preferences'),
        headers: _getHeaders(),
        body: jsonEncode(preferences.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserPreferences.fromJson(data['preferences'] ?? {});
      } else {
        throw ApiException(
          jsonDecode(response.body)['message'] ?? 'Failed to update preferences',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  // ===== DASHBOARD ENDPOINTS =====

  Future<DashboardData> getDashboard() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return DashboardData.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw ApiException('Unauthorized', statusCode: 401);
      } else {
        throw ApiException(
          jsonDecode(response.body)['message'] ?? 'Failed to fetch dashboard',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  // ===== RECIPE ENDPOINTS =====

  Future<Recipe> generateRecipe({
    String? topic,
    required String fromLocation,
    required String toLocation,
    String? startDate,
    String? endDate,
    List<String>? interests,
    String? budget,
    int? travelerCount,
    String? extraNotes,
  }) async {
    try {
      final body = {
        if (topic != null) 'topic': topic,
        'fromLocation': fromLocation,
        'toLocation': toLocation,
        if (startDate != null) 'startDate': startDate,
        if (endDate != null) 'endDate': endDate,
        if (interests != null) 'interests': interests,
        if (budget != null) 'budget': budget,
        if (travelerCount != null) 'travelerCount': travelerCount,
        if (extraNotes != null) 'extraNotes': extraNotes,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/recipes/generate'),
        headers: _getHeaders(),
        body: jsonEncode(body),
      ).timeout(const Duration(minutes: 2));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Recipe.fromJson(data['recipe'] ?? {});
      } else if (response.statusCode == 401) {
        throw ApiException('Unauthorized', statusCode: 401);
      } else {
        throw ApiException(
          jsonDecode(response.body)['message'] ?? 'Failed to generate recipe',
          statusCode: response.statusCode,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<List<Recipe>> getRecipes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/recipes'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final recipes = (data['recipes'] as List?)
                ?.map((e) => Recipe.fromJson(e))
                .toList() ??
            [];
        return recipes;
      } else if (response.statusCode == 401) {
        throw ApiException('Unauthorized', statusCode: 401);
      } else {
        throw ApiException(
          jsonDecode(response.body)['message'] ?? 'Failed to fetch recipes',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<void> deleteRecipe(String recipeId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/recipes/$recipeId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401) {
        throw ApiException('Unauthorized', statusCode: 401);
      } else if (response.statusCode == 404) {
        throw ApiException('Itinerary not found', statusCode: 404);
      } else {
        final body = response.body.isNotEmpty
            ? jsonDecode(response.body)
            : <String, dynamic>{};
        throw ApiException(
          body['message'] ?? 'Failed to delete itinerary',
          statusCode: response.statusCode,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  // ===== HEALTH CHECK =====

  Future<bool> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: _getHeaders(includeAuth: false),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

class AuthResponse {
  final String message;
  final String token;
  final User user;

  AuthResponse({
    required this.message,
    required this.token,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      message: json['message'] ?? '',
      token: json['token'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
    );
  }
}

class DashboardData {
  final User user;
  final List<Recipe> recentRecipes;

  DashboardData({
    required this.user,
    required this.recentRecipes,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final dashboard = json['dashboard'] as Map<String, dynamic>? ?? {};
    final recipes = (dashboard['recentRecipes'] as List?)
            ?.map((e) => Recipe.fromJson(e))
            .toList() ??
        [];
    return DashboardData(
      user: User.fromJson(dashboard['user'] ?? {}),
      recentRecipes: recipes,
    );
  }
}
