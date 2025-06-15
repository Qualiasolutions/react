import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vuet_flutter/features/auth/data/repositories/auth_repository.dart';
import 'package:vuet_flutter/core/theme/app_theme.dart';
import 'package:vuet_flutter/core/utils/error_handler.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isEmailSignup = true; // State to toggle between email/phone signup
  bool _isLoading = false;
  String? _errorMessage;
  bool _termsAccepted = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_termsAccepted) {
      setState(() {
        _errorMessage = 'You must accept the terms and conditions.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isEmailSignup) {
        await ref.read(authRepositoryProvider).signUpWithEmail(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              fullName: _fullNameController.text.trim(),
            );
        // AuthStateNotifier will handle navigation to /home on successful signup
      } else {
        // For phone signup, we send OTP first, then navigate to verification screen
        await ref.read(authRepositoryProvider).signInWithPhone(
              phoneNumber: _phoneController.text.trim(),
            );
        // Navigate to OTP verification screen, passing phone number and full name
        if (mounted) {
          context.go(
            '/verify/phone',
            extra: {
              'phoneNumber': _phoneController.text.trim(),
              'fullName': _fullNameController.text.trim(),
            },
          );
        }
      }
    } catch (e, stackTrace) {
      ErrorHandler.reportError('Sign up failed', e, stackTrace: stackTrace);
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(bottom: AppTheme.spacingL),
                  child: Text(
                    'Vuet',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),

                // Title
                Text(
                  _isEmailSignup ? 'Create an Account' : 'Sign Up with Phone',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppTheme.spacingXs),

                // Subtitle
                Text(
                  _isEmailSignup ? 'Sign up to get started' : 'Enter your details to create an account',
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

                // Full Name field
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppTheme.spacingM),

                // Email/Phone field
                _isEmailSignup
                    ? TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      )
                    : TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          // Basic phone number validation (can be enhanced)
                          if (value.length < 10) {
                            return 'Please enter a valid phone number';
                          }
                          return null;
                        },
                      ),

                const SizedBox(height: AppTheme.spacingM),

                // Password field (only for email signup)
                if (_isEmailSignup)
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),

                const SizedBox(height: AppTheme.spacingM),

                // Terms and Conditions checkbox
                CheckboxListTile(
                  title: Text(
                    'I accept the terms and conditions',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  value: _termsAccepted,
                  onChanged: (bool? newValue) {
                    setState(() {
                      _termsAccepted = newValue ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),

                const SizedBox(height: AppTheme.spacingL),

                // Sign up button
                ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
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
                          'Sign Up',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                              ),
                        ),
                ),

                const SizedBox(height: AppTheme.spacingM),

                // Toggle between email/phone signup
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isEmailSignup = !_isEmailSignup;
                      _errorMessage = null; // Clear error when switching
                      _formKey.currentState?.reset(); // Reset form validation
                      _termsAccepted = false; // Reset terms acceptance
                    });
                  },
                  child: Text(
                    _isEmailSignup
                        ? 'Use Phone Number Instead'
                        : 'Use Email/Password Instead',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppTheme.primaryColor,
                        ),
                  ),
                ),

                // Login link
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(
                    'Already have an account? Log in',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppTheme.primaryColor,
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
