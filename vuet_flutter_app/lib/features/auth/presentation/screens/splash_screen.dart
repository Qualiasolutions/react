import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vuet_flutter/core/theme/app_theme.dart';
import 'package:vuet_flutter/features/auth/domain/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    
    // Start animation
    _animationController.forward();
    
    // Check auth state after a delay to allow splash screen to be visible
    Future.delayed(const Duration(seconds: 2), () {
      _checkAuthState();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Check authentication state and navigate accordingly
  void _checkAuthState() {
    final authState = ref.read(authStateProvider);
    
    if (authState.isAuthenticated) {
      // If authenticated, go to home screen
      context.go('/home');
    } else if (!authState.isLoading) {
      // If not authenticated and not loading, go to login screen
      context.go('/login');
    }
    // If still loading, wait for auth state to change
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes for navigation
    ref.listen(authStateProvider, (previous, current) {
      if (!current.isLoading) {
        if (current.isAuthenticated) {
          context.go('/home');
        } else {
          context.go('/login');
        }
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeInAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      width: 120.w,
                      height: 120.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'V',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 72.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 24.h),
                    
                    // App name
                    Text(
                      'Vuet',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    
                    SizedBox(height: 8.h),
                    
                    // Tagline
                    Text(
                      'Task Management Simplified',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16.sp,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    
                    SizedBox(height: 48.h),
                    
                    // Loading indicator
                    SizedBox(
                      width: 40.w,
                      height: 40.w,
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
