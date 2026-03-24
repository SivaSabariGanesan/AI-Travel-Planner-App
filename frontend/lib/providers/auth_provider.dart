import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_client.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient apiClient;
  
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;
  bool _tokenLoaded = false;

  AuthProvider({required this.apiClient}) {
    _initializeAuth();
  }

  bool get tokenLoaded => _tokenLoaded;

  Future<void> _initializeAuth() async {
    await _loadStoredToken();
    _tokenLoaded = true;
    notifyListeners();
  }

  // Getters
  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  // Load stored token from SharedPreferences
  Future<void> _loadStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null) {
        _token = token;
        apiClient.setAuthToken(token);
        // Verify token is still valid
        await _fetchUser();
        _isAuthenticated = true;
      }
    } catch (e) {
      _error = 'Failed to load stored token';
    }
    notifyListeners();
  }

  // Signup with email
  Future<void> signup({required String name, required String email}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await apiClient.signup(name: name, email: email);
      
      // Store email temporarily for OTP verification
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('temp_email', email);
      await prefs.setString('signup_name', name);
      await prefs.setString('auth_purpose', 'signup');
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Signin with email
  Future<void> signin({required String email}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await apiClient.signin(email: email);
      
      // Store email temporarily for OTP verification
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('temp_email', email);
      await prefs.setString('auth_purpose', 'signin');
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Verify OTP
  Future<bool> verifyOtp({
    required String email,
    required String otp,
    required String purpose,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final authResponse = await apiClient.verifyOtp(
        email: email,
        otp: otp,
        purpose: purpose,
      );

      _token = authResponse.token;
      _user = authResponse.user;
      _isAuthenticated = true;

      // Store token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', authResponse.token);
      await prefs.remove('temp_email');
      await prefs.remove('signup_name');
      await prefs.remove('auth_purpose');

      apiClient.setAuthToken(authResponse.token);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch current user
  Future<void> _fetchUser() async {
    try {
      _user = await apiClient.getMe();
    } catch (e) {
      _error = 'Failed to fetch user: $e';
      _isAuthenticated = false;
    }
    notifyListeners();
  }

  // Refresh user data
  Future<void> refreshUser() async {
    await _fetchUser();
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('temp_email');
      
      _token = null;
      _user = null;
      _isAuthenticated = false;
      _error = null;
    } catch (e) {
      _error = 'Logout failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
