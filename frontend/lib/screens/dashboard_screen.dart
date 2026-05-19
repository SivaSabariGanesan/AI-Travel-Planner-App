import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/recipe_provider.dart';
import '../models/recipe_model.dart';
import 'recipe_generation_screen.dart';
import 'recipe_detail_screen.dart';
import 'preferences_screen.dart';
import 'ai_settings_screen.dart';
import 'ai_chat_screen.dart';
import 'usage_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load recipes on init
    Future.microtask(
      () => context.read<RecipeProvider>().fetchRecipes(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final recipeProvider = context.watch<RecipeProvider>();
    final recipes = recipeProvider.recipes;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            elevation: 0,
            backgroundColor: Colors.blue.shade400,
            expandedHeight: 200,
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
                      Icons.travel_explore_rounded,
                      size: 60,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome, ${user?.name}!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'preferences') {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PreferencesScreen(),
                      ),
                    );
                  } else if (value == 'ai_settings') {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AiSettingsScreen(),
                      ),
                    );
                  } else if (value == 'usage') {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const UsageScreen(),
                      ),
                    );
                  } else if (value == 'ai_chat') {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AiChatScreen(),
                      ),
                    );
                  } else if (value == 'logout') {
                    await authProvider.logout();
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem(
                    value: 'ai_chat',
                    child: Row(
                      children: [
                        Icon(Icons.chat_outlined),
                        SizedBox(width: 8),
                        Text('AI Chat'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'usage',
                    child: Row(
                      children: [
                        Icon(Icons.show_chart_outlined),
                        SizedBox(width: 8),
                        Text('AI Usage'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'ai_settings',
                    child: Row(
                      children: [
                        Icon(Icons.smart_toy_outlined),
                        SizedBox(width: 8),
                        Text('AI Settings'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'preferences',
                    child: Row(
                      children: [
                        Icon(Icons.settings_outlined),
                        SizedBox(width: 8),
                        Text('Preferences'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout_outlined),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Generate Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RecipeGenerationScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_location_outlined),
                      label: const Text('Generate New Itinerary'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  TravelSnapshotCard(recipes: recipes),

                  const SizedBox(height: 32),

                  // Recent Itineraries Section
                  Text(
                    'Recent Itineraries',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Recipes List
          if (recipeProvider.isLoading)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: CircularProgressIndicator(
                    color: Colors.blue.shade400,
                  ),
                ),
              ),
            )
          else if (recipes.isEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.explore_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No itineraries yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Generate your first travel plan',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final recipe = recipes[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: RecipeCard(
                      recipe: recipe,
                      onDelete: () async {
                        final deleted = await context
                            .read<RecipeProvider>()
                            .deleteRecipe(recipe.id);

                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              deleted
                                  ? 'Itinerary deleted'
                                  : (context.read<RecipeProvider>().error ??
                                      'Failed to delete itinerary'),
                            ),
                            backgroundColor:
                                deleted ? Colors.green : Colors.red,
                          ),
                        );
                      },
                    ),
                  );
                },
                childCount: recipes.length,
              ),
            ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class TravelSnapshotCard extends StatelessWidget {
  final List<Recipe> recipes;

  const TravelSnapshotCard({super.key, required this.recipes});

  String _favoriteDestination() {
    if (recipes.isEmpty) {
      return 'Start planning to see trends';
    }

    final counts = <String, int>{};
    for (final recipe in recipes) {
      final destination = recipe.itineraryInput.toLocation.trim();
      if (destination.isEmpty) continue;
      counts[destination] = (counts[destination] ?? 0) + 1;
    }

    if (counts.isEmpty) {
      return 'Start planning to see trends';
    }

    final entries = counts.entries.toList()
      ..sort((a, b) {
        final countCompare = b.value.compareTo(a.value);
        if (countCompare != 0) return countCompare;
        return a.key.compareTo(b.key);
      });

    return entries.first.key;
  }

  double _averageTripLength() {
    final dayValues = recipes
        .map((recipe) => recipe.days)
        .whereType<int>()
        .where((days) => days > 0)
        .toList();

    if (dayValues.isEmpty) {
      return 0;
    }

    final totalDays = dayValues.fold<int>(0, (sum, days) => sum + days);
    return totalDays / dayValues.length;
  }

  String _latestTripLabel() {
    if (recipes.isEmpty) {
      return 'No trips yet';
    }

    final latestRecipe = recipes.reduce((current, next) {
      return next.createdAt.isAfter(current.createdAt) ? next : current;
    });

    return DateFormat('MMM d').format(latestRecipe.createdAt);
  }

  String _insightText() {
    if (recipes.isEmpty) {
      return 'Generate your first itinerary to unlock travel insights.';
    }

    final favoriteDestination = _favoriteDestination();
    final averageTripLength = _averageTripLength();

    if (averageTripLength > 0) {
      return 'Your trips average ${averageTripLength.toStringAsFixed(1)} days, and $favoriteDestination appears most often.';
    }

    return 'You have ${recipes.length} itineraries ready, with $favoriteDestination showing up most often.';
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 10),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.82),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final averageTripLength = _averageTripLength();
    final tripsLabel = recipes.length == 1 ? '1 trip' : '${recipes.length} trips';
    final averageLabel = averageTripLength > 0
        ? '${averageTripLength.toStringAsFixed(1)} days'
        : 'Add trip length';
    final favoriteDestination = _favoriteDestination();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.indigo.shade700,
            Colors.blue.shade500,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.insights_outlined,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Travel Snapshot',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Live insights from your itinerary history',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _insightText(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _buildMetricCard(
                icon: Icons.flight_takeoff_outlined,
                label: 'Itineraries',
                value: tripsLabel,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              _buildMetricCard(
                icon: Icons.schedule_outlined,
                label: 'Average length',
                value: averageLabel,
                color: Colors.amberAccent,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMetricCard(
                icon: Icons.place_outlined,
                label: 'Top destination',
                value: favoriteDestination,
                color: Colors.lightGreenAccent,
              ),
              const SizedBox(width: 12),
              _buildMetricCard(
                icon: Icons.calendar_today_outlined,
                label: 'Latest trip',
                value: _latestTripLabel(),
                color: Colors.lightBlueAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final Future<void> Function()? onDelete;

  const RecipeCard({
    super.key,
    required this.recipe,
    this.onDelete,
  });

  Future<void> _confirmDelete(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete itinerary?'),
            content: const Text(
              'This itinerary will be removed permanently.',
            ),
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

    if (shouldDelete && onDelete != null) {
      await onDelete!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM dd, yyyy').format(recipe.createdAt);

    return GestureDetector(
      onTap: () {
        context.read<RecipeProvider>().selectRecipe(recipe);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RecipeDetailScreen(recipe: recipe),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[300]!,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.topic ?? 'Trip',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${recipe.itineraryInput.fromLocation} → ${recipe.itineraryInput.toLocation}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _confirmDelete(context),
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red,
                      tooltip: 'Delete itinerary',
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 6),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                if (recipe.days != null) ...[
                  const SizedBox(width: 16),
                  Icon(
                    Icons.schedule_outlined,
                    size: 14,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${recipe.days} days',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
