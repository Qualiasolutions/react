// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'entity_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

EntityModel _$EntityModelFromJson(Map<String, dynamic> json) {
  return _EntityModel.fromJson(json);
}

/// @nodoc
mixin _$EntityModel {
  String get id => throw _privateConstructorUsedError;
  String get ownerId => throw _privateConstructorUsedError;
  int get categoryId => throw _privateConstructorUsedError;
  EntityType get type => throw _privateConstructorUsedError;
  String? get subtype => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get notes => throw _privateConstructorUsedError;
  String? get imagePath => throw _privateConstructorUsedError;
  bool get hidden => throw _privateConstructorUsedError;
  String? get parentId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt =>
      throw _privateConstructorUsedError; // JSON fields for specialized entity data
  Map<String, dynamic>? get dates => throw _privateConstructorUsedError;
  Map<String, dynamic>? get contactInfo => throw _privateConstructorUsedError;
  Map<String, dynamic>? get location => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata =>
      throw _privateConstructorUsedError; // Relationships (not stored in DB, populated by app)
  List<String> get memberIds => throw _privateConstructorUsedError;

  /// Serializes this EntityModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EntityModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EntityModelCopyWith<EntityModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EntityModelCopyWith<$Res> {
  factory $EntityModelCopyWith(
          EntityModel value, $Res Function(EntityModel) then) =
      _$EntityModelCopyWithImpl<$Res, EntityModel>;
  @useResult
  $Res call(
      {String id,
      String ownerId,
      int categoryId,
      EntityType type,
      String? subtype,
      String name,
      String notes,
      String? imagePath,
      bool hidden,
      String? parentId,
      DateTime createdAt,
      DateTime updatedAt,
      Map<String, dynamic>? dates,
      Map<String, dynamic>? contactInfo,
      Map<String, dynamic>? location,
      Map<String, dynamic>? metadata,
      List<String> memberIds});
}

/// @nodoc
class _$EntityModelCopyWithImpl<$Res, $Val extends EntityModel>
    implements $EntityModelCopyWith<$Res> {
  _$EntityModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EntityModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ownerId = null,
    Object? categoryId = null,
    Object? type = null,
    Object? subtype = freezed,
    Object? name = null,
    Object? notes = null,
    Object? imagePath = freezed,
    Object? hidden = null,
    Object? parentId = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? dates = freezed,
    Object? contactInfo = freezed,
    Object? location = freezed,
    Object? metadata = freezed,
    Object? memberIds = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      ownerId: null == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as EntityType,
      subtype: freezed == subtype
          ? _value.subtype
          : subtype // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      notes: null == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
      imagePath: freezed == imagePath
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as String?,
      hidden: null == hidden
          ? _value.hidden
          : hidden // ignore: cast_nullable_to_non_nullable
              as bool,
      parentId: freezed == parentId
          ? _value.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      dates: freezed == dates
          ? _value.dates
          : dates // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      contactInfo: freezed == contactInfo
          ? _value.contactInfo
          : contactInfo // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      memberIds: null == memberIds
          ? _value.memberIds
          : memberIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EntityModelImplCopyWith<$Res>
    implements $EntityModelCopyWith<$Res> {
  factory _$$EntityModelImplCopyWith(
          _$EntityModelImpl value, $Res Function(_$EntityModelImpl) then) =
      __$$EntityModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String ownerId,
      int categoryId,
      EntityType type,
      String? subtype,
      String name,
      String notes,
      String? imagePath,
      bool hidden,
      String? parentId,
      DateTime createdAt,
      DateTime updatedAt,
      Map<String, dynamic>? dates,
      Map<String, dynamic>? contactInfo,
      Map<String, dynamic>? location,
      Map<String, dynamic>? metadata,
      List<String> memberIds});
}

/// @nodoc
class __$$EntityModelImplCopyWithImpl<$Res>
    extends _$EntityModelCopyWithImpl<$Res, _$EntityModelImpl>
    implements _$$EntityModelImplCopyWith<$Res> {
  __$$EntityModelImplCopyWithImpl(
      _$EntityModelImpl _value, $Res Function(_$EntityModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of EntityModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ownerId = null,
    Object? categoryId = null,
    Object? type = null,
    Object? subtype = freezed,
    Object? name = null,
    Object? notes = null,
    Object? imagePath = freezed,
    Object? hidden = null,
    Object? parentId = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? dates = freezed,
    Object? contactInfo = freezed,
    Object? location = freezed,
    Object? metadata = freezed,
    Object? memberIds = null,
  }) {
    return _then(_$EntityModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      ownerId: null == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as EntityType,
      subtype: freezed == subtype
          ? _value.subtype
          : subtype // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      notes: null == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
      imagePath: freezed == imagePath
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as String?,
      hidden: null == hidden
          ? _value.hidden
          : hidden // ignore: cast_nullable_to_non_nullable
              as bool,
      parentId: freezed == parentId
          ? _value.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      dates: freezed == dates
          ? _value._dates
          : dates // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      contactInfo: freezed == contactInfo
          ? _value._contactInfo
          : contactInfo // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      location: freezed == location
          ? _value._location
          : location // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      memberIds: null == memberIds
          ? _value._memberIds
          : memberIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$EntityModelImpl extends _EntityModel with DiagnosticableTreeMixin {
  const _$EntityModelImpl(
      {required this.id,
      required this.ownerId,
      required this.categoryId,
      required this.type,
      this.subtype,
      required this.name,
      this.notes = '',
      this.imagePath,
      this.hidden = false,
      this.parentId,
      required this.createdAt,
      required this.updatedAt,
      final Map<String, dynamic>? dates,
      final Map<String, dynamic>? contactInfo,
      final Map<String, dynamic>? location,
      final Map<String, dynamic>? metadata,
      final List<String> memberIds = const []})
      : _dates = dates,
        _contactInfo = contactInfo,
        _location = location,
        _metadata = metadata,
        _memberIds = memberIds,
        super._();

  factory _$EntityModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$EntityModelImplFromJson(json);

  @override
  final String id;
  @override
  final String ownerId;
  @override
  final int categoryId;
  @override
  final EntityType type;
  @override
  final String? subtype;
  @override
  final String name;
  @override
  @JsonKey()
  final String notes;
  @override
  final String? imagePath;
  @override
  @JsonKey()
  final bool hidden;
  @override
  final String? parentId;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
// JSON fields for specialized entity data
  final Map<String, dynamic>? _dates;
// JSON fields for specialized entity data
  @override
  Map<String, dynamic>? get dates {
    final value = _dates;
    if (value == null) return null;
    if (_dates is EqualUnmodifiableMapView) return _dates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _contactInfo;
  @override
  Map<String, dynamic>? get contactInfo {
    final value = _contactInfo;
    if (value == null) return null;
    if (_contactInfo is EqualUnmodifiableMapView) return _contactInfo;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _location;
  @override
  Map<String, dynamic>? get location {
    final value = _location;
    if (value == null) return null;
    if (_location is EqualUnmodifiableMapView) return _location;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

// Relationships (not stored in DB, populated by app)
  final List<String> _memberIds;
// Relationships (not stored in DB, populated by app)
  @override
  @JsonKey()
  List<String> get memberIds {
    if (_memberIds is EqualUnmodifiableListView) return _memberIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_memberIds);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'EntityModel(id: $id, ownerId: $ownerId, categoryId: $categoryId, type: $type, subtype: $subtype, name: $name, notes: $notes, imagePath: $imagePath, hidden: $hidden, parentId: $parentId, createdAt: $createdAt, updatedAt: $updatedAt, dates: $dates, contactInfo: $contactInfo, location: $location, metadata: $metadata, memberIds: $memberIds)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'EntityModel'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('ownerId', ownerId))
      ..add(DiagnosticsProperty('categoryId', categoryId))
      ..add(DiagnosticsProperty('type', type))
      ..add(DiagnosticsProperty('subtype', subtype))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('notes', notes))
      ..add(DiagnosticsProperty('imagePath', imagePath))
      ..add(DiagnosticsProperty('hidden', hidden))
      ..add(DiagnosticsProperty('parentId', parentId))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('updatedAt', updatedAt))
      ..add(DiagnosticsProperty('dates', dates))
      ..add(DiagnosticsProperty('contactInfo', contactInfo))
      ..add(DiagnosticsProperty('location', location))
      ..add(DiagnosticsProperty('metadata', metadata))
      ..add(DiagnosticsProperty('memberIds', memberIds));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EntityModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.subtype, subtype) || other.subtype == subtype) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath) &&
            (identical(other.hidden, hidden) || other.hidden == hidden) &&
            (identical(other.parentId, parentId) ||
                other.parentId == parentId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(other._dates, _dates) &&
            const DeepCollectionEquality()
                .equals(other._contactInfo, _contactInfo) &&
            const DeepCollectionEquality().equals(other._location, _location) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            const DeepCollectionEquality()
                .equals(other._memberIds, _memberIds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      ownerId,
      categoryId,
      type,
      subtype,
      name,
      notes,
      imagePath,
      hidden,
      parentId,
      createdAt,
      updatedAt,
      const DeepCollectionEquality().hash(_dates),
      const DeepCollectionEquality().hash(_contactInfo),
      const DeepCollectionEquality().hash(_location),
      const DeepCollectionEquality().hash(_metadata),
      const DeepCollectionEquality().hash(_memberIds));

  /// Create a copy of EntityModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EntityModelImplCopyWith<_$EntityModelImpl> get copyWith =>
      __$$EntityModelImplCopyWithImpl<_$EntityModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EntityModelImplToJson(
      this,
    );
  }
}

abstract class _EntityModel extends EntityModel {
  const factory _EntityModel(
      {required final String id,
      required final String ownerId,
      required final int categoryId,
      required final EntityType type,
      final String? subtype,
      required final String name,
      final String notes,
      final String? imagePath,
      final bool hidden,
      final String? parentId,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final Map<String, dynamic>? dates,
      final Map<String, dynamic>? contactInfo,
      final Map<String, dynamic>? location,
      final Map<String, dynamic>? metadata,
      final List<String> memberIds}) = _$EntityModelImpl;
  const _EntityModel._() : super._();

  factory _EntityModel.fromJson(Map<String, dynamic> json) =
      _$EntityModelImpl.fromJson;

  @override
  String get id;
  @override
  String get ownerId;
  @override
  int get categoryId;
  @override
  EntityType get type;
  @override
  String? get subtype;
  @override
  String get name;
  @override
  String get notes;
  @override
  String? get imagePath;
  @override
  bool get hidden;
  @override
  String? get parentId;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt; // JSON fields for specialized entity data
  @override
  Map<String, dynamic>? get dates;
  @override
  Map<String, dynamic>? get contactInfo;
  @override
  Map<String, dynamic>? get location;
  @override
  Map<String, dynamic>?
      get metadata; // Relationships (not stored in DB, populated by app)
  @override
  List<String> get memberIds;

  /// Create a copy of EntityModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EntityModelImplCopyWith<_$EntityModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EntityMember _$EntityMemberFromJson(Map<String, dynamic> json) {
  return _EntityMember.fromJson(json);
}

/// @nodoc
mixin _$EntityMember {
  String get entityId => throw _privateConstructorUsedError;
  String get memberId => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;
  DateTime get addedAt => throw _privateConstructorUsedError;

  /// Serializes this EntityMember to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EntityMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EntityMemberCopyWith<EntityMember> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EntityMemberCopyWith<$Res> {
  factory $EntityMemberCopyWith(
          EntityMember value, $Res Function(EntityMember) then) =
      _$EntityMemberCopyWithImpl<$Res, EntityMember>;
  @useResult
  $Res call({String entityId, String memberId, String role, DateTime addedAt});
}

/// @nodoc
class _$EntityMemberCopyWithImpl<$Res, $Val extends EntityMember>
    implements $EntityMemberCopyWith<$Res> {
  _$EntityMemberCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EntityMember
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? entityId = null,
    Object? memberId = null,
    Object? role = null,
    Object? addedAt = null,
  }) {
    return _then(_value.copyWith(
      entityId: null == entityId
          ? _value.entityId
          : entityId // ignore: cast_nullable_to_non_nullable
              as String,
      memberId: null == memberId
          ? _value.memberId
          : memberId // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      addedAt: null == addedAt
          ? _value.addedAt
          : addedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EntityMemberImplCopyWith<$Res>
    implements $EntityMemberCopyWith<$Res> {
  factory _$$EntityMemberImplCopyWith(
          _$EntityMemberImpl value, $Res Function(_$EntityMemberImpl) then) =
      __$$EntityMemberImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String entityId, String memberId, String role, DateTime addedAt});
}

/// @nodoc
class __$$EntityMemberImplCopyWithImpl<$Res>
    extends _$EntityMemberCopyWithImpl<$Res, _$EntityMemberImpl>
    implements _$$EntityMemberImplCopyWith<$Res> {
  __$$EntityMemberImplCopyWithImpl(
      _$EntityMemberImpl _value, $Res Function(_$EntityMemberImpl) _then)
      : super(_value, _then);

  /// Create a copy of EntityMember
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? entityId = null,
    Object? memberId = null,
    Object? role = null,
    Object? addedAt = null,
  }) {
    return _then(_$EntityMemberImpl(
      entityId: null == entityId
          ? _value.entityId
          : entityId // ignore: cast_nullable_to_non_nullable
              as String,
      memberId: null == memberId
          ? _value.memberId
          : memberId // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      addedAt: null == addedAt
          ? _value.addedAt
          : addedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EntityMemberImpl with DiagnosticableTreeMixin implements _EntityMember {
  const _$EntityMemberImpl(
      {required this.entityId,
      required this.memberId,
      this.role = 'VIEWER',
      required this.addedAt});

  factory _$EntityMemberImpl.fromJson(Map<String, dynamic> json) =>
      _$$EntityMemberImplFromJson(json);

  @override
  final String entityId;
  @override
  final String memberId;
  @override
  @JsonKey()
  final String role;
  @override
  final DateTime addedAt;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'EntityMember(entityId: $entityId, memberId: $memberId, role: $role, addedAt: $addedAt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'EntityMember'))
      ..add(DiagnosticsProperty('entityId', entityId))
      ..add(DiagnosticsProperty('memberId', memberId))
      ..add(DiagnosticsProperty('role', role))
      ..add(DiagnosticsProperty('addedAt', addedAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EntityMemberImpl &&
            (identical(other.entityId, entityId) ||
                other.entityId == entityId) &&
            (identical(other.memberId, memberId) ||
                other.memberId == memberId) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.addedAt, addedAt) || other.addedAt == addedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, entityId, memberId, role, addedAt);

  /// Create a copy of EntityMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EntityMemberImplCopyWith<_$EntityMemberImpl> get copyWith =>
      __$$EntityMemberImplCopyWithImpl<_$EntityMemberImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EntityMemberImplToJson(
      this,
    );
  }
}

abstract class _EntityMember implements EntityMember {
  const factory _EntityMember(
      {required final String entityId,
      required final String memberId,
      final String role,
      required final DateTime addedAt}) = _$EntityMemberImpl;

  factory _EntityMember.fromJson(Map<String, dynamic> json) =
      _$EntityMemberImpl.fromJson;

  @override
  String get entityId;
  @override
  String get memberId;
  @override
  String get role;
  @override
  DateTime get addedAt;

  /// Create a copy of EntityMember
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EntityMemberImplCopyWith<_$EntityMemberImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
