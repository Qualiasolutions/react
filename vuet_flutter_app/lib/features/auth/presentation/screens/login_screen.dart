import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vuet_flutter/features/auth/data/repositories/auth_repository.dart';
import 'package:vuet_flutter/core/theme/app_theme.dart'; // Import AppTheme for colors and typography

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isEmailLogin = true; // State to toggle between email/phone login
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isEmailLogin) {
        await ref.read(authRepositoryProvider).signInWithEmail(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );
      } else {
        // For phone login, we send OTP first, then navigate to verification screen
        await ref.read(authRepositoryProvider).signInWithPhone(
              phoneNumber: _phoneController.text.trim(),
            );
        // Navigate to OTP verification screen
        if (mounted) {
          context.go('/verify/phone', extra: _phoneController.text.trim());
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
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
                  _isEmailLogin ? 'Welcome Back' : 'Login with Phone',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppTheme.spacingXs),

                // Subtitle
                Text(
                  _isEmailLogin ? 'Log in to your account' : 'Enter your phone number',
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

                // Email/Phone field
                _isEmailLogin
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

                // Password field (only for email login)
                if (_isEmailLogin)
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),

                const SizedBox(height: AppTheme.spacingL),

                // Login button
                ElevatedButton(
                  onPressed: _isLoading ? null : _signIn,
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
                          _isEmailLogin ? 'Log In' : 'Send OTP',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                              ),
                        ),
                ),

                const SizedBox(height: AppTheme.spacingM),

                // Toggle between email/phone login
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isEmailLogin = !_isEmailLogin;
                      _errorMessage = null; // Clear error when switching
                      _formKey.currentState?.reset(); // Reset form validation
                    });
                  },
                  child: Text(
                    _isEmailLogin
                        ? 'Use Phone Number Instead'
                        : 'Use Email/Password Instead',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppTheme.primaryColor,
                        ),
                  ),
                ),

                // Sign up link
                TextButton(
                  onPressed: () => context.go('/signup'),
                  child: Text(
                    'Don\'t have an account? Sign up',
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
