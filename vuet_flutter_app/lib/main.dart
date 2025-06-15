import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

// Core
import 'package:vuet_flutter/core/constants/app_constants.dart';
import 'package:vuet_flutter/core/theme/app_theme.dart';
import 'package:vuet_flutter/core/utils/logger.dart';

// Features
import 'package:vuet_flutter/features/auth/providers/auth_provider.dart';
import 'package:vuet_flutter/features/auth/screens/splash_screen.dart';
import 'package:vuet_flutter/features/auth/screens/login_screen.dart';
import 'package:vuet_flutter/features/auth/screens/register_screen.dart';
import 'package:vuet_flutter/features/auth/screens/verify_phone_screen.dart';
import 'package:vuet_flutter/features/auth/screens/forgot_password_screen.dart';

// Setup
import 'package:vuet_flutter/features/setup/screens/setup_navigator.dart';

// Family
import 'package:vuet_flutter/features/family/screens/family_request_navigator.dart';

// Main App
import 'package:vuet_flutter/features/main/screens/side_navigator.dart';

// Providers
import 'package:vuet_flutter/features/categories/providers/categories_provider.dart';
import 'package:vuet_flutter/features/user/providers/user_provider.dart';

void main() async {
  // Keep splash screen visible while initializing
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize timezone data
  tz.initializeTimeZones();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    debug: false,
    localStorage: const SecureLocalStorage(),
  );
  
  // Initialize shared preferences for app settings
  final sharedPreferences = await SharedPreferences.getInstance();
  
  // Initialize Sentry for error tracking
  await SentryFlutter.init(
    (options) {
      options.dsn = dotenv.env['SENTRY_DSN'] ?? '';
      options.tracesSampleRate = 1.0;
      options.enableAutoSessionTracking = true;
    },
    appRunner: () => runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: const VuetApp(),
      ),
    ),
  );
  
  // Configure toast notifications
  configureEasyLoading();
}

// Secure storage for Supabase
class SecureLocalStorage extends LocalStorage {
  const SecureLocalStorage();
  static const _storage = FlutterSecureStorage();

  @override
  Future<String?> getItem({required String key}) {
    return _storage.read(key: key);
  }

  @override
  Future<void> removeItem({required String key}) {
    return _storage.delete(key: key);
  }

  @override
  Future<void> setItem({required String key, required String value}) {
    return _storage.write(key: key, value: value);
  }
}

// Shared preferences provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

// Configure toast notifications
void configureEasyLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.white
    ..backgroundColor = Colors.black.withOpacity(0.8)
    ..indicatorColor = Colors.white
    ..textColor = Colors.white
    ..maskColor = Colors.black.withOpacity(0.5)
    ..userInteractions = false
    ..dismissOnTap = false;
}

class VuetApp extends ConsumerStatefulWidget {
  const VuetApp({Key? key}) : super(key: key);

  @override
  ConsumerState<VuetApp> createState() => _VuetAppState();
}

class _VuetAppState extends ConsumerState<VuetApp> {
  @override
  void initState() {
    super.initState();
    
    // Remove splash screen after initialization
    FlutterNativeSplash.remove();
    
    // Set preferred orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth state for navigation
    final authState = ref.watch(authStateProvider);
    
    // Watch user details for setup status
    final userDetails = ref.watch(userDetailsProvider);
    
    // Watch family invites
    final familyInvites = ref.watch(familyInvitesProvider);
    
    // Force fetch categories when user is logged in
    if (authState.isAuthenticated) {
      ref.read(categoriesProvider);
    }

    // Configure router with auth guards
    final router = GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: GoRouterRefreshStream(authState.stream),
      redirect: (context, state) {
        // Handle loading state
        if (authState.isLoading || userDetails.isLoading || familyInvites.isLoading) {
          return '/splash';
        }
        
        // Handle unauthenticated state
        if (!authState.isAuthenticated) {
          // Allow access to auth screens
          if (state.location.startsWith('/auth')) {
            return null;
          }
          return '/auth/login';
        }
        
        // Handle family invites
        if (familyInvites.hasInvites) {
          // Allow access to family request screens
          if (state.location.startsWith('/family-request')) {
            return null;
          }
          return '/family-request';
        }
        
        // Handle setup required
        if (userDetails.data != null && !userDetails.data!.hasCompletedSetup) {
          // Allow access to setup screens
          if (state.location.startsWith('/setup')) {
            return null;
          }
          return '/setup';
        }
        
        // Redirect to home if trying to access auth screens while authenticated
        if (state.location.startsWith('/auth') || 
            state.location.startsWith('/setup') ||
            state.location.startsWith('/family-request') ||
            state.location == '/splash') {
          return '/';
        }
        
        // No redirection needed
        return null;
      },
      routes: [
        // Splash screen
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        
        // Auth routes
        GoRoute(
          path: '/auth/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/auth/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/auth/verify-phone',
          builder: (context, state) => const VerifyPhoneScreen(),
        ),
        GoRoute(
          path: '/auth/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        
        // Setup routes
        GoRoute(
          path: '/setup',
          builder: (context, state) => const SetupNavigator(),
        ),
        
        // Family request routes
        GoRoute(
          path: '/family-request',
          builder: (context, state) => const FamilyRequestNavigator(),
        ),
        
        // Main app routes
        GoRoute(
          path: '/',
          builder: (context, state) => const SideNavigator(hasJustSignedUp: false),
        ),
      ],
      errorBuilder: (context, state) => ErrorScreen(error: state.error),
    );

    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Vuet',
          debugShowCheckedModeBanner: false,
          routerConfig: router,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ref.watch(themeModeProvider),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('en', 'GB'),
          ],
          builder: (context, child) {
            // Apply font scaling
            final mediaQuery = MediaQuery.of(context);
            final scale = mediaQuery.textScaleFactor.clamp(0.8, 1.2);
            
            return MediaQuery(
              data: mediaQuery.copyWith(textScaleFactor: scale),
              child: EasyLoading.init()(context, child),
            );
          },
        );
      },
    );
  }
}

// Error screen
class ErrorScreen extends StatelessWidget {
  final Exception? error;
  
  const ErrorScreen({Key? key, this.error}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                error?.toString() ?? 'Unknown error',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => GoRouter.of(context).go('/'),
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Stream extension for GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// Theme mode provider
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system;
});

// Family invites provider
final familyInvitesProvider = FutureProvider<List<dynamic>>((ref) async {
  if (!ref.watch(authStateProvider).isAuthenticated) {
    return [];
  }
  
  try {
    final response = await Supabase.instance.client
        .from('family_invites')
        .select()
        .eq('status', 'PENDING')
        .eq('email', ref.watch(userDetailsProvider).data?.email);
    
    return response as List<dynamic>;
  } catch (e, st) {
    Logger.error('Error fetching family invites', e, st);
    return [];
  }
});
