import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vuet_flutter/core/config/supabase_config.dart';
import 'package:vuet_flutter/core/utils/error_handler.dart';
import 'package:vuet_flutter/features/auth/data/models/user_model.dart';

/// Provider for the auth repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Provider for the current auth state
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthStateNotifier(authRepository);
});

/// Auth state notifier to manage authentication state changes
class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<AuthState>? _authSubscription;

  AuthStateNotifier(this._authRepository) : super(const AuthState.initial()) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = const AuthState.loading();
    
    try {
      final session = await _authRepository.getCurrentSession();
      
      if (session != null) {
        final user = await _authRepository.getCurrentUser();
        state = AuthState.authenticated(user);
      } else {
        state = const AuthState.unauthenticated();
      }
      
      // Listen for auth state changes
      _authSubscription = _authRepository.onAuthStateChange.listen((newState) {
        state = newState;
      });
      
    } catch (e, stackTrace) {
      ErrorHandler.reportError(
        'Failed to initialize auth state',
        e,
        stackTrace: stackTrace,
      );
      state = AuthState.error(e.toString());
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

/// Authentication state class
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.errorMessage,
  });

  const AuthState.initial()
      : isLoading = true,
        isAuthenticated = false,
        user = null,
        errorMessage = null;

  const AuthState.loading()
      : isLoading = true,
        isAuthenticated = false,
        user = null,
        errorMessage = null;

  const AuthState.unauthenticated()
      : isLoading = false,
        isAuthenticated = false,
        user = null,
        errorMessage = null;

  const AuthState.authenticated(this.user)
      : isLoading = false,
        isAuthenticated = true,
        errorMessage = null;

  const AuthState.error(this.errorMessage)
      : isLoading = false,
        isAuthenticated = false,
        user = null;

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Repository for handling all authentication operations
class AuthRepository {
  final SupabaseClient _supabase = SupabaseConfig.client;
  final _authStateController = StreamController<AuthState>.broadcast();

  /// Stream of auth state changes
  Stream<AuthState> get onAuthStateChange => _authStateController.stream;

  /// Constructor
  AuthRepository() {
    // Listen to Supabase auth state changes
    _supabase.auth.onAuthStateChange.listen(_handleAuthStateChange);
  }

  /// Handle auth state changes from Supabase
  Future<void> _handleAuthStateChange(AuthState event) async {
    if (event.isAuthenticated && event.user != null) {
      _authStateController.add(event);
    } else if (!event.isAuthenticated) {
      _authStateController.add(const AuthState.unauthenticated());
    }
  }

  /// Sign up with email and password
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      _authStateController.add(const AuthState.loading());
      
      // Sign up with Supabase
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
        },
      );
      
      if (response.user == null) {
        throw Exception('Failed to create user account');
      }
      
      // Create user profile
      await _supabase.from('profiles').insert({
        'id': response.user!.id,
        'full_name': fullName,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'last_active_at': DateTime.now().toIso8601String(),
      });
      
      // Create user settings
      await _supabase.from('user_settings').insert({
        'id': response.user!.id,
        'preferred_days': [1, 2, 3, 4, 5], // Default to weekdays
        'blocked_days': [],
        'flexible_task_preferences': {},
      });
      
      // Get the created user
      final user = await getCurrentUser();
      
      return user;
    } catch (e, stackTrace) {
      ErrorHandler.reportError('Sign up with email failed', e, stackTrace: stackTrace);
      _authStateController.add(AuthState.error(e.toString()));
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _authStateController.add(const AuthState.loading());
      
      // Sign in with Supabase
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        throw Exception('Invalid login credentials');
      }
      
      // Update last active timestamp
      await _supabase.from('profiles').update({
        'last_active_at': DateTime.now().toIso8601String(),
      }).eq('id', response.user!.id);
      
      // Get the user data
      final user = await getCurrentUser();
      
      return user;
    } catch (e, stackTrace) {
      ErrorHandler.reportError('Sign in with email failed', e, stackTrace: stackTrace);
      _authStateController.add(AuthState.error(e.toString()));
      rethrow;
    }
  }

  /// Sign up or sign in with phone number
  Future<void> signInWithPhone({
    required String phoneNumber,
  }) async {
    try {
      _authStateController.add(const AuthState.loading());
      
      // Send OTP to phone number
      await _supabase.auth.signInWithOtp(
        phone: phoneNumber,
      );
      
      // Note: This doesn't complete the sign-in process
      // The user needs to verify the OTP using verifyPhoneOTP
    } catch (e, stackTrace) {
      ErrorHandler.reportError('Sign in with phone failed', e, stackTrace: stackTrace);
      _authStateController.add(AuthState.error(e.toString()));
      rethrow;
    }
  }

  /// Verify phone OTP (one-time password)
  Future<UserModel> verifyPhoneOTP({
    required String phoneNumber,
    required String otp,
    String? fullName,
  }) async {
    try {
      _authStateController.add(const AuthState.loading());
      
      // Verify OTP with Supabase
      final response = await _supabase.auth.verifyOTP(
        phone: phoneNumber,
        token: otp,
        type: OtpType.sms,
      );
      
      if (response.user == null) {
        throw Exception('Invalid verification code');
      }
      
      // Check if this is a new user
      final isNewUser = response.user!.createdAt.difference(DateTime.now()).inSeconds.abs() < 60;
      
      if (isNewUser) {
        // Create profile for new user
        await _supabase.from('profiles').insert({
          'id': response.user!.id,
          'full_name': fullName ?? '',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'last_active_at': DateTime.now().toIso8601String(),
        });
        
        // Create user settings
        await _supabase.from('user_settings').insert({
          'id': response.user!.id,
          'preferred_days': [1, 2, 3, 4, 5], // Default to weekdays
          'blocked_days': [],
          'flexible_task_preferences': {},
        });
      } else {
        // Update last active timestamp for existing user
        await _supabase.from('profiles').update({
          'last_active_at': DateTime.now().toIso8601String(),
        }).eq('id', response.user!.id);
      }
      
      // Get the user data
      final user = await getCurrentUser();
      
      return user;
    } catch (e, stackTrace) {
      ErrorHandler.reportError('Verify phone OTP failed', e, stackTrace: stackTrace);
      _authStateController.add(AuthState.error(e.toString()));
      rethrow;
    }
  }

  /// Request password reset
  Future<void> resetPassword({
    required String email,
  }) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: kIsWeb ? '${Uri.base.origin}/reset-password' : null,
      );
    } catch (e, stackTrace) {
      ErrorHandler.reportError('Reset password failed', e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Update password
  Future<void> updatePassword({
    required String newPassword,
  }) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(
          password: newPassword,
        ),
      );
    } catch (e, stackTrace) {
      ErrorHandler.reportError('Update password failed', e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get current session
  Future<Session?> getCurrentSession() async {
    try {
      return _supabase.auth.currentSession;
    } catch (e, stackTrace) {
      ErrorHandler.reportError('Get current session failed', e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Get current user
  Future<UserModel> getCurrentUser() async {
    try {
      final authUser = _supabase.auth.currentUser;
      
      if (authUser == null) {
        throw Exception('No authenticated user found');
      }
      
      // Get user profile
      final profileResponse = await _supabase
          .from('profiles')
          .select()
          .eq('id', authUser.id)
          .single();
      
      // Get user settings
      final settingsResponse = await _supabase
          .from('user_settings')
          .select()
          .eq('id', authUser.id)
          .maybeSingle();
      
      // Get family memberships
      final familyMemberships = await _supabase
          .from('family_members')
          .select('family_id, role')
          .eq('user_id', authUser.id);
      
      // Create user model
      final user = UserModel.fromSupabase(
        user: authUser.toJson(),
        profile: profileResponse,
        settings: settingsResponse,
      );
      
      // Update auth state
      _authStateController.add(AuthState.authenticated(user));
      
      return user;
    } catch (e, stackTrace) {
      ErrorHandler.reportError('Get current user failed', e, stackTrace: stackTrace);
      _authStateController.add(AuthState.error(e.toString()));
      rethrow;
    }
  }

  /// Update user profile
  Future<UserModel> updateUserProfile({
    required String fullName,
    String? avatarUrl,
  }) async {
    try {
      final authUser = _supabase.auth.currentUser;
      
      if (authUser == null) {
        throw Exception('No authenticated user found');
      }
      
      // Update profile
      await _supabase.from('profiles').update({
        'full_name': fullName,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', authUser.id);
      
      // Get updated user
      return await getCurrentUser();
    } catch (e, stackTrace) {
      ErrorHandler.reportError('Update user profile failed', e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Update user settings
  Future<UserModel> updateUserSettings({
    List<int>? preferredDays,
    List<int>? blockedDays,
    Map<String, dynamic>? flexibleTaskPreferences,
  }) async {
    try {
      final authUser = _supabase.auth.currentUser;
      
      if (authUser == null) {
        throw Exception('No authenticated user found');
      }
      
      // Prepare update data
      final updateData = <String, dynamic>{};
      if (preferredDays != null) updateData['preferred_days'] = preferredDays;
      if (blockedDays != null) updateData['blocked_days'] = blockedDays;
      if (flexibleTaskPreferences != null) {
        updateData['flexible_task_preferences'] = flexibleTaskPreferences;
      }
      
      // Update settings
      await _supabase
          .from('user_settings')
          .update(updateData)
          .eq('id', authUser.id);
      
      // Get updated user
      return await getCurrentUser();
    } catch (e, stackTrace) {
      ErrorHandler.reportError('Update user settings failed', e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      _authStateController.add(const AuthState.loading());
      await _supabase.auth.signOut();
      _authStateController.add(const AuthState.unauthenticated());
    } catch (e, stackTrace) {
      ErrorHandler.reportError('Sign out failed', e, stackTrace: stackTrace);
      _authStateController.add(AuthState.error(e.toString()));
      rethrow;
    }
  }

  /// Upload avatar image
  Future<String> uploadAvatar({
    required String filePath,
    required String fileType,
  }) async {
    try {
      final authUser = _supabase.auth.currentUser;
      
      if (authUser == null) {
        throw Exception('No authenticated user found');
      }
      
      // Upload file to storage
      final fileName = '${authUser.id}_${DateTime.now().millisecondsSinceEpoch}.$fileType';
      final storageResponse = await _supabase.storage
          .from('avatars')
          .upload(fileName, File(filePath));
      
      // Get public URL
      final imageUrl = _supabase.storage.from('avatars').getPublicUrl(fileName);
      
      // Update profile with avatar URL
      await updateUserProfile(
        fullName: (await getCurrentUser()).fullName,
        avatarUrl: imageUrl,
      );
      
      return imageUrl;
    } catch (e, stackTrace) {
      ErrorHandler.reportError('Upload avatar failed', e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Check if email exists
  Future<bool> checkEmailExists(String email) async {
    try {
      final response = await _supabase.functions.invoke(
        'check-email-exists',
        body: {'email': email},
      );
      
      return response.data['exists'] as bool;
    } catch (e, stackTrace) {
      ErrorHandler.reportError('Check email exists failed', e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Check if phone exists
  Future<bool> checkPhoneExists(String phone) async {
    try {
      final response = await _supabase.functions.invoke(
        'check-phone-exists',
        body: {'phone': phone},
      );
      
      return response.data['exists'] as bool;
    } catch (e, stackTrace) {
      ErrorHandler.reportError('Check phone exists failed', e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Update user email
  Future<void> updateEmail({
    required String newEmail,
    required String password,
  }) async {
    try {
      // First verify the current password
      await _supabase.auth.signInWithPassword(
        email: _supabase.auth.currentUser!.email!,
        password: password,
      );
      
      // Then update the email
      await _supabase.auth.updateUser(
        UserAttributes(email: newEmail),
      );
    } catch (e, stackTrace) {
      ErrorHandler.reportError('Update email failed', e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Update user phone
  Future<void> updatePhone({
    required String newPhone,
  }) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(phone: newPhone),
      );
      
      // Note: This will require verification via OTP
    } catch (e, stackTrace) {
      ErrorHandler.reportError('Update phone failed', e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Track setup completion
  Future<void> markSetupComplete(String setupKey) async {
    try {
      final authUser = _supabase.auth.currentUser;
      
      if (authUser == null) {
        throw Exception('No authenticated user found');
      }
      
      // Check which table to update based on setupKey
      String tableName;
      switch (setupKey) {
        case 'references':
          tableName = 'references_setup_completion';
          break;
        case 'tags':
          tableName = 'tag_setup_completion';
          break;
        case 'link_list':
          tableName = 'link_list_setup_completion';
          break;
        default:
          if (setupKey.startsWith('entity_type_')) {
            tableName = 'entity_type_setup_completion';
          } else {
            throw Exception('Invalid setup key: $setupKey');
          }
      }
      
      // Update the appropriate setup completion table
      if (tableName == 'entity_type_setup_completion') {
        final entityType = setupKey.replaceFirst('entity_type_', '');
        
        // Check if record exists
        final existing = await _supabase
            .from(tableName)
            .select()
            .eq('id', authUser.id)
            .eq('entity_type', entityType)
            .maybeSingle();
        
        if (existing != null) {
          // Update existing record
          await _supabase
              .from(tableName)
              .update({
                'completed': true,
                'completed_at': DateTime.now().toIso8601String(),
              })
              .eq('id', authUser.id)
              .eq('entity_type', entityType);
        } else {
          // Insert new record
          await _supabase.from(tableName).insert({
            'id': authUser.id,
            'entity_type': entityType,
            'completed': true,
            'completed_at': DateTime.now().toIso8601String(),
          });
        }
      } else {
        // Check if record exists
        final existing = await _supabase
            .from(tableName)
            .select()
            .eq('id', authUser.id)
            .maybeSingle();
        
        if (existing != null) {
          // Update existing record
          await _supabase
              .from(tableName)
              .update({
                'completed': true,
                'completed_at': DateTime.now().toIso8601String(),
              })
              .eq('id', authUser.id);
        } else {
          // Insert new record
          await _supabase.from(tableName).insert({
            'id': authUser.id,
            'completed': true,
            'completed_at': DateTime.now().toIso8601String(),
          });
        }
      }
    } catch (e, stackTrace) {
      ErrorHandler.reportError('Mark setup complete failed', e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
