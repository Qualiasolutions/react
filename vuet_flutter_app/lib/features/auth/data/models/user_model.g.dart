// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      id: json['id'] as String,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      fullName: json['fullName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastActiveAt: DateTime.parse(json['lastActiveAt'] as String),
      preferredDays: (json['preferredDays'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      blockedDays: (json['blockedDays'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      flexibleTaskPreferences:
          json['flexibleTaskPreferences'] as Map<String, dynamic>? ?? const {},
      familyIds: (json['familyIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      familyRoles: (json['familyRoles'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      ownedEntityIds: (json['ownedEntityIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      sharedEntityIds: (json['sharedEntityIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      professionalCategoryIds:
          (json['professionalCategoryIds'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              const [],
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
      isPremium: json['isPremium'] as bool? ?? false,
      subscriptionPlanId: json['subscriptionPlanId'] as String?,
      subscriptionExpiresAt: json['subscriptionExpiresAt'] == null
          ? null
          : DateTime.parse(json['subscriptionExpiresAt'] as String),
      notificationPreferences:
          (json['notificationPreferences'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, e as bool),
              ) ??
              const {},
      timezone: json['timezone'] as String? ?? 'UTC',
      locale: json['locale'] as String? ?? 'en_US',
      emailVerified: json['emailVerified'] as bool? ?? false,
      phoneVerified: json['phoneVerified'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      authProvider: json['authProvider'] as String? ?? 'email',
      enabledCategories: (json['enabledCategories'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13],
      familyVisibilitySettings:
          (json['familyVisibilitySettings'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(
                    k,
                    (e as List<dynamic>)
                        .map((e) => (e as num).toInt())
                        .toList()),
              ) ??
              const {},
      setupCompletionStatus:
          (json['setupCompletionStatus'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, e as bool),
              ) ??
              const {},
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'fullName': instance.fullName,
      'avatarUrl': instance.avatarUrl,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'lastActiveAt': instance.lastActiveAt.toIso8601String(),
      'preferredDays': instance.preferredDays,
      'blockedDays': instance.blockedDays,
      'flexibleTaskPreferences': instance.flexibleTaskPreferences,
      'familyIds': instance.familyIds,
      'familyRoles': instance.familyRoles,
      'ownedEntityIds': instance.ownedEntityIds,
      'sharedEntityIds': instance.sharedEntityIds,
      'professionalCategoryIds': instance.professionalCategoryIds,
      'onboardingCompleted': instance.onboardingCompleted,
      'isPremium': instance.isPremium,
      'subscriptionPlanId': instance.subscriptionPlanId,
      'subscriptionExpiresAt':
          instance.subscriptionExpiresAt?.toIso8601String(),
      'notificationPreferences': instance.notificationPreferences,
      'timezone': instance.timezone,
      'locale': instance.locale,
      'emailVerified': instance.emailVerified,
      'phoneVerified': instance.phoneVerified,
      'isActive': instance.isActive,
      'authProvider': instance.authProvider,
      'enabledCategories': instance.enabledCategories,
      'familyVisibilitySettings': instance.familyVisibilitySettings,
      'setupCompletionStatus': instance.setupCompletionStatus,
    };
