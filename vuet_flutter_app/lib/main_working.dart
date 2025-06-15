import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vuet_flutter/core/theme/app_theme.dart';
import 'package:vuet_flutter/core/utils/error_handler.dart';
import 'package:vuet_flutter/features/auth/presentation/screens/splash_screen.dart';
import 'package:vuet_flutter/features/auth/presentation/screens/login_screen.dart';
import 'package:vuet_flutter/features/auth/presentation/screens/signup_screen.dart';
import 'package:vuet_flutter/features/auth/presentation/screens/verify_phone_screen.dart';
import 'package:vuet_flutter/features/home/presentation/screens/home_screen.dart';
import 'package:vuet_flutter/features/auth/domain/providers/auth_provider.dart';
import 'package:vuet_flutter/features/auth/data/repositories/auth_repository.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize error handling
  ErrorHandler.initialize();

  // Initialize Supabase
  try {
    await Supabase.initialize(
      url: 'https://vhiwshayajhjmrouddqi.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZoaXdzaGF5YWpoam1yb3VkZHFpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk5MzExMTMsImV4cCI6MjA2NTUwNzExM30.ixFBNk5LcqrkhslzYsqQV3aiOcig0VQQoyKlzSikxNo',
      authFlowType: AuthFlowType.pkce,
    );
    debugPrint('Supabase initialized successfully');
  } catch (e, stackTrace) {
    debugPrint('Failed to initialize Supabase: $e');
    ErrorHandler.reportError('Supabase initialization failed', e,
        stackTrace: stackTrace);
  }

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Run the app with ProviderScope for Riverpod
  runApp(
    const ProviderScope(
      child: VuetApp(),
    ),
  );
}

// App state notifier to handle global app state
final appStateProvider =
    StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier(ref);
});

class AppStateNotifier extends StateNotifier<AppState> {
  final Ref _ref;

  AppStateNotifier(this._ref) : super(AppState.initializing) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Check if user is already authenticated
      final session =
          await _ref.read(authRepositoryProvider).getCurrentSession();

      if (session != null) {
        state = AppState.authenticated;
      } else {
        state = AppState.unauthenticated;
      }
    } catch (e, stackTrace) {
      ErrorHandler.reportError('Error initializing app state', e,
          stackTrace: stackTrace);
      state = AppState.unauthenticated;
    }
  }

  void setAuthenticated() {
    state = AppState.authenticated;
  }

  void setUnauthenticated() {
    state = AppState.unauthenticated;
  }
}

enum AppState {
  initializing,
  authenticated,
  unauthenticated,
}

class VuetApp extends ConsumerWidget {
  const VuetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final authState = ref.watch(authStateProvider);

    // Configure the router based on authentication state
    final router = GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      redirect: (context, state) {
        final isInitializing = appState == AppState.initializing;
        final isAuthenticated = authState.isAuthenticated;
        final isLoginRoute = state.matchedLocation == '/login';
        final isSignupRoute = state.matchedLocation == '/signup';
        final isVerifyRoute = state.matchedLocation.startsWith('/verify');

        // Show splash screen while initializing
        if (isInitializing) {
          return '/';
        }

        // If not authenticated and not on auth routes, redirect to login
        if (!isAuthenticated &&
            !isLoginRoute &&
            !isSignupRoute &&
            !isVerifyRoute &&
            state.matchedLocation != '/') {
          return '/login';
        }

        // If authenticated and on auth routes, redirect to home
        if (isAuthenticated &&
            (isLoginRoute ||
                isSignupRoute ||
                isVerifyRoute ||
                state.matchedLocation == '/')) {
          return '/home';
        }

        // No redirect needed
        return null;
      },
      routes: [
        // Splash screen route
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),

        // Authentication routes
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignupScreen(),
        ),
        GoRoute(
          path: '/verify/:method',
          builder: (context, state) {
            final method = state.pathParameters['method'] ?? 'phone';
            final extraData = state.extra; // Retrieve extra data
            return VerifyPhoneScreen(method: method, extraData: extraData);
          },
        ),

        // Main app routes
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        // Placeholder routes for other main sections
        GoRoute(
          path: '/categories',
          builder: (context, state) => const CategoriesScreenPlaceholder(),
        ),
        GoRoute(
          path: '/entities/:categoryId',
          builder: (context, state) {
            final categoryId = state.pathParameters['categoryId'];
            return EntityListScreenPlaceholder(categoryId: categoryId);
          },
        ),
        GoRoute(
          path: '/calendar',
          builder: (context, state) => const TaskCalendarScreenPlaceholder(),
        ),
        GoRoute(
          path: '/messages',
          builder: (context, state) => const MessageListScreenPlaceholder(),
        ),
      ],
      errorBuilder: (context, state) => ErrorScreen(
        error: state.error,
      ),
    );

    return ScreenUtilInit(
      designSize:
          const Size(375, 812), // Base design size from Figma or design specs
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Vuet',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            // Add global error handling and loading overlay
            return Stack(
              children: [
                if (child != null) child,
                // Show loading indicator when auth state is loading
                if (authState.isLoading)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

// Error screen for router errors
class ErrorScreen extends StatelessWidget {
  final Exception? error;

  const ErrorScreen({
    super.key,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error?.toString() ?? 'Unknown error',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  GoRouter.of(context).go('/home');
                },
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder screens for future implementation
class CategoriesScreenPlaceholder extends StatelessWidget {
  const CategoriesScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: const Center(child: Text('Categories Screen - Coming Soon!')),
    );
  }
}

class EntityListScreenPlaceholder extends StatelessWidget {
  final String? categoryId;
  const EntityListScreenPlaceholder({super.key, this.categoryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Entities for Category ${categoryId ?? ''}')),
      body: const Center(child: Text('Entity List Screen - Coming Soon!')),
    );
  }
}

class TaskCalendarScreenPlaceholder extends StatelessWidget {
  const TaskCalendarScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Calendar')),
      body: const Center(child: Text('Task Calendar Screen - Coming Soon!')),
    );
  }
}

class MessageListScreenPlaceholder extends StatelessWidget {
  const MessageListScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: const Center(child: Text('Message List Screen - Coming Soon!')),
    );
  }
}
