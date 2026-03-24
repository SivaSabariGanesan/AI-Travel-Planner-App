import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'services/api_client.dart';
import 'providers/auth_provider.dart';
import 'providers/recipe_provider.dart';
import 'providers/user_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // API Client
        Provider<ApiClient>(
          create: (_) => ApiClient(),
        ),
        // Auth Provider
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            apiClient: context.read<ApiClient>(),
          ),
        ),
        // Recipe Provider
        ChangeNotifierProvider<RecipeProvider>(
          create: (context) => RecipeProvider(
            apiClient: context.read<ApiClient>(),
          ),
        ),
        // User Provider
        ChangeNotifierProvider<UserProvider>(
          create: (context) => UserProvider(
            apiClient: context.read<ApiClient>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Travel Planner',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          textTheme: GoogleFonts.interTextTheme(),
        ),
        home: const RootScreen(),
      ),
    );
  }
}

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Wait for token to be loaded
        if (!authProvider.tokenLoaded) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.blue.shade400,
              ),
            ),
          );
        }

        // If user is authenticated, show dashboard
        if (authProvider.isAuthenticated && authProvider.user != null) {
          // Set user in UserProvider
          context.read<UserProvider>().setUser(authProvider.user);
          return const DashboardScreen();
        }

        // Otherwise show auth screen
        return const AuthScreen();
      },
    );
  }
}
