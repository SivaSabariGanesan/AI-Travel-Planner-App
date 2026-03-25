import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/recipe_provider.dart';
import 'recipe_generation_screen.dart';
import 'recipe_detail_screen.dart';
import 'preferences_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

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
                  } else if (value == 'logout') {
                    await authProvider.logout();
                  }
                },
                itemBuilder: (BuildContext context) => [
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
          Consumer<RecipeProvider>(
            builder: (context, recipeProvider, _) {
              if (recipeProvider.isLoading) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: CircularProgressIndicator(
                        color: Colors.blue.shade400,
                      ),
                    ),
                  ),
                );
              }

              if (recipeProvider.recipes.isEmpty) {
                return SliverToBoxAdapter(
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
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final recipe = recipeProvider.recipes[index];
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
                                    : (context
                                            .read<RecipeProvider>()
                                            .error ??
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
                  childCount: recipeProvider.recipes.length,
                ),
              );
            },
          ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class RecipeCard extends StatelessWidget {
  final dynamic recipe; // Use dynamic to avoid import issues
  final Future<void> Function()? onDelete;

  const RecipeCard({
    Key? key,
    required this.recipe,
    this.onDelete,
  }) : super(key: key);

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
    final dateStr = recipe.createdAt != null
        ? DateFormat('MMM dd, yyyy').format(recipe.createdAt)
        : 'Unknown date';

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
                        '${recipe.itineraryInput?.fromLocation ?? 'Unknown'} → ${recipe.itineraryInput?.toLocation ?? 'Unknown'}',
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
