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

  // Update AI settings (aiMode: 'app' or 'byok'), optionally provide geminiApiKey
  Future<Map<String, dynamic>> updateAiSettings({
    required String aiMode,
    String? geminiApiKey,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final resp = await apiClient.updateAiSettings(
        aiMode: aiMode,
        geminiApiKey: geminiApiKey,
      );

      if (_user != null) {
        _user = _user!.copyWith(aiMode: aiMode);
      }

      return resp;
    } catch (e) {
      _error = e.toString();
      return {'success': false, 'message': _error};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Test a Gemini API key without saving it
  Future<bool> testGeminiKey(String geminiApiKey) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await apiClient.testGeminiKey(geminiApiKey);
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
