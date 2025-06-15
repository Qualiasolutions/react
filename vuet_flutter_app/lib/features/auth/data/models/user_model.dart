import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// Comprehensive user model that represents the user data structure
/// from the original Django app, including profile information,
/// settings, and all fields needed for user management,
/// family sharing, and authentication state.
@freezed
class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    /// Unique identifier for the user
    required String id,
    
    /// User's email address (can be null if phone auth is used)
    String? email,
    
    /// User's phone number (can be null if email auth is used)
    String? phoneNumber,
    
    /// User's full name
    required String fullName,
    
    /// URL to the user's avatar image
    String? avatarUrl,
    
    /// When the user was created
    required DateTime createdAt,
    
    /// When the user was last updated
    required DateTime updatedAt,
    
    /// When the user was last active
    required DateTime lastActiveAt,
    
    /// User's preferred days for tasks (JSON format)
    @Default([]) List<int> preferredDays,
    
    /// User's blocked days for tasks (JSON format)
    @Default([]) List<int> blockedDays,
    
    /// User's preferences for flexible tasks (JSON format)
    @Default({}) Map<String, dynamic> flexibleTaskPreferences,
    
    /// IDs of families the user belongs to
    @Default([]) List<String> familyIds,
    
    /// User's role in each family (key: familyId, value: role)
    @Default({}) Map<String, String> familyRoles,
    
    /// IDs of entities owned by the user
    @Default([]) List<String> ownedEntityIds,
    
    /// IDs of entities shared with the user
    @Default([]) List<String> sharedEntityIds,
    
    /// IDs of professional categories created by the user
    @Default([]) List<String> professionalCategoryIds,
    
    /// Whether the user has completed onboarding
    @Default(false) bool onboardingCompleted,
    
    /// Whether the user has a premium subscription
    @Default(false) bool isPremium,
    
    /// User's subscription plan ID (if any)
    String? subscriptionPlanId,
    
    /// When the user's subscription expires (if any)
    DateTime? subscriptionExpiresAt,
    
    /// User's notification preferences
    @Default({}) Map<String, bool> notificationPreferences,
    
    /// User's timezone
    @Default('UTC') String timezone,
    
    /// User's locale/language preference
    @Default('en_US') String locale,
    
    /// Whether the user's email is verified
    @Default(false) bool emailVerified,
    
    /// Whether the user's phone number is verified
    @Default(false) bool phoneVerified,
    
    /// Whether the user's account is active
    @Default(true) bool isActive,
    
    /// Authentication provider (email, phone, google, apple)
    @Default('email') String authProvider,
    
    /// Categories that are enabled for this user
    @Default([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]) List<int> enabledCategories,
    
    /// Family visibility settings (what family members can see)
    @Default({}) Map<String, List<int>> familyVisibilitySettings,
    
    /// Setup completion tracking
    @Default({}) Map<String, bool> setupCompletionStatus,
  }) = _UserModel;

  /// Create a new user from JSON data
  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  /// Create an empty user with default values
  factory UserModel.empty() => UserModel(
    id: const Uuid().v4(),
    fullName: '',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    lastActiveAt: DateTime.now(),
  );

  /// Create a user from Supabase auth and profile data
  factory UserModel.fromSupabase({
    required Map<String, dynamic> user,
    required Map<String, dynamic>? profile,
    required Map<String, dynamic>? settings,
  }) {
    final now = DateTime.now();
    
    return UserModel(
      id: user['id'] as String,
      email: user['email'] as String?,
      phoneNumber: user['phone'] as String?,
      fullName: profile?['full_name'] as String? ?? '',
      avatarUrl: profile?['avatar_url'] as String?,
      createdAt: user['created_at'] != null 
          ? DateTime.parse(user['created_at'] as String) 
          : now,
      updatedAt: profile?['updated_at'] != null 
          ? DateTime.parse(profile?['updated_at'] as String) 
          : now,
      lastActiveAt: profile?['last_active_at'] != null 
          ? DateTime.parse(profile?['last_active_at'] as String) 
          : now,
      preferredDays: settings?['preferred_days'] != null 
          ? List<int>.from(settings!['preferred_days'] as List) 
          : [],
      blockedDays: settings?['blocked_days'] != null 
          ? List<int>.from(settings!['blocked_days'] as List) 
          : [],
      flexibleTaskPreferences: settings?['flexible_task_preferences'] as Map<String, dynamic>? ?? {},
      emailVerified: user['email_confirmed_at'] != null,
      phoneVerified: user['phone_confirmed_at'] != null,
    );
  }

  /// Check if the user has completed setup for a specific feature
  bool hasCompletedSetup(String setupKey) {
    return setupCompletionStatus[setupKey] == true;
  }

  /// Check if the user is a member of a specific family
  bool isFamilyMember(String familyId) {
    return familyIds.contains(familyId);
  }

  /// Check if the user has a specific role in a family
  bool hasFamilyRole(String familyId, String role) {
    return familyRoles[familyId]?.toLowerCase() == role.toLowerCase();
  }

  /// Check if the user has access to a specific category
  bool hasAccessToCategory(int categoryId) {
    // If premium categories are 7-13, check premium status
    if (categoryId > 6 && !isPremium) {
      return false;
    }
    return enabledCategories.contains(categoryId);
  }

  /// Check if the user has shared a category with their family
  bool hasSharedCategoryWithFamily(String familyId, int categoryId) {
    final visibleCategories = familyVisibilitySettings[familyId] ?? [];
    return visibleCategories.contains(categoryId);
  }

  /// Get the user's display name (or email if name is empty)
  String get displayName {
    if (fullName.isNotEmpty) return fullName;
    if (email != null && email!.isNotEmpty) return email!.split('@').first;
    if (phoneNumber != null) return 'User ${phoneNumber!.substring(phoneNumber!.length - 4)}';
    return 'User';
  }

  /// Get the user's initials for avatar display
  String get initials {
    if (fullName.isEmpty) {
      return email != null ? email![0].toUpperCase() : 'U';
    }
    
    final nameParts = fullName.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    
    return fullName[0].toUpperCase();
  }
}
