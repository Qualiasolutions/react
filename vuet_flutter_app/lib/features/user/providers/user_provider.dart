// lib/features/user/providers/user_provider.dart
// User provider that fetches and manages user details from Supabase profiles table

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vuet_flutter/core/utils/logger.dart';
import 'package:vuet_flutter/features/auth/providers/auth_provider.dart';

/// User details model
class UserDetails {
  final String id;
  final String? email;
  final String? phone;
  final String? fullName;
  final bool hasCompletedSetup;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? preferences;

  UserDetails({
    required this.id,
    this.email,
    this.phone,
    this.fullName,
    this.hasCompletedSetup = false,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
    this.preferences,
  });

  /// Create from Supabase JSON response
  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      id: json['id'],
      email: json['email'],
      phone: json['phone'],
      fullName: json['full_name'],
      hasCompletedSetup: json['has_completed_setup'] ?? false,
      avatarUrl: json['avatar_url'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      preferences: json['preferences'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'full_name': fullName,
      'has_completed_setup': hasCompletedSetup,
      'avatar_url': avatarUrl,
      'preferences': preferences,
    };
  }

  /// Create a copy with updated fields
  UserDetails copyWith({
    String? id,
    String? email,
    String? phone,
    String? fullName,
    bool? hasCompletedSetup,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? preferences,
  }) {
    return UserDetails(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      hasCompletedSetup: hasCompletedSetup ?? this.hasCompletedSetup,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      preferences: preferences ?? this.preferences,
    );
  }
}

/// User details state
class UserDetailsState {
  final UserDetails? data;
  final bool isLoading;
  final String? error;

  const UserDetailsState({
    this.data,
    this.isLoading = false,
    this.error,
  });

  /// Create a loading state
  UserDetailsState loading() {
    return UserDetailsState(
      data: data,
      isLoading: true,
      error: null,
    );
  }

  /// Create an error state
  UserDetailsState withError(String errorMessage) {
    return UserDetailsState(
      data: data,
      isLoading: false,
      error: errorMessage,
    );
  }

  /// Create a success state
  UserDetailsState withData(UserDetails userData) {
    return UserDetailsState(
      data: userData,
      isLoading: false,
      error: null,
    );
  }
}

/// User details notifier
class UserDetailsNotifier extends StateNotifier<UserDetailsState> {
  final SupabaseClient _supabase;
  final String? _userId;

  UserDetailsNotifier(this._supabase, this._userId) : super(const UserDetailsState()) {
    if (_userId != null) {
      fetchUserDetails();
    }
  }

  /// Fetch user details from Supabase
  Future<void> fetchUserDetails() async {
    if (_userId == null) return;

    try {
      state = state.loading();

      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', _userId)
          .single();

      final userDetails = UserDetails.fromJson(response);
      state = state.withData(userDetails);
    } catch (e, st) {
      Logger.error('Failed to fetch user details', e, st);
      state = state.withError(e.toString());
    }
  }

  /// Update user details
  Future<void> updateUserDetails({
    String? fullName,
    String? avatarUrl,
    Map<String, dynamic>? preferences,
  }) async {
    if (_userId == null) return;

    try {
      state = state.loading();

      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (preferences != null) updates['preferences'] = preferences;

      await _supabase
          .from('profiles')
          .update(updates)
          .eq('id', _userId);

      // Refresh user details
      await fetchUserDetails();
    } catch (e, st) {
      Logger.error('Failed to update user details', e, st);
      state = state.withError(e.toString());
    }
  }

  /// Mark user setup as completed
  Future<void> completeUserSetup() async {
    if (_userId == null) return;

    try {
      state = state.loading();

      await _supabase
          .from('profiles')
          .update({'has_completed_setup': true})
          .eq('id', _userId);

      // If we have current data, update it directly
      if (state.data != null) {
        state = state.withData(state.data!.copyWith(hasCompletedSetup: true));
      } else {
        // Otherwise refresh the whole user details
        await fetchUserDetails();
      }
    } catch (e, st) {
      Logger.error('Failed to complete user setup', e, st);
      state = state.withError(e.toString());
    }
  }

  /// Upload avatar image and update user profile
  Future<void> uploadAvatar(List<int> fileBytes, String fileName) async {
    if (_userId == null) return;

    try {
      state = state.loading();

      // Upload image to storage
      final filePath = 'avatars/$_userId/$fileName';
      await _supabase.storage.from('profiles').uploadBinary(
        filePath,
        fileBytes,
        fileOptions: const FileOptions(
          cacheControl: '3600',
          upsert: true,
        ),
      );

      // Get public URL
      final imageUrlResponse = _supabase.storage.from('profiles').getPublicUrl(filePath);

      // Update user profile with avatar URL
      await updateUserDetails(avatarUrl: imageUrlResponse);
    } catch (e, st) {
      Logger.error('Failed to upload avatar', e, st);
      state = state.withError(e.toString());
    }
  }

  /// Update user preferences
  Future<void> updatePreferences(Map<String, dynamic> newPreferences) async {
    if (_userId == null) return;

    try {
      // Merge with existing preferences
      final currentPreferences = state.data?.preferences ?? {};
      final mergedPreferences = {...currentPreferences, ...newPreferences};

      await updateUserDetails(preferences: mergedPreferences);
    } catch (e, st) {
      Logger.error('Failed to update preferences', e, st);
      state = state.withError(e.toString());
    }
  }
}

/// User details provider
final userDetailsProvider = StateNotifierProvider<UserDetailsNotifier, UserDetailsState>((ref) {
  final userId = ref.watch(userIdProvider);
  return UserDetailsNotifier(Supabase.instance.client, userId);
});

/// Convenience providers
final userFullNameProvider = Provider<String?>((ref) {
  return ref.watch(userDetailsProvider).data?.fullName;
});

final userEmailProvider = Provider<String?>((ref) {
  return ref.watch(userDetailsProvider).data?.email;
});

final userPhoneProvider = Provider<String?>((ref) {
  return ref.watch(userDetailsProvider).data?.phone;
});

final userAvatarProvider = Provider<String?>((ref) {
  return ref.watch(userDetailsProvider).data?.avatarUrl;
});

final userSetupCompletedProvider = Provider<bool>((ref) {
  return ref.watch(userDetailsProvider).data?.hasCompletedSetup ?? false;
});

final userPreferencesProvider = Provider<Map<String, dynamic>?>((ref) {
  return ref.watch(userDetailsProvider).data?.preferences;
});
