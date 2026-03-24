import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({Key? key}) : super(key: key);

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  late String? _selectedTravelStyle;
  late String? _selectedBudget;
  late String? _selectedPace;
  late List<String> _selectedFoods;
  late List<String> _selectedDietary;
  late List<String> _selectedDestinations;

  final List<String> _travelStyles = [
    'Adventure',
    'Relaxation',
    'Cultural',
    'Food',
    'Beach',
    'Mountain',
    'Urban',
  ];

  final List<String> _budgets = ['Budget', 'Moderate', 'Luxury'];
  
  final List<String> _paces = ['Slow', 'Moderate', 'Fast'];
  
  final List<String> _foodChoices = [
    'Vegetarian',
    'Vegan',
    'Non-Vegetarian',
    'Seafood',
    'Local Cuisine',
    'International',
  ];

  final List<String> _dietaryOptions = [
    'Gluten-free',
    'Dairy-free',
    'Nut-free',
    'Low-sodium',
    'Low-sugar',
  ];

  final List<String> _destinations = [
    'Mountains',
    'Beaches',
    'Cities',
    'Countryside',
    'Deserts',
    'Forests',
    'Islands',
  ];

  @override
  void initState() {
    super.initState();
    final userProvider = context.read<UserProvider>();
    final prefs = userProvider.user?.preferences;

    _selectedTravelStyle = prefs?.travelStyle;
    _selectedBudget = prefs?.budget;
    _selectedPace = prefs?.tripPace;
    _selectedFoods = List.from(prefs?.foodChoices ?? []);
    _selectedDietary = List.from(prefs?.dietaryRestrictions ?? []);
    _selectedDestinations = List.from(prefs?.preferredDestinations ?? []);
  }

  void _handleSave() async {
    final preferences = UserPreferences(
      travelStyle: _selectedTravelStyle,
      budget: _selectedBudget,
      tripPace: _selectedPace,
      foodChoices: _selectedFoods,
      dietaryRestrictions: _selectedDietary,
      preferredDestinations: _selectedDestinations,
    );

    final userProvider = context.read<UserProvider>();
    final success = await userProvider.updatePreferences(preferences);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Preferences saved!' : 'Failed to save preferences'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      if (success) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Preferences'),
        elevation: 0,
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Travel Style
                _buildSectionTitle('Travel Style'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _travelStyles.map((style) {
                    return ChoiceChip(
                      label: Text(style),
                      selected: _selectedTravelStyle == style,
                      onSelected: (selected) {
                        setState(() {
                          _selectedTravelStyle = selected ? style : null;
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // Budget
                _buildSectionTitle('Typical Budget'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _budgets.map((budget) {
                    return ChoiceChip(
                      label: Text(budget),
                      selected: _selectedBudget == budget,
                      onSelected: (selected) {
                        setState(() {
                          _selectedBudget = selected ? budget : null;
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // Trip Pace
                _buildSectionTitle('Trip Pace'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _paces.map((pace) {
                    return ChoiceChip(
                      label: Text(pace),
                      selected: _selectedPace == pace,
                      onSelected: (selected) {
                        setState(() {
                          _selectedPace = selected ? pace : null;
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // Food Preferences
                _buildSectionTitle('Food Preferences'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _foodChoices.map((food) {
                    return FilterChip(
                      label: Text(food),
                      selected: _selectedFoods.contains(food),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedFoods.add(food);
                          } else {
                            _selectedFoods.remove(food);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // Dietary Restrictions
                _buildSectionTitle('Dietary Restrictions'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _dietaryOptions.map((dietary) {
                    return FilterChip(
                      label: Text(dietary),
                      selected: _selectedDietary.contains(dietary),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedDietary.add(dietary);
                          } else {
                            _selectedDietary.remove(dietary);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // Preferred Destinations
                _buildSectionTitle('Preferred Destinations'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _destinations.map((dest) {
                    return FilterChip(
                      label: Text(dest),
                      selected: _selectedDestinations.contains(dest),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedDestinations.add(dest);
                          } else {
                            _selectedDestinations.remove(dest);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: userProvider.isLoading ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: userProvider.isLoading
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.blue.shade50,
                              ),
                            ),
                          )
                        : const Text(
                            'Save Preferences',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                if (userProvider.error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      border: Border.all(color: Colors.red.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      userProvider.error!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                ],

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
