// lib/features/auth/screens/verify_phone_screen.dart
// Phone verification screen with OTP input matching the app's design language

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vuet_flutter/core/utils/logger.dart';
import 'package:vuet_flutter/features/auth/providers/auth_provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class VerifyPhoneScreen extends ConsumerStatefulWidget {
  const VerifyPhoneScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<VerifyPhoneScreen> createState() => _VerifyPhoneScreenState();
}

class _VerifyPhoneScreenState extends ConsumerState<VerifyPhoneScreen> {
  // OTP input controllers
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  
  // Focus nodes for each OTP field
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (_) => FocusNode(),
  );
  
  // Phone number to verify (will be passed from previous screen)
  late String _phoneNumber;
  
  // Timer for resend functionality
  Timer? _resendTimer;
  int _resendSeconds = 60;
  bool _canResend = false;
  
  @override
  void initState() {
    super.initState();
    // Start resend timer
    _startResendTimer();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get phone number from route
    final phoneNumber = GoRouterState.of(context).extra as String?;
    _phoneNumber = phoneNumber ?? 'your phone';
  }

  @override
  void dispose() {
    // Dispose controllers and focus nodes
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    // Cancel timer
    _resendTimer?.cancel();
    super.dispose();
  }
  
  // Start timer for resend functionality
  void _startResendTimer() {
    setState(() {
      _canResend = false;
      _resendSeconds = 60;
    });
    
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendSeconds > 0) {
          _resendSeconds--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }
  
  // Handle resend code
  Future<void> _handleResendCode() async {
    if (!_canResend) return;
    
    try {
      EasyLoading.show(status: 'Sending code...');
      
      await ref.read(authStateProvider.notifier).sendPhoneVerification(
        phone: _phoneNumber,
      );
      
      EasyLoading.dismiss();
      
      final error = ref.read(authErrorProvider);
      if (error != null) {
        EasyLoading.showError(error);
      } else {
        EasyLoading.showSuccess('Code sent!');
        // Restart timer
        _startResendTimer();
      }
    } catch (e, st) {
      Logger.error('Resend code error', e, st);
      EasyLoading.showError('Failed to resend code: ${e.toString()}');
    }
  }
  
  // Handle OTP verification
  Future<void> _handleVerifyOTP() async {
    // Combine OTP digits
    final otp = _otpControllers.map((c) => c.text).join();
    
    // Validate OTP
    if (otp.length != 6) {
      EasyLoading.showError('Please enter all 6 digits');
      return;
    }
    
    try {
      EasyLoading.show(status: 'Verifying...');
      
      await ref.read(authStateProvider.notifier).verifyPhone(
        phone: _phoneNumber,
        otp: otp,
      );
      
      EasyLoading.dismiss();
      
      final error = ref.read(authErrorProvider);
      if (error != null) {
        EasyLoading.showError(error);
      }
    } catch (e, st) {
      Logger.error('OTP verification error', e, st);
      EasyLoading.showError('Verification failed: ${e.toString()}');
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
        title: const Text('Verify Phone'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 30.h),
                
                // Phone number display
                Text(
                  'Verification code sent to',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 8.h),
                
                Text(
                  _phoneNumber,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 40.h),
                
                // OTP input fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 45.w,
                      child: TextFormField(
                        controller: _otpControllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 16.h,
                          ),
                        ),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(1),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            // Move to next field
                            if (index < 5) {
                              _focusNodes[index + 1].requestFocus();
                            } else {
                              // Last field, hide keyboard
                              FocusScope.of(context).unfocus();
                            }
                          }
                        },
                      ),
                    );
                  }),
                ),
                
                SizedBox(height: 40.h),
                
                // Verify button
                ElevatedButton(
                  onPressed: _handleVerifyOTP,
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
                    'Verify',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                SizedBox(height: 24.h),
                
                // Resend code
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive code? ",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    TextButton(
                      onPressed: _canResend ? _handleResendCode : null,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFD2691E),
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        _canResend 
                            ? 'Resend Code' 
                            : 'Resend in $_resendSeconds s',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: _canResend 
                              ? const Color(0xFFD2691E) 
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
