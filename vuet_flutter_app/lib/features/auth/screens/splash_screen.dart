// lib/features/auth/screens/splash_screen.dart
// Splash screen that matches the React Native version's loading state

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vuet_flutter/core/constants/app_constants.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Hero(
                tag: 'app_logo',
                child: Image.asset(
                  'assets/images/vuet_logo.png',
                  width: 120.w,
                  height: 120.w,
                ),
              ),
              
              SizedBox(height: 24.h),
              
              // App name
              Text(
                AppInfo.name,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              
              SizedBox(height: 48.h),
              
              // Loading spinner
              SizedBox(
                width: 40.w,
                height: 40.w,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                  strokeWidth: 4.w,
                ),
              ),
              
              SizedBox(height: 24.h),
              
              // Loading text
              Text(
                'Loading...',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onBackground.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
