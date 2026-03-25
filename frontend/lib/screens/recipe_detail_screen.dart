import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/recipe_model.dart';
import '../providers/recipe_provider.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  int _expandedDayIndex = -1;

  Future<void> _deleteCurrentRecipe() async {
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete itinerary?'),
            content: const Text('This itinerary will be removed permanently.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldDelete) return;

    final deleted = await context
        .read<RecipeProvider>()
        .deleteRecipe(widget.recipe.id);

    if (!mounted) return;

    if (deleted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Itinerary deleted'),
          backgroundColor: Colors.green,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.read<RecipeProvider>().error ?? 'Failed to delete itinerary',
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _buildDaySummary(DayWisePlan day) {
    final summaryParts = <String>[];

    if (day.plan?.trim().isNotEmpty ?? false) {
      summaryParts.add(day.plan!.trim());
    }

    if (summaryParts.isEmpty && (day.morning?.trim().isNotEmpty ?? false)) {
      summaryParts.add('Morning: ${day.morning!.trim()}');
    }

    if (summaryParts.isEmpty && (day.afternoon?.trim().isNotEmpty ?? false)) {
      summaryParts.add('Afternoon: ${day.afternoon!.trim()}');
    }

    if (summaryParts.isEmpty && (day.evening?.trim().isNotEmpty ?? false)) {
      summaryParts.add('Evening: ${day.evening!.trim()}');
    }

    if (summaryParts.isEmpty && day.activities.isNotEmpty) {
      summaryParts.add(day.activities.take(2).join(', '));
    }

    if (summaryParts.isEmpty && day.meals.isNotEmpty) {
      summaryParts.add('Meals: ${day.meals.take(2).join(', ')}');
    }

    if (summaryParts.isEmpty && day.food.isNotEmpty) {
      summaryParts.add('Food: ${day.food.take(2).join(', ')}');
    }

    return summaryParts.isEmpty
        ? 'No summary available for this day yet.'
        : summaryParts.first;
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final content = recipe.generatedContent;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: _deleteCurrentRecipe,
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete itinerary',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.shade400,
                      Colors.blue.shade600,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.place_outlined,
                      size: 60,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '${recipe.itineraryInput.fromLocation} → ${recipe.itineraryInput.toLocation}',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Overview Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and meta
                  if (content.title != null) ...[
                    Text(
                      content.title!,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Trip Info
                  Row(
                    children: [
                      if (recipe.days != null)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.schedule_outlined,
                                    color: Colors.blue.shade400),
                                const SizedBox(height: 4),
                                Text(
                                  '${recipe.days} Days',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (recipe.days != null) const SizedBox(width: 12),
                      if (recipe.itineraryInput.travelerCount > 0)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.people_outline,
                                    color: Colors.orange.shade400),
                                const SizedBox(height: 4),
                                Text(
                                  '${recipe.itineraryInput.travelerCount} Travelers',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (recipe.itineraryInput.travelerCount > 0)
                        const SizedBox(width: 12),
                      if (recipe.itineraryInput.budget != null)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.attach_money,
                                    color: Colors.green.shade400),
                                const SizedBox(height: 4),
                                Text(
                                  recipe.itineraryInput.budget!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Summary
                  if (content.summary != null) ...[
                    Text(
                      'Overview',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        content.summary!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Interests
                  if (content.interests.isNotEmpty) ...[
                    Text(
                      'Interests',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: content.interests.map((interest) {
                        return Chip(
                          label: Text(interest),
                          backgroundColor: Colors.blue.shade50,
                          labelStyle: TextStyle(color: Colors.blue.shade700),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Budget Info
                  if (content.estimatedBudget != null) ...[
                    Text(
                      'Estimated Budget',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Text(
                        content.estimatedBudget!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Day-wise Plan
                  if (content.dayWisePlan.isNotEmpty) ...[
                    Text(
                      'Day-wise Itinerary',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ),

          // Day-wise List
          if (content.dayWisePlan.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final day = content.dayWisePlan[index];
                  final isExpanded = _expandedDayIndex == index;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: _buildDayCard(day, index, isExpanded),
                  );
                },
                childCount: content.dayWisePlan.length,
              ),
            ),

          // Local Food Ideas
          if (content.localFoodIdeas.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      'Local Food Ideas',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    ...content.localFoodIdeas.map((food) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.restaurant_outlined,
                              color: Colors.orange.shade400,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(food),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

          // Packing Checklist
          if (content.packingChecklist.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Packing Checklist',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    ...content.packingChecklist.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              color: Colors.green.shade400,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(item),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

          // Transport Tips
          if (content.transportTips != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transport Tips',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.cyan.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.cyan.shade200),
                      ),
                      child: Text(
                        content.transportTips!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.cyan[800],
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDayCard(DayWisePlan day, int index, bool isExpanded) {
    final daySummary = _buildDaySummary(day);
    final hasPrimaryPlan = (day.plan?.trim().isNotEmpty ?? false);
    final hasActivities = day.activities.isNotEmpty;
    final hasMeals = day.meals.isNotEmpty;
    final hasMorning = (day.morning?.trim().isNotEmpty ?? false);
    final hasAfternoon = (day.afternoon?.trim().isNotEmpty ?? false);
    final hasEvening = (day.evening?.trim().isNotEmpty ?? false);
    final hasFood = day.food.isNotEmpty;
    final hasCost = (day.estimatedCost?.trim().isNotEmpty ?? false);
    final hasDate = (day.date?.trim().isNotEmpty ?? false);
    

    return GestureDetector(
      onTap: () {
        setState(() {
          _expandedDayIndex = isExpanded ? -1 : index;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isExpanded ? Colors.blue.shade300 : Colors.grey.shade200,
            width: isExpanded ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[300]!,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day.day ?? 'Day ${index + 1}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (hasDate)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            day.date!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      if (!hasDate && hasPrimaryPlan)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            day.plan!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
            if (isExpanded) ...[
              Divider(height: 1, color: Colors.grey[200]),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Day Summary',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(daySummary),
                    const SizedBox(height: 16),
                    if (hasPrimaryPlan) ...[
                      Text(
                        'Plan',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(day.plan!),
                      const SizedBox(height: 16),
                    ],
                    if (hasMorning) ...[
                      Text(
                        'Morning',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(day.morning!),
                      const SizedBox(height: 16),
                    ],
                    if (hasAfternoon) ...[
                      Text(
                        'Afternoon',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(day.afternoon!),
                      const SizedBox(height: 16),
                    ],
                    if (hasEvening) ...[
                      Text(
                        'Evening',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(day.evening!),
                      const SizedBox(height: 16),
                    ],
                    if (hasActivities) ...[
                      Text(
                        'Activities',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...day.activities.map((activity) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Icon(
                                Icons.circle,
                                size: 8,
                                color: Colors.blue.shade400,
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(activity)),
                            ],
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 16),
                    ],
                    if (hasMeals) ...[
                      Text(
                        'Meals',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...day.meals.map((meal) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Icon(
                                Icons.restaurant_outlined,
                                size: 16,
                                color: Colors.orange.shade400,
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(meal)),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                    if (hasFood) ...[
                      if (hasMeals) const SizedBox(height: 16),
                      Text(
                        'Food',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...day.food.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Icon(
                                Icons.restaurant_menu,
                                size: 16,
                                color: Colors.orange.shade400,
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(item)),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                    if (hasCost) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Estimated Cost',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(day.estimatedCost!),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
