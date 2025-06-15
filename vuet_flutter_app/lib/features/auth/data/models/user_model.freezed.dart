// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return _UserModel.fromJson(json);
}

/// @nodoc
mixin _$UserModel {
  /// Unique identifier for the user
  String get id => throw _privateConstructorUsedError;

  /// User's email address (can be null if phone auth is used)
  String? get email => throw _privateConstructorUsedError;

  /// User's phone number (can be null if email auth is used)
  String? get phoneNumber => throw _privateConstructorUsedError;

  /// User's full name
  String get fullName => throw _privateConstructorUsedError;

  /// URL to the user's avatar image
  String? get avatarUrl => throw _privateConstructorUsedError;

  /// When the user was created
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// When the user was last updated
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// When the user was last active
  DateTime get lastActiveAt => throw _privateConstructorUsedError;

  /// User's preferred days for tasks (JSON format)
  List<int> get preferredDays => throw _privateConstructorUsedError;

  /// User's blocked days for tasks (JSON format)
  List<int> get blockedDays => throw _privateConstructorUsedError;

  /// User's preferences for flexible tasks (JSON format)
  Map<String, dynamic> get flexibleTaskPreferences =>
      throw _privateConstructorUsedError;

  /// IDs of families the user belongs to
  List<String> get familyIds => throw _privateConstructorUsedError;

  /// User's role in each family (key: familyId, value: role)
  Map<String, String> get familyRoles => throw _privateConstructorUsedError;

  /// IDs of entities owned by the user
  List<String> get ownedEntityIds => throw _privateConstructorUsedError;

  /// IDs of entities shared with the user
  List<String> get sharedEntityIds => throw _privateConstructorUsedError;

  /// IDs of professional categories created by the user
  List<String> get professionalCategoryIds =>
      throw _privateConstructorUsedError;

  /// Whether the user has completed onboarding
  bool get onboardingCompleted => throw _privateConstructorUsedError;

  /// Whether the user has a premium subscription
  bool get isPremium => throw _privateConstructorUsedError;

  /// User's subscription plan ID (if any)
  String? get subscriptionPlanId => throw _privateConstructorUsedError;

  /// When the user's subscription expires (if any)
  DateTime? get subscriptionExpiresAt => throw _privateConstructorUsedError;

  /// User's notification preferences
  Map<String, bool> get notificationPreferences =>
      throw _privateConstructorUsedError;

  /// User's timezone
  String get timezone => throw _privateConstructorUsedError;

  /// User's locale/language preference
  String get locale => throw _privateConstructorUsedError;

  /// Whether the user's email is verified
  bool get emailVerified => throw _privateConstructorUsedError;

  /// Whether the user's phone number is verified
  bool get phoneVerified => throw _privateConstructorUsedError;

  /// Whether the user's account is active
  bool get isActive => throw _privateConstructorUsedError;

  /// Authentication provider (email, phone, google, apple)
  String get authProvider => throw _privateConstructorUsedError;

  /// Categories that are enabled for this user
  List<int> get enabledCategories => throw _privateConstructorUsedError;

  /// Family visibility settings (what family members can see)
  Map<String, List<int>> get familyVisibilitySettings =>
      throw _privateConstructorUsedError;

  /// Setup completion tracking
  Map<String, bool> get setupCompletionStatus =>
      throw _privateConstructorUsedError;

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserModelCopyWith<UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) then) =
      _$UserModelCopyWithImpl<$Res, UserModel>;
  @useResult
  $Res call(
      {String id,
      String? email,
      String? phoneNumber,
      String fullName,
      String? avatarUrl,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime lastActiveAt,
      List<int> preferredDays,
      List<int> blockedDays,
      Map<String, dynamic> flexibleTaskPreferences,
      List<String> familyIds,
      Map<String, String> familyRoles,
      List<String> ownedEntityIds,
      List<String> sharedEntityIds,
      List<String> professionalCategoryIds,
      bool onboardingCompleted,
      bool isPremium,
      String? subscriptionPlanId,
      DateTime? subscriptionExpiresAt,
      Map<String, bool> notificationPreferences,
      String timezone,
      String locale,
      bool emailVerified,
      bool phoneVerified,
      bool isActive,
      String authProvider,
      List<int> enabledCategories,
      Map<String, List<int>> familyVisibilitySettings,
      Map<String, bool> setupCompletionStatus});
}

/// @nodoc
class _$UserModelCopyWithImpl<$Res, $Val extends UserModel>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = freezed,
    Object? phoneNumber = freezed,
    Object? fullName = null,
    Object? avatarUrl = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? lastActiveAt = null,
    Object? preferredDays = null,
    Object? blockedDays = null,
    Object? flexibleTaskPreferences = null,
    Object? familyIds = null,
    Object? familyRoles = null,
    Object? ownedEntityIds = null,
    Object? sharedEntityIds = null,
    Object? professionalCategoryIds = null,
    Object? onboardingCompleted = null,
    Object? isPremium = null,
    Object? subscriptionPlanId = freezed,
    Object? subscriptionExpiresAt = freezed,
    Object? notificationPreferences = null,
    Object? timezone = null,
    Object? locale = null,
    Object? emailVerified = null,
    Object? phoneVerified = null,
    Object? isActive = null,
    Object? authProvider = null,
    Object? enabledCategories = null,
    Object? familyVisibilitySettings = null,
    Object? setupCompletionStatus = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastActiveAt: null == lastActiveAt
          ? _value.lastActiveAt
          : lastActiveAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      preferredDays: null == preferredDays
          ? _value.preferredDays
          : preferredDays // ignore: cast_nullable_to_non_nullable
              as List<int>,
      blockedDays: null == blockedDays
          ? _value.blockedDays
          : blockedDays // ignore: cast_nullable_to_non_nullable
              as List<int>,
      flexibleTaskPreferences: null == flexibleTaskPreferences
          ? _value.flexibleTaskPreferences
          : flexibleTaskPreferences // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      familyIds: null == familyIds
          ? _value.familyIds
          : familyIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      familyRoles: null == familyRoles
          ? _value.familyRoles
          : familyRoles // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      ownedEntityIds: null == ownedEntityIds
          ? _value.ownedEntityIds
          : ownedEntityIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      sharedEntityIds: null == sharedEntityIds
          ? _value.sharedEntityIds
          : sharedEntityIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      professionalCategoryIds: null == professionalCategoryIds
          ? _value.professionalCategoryIds
          : professionalCategoryIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      onboardingCompleted: null == onboardingCompleted
          ? _value.onboardingCompleted
          : onboardingCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      isPremium: null == isPremium
          ? _value.isPremium
          : isPremium // ignore: cast_nullable_to_non_nullable
              as bool,
      subscriptionPlanId: freezed == subscriptionPlanId
          ? _value.subscriptionPlanId
          : subscriptionPlanId // ignore: cast_nullable_to_non_nullable
              as String?,
      subscriptionExpiresAt: freezed == subscriptionExpiresAt
          ? _value.subscriptionExpiresAt
          : subscriptionExpiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notificationPreferences: null == notificationPreferences
          ? _value.notificationPreferences
          : notificationPreferences // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>,
      timezone: null == timezone
          ? _value.timezone
          : timezone // ignore: cast_nullable_to_non_nullable
              as String,
      locale: null == locale
          ? _value.locale
          : locale // ignore: cast_nullable_to_non_nullable
              as String,
      emailVerified: null == emailVerified
          ? _value.emailVerified
          : emailVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      phoneVerified: null == phoneVerified
          ? _value.phoneVerified
          : phoneVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      authProvider: null == authProvider
          ? _value.authProvider
          : authProvider // ignore: cast_nullable_to_non_nullable
              as String,
      enabledCategories: null == enabledCategories
          ? _value.enabledCategories
          : enabledCategories // ignore: cast_nullable_to_non_nullable
              as List<int>,
      familyVisibilitySettings: null == familyVisibilitySettings
          ? _value.familyVisibilitySettings
          : familyVisibilitySettings // ignore: cast_nullable_to_non_nullable
              as Map<String, List<int>>,
      setupCompletionStatus: null == setupCompletionStatus
          ? _value.setupCompletionStatus
          : setupCompletionStatus // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserModelImplCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$$UserModelImplCopyWith(
          _$UserModelImpl value, $Res Function(_$UserModelImpl) then) =
      __$$UserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String? email,
      String? phoneNumber,
      String fullName,
      String? avatarUrl,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime lastActiveAt,
      List<int> preferredDays,
      List<int> blockedDays,
      Map<String, dynamic> flexibleTaskPreferences,
      List<String> familyIds,
      Map<String, String> familyRoles,
      List<String> ownedEntityIds,
      List<String> sharedEntityIds,
      List<String> professionalCategoryIds,
      bool onboardingCompleted,
      bool isPremium,
      String? subscriptionPlanId,
      DateTime? subscriptionExpiresAt,
      Map<String, bool> notificationPreferences,
      String timezone,
      String locale,
      bool emailVerified,
      bool phoneVerified,
      bool isActive,
      String authProvider,
      List<int> enabledCategories,
      Map<String, List<int>> familyVisibilitySettings,
      Map<String, bool> setupCompletionStatus});
}

/// @nodoc
class __$$UserModelImplCopyWithImpl<$Res>
    extends _$UserModelCopyWithImpl<$Res, _$UserModelImpl>
    implements _$$UserModelImplCopyWith<$Res> {
  __$$UserModelImplCopyWithImpl(
      _$UserModelImpl _value, $Res Function(_$UserModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = freezed,
    Object? phoneNumber = freezed,
    Object? fullName = null,
    Object? avatarUrl = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? lastActiveAt = null,
    Object? preferredDays = null,
    Object? blockedDays = null,
    Object? flexibleTaskPreferences = null,
    Object? familyIds = null,
    Object? familyRoles = null,
    Object? ownedEntityIds = null,
    Object? sharedEntityIds = null,
    Object? professionalCategoryIds = null,
    Object? onboardingCompleted = null,
    Object? isPremium = null,
    Object? subscriptionPlanId = freezed,
    Object? subscriptionExpiresAt = freezed,
    Object? notificationPreferences = null,
    Object? timezone = null,
    Object? locale = null,
    Object? emailVerified = null,
    Object? phoneVerified = null,
    Object? isActive = null,
    Object? authProvider = null,
    Object? enabledCategories = null,
    Object? familyVisibilitySettings = null,
    Object? setupCompletionStatus = null,
  }) {
    return _then(_$UserModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastActiveAt: null == lastActiveAt
          ? _value.lastActiveAt
          : lastActiveAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      preferredDays: null == preferredDays
          ? _value._preferredDays
          : preferredDays // ignore: cast_nullable_to_non_nullable
              as List<int>,
      blockedDays: null == blockedDays
          ? _value._blockedDays
          : blockedDays // ignore: cast_nullable_to_non_nullable
              as List<int>,
      flexibleTaskPreferences: null == flexibleTaskPreferences
          ? _value._flexibleTaskPreferences
          : flexibleTaskPreferences // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      familyIds: null == familyIds
          ? _value._familyIds
          : familyIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      familyRoles: null == familyRoles
          ? _value._familyRoles
          : familyRoles // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      ownedEntityIds: null == ownedEntityIds
          ? _value._ownedEntityIds
          : ownedEntityIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      sharedEntityIds: null == sharedEntityIds
          ? _value._sharedEntityIds
          : sharedEntityIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      professionalCategoryIds: null == professionalCategoryIds
          ? _value._professionalCategoryIds
          : professionalCategoryIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      onboardingCompleted: null == onboardingCompleted
          ? _value.onboardingCompleted
          : onboardingCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      isPremium: null == isPremium
          ? _value.isPremium
          : isPremium // ignore: cast_nullable_to_non_nullable
              as bool,
      subscriptionPlanId: freezed == subscriptionPlanId
          ? _value.subscriptionPlanId
          : subscriptionPlanId // ignore: cast_nullable_to_non_nullable
              as String?,
      subscriptionExpiresAt: freezed == subscriptionExpiresAt
          ? _value.subscriptionExpiresAt
          : subscriptionExpiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notificationPreferences: null == notificationPreferences
          ? _value._notificationPreferences
          : notificationPreferences // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>,
      timezone: null == timezone
          ? _value.timezone
          : timezone // ignore: cast_nullable_to_non_nullable
              as String,
      locale: null == locale
          ? _value.locale
          : locale // ignore: cast_nullable_to_non_nullable
              as String,
      emailVerified: null == emailVerified
          ? _value.emailVerified
          : emailVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      phoneVerified: null == phoneVerified
          ? _value.phoneVerified
          : phoneVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      authProvider: null == authProvider
          ? _value.authProvider
          : authProvider // ignore: cast_nullable_to_non_nullable
              as String,
      enabledCategories: null == enabledCategories
          ? _value._enabledCategories
          : enabledCategories // ignore: cast_nullable_to_non_nullable
              as List<int>,
      familyVisibilitySettings: null == familyVisibilitySettings
          ? _value._familyVisibilitySettings
          : familyVisibilitySettings // ignore: cast_nullable_to_non_nullable
              as Map<String, List<int>>,
      setupCompletionStatus: null == setupCompletionStatus
          ? _value._setupCompletionStatus
          : setupCompletionStatus // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserModelImpl extends _UserModel with DiagnosticableTreeMixin {
  const _$UserModelImpl(
      {required this.id,
      this.email,
      this.phoneNumber,
      required this.fullName,
      this.avatarUrl,
      required this.createdAt,
      required this.updatedAt,
      required this.lastActiveAt,
      final List<int> preferredDays = const [],
      final List<int> blockedDays = const [],
      final Map<String, dynamic> flexibleTaskPreferences = const {},
      final List<String> familyIds = const [],
      final Map<String, String> familyRoles = const {},
      final List<String> ownedEntityIds = const [],
      final List<String> sharedEntityIds = const [],
      final List<String> professionalCategoryIds = const [],
      this.onboardingCompleted = false,
      this.isPremium = false,
      this.subscriptionPlanId,
      this.subscriptionExpiresAt,
      final Map<String, bool> notificationPreferences = const {},
      this.timezone = 'UTC',
      this.locale = 'en_US',
      this.emailVerified = false,
      this.phoneVerified = false,
      this.isActive = true,
      this.authProvider = 'email',
      final List<int> enabledCategories = const [
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10,
        11,
        12,
        13
      ],
      final Map<String, List<int>> familyVisibilitySettings = const {},
      final Map<String, bool> setupCompletionStatus = const {}})
      : _preferredDays = preferredDays,
        _blockedDays = blockedDays,
        _flexibleTaskPreferences = flexibleTaskPreferences,
        _familyIds = familyIds,
        _familyRoles = familyRoles,
        _ownedEntityIds = ownedEntityIds,
        _sharedEntityIds = sharedEntityIds,
        _professionalCategoryIds = professionalCategoryIds,
        _notificationPreferences = notificationPreferences,
        _enabledCategories = enabledCategories,
        _familyVisibilitySettings = familyVisibilitySettings,
        _setupCompletionStatus = setupCompletionStatus,
        super._();

  factory _$UserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserModelImplFromJson(json);

  /// Unique identifier for the user
  @override
  final String id;

  /// User's email address (can be null if phone auth is used)
  @override
  final String? email;

  /// User's phone number (can be null if email auth is used)
  @override
  final String? phoneNumber;

  /// User's full name
  @override
  final String fullName;

  /// URL to the user's avatar image
  @override
  final String? avatarUrl;

  /// When the user was created
  @override
  final DateTime createdAt;

  /// When the user was last updated
  @override
  final DateTime updatedAt;

  /// When the user was last active
  @override
  final DateTime lastActiveAt;

  /// User's preferred days for tasks (JSON format)
  final List<int> _preferredDays;

  /// User's preferred days for tasks (JSON format)
  @override
  @JsonKey()
  List<int> get preferredDays {
    if (_preferredDays is EqualUnmodifiableListView) return _preferredDays;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_preferredDays);
  }

  /// User's blocked days for tasks (JSON format)
  final List<int> _blockedDays;

  /// User's blocked days for tasks (JSON format)
  @override
  @JsonKey()
  List<int> get blockedDays {
    if (_blockedDays is EqualUnmodifiableListView) return _blockedDays;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_blockedDays);
  }

  /// User's preferences for flexible tasks (JSON format)
  final Map<String, dynamic> _flexibleTaskPreferences;

  /// User's preferences for flexible tasks (JSON format)
  @override
  @JsonKey()
  Map<String, dynamic> get flexibleTaskPreferences {
    if (_flexibleTaskPreferences is EqualUnmodifiableMapView)
      return _flexibleTaskPreferences;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_flexibleTaskPreferences);
  }

  /// IDs of families the user belongs to
  final List<String> _familyIds;

  /// IDs of families the user belongs to
  @override
  @JsonKey()
  List<String> get familyIds {
    if (_familyIds is EqualUnmodifiableListView) return _familyIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_familyIds);
  }

  /// User's role in each family (key: familyId, value: role)
  final Map<String, String> _familyRoles;

  /// User's role in each family (key: familyId, value: role)
  @override
  @JsonKey()
  Map<String, String> get familyRoles {
    if (_familyRoles is EqualUnmodifiableMapView) return _familyRoles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_familyRoles);
  }

  /// IDs of entities owned by the user
  final List<String> _ownedEntityIds;

  /// IDs of entities owned by the user
  @override
  @JsonKey()
  List<String> get ownedEntityIds {
    if (_ownedEntityIds is EqualUnmodifiableListView) return _ownedEntityIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ownedEntityIds);
  }

  /// IDs of entities shared with the user
  final List<String> _sharedEntityIds;

  /// IDs of entities shared with the user
  @override
  @JsonKey()
  List<String> get sharedEntityIds {
    if (_sharedEntityIds is EqualUnmodifiableListView) return _sharedEntityIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sharedEntityIds);
  }

  /// IDs of professional categories created by the user
  final List<String> _professionalCategoryIds;

  /// IDs of professional categories created by the user
  @override
  @JsonKey()
  List<String> get professionalCategoryIds {
    if (_professionalCategoryIds is EqualUnmodifiableListView)
      return _professionalCategoryIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_professionalCategoryIds);
  }

  /// Whether the user has completed onboarding
  @override
  @JsonKey()
  final bool onboardingCompleted;

  /// Whether the user has a premium subscription
  @override
  @JsonKey()
  final bool isPremium;

  /// User's subscription plan ID (if any)
  @override
  final String? subscriptionPlanId;

  /// When the user's subscription expires (if any)
  @override
  final DateTime? subscriptionExpiresAt;

  /// User's notification preferences
  final Map<String, bool> _notificationPreferences;

  /// User's notification preferences
  @override
  @JsonKey()
  Map<String, bool> get notificationPreferences {
    if (_notificationPreferences is EqualUnmodifiableMapView)
      return _notificationPreferences;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_notificationPreferences);
  }

  /// User's timezone
  @override
  @JsonKey()
  final String timezone;

  /// User's locale/language preference
  @override
  @JsonKey()
  final String locale;

  /// Whether the user's email is verified
  @override
  @JsonKey()
  final bool emailVerified;

  /// Whether the user's phone number is verified
  @override
  @JsonKey()
  final bool phoneVerified;

  /// Whether the user's account is active
  @override
  @JsonKey()
  final bool isActive;

  /// Authentication provider (email, phone, google, apple)
  @override
  @JsonKey()
  final String authProvider;

  /// Categories that are enabled for this user
  final List<int> _enabledCategories;

  /// Categories that are enabled for this user
  @override
  @JsonKey()
  List<int> get enabledCategories {
    if (_enabledCategories is EqualUnmodifiableListView)
      return _enabledCategories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_enabledCategories);
  }

  /// Family visibility settings (what family members can see)
  final Map<String, List<int>> _familyVisibilitySettings;

  /// Family visibility settings (what family members can see)
  @override
  @JsonKey()
  Map<String, List<int>> get familyVisibilitySettings {
    if (_familyVisibilitySettings is EqualUnmodifiableMapView)
      return _familyVisibilitySettings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_familyVisibilitySettings);
  }

  /// Setup completion tracking
  final Map<String, bool> _setupCompletionStatus;

  /// Setup completion tracking
  @override
  @JsonKey()
  Map<String, bool> get setupCompletionStatus {
    if (_setupCompletionStatus is EqualUnmodifiableMapView)
      return _setupCompletionStatus;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_setupCompletionStatus);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'UserModel(id: $id, email: $email, phoneNumber: $phoneNumber, fullName: $fullName, avatarUrl: $avatarUrl, createdAt: $createdAt, updatedAt: $updatedAt, lastActiveAt: $lastActiveAt, preferredDays: $preferredDays, blockedDays: $blockedDays, flexibleTaskPreferences: $flexibleTaskPreferences, familyIds: $familyIds, familyRoles: $familyRoles, ownedEntityIds: $ownedEntityIds, sharedEntityIds: $sharedEntityIds, professionalCategoryIds: $professionalCategoryIds, onboardingCompleted: $onboardingCompleted, isPremium: $isPremium, subscriptionPlanId: $subscriptionPlanId, subscriptionExpiresAt: $subscriptionExpiresAt, notificationPreferences: $notificationPreferences, timezone: $timezone, locale: $locale, emailVerified: $emailVerified, phoneVerified: $phoneVerified, isActive: $isActive, authProvider: $authProvider, enabledCategories: $enabledCategories, familyVisibilitySettings: $familyVisibilitySettings, setupCompletionStatus: $setupCompletionStatus)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'UserModel'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('email', email))
      ..add(DiagnosticsProperty('phoneNumber', phoneNumber))
      ..add(DiagnosticsProperty('fullName', fullName))
      ..add(DiagnosticsProperty('avatarUrl', avatarUrl))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('updatedAt', updatedAt))
      ..add(DiagnosticsProperty('lastActiveAt', lastActiveAt))
      ..add(DiagnosticsProperty('preferredDays', preferredDays))
      ..add(DiagnosticsProperty('blockedDays', blockedDays))
      ..add(DiagnosticsProperty(
          'flexibleTaskPreferences', flexibleTaskPreferences))
      ..add(DiagnosticsProperty('familyIds', familyIds))
      ..add(DiagnosticsProperty('familyRoles', familyRoles))
      ..add(DiagnosticsProperty('ownedEntityIds', ownedEntityIds))
      ..add(DiagnosticsProperty('sharedEntityIds', sharedEntityIds))
      ..add(DiagnosticsProperty(
          'professionalCategoryIds', professionalCategoryIds))
      ..add(DiagnosticsProperty('onboardingCompleted', onboardingCompleted))
      ..add(DiagnosticsProperty('isPremium', isPremium))
      ..add(DiagnosticsProperty('subscriptionPlanId', subscriptionPlanId))
      ..add(DiagnosticsProperty('subscriptionExpiresAt', subscriptionExpiresAt))
      ..add(DiagnosticsProperty(
          'notificationPreferences', notificationPreferences))
      ..add(DiagnosticsProperty('timezone', timezone))
      ..add(DiagnosticsProperty('locale', locale))
      ..add(DiagnosticsProperty('emailVerified', emailVerified))
      ..add(DiagnosticsProperty('phoneVerified', phoneVerified))
      ..add(DiagnosticsProperty('isActive', isActive))
      ..add(DiagnosticsProperty('authProvider', authProvider))
      ..add(DiagnosticsProperty('enabledCategories', enabledCategories))
      ..add(DiagnosticsProperty(
          'familyVisibilitySettings', familyVisibilitySettings))
      ..add(
          DiagnosticsProperty('setupCompletionStatus', setupCompletionStatus));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.lastActiveAt, lastActiveAt) ||
                other.lastActiveAt == lastActiveAt) &&
            const DeepCollectionEquality()
                .equals(other._preferredDays, _preferredDays) &&
            const DeepCollectionEquality()
                .equals(other._blockedDays, _blockedDays) &&
            const DeepCollectionEquality().equals(
                other._flexibleTaskPreferences, _flexibleTaskPreferences) &&
            const DeepCollectionEquality()
                .equals(other._familyIds, _familyIds) &&
            const DeepCollectionEquality()
                .equals(other._familyRoles, _familyRoles) &&
            const DeepCollectionEquality()
                .equals(other._ownedEntityIds, _ownedEntityIds) &&
            const DeepCollectionEquality()
                .equals(other._sharedEntityIds, _sharedEntityIds) &&
            const DeepCollectionEquality().equals(
                other._professionalCategoryIds, _professionalCategoryIds) &&
            (identical(other.onboardingCompleted, onboardingCompleted) ||
                other.onboardingCompleted == onboardingCompleted) &&
            (identical(other.isPremium, isPremium) ||
                other.isPremium == isPremium) &&
            (identical(other.subscriptionPlanId, subscriptionPlanId) ||
                other.subscriptionPlanId == subscriptionPlanId) &&
            (identical(other.subscriptionExpiresAt, subscriptionExpiresAt) ||
                other.subscriptionExpiresAt == subscriptionExpiresAt) &&
            const DeepCollectionEquality().equals(
                other._notificationPreferences, _notificationPreferences) &&
            (identical(other.timezone, timezone) ||
                other.timezone == timezone) &&
            (identical(other.locale, locale) || other.locale == locale) &&
            (identical(other.emailVerified, emailVerified) ||
                other.emailVerified == emailVerified) &&
            (identical(other.phoneVerified, phoneVerified) ||
                other.phoneVerified == phoneVerified) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.authProvider, authProvider) ||
                other.authProvider == authProvider) &&
            const DeepCollectionEquality()
                .equals(other._enabledCategories, _enabledCategories) &&
            const DeepCollectionEquality().equals(
                other._familyVisibilitySettings, _familyVisibilitySettings) &&
            const DeepCollectionEquality()
                .equals(other._setupCompletionStatus, _setupCompletionStatus));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        email,
        phoneNumber,
        fullName,
        avatarUrl,
        createdAt,
        updatedAt,
        lastActiveAt,
        const DeepCollectionEquality().hash(_preferredDays),
        const DeepCollectionEquality().hash(_blockedDays),
        const DeepCollectionEquality().hash(_flexibleTaskPreferences),
        const DeepCollectionEquality().hash(_familyIds),
        const DeepCollectionEquality().hash(_familyRoles),
        const DeepCollectionEquality().hash(_ownedEntityIds),
        const DeepCollectionEquality().hash(_sharedEntityIds),
        const DeepCollectionEquality().hash(_professionalCategoryIds),
        onboardingCompleted,
        isPremium,
        subscriptionPlanId,
        subscriptionExpiresAt,
        const DeepCollectionEquality().hash(_notificationPreferences),
        timezone,
        locale,
        emailVerified,
        phoneVerified,
        isActive,
        authProvider,
        const DeepCollectionEquality().hash(_enabledCategories),
        const DeepCollectionEquality().hash(_familyVisibilitySettings),
        const DeepCollectionEquality().hash(_setupCompletionStatus)
      ]);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      __$$UserModelImplCopyWithImpl<_$UserModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserModelImplToJson(
      this,
    );
  }
}

abstract class _UserModel extends UserModel {
  const factory _UserModel(
      {required final String id,
      final String? email,
      final String? phoneNumber,
      required final String fullName,
      final String? avatarUrl,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      required final DateTime lastActiveAt,
      final List<int> preferredDays,
      final List<int> blockedDays,
      final Map<String, dynamic> flexibleTaskPreferences,
      final List<String> familyIds,
      final Map<String, String> familyRoles,
      final List<String> ownedEntityIds,
      final List<String> sharedEntityIds,
      final List<String> professionalCategoryIds,
      final bool onboardingCompleted,
      final bool isPremium,
      final String? subscriptionPlanId,
      final DateTime? subscriptionExpiresAt,
      final Map<String, bool> notificationPreferences,
      final String timezone,
      final String locale,
      final bool emailVerified,
      final bool phoneVerified,
      final bool isActive,
      final String authProvider,
      final List<int> enabledCategories,
      final Map<String, List<int>> familyVisibilitySettings,
      final Map<String, bool> setupCompletionStatus}) = _$UserModelImpl;
  const _UserModel._() : super._();

  factory _UserModel.fromJson(Map<String, dynamic> json) =
      _$UserModelImpl.fromJson;

  /// Unique identifier for the user
  @override
  String get id;

  /// User's email address (can be null if phone auth is used)
  @override
  String? get email;

  /// User's phone number (can be null if email auth is used)
  @override
  String? get phoneNumber;

  /// User's full name
  @override
  String get fullName;

  /// URL to the user's avatar image
  @override
  String? get avatarUrl;

  /// When the user was created
  @override
  DateTime get createdAt;

  /// When the user was last updated
  @override
  DateTime get updatedAt;

  /// When the user was last active
  @override
  DateTime get lastActiveAt;

  /// User's preferred days for tasks (JSON format)
  @override
  List<int> get preferredDays;

  /// User's blocked days for tasks (JSON format)
  @override
  List<int> get blockedDays;

  /// User's preferences for flexible tasks (JSON format)
  @override
  Map<String, dynamic> get flexibleTaskPreferences;

  /// IDs of families the user belongs to
  @override
  List<String> get familyIds;

  /// User's role in each family (key: familyId, value: role)
  @override
  Map<String, String> get familyRoles;

  /// IDs of entities owned by the user
  @override
  List<String> get ownedEntityIds;

  /// IDs of entities shared with the user
  @override
  List<String> get sharedEntityIds;

  /// IDs of professional categories created by the user
  @override
  List<String> get professionalCategoryIds;

  /// Whether the user has completed onboarding
  @override
  bool get onboardingCompleted;

  /// Whether the user has a premium subscription
  @override
  bool get isPremium;

  /// User's subscription plan ID (if any)
  @override
  String? get subscriptionPlanId;

  /// When the user's subscription expires (if any)
  @override
  DateTime? get subscriptionExpiresAt;

  /// User's notification preferences
  @override
  Map<String, bool> get notificationPreferences;

  /// User's timezone
  @override
  String get timezone;

  /// User's locale/language preference
  @override
  String get locale;

  /// Whether the user's email is verified
  @override
  bool get emailVerified;

  /// Whether the user's phone number is verified
  @override
  bool get phoneVerified;

  /// Whether the user's account is active
  @override
  bool get isActive;

  /// Authentication provider (email, phone, google, apple)
  @override
  String get authProvider;

  /// Categories that are enabled for this user
  @override
  List<int> get enabledCategories;

  /// Family visibility settings (what family members can see)
  @override
  Map<String, List<int>> get familyVisibilitySettings;

  /// Setup completion tracking
  @override
  Map<String, bool> get setupCompletionStatus;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
