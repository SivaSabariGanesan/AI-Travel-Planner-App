import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../providers/auth_provider.dart';
import 'recipe_detail_screen.dart';

class RecipeGenerationScreen extends StatefulWidget {
  const RecipeGenerationScreen({Key? key}) : super(key: key);

  @override
  State<RecipeGenerationScreen> createState() => _RecipeGenerationScreenState();
}

class _RecipeGenerationScreenState extends State<RecipeGenerationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController();
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _extraNotesController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedBudget;
  int _travelerCount = 1;
  final List<String> _selectedInterests = [];

  final List<String> _budgetOptions = ['Budget', 'Moderate', 'Luxury', 'Custom'];
  final List<String> _interestOptions = [
    'Adventure',
    'Culture',
    'Food',
    'Nature',
    'Beach',
    'Historical',
    'Art',
    'Photography',
    'Nightlife',
    'Shopping',
  ];

  @override
  void dispose() {
    _topicController.dispose();
    _fromController.dispose();
    _toController.dispose();
    _extraNotesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now()),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStart) {
          _startDate = pickedDate;
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  void _handleGenerateRecipe(BuildContext context, RecipeProvider recipeProvider) async {
    if (!_formKey.currentState!.validate()) return;

    // Check if user is authenticated
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated || authProvider.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session expired. Please login again.'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    final recipe = await recipeProvider.generateRecipe(
      topic: _topicController.text.isEmpty ? null : _topicController.text,
      fromLocation: _fromController.text,
      toLocation: _toController.text,
      startDate: _startDate?.toIso8601String(),
      endDate: _endDate?.toIso8601String(),
      interests: _selectedInterests.isEmpty ? null : _selectedInterests,
      budget: _selectedBudget,
      travelerCount: _travelerCount,
      extraNotes: _extraNotesController.text.isEmpty ? null : _extraNotesController.text,
    );

    if (mounted && recipe != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Itinerary generated successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RecipeDetailScreen(recipe: recipe),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(recipeProvider.error ?? 'Failed to generate itinerary'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan Your Trip'),
        elevation: 0,
      ),
      body: Consumer<RecipeProvider>(
        builder: (context, recipeProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Topic
                  _buildSectionTitle('Trip Topic (Optional)'),
                  TextFormField(
                    controller: _topicController,
                    decoration: InputDecoration(
                      hintText: 'e.g., Summer Vacation, Honeymoon',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // From & To Location
                  _buildSectionTitle('Starting Location'),
                  TextFormField(
                    controller: _fromController,
                    decoration: InputDecoration(
                      hintText: 'Where are you starting from?',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Starting location is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  

                  _buildSectionTitle('Destination'),
                  TextFormField(
                    controller: _toController,
                    decoration: InputDecoration(
                      hintText: 'Where do you want to go?',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Destination is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Dates
                  _buildSectionTitle('Trip Dates (Optional)'),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _selectDate(context, true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _startDate == null
                                        ? 'Start Date'
                                        : DateFormat('MMM dd, yyyy').format(_startDate!),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _selectDate(context, false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _endDate == null
                                        ? 'End Date'
                                        : DateFormat('MMM dd, yyyy').format(_endDate!),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Budget
                  _buildSectionTitle('Budget'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _budgetOptions.map((budget) {
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

                  // Travelers
                  _buildSectionTitle('Number of Travelers'),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _travelerCount > 1
                            ? () => setState(() => _travelerCount--)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _travelerCount.toString(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _travelerCount < 10
                            ? () => setState(() => _travelerCount++)
                            : null,
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Interests
                  _buildSectionTitle('Interests (Optional)'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _interestOptions.map((interest) {
                      return FilterChip(
                        label: Text(interest),
                        selected: _selectedInterests.contains(interest),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedInterests.add(interest);
                            } else {
                              _selectedInterests.remove(interest);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Extra Notes
                  _buildSectionTitle('Additional Notes (Optional)'),
                  TextFormField(
                    controller: _extraNotesController,
                    decoration: InputDecoration(
                      hintText: 'Any specific requirements or preferences?',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),

                  // Generate Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: recipeProvider.isGenerating
                          ? null
                          : () => _handleGenerateRecipe(context, recipeProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: recipeProvider.isGenerating
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
                              'Generate Itinerary',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
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
