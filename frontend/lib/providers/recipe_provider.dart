import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../services/api_client.dart';

class RecipeProvider extends ChangeNotifier {
  final ApiClient apiClient;

  List<Recipe> _recipes = [];
  Recipe? _currentRecipe;
  bool _isLoading = false;
  bool _isGenerating = false;
  String? _error;

  RecipeProvider({required this.apiClient});

  // Getters
  List<Recipe> get recipes => _recipes;
  Recipe? get currentRecipe => _currentRecipe;
  bool get isLoading => _isLoading;
  bool get isGenerating => _isGenerating;
  String? get error => _error;

  // Fetch all recipes
  Future<void> fetchRecipes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _recipes = await apiClient.getRecipes();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Generate new recipe
  Future<Recipe?> generateRecipe({
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
    _isGenerating = true;
    _error = null;
    notifyListeners();

    try {
      final recipe = await apiClient.generateRecipe(
        topic: topic,
        fromLocation: fromLocation,
        toLocation: toLocation,
        startDate: startDate,
        endDate: endDate,
        interests: interests,
        budget: budget,
        travelerCount: travelerCount,
        extraNotes: extraNotes,
      );

      _currentRecipe = recipe;
      _recipes.insert(0, recipe);
      return recipe;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  // Set current recipe for viewing
  void selectRecipe(Recipe recipe) {
    _currentRecipe = recipe;
    notifyListeners();
  }

  // Clear current recipe
  void clearCurrentRecipe() {
    _currentRecipe = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Delete recipe by id
  Future<bool> deleteRecipe(String recipeId) async {
    _error = null;
    notifyListeners();

    try {
      await apiClient.deleteRecipe(recipeId);
      _recipes.removeWhere((recipe) => recipe.id == recipeId);

      if (_currentRecipe?.id == recipeId) {
        _currentRecipe = null;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
