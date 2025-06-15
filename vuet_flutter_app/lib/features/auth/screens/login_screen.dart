// lib/features/auth/screens/login_screen.dart
// Login screen that exactly matches the React Native version's design

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vuet_flutter/core/constants/app_constants.dart';
import 'package:vuet_flutter/core/utils/logger.dart';
import 'package:vuet_flutter/features/auth/providers/auth_provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isPhoneLogin = false;
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _toggleLoginMethod() {
    setState(() {
      _isPhoneLogin = !_isPhoneLogin;
    });
  }

  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      EasyLoading.show(status: 'Logging in...');
      
      await ref.read(authStateProvider.notifier).signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      EasyLoading.dismiss();
      
      final error = ref.read(authErrorProvider);
      if (error != null) {
        EasyLoading.showError(error);
      }
    } catch (e, st) {
      Logger.error('Login error', e, st);
      EasyLoading.showError('Login failed: ${e.toString()}');
    }
  }

  Future<void> _handlePhoneLogin() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      EasyLoading.show(status: 'Sending verification code...');
      
      await ref.read(authStateProvider.notifier).sendPhoneVerification(
        phone: _phoneController.text.trim(),
      );
      
      EasyLoading.dismiss();
      
      final error = ref.read(authErrorProvider);
      if (error != null) {
        EasyLoading.showError(error);
      } else {
        // Navigate to phone verification screen
        context.push('/auth/verify-phone', extra: _phoneController.text.trim());
      }
    } catch (e, st) {
      Logger.error('Phone login error', e, st);
      EasyLoading.showError('Phone login failed: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // App Logo
                    Hero(
                      tag: 'app_logo',
                      child: Container(
                        height: 100.h,
                        width: 100.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/images/vuet_logo.png',
                            height: 60.h,
                            width: 60.h,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.image,
                                size: 60.h,
                                color: const Color(0xFFD2691E),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 32.h),
                    
                    // Welcome Text
                    Text(
                      _isPhoneLogin ? 'Login with Phone' : 'Welcome Back',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFD2691E),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: 8.h),
                    
                    Text(
                      _isPhoneLogin 
                          ? 'Enter your phone number to continue'
                          : 'Sign in to continue using Vuet App',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: 32.h),
                    
                    // Email/Phone Login Form
                    if (_isPhoneLogin)
                      // Phone Input
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'Phone Number',
                          prefixIcon: Icon(
                            Icons.phone,
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
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                      )
                    else
                      // Email and Password Inputs
                      Column(
                        children: [
                          // Email Input
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'Email',
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
                              return null;
                            },
                          ),
                          
                          SizedBox(height: 16.h),
                          
                          // Password Input
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: Colors.grey[600],
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey[600],
                                ),
                                onPressed: _togglePasswordVisibility,
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
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                          
                          SizedBox(height: 16.h),
                          
                          // Forgot Password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                context.push('/auth/forgot-password');
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFFD2691E),
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    
                    SizedBox(height: 32.h),
                    
                    // Login Button
                    ElevatedButton(
                      onPressed: authState.isLoading
                          ? null
                          : (_isPhoneLogin ? _handlePhoneLogin : _handleEmailLogin),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD2691E),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: authState.isLoading
                          ? SizedBox(
                              height: 20.h,
                              width: 20.h,
                              child: const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _isPhoneLogin ? 'Send Code' : 'Login',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    
                    SizedBox(height: 24.h),
                    
                    // Toggle Login Method
                    TextButton(
                      onPressed: _toggleLoginMethod,
                      child: Text(
                        _isPhoneLogin
                            ? 'Login with Email instead'
                            : 'Login with Phone instead',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFD2691E),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 24.h),
                    
                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.push('/auth/register');
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFD2691E),
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Register',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
