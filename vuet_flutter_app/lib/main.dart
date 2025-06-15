import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vuet_flutter/core/config/supabase_config.dart';
import 'package:vuet_flutter/core/theme/app_theme.dart';
import 'package:vuet_flutter/core/utils/error_handler.dart';
import 'package:vuet_flutter/features/auth/presentation/screens/splash_screen.dart';
import 'package:vuet_flutter/features/auth/presentation/screens/login_screen.dart';
import 'package:vuet_flutter/features/auth/presentation/screens/signup_screen.dart';
import 'package:vuet_flutter/features/auth/presentation/screens/verify_phone_screen.dart';
import 'package:vuet_flutter/features/home/presentation/screens/home_screen.dart';
import 'package:vuet_flutter/features/categories/presentation/screens/categories_screen.dart';
import 'package:vuet_flutter/features/entities/presentation/screens/entity_list_screen.dart';
import 'package:vuet_flutter/features/tasks/presentation/screens/task_calendar_screen.dart';
import 'package:vuet_flutter/features/messages/presentation/screens/message_list_screen.dart';
import 'package:vuet_flutter/features/auth/data/repositories/auth_repository.dart';
import 'package:vuet_flutter/features/auth/domain/providers/auth_provider.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize error handling
  ErrorHandler.initialize();
  
  // Initialize Supabase
  try {
    await SupabaseConfig.initialize();
    debugPrint('Supabase initialized successfully');
  } catch (e) {
    debugPrint('Failed to initialize Supabase: $e');
    ErrorHandler.reportError('Supabase initialization failed', e);
  }
  
  // Run the app with ProviderScope for Riverpod
  runApp(
    const ProviderScope(
      child: VuetApp(),
    ),
  );
}

// App state notifier to handle global app state
final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((ref) {
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
      final authState = await _ref.read(authRepositoryProvider).getCurrentSession();
      
      if (authState != null) {
        state = AppState.authenticated;
      } else {
        state = AppState.unauthenticated;
      }
    } catch (e) {
      debugPrint('Error initializing app state: $e');
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
  const VuetApp({Key? key}) : super(key: key);

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
        final isAuthenticated = appState == AppState.authenticated;
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
            (isLoginRoute || isSignupRoute || isVerifyRoute || state.matchedLocation == '/')) {
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
            return VerifyPhoneScreen(method: method);
          },
        ),
        
        // Main app routes
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/categories',
          builder: (context, state) => const CategoriesScreen(),
        ),
        GoRoute(
          path: '/entities/:categoryId',
          builder: (context, state) {
            final categoryId = state.pathParameters['categoryId'];
            return EntityListScreen(categoryId: categoryId);
          },
        ),
        GoRoute(
          path: '/calendar',
          builder: (context, state) => const TaskCalendarScreen(),
        ),
        GoRoute(
          path: '/messages',
          builder: (context, state) => const MessageListScreen(),
        ),
      ],
      errorBuilder: (context, state) => ErrorScreen(
        error: state.error,
        location: state.matchedLocation,
      ),
    );

    return ScreenUtilInit(
      designSize: const Size(375, 812), // Base design size from Figma or design specs
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
  final String? location;
  
  const ErrorScreen({
    Key? key,
    this.error,
    this.location,
  }) : super(key: key);

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
              if (location != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Location: $location',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
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
