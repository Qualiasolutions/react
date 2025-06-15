// lib/main_demo.dart
// Demo version that bypasses auth issues and shows main functionality

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

// Core
import 'package:vuet_flutter/core/theme/app_theme.dart';
import 'package:vuet_flutter/core/utils/logger.dart';

// Features
import 'package:vuet_flutter/features/main/screens/side_navigator.dart';

void main() async {
  // Initialize Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    Logger.debug('Environment file not found, using defaults');
  }

  // Initialize Supabase with fallback values
  try {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ??
          'https://vhiwshayajhjmrouddqi.supabase.co',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ??
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZoaXdzaGF5YWpoak1yb3VkZHFpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ3MjE0MzEsImV4cCI6MjA1MDI5NzQzMX0.YmPXJQpA4F1EIuHYGMVBtYmvROOHSFf-G-O96UDbUbE',
      debug: false,
    );
    Logger.debug('Supabase initialized successfully');
  } catch (e) {
    Logger.error('Supabase initialization failed', e, null);
  }

  // Configure toast notifications
  configureEasyLoading();

  // Run app
  runApp(
    const ProviderScope(
      child: VuetDemoApp(),
    ),
  );
}

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

class VuetDemoApp extends ConsumerStatefulWidget {
  const VuetDemoApp({super.key});

  @override
  ConsumerState<VuetDemoApp> createState() => _VuetDemoAppState();
}

class _VuetDemoAppState extends ConsumerState<VuetDemoApp> {
  @override
  void initState() {
    super.initState();

    // Set preferred orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Vuet Demo',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          home: const SideNavigator(hasJustSignedUp: false),
          builder: (context, child) {
            // Apply font scaling
            final mediaQuery = MediaQuery.of(context);
            final scale = mediaQuery.textScaleFactor.clamp(0.8, 1.2);

            return MediaQuery(
              data: mediaQuery.copyWith(textScaler: TextScaler.linear(scale)),
              child: EasyLoading.init()(context, child),
            );
          },
        );
      },
    );
  }
}
