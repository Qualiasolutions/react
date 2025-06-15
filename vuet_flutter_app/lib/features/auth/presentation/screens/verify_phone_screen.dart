import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vuet_flutter/core/theme/app_theme.dart';
import 'package:vuet_flutter/core/utils/error_handler.dart';
import 'package:vuet_flutter/features/auth/data/repositories/auth_repository.dart';

class VerifyPhoneScreen extends ConsumerStatefulWidget {
  final String method;
  final dynamic extraData; // Can be String (phone) or Map (phone + name)

  const VerifyPhoneScreen({
    super.key,
    required this.method,
    this.extraData,
  });

  @override
  ConsumerState<VerifyPhoneScreen> createState() => _VerifyPhoneScreenState();
}

class _VerifyPhoneScreenState extends ConsumerState<VerifyPhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  String? _phoneNumber;
  String? _fullName;

  Timer? _resendTimer;
  int _resendCountdown = 60; // seconds

  @override
  void initState() {
    super.initState();
    _extractExtraData();
    _startResendTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _extractExtraData() {
    if (widget.extraData is String) {
      _phoneNumber = widget.extraData as String;
    } else if (widget.extraData is Map<String, dynamic>) {
      _phoneNumber = widget.extraData['phoneNumber'] as String?;
      _fullName = widget.extraData['fullName'] as String?;
    }
  }

  void _startResendTimer() {
    _resendCountdown = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown == 0) {
        timer.cancel();
        setState(() {}); // Rebuild to enable resend button
      } else {
        setState(() {
          _resendCountdown--;
        });
      }
    });
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;
    if (_phoneNumber == null) {
      setState(() {
        _errorMessage = 'Phone number not provided. Please go back and try again.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authRepositoryProvider).verifyPhoneOTP(
            phoneNumber: _phoneNumber!,
            otp: _otpController.text.trim(),
            fullName: _fullName,
          );
      // AuthStateNotifier will handle navigation to /home on successful verification
    } catch (e, stackTrace) {
      ErrorHandler.reportError('OTP verification failed', e, stackTrace: stackTrace);
      setState(() {
        _errorMessage = ErrorHandler.handleSupabaseError(e);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resendOtp() async {
    if (_phoneNumber == null) {
      setState(() {
        _errorMessage = 'Phone number not provided. Cannot resend OTP.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authRepositoryProvider).signInWithPhone(
            phoneNumber: _phoneNumber!,
          );
      _startResendTimer(); // Restart timer
      setState(() {
        _errorMessage = 'New OTP sent!';
      });
    } catch (e, stackTrace) {
      ErrorHandler.reportError('Resend OTP failed', e, stackTrace: stackTrace);
      setState(() {
        _errorMessage = ErrorHandler.handleSupabaseError(e);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Phone'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'), // Go back to login/signup
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                Text(
                  'Verify Your Phone Number',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppTheme.spacingXs),

                // Subtitle
                Text(
                  'Enter the 6-digit code sent to ${_phoneNumber ?? 'your phone'}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textMuted,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppTheme.spacingL),

                // Error message
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingS),
                    margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                      border: Border.all(color: AppTheme.errorColor.withOpacity(0.5)),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.errorColor,
                          ),
                    ),
                  ),

                // OTP input field
                TextFormField(
                  controller: _otpController,
                  decoration: const InputDecoration(
                    labelText: 'Verification Code',
                    prefixIcon: Icon(Icons.vpn_key),
                    counterText: '', // Hide default counter
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 6, // Assuming 6-digit OTP
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        letterSpacing: 8.0,
                        fontWeight: FontWeight.bold,
                      ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the code';
                    }
                    if (value.length != 6 || int.tryParse(value) == null) {
                      return 'Please enter a valid 6-digit code';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppTheme.spacingL),

                // Verify button
                ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Verify',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                              ),
                        ),
                ),

                const SizedBox(height: AppTheme.spacingM),

                // Resend OTP button with timer
                TextButton(
                  onPressed: _resendCountdown == 0 && !_isLoading ? _resendOtp : null,
                  child: Text(
                    _resendCountdown == 0
                        ? 'Resend Code'
                        : 'Resend Code in $_resendCountdown s',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: _resendCountdown == 0
                              ? AppTheme.primaryColor
                              : AppTheme.textMuted,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
