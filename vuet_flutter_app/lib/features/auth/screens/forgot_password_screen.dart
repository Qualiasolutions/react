// lib/features/auth/screens/forgot_password_screen.dart
// Forgot password screen that matches the app's design language

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vuet_flutter/core/utils/logger.dart';
import 'package:vuet_flutter/features/auth/providers/auth_provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _resetSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      EasyLoading.show(status: 'Sending reset link...');
      
      await ref.read(authStateProvider.notifier).resetPassword(
        email: _emailController.text.trim(),
      );
      
      EasyLoading.dismiss();
      
      final error = ref.read(authErrorProvider);
      if (error != null) {
        EasyLoading.showError(error);
      } else {
        setState(() {
          _resetSent = true;
        });
      }
    } catch (e, st) {
      Logger.error('Password reset error', e, st);
      EasyLoading.showError('Reset failed: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A4A4A),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Reset Password'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 40.h),
                  
                  // Icon
                  if (!_resetSent)
                    Icon(
                      Icons.lock_reset,
                      size: 70.sp,
                      color: const Color(0xFFD2691E),
                    )
                  else
                    Icon(
                      Icons.check_circle_outline,
                      size: 70.sp,
                      color: Colors.green,
                    ),
                  
                  SizedBox(height: 24.h),
                  
                  // Title
                  Text(
                    _resetSent ? 'Reset Link Sent' : 'Forgot Password',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFD2691E),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  // Description
                  Text(
                    _resetSent 
                        ? 'We\'ve sent a password reset link to your email. Please check your inbox and follow the instructions.'
                        : 'Enter your email address and we\'ll send you a link to reset your password.',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: 40.h),
                  
                  if (!_resetSent) ...[
                    // Email input
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Email Address',
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: Colors.grey[600],
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 16.h,
                          horizontal: 16.w,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        // Simple email validation
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    
                    SizedBox(height: 32.h),
                    
                    // Reset button
                    ElevatedButton(
                      onPressed: _handleResetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD2691E),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Send Reset Link',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ] else ...[
                    // Return to login button
                    ElevatedButton(
                      onPressed: () => context.go('/auth/login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD2691E),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Return to Login',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // Resend link button
                    TextButton(
                      onPressed: _handleResetPassword,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFD2691E),
                      ),
                      child: Text(
                        'Resend Reset Link',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                  
                  SizedBox(height: 30.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
