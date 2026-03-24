import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_client.dart';

class UserProvider extends ChangeNotifier {
  final ApiClient apiClient;

  User? _user;
  bool _isLoading = false;
  String? _error;

  UserProvider({required this.apiClient});

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Set user (called from auth provider)
  void setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  // Update preferences
  Future<bool> updatePreferences(UserPreferences preferences) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedPreferences = await apiClient.updatePreferences(preferences);
      if (_user != null) {
        _user = _user!.copyWith(preferences: updatedPreferences);
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
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
