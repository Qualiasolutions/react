// lib/features/auth/providers/auth_provider.dart
// Authentication provider that replicates Redux auth state from React Native app

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Hide Supabase's `Provider` enum to avoid a name clash with Riverpod's `Provider`
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import 'package:vuet_flutter/core/utils/logger.dart';

/// Authentication state class
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? accessToken;
  final String? refreshToken;
  final String? userId;
  final String? error;
  final Stream<AuthState>? stream;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.accessToken,
    this.refreshToken,
    this.userId,
    this.error,
    this.stream,
  });

  /// Create a copy of this state with specified fields updated
  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? accessToken,
    String? refreshToken,
    String? userId,
    String? error,
    Stream<AuthState>? stream,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      userId: userId ?? this.userId,
      error: error ?? this.error,
      stream: stream ?? this.stream,
    );
  }

  /// Create a loading state
  AuthState loading() {
    return copyWith(isLoading: true, error: null);
  }

  /// Create an error state
  AuthState withError(String errorMessage) {
    return copyWith(error: errorMessage, isLoading: false);
  }

  /// Create an authenticated state
  AuthState authenticated({
    required String accessToken,
    required String refreshToken,
    required String userId,
  }) {
    return copyWith(
      isAuthenticated: true,
      isLoading: false,
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: userId,
      error: null,
    );
  }

  /// Create an unauthenticated state
  AuthState unauthenticated() {
    return const AuthState(
      isAuthenticated: false,
      isLoading: false,
      accessToken: null,
      refreshToken: null,
      userId: null,
      error: null,
    );
  }
}

/// Authentication notifier that handles state changes
class AuthNotifier extends StateNotifier<AuthState> {
  final SupabaseClient _supabase;
  StreamSubscription<AuthState>? _authSubscription;
  
  AuthNotifier(this._supabase) : super(const AuthState(isLoading: true)) {
    // Initialize auth state
    _initAuthState();
  }

  /// Initialize authentication state from session
  Future<void> _initAuthState() async {
    try {
      final session = _supabase.auth.currentSession;
      
      if (session != null) {
        state = state.authenticated(
          accessToken: session.accessToken,
          refreshToken: session.refreshToken,
          userId: session.user.id,
        );
      } else {
        state = state.unauthenticated();
      }
      
      // Listen for auth state changes
      _listenToAuthChanges();
    } catch (e, st) {
      Logger.error('Failed to initialize auth state', e, st);
      state = state.unauthenticated();
    }
  }

  /// Listen to authentication changes from Supabase
  void _listenToAuthChanges() {
    final controller = StreamController<AuthState>.broadcast();
    
    _supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;
      
      switch (event) {
        case AuthChangeEvent.signedIn:
        case AuthChangeEvent.tokenRefreshed:
        case AuthChangeEvent.userUpdated:
          if (session != null) {
            state = state.authenticated(
              accessToken: session.accessToken,
              refreshToken: session.refreshToken,
              userId: session.user.id,
            );
            controller.add(state);
          }
          break;
        case AuthChangeEvent.signedOut:
        case AuthChangeEvent.userDeleted:
          state = state.unauthenticated();
          controller.add(state);
          break;
        default:
          break;
      }
    });
    
    state = state.copyWith(stream: controller.stream);
  }

  /// Sign in with email and password
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      state = state.loading();
      
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.session != null) {
        state = state.authenticated(
          accessToken: response.session!.accessToken,
          refreshToken: response.session!.refreshToken,
          userId: response.user!.id,
        );
      } else {
        state = state.withError('Authentication failed');
      }
    } catch (e, st) {
      Logger.error('Sign in error', e, st);
      state = state.withError(e.toString());
    }
  }

  /// Sign up with email, password, and name
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      state = state.loading();
      
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );
      
      if (response.session != null) {
        // Create profile record
        await _supabase.from('profiles').insert({
          'id': response.user!.id,
          'email': email,
          'full_name': name,
          'has_completed_setup': false,
        });
        
        state = state.authenticated(
          accessToken: response.session!.accessToken,
          refreshToken: response.session!.refreshToken,
          userId: response.user!.id,
        );
      } else {
        state = state.withError('Registration failed');
      }
    } catch (e, st) {
      Logger.error('Sign up error', e, st);
      state = state.withError(e.toString());
    }
  }

  /// Send phone verification code
  Future<void> sendPhoneVerification({required String phone}) async {
    try {
      state = state.loading();
      
      await _supabase.auth.signInWithOtp(
        phone: phone,
      );
      
      // Phone verification sent - we'll stay in loading state until verified
      state = state.copyWith(isLoading: false);
    } catch (e, st) {
      Logger.error('Phone verification error', e, st);
      state = state.withError(e.toString());
    }
  }

  /// Verify phone with OTP code
  Future<void> verifyPhone({
    required String phone,
    required String otp,
  }) async {
    try {
      state = state.loading();
      
      final response = await _supabase.auth.verifyOTP(
        phone: phone,
        token: otp,
        type: OtpType.sms,
      );
      
      if (response.session != null) {
        state = state.authenticated(
          accessToken: response.session!.accessToken,
          refreshToken: response.session!.refreshToken,
          userId: response.user!.id,
        );
      } else {
        state = state.withError('Phone verification failed');
      }
    } catch (e, st) {
      Logger.error('OTP verification error', e, st);
      state = state.withError(e.toString());
    }
  }

  /// Reset password
  Future<void> resetPassword({required String email}) async {
    try {
      state = state.loading();
      
      await _supabase.auth.resetPasswordForEmail(
        email,
      );
      
      state = state.copyWith(isLoading: false);
    } catch (e, st) {
      Logger.error('Password reset error', e, st);
      state = state.withError(e.toString());
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      state = state.loading();
      
      await _supabase.auth.signOut();
      
      state = state.unauthenticated();
    } catch (e, st) {
      Logger.error('Sign out error', e, st);
      state = state.withError(e.toString());
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    String? fullName,
    String? phone,
  }) async {
    try {
      if (state.userId == null) {
        throw Exception('User not authenticated');
      }
      
      state = state.loading();
      
      // Update auth user if phone is provided
      if (phone != null) {
        await _supabase.auth.updateUser(
          UserAttributes(
            phone: phone,
          ),
        );
      }
      
      // Update profile if fullName is provided
      if (fullName != null) {
        await _supabase.from('profiles').update({
          'full_name': fullName,
        }).eq('id', state.userId);
      }
      
      // Refresh state with current session
      final session = _supabase.auth.currentSession;
      if (session != null) {
        state = state.authenticated(
          accessToken: session.accessToken,
          refreshToken: session.refreshToken,
          userId: session.user.id,
        );
      } else {
        state = state.unauthenticated();
      }
    } catch (e, st) {
      Logger.error('Update profile error', e, st);
      state = state.withError(e.toString());
    }
  }

  /// Mark user setup as complete
  Future<void> completeUserSetup() async {
    try {
      if (state.userId == null) {
        throw Exception('User not authenticated');
      }
      
      await _supabase.from('profiles').update({
        'has_completed_setup': true,
      }).eq('id', state.userId);
      
    } catch (e, st) {
      Logger.error('Complete user setup error', e, st);
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

/// Auth state provider
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(Supabase.instance.client);
});

/// Convenience providers for auth state components
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).isAuthenticated;
});

final isAuthLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).error;
});

final accessTokenProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).accessToken;
});

final refreshTokenProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).refreshToken;
});

final userIdProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).userId;
});
