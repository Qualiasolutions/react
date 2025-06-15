// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TaskModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  TaskType get type => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  @JsonKey(name: 'contact_name')
  String? get contactName => throw _privateConstructorUsedError;
  @JsonKey(name: 'contact_email')
  String? get contactEmail => throw _privateConstructorUsedError;
  @JsonKey(name: 'contact_phone')
  String? get contactPhone => throw _privateConstructorUsedError;
  @JsonKey(name: 'hidden_tag')
  HiddenTagType? get hiddenTag => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  @JsonKey(name: 'routine_id')
  String? get routineId => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            String title,
            TaskType type,
            String? notes,
            String? location,
            @JsonKey(name: 'contact_name') String? contactName,
            @JsonKey(name: 'contact_email') String? contactEmail,
            @JsonKey(name: 'contact_phone') String? contactPhone,
            @JsonKey(name: 'hidden_tag') HiddenTagType? hiddenTag,
            List<String> tags,
            @JsonKey(name: 'routine_id') String? routineId,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt)
        $default, {
    required TResult Function(
            String id,
            String title,
            TaskType type,
            String? notes,
            String? location,
            @JsonKey(name: 'contact_name') String? contactName,
            @JsonKey(name: 'contact_email') String? contactEmail,
            @JsonKey(name: 'contact_phone') String? contactPhone,
            @JsonKey(name: 'hidden_tag') HiddenTagType? hiddenTag,
            List<String> tags,
            @JsonKey(name: 'routine_id') String? routineId,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'start_datetime') DateTime? startDatetime,
            @JsonKey(name: 'end_datetime') DateTime? endDatetime,
            @JsonKey(name: 'start_timezone') String? startReadonlyTimezone,
            @JsonKey(name: 'end_timezone') String? endReadonlyTimezone,
            @JsonKey(name: 'start_date') DateTime? startDate,
            @JsonKey(name: 'end_date') DateTime? endDate,
            DateTime? date,
            int? duration)
        fixed,
    required TResult Function(
            String id,
            String title,
            TaskType type,
            String? notes,
            String? location,
            @JsonKey(name: 'contact_name') String? contactName,
            @JsonKey(name: 'contact_email') String? contactEmail,
            @JsonKey(name: 'contact_phone') String? contactPhone,
            @JsonKey(name: 'hidden_tag') HiddenTagType? hiddenTag,
            List<String> tags,
            @JsonKey(name: 'routine_id') String? routineId,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'earliest_action_date') DateTime? earliestActionDate,
            @JsonKey(name: 'due_date') DateTime? dueDate,
            int duration,
            UrgencyType? urgency)
        flexible,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            String title,
            TaskType type,
            String? notes,
            String? location,
            @JsonKey(name: 'contact_name') String? contactName,
            @JsonKey(name: 'contact_email') String? contactEmail,
            @JsonKey(name: 'contact_phone') String? contactPhone,
            @JsonKey(name: 'hidden_tag') HiddenTagType? hiddenTag,
            List<String> tags,
            @JsonKey(name: 'routine_id') String? routineId,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt)?
        $default, {
    TResult? Function(
            String id,
            String title,
            TaskType type,
            String? notes,
            String? location,
            @JsonKey(name: 'contact_name') String? contactName,
            @JsonKey(name: 'contact_email') String? contactEmail,
            @JsonKey(name: 'contact_phone') String? contactPhone,
            @JsonKey(name: 'hidden_tag') HiddenTagType? hiddenTag,
            List<String> tags,
            @JsonKey(name: 'routine_id') String? routineId,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'start_datetime') DateTime? startDatetime,
            @JsonKey(name: 'end_datetime') DateTime? endDatetime,
            @JsonKey(name: 'start_timezone') String? startReadonlyTimezone,
            @JsonKey(name: 'end_timezone') String? endReadonlyTimezone,
            @JsonKey(name: 'start_date') DateTime? startDate,
            @JsonKey(name: 'end_date') DateTime? endDate,
            DateTime? date,
            int? duration)?
        fixed,
    TResult? Function(
            String id,
            String title,
            TaskType type,
            String? notes,
            String? location,
            @JsonKey(name: 'contact_name') String? contactName,
            @JsonKey(name: 'contact_email') String? contactEmail,
            @JsonKey(name: 'contact_phone') String? contactPhone,
            @JsonKey(name: 'hidden_tag') HiddenTagType? hiddenTag,
            List<String> tags,
            @JsonKey(name: 'routine_id') String? routineId,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'earliest_action_date') DateTime? earliestActionDate,
            @JsonKey(name: 'due_date') DateTime? dueDate,
            int duration,
            UrgencyType? urgency)?
        flexible,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            String title,
            TaskType type,
            String? notes,
            String? location,
            @JsonKey(name: 'contact_name') String? contactName,
            @JsonKey(name: 'contact_email') String? contactEmail,
            @JsonKey(name: 'contact_phone') String? contactPhone,
            @JsonKey(name: 'hidden_tag') HiddenTagType? hiddenTag,
            List<String> tags,
            @JsonKey(name: 'routine_id') String? routineId,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt)?
        $default, {
    TResult Function(
            String id,
            String title,
            TaskType type,
            String? notes,
            String? location,
            @JsonKey(name: 'contact_name') String? contactName,
            @JsonKey(name: 'contact_email') String? contactEmail,
            @JsonKey(name: 'contact_phone') String? contactPhone,
            @JsonKey(name: 'hidden_tag') HiddenTagType? hiddenTag,
            List<String> tags,
            @JsonKey(name: 'routine_id') String? routineId,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'start_datetime') DateTime? startDatetime,
            @JsonKey(name: 'end_datetime') DateTime? endDatetime,
            @JsonKey(name: 'start_timezone') String? startReadonlyTimezone,
            @JsonKey(name: 'end_timezone') String? endReadonlyTimezone,
            @JsonKey(name: 'start_date') DateTime? startDate,
            @JsonKey(name: 'end_date') DateTime? endDate,
            DateTime? date,
            int? duration)?
        fixed,
    TResult Function(
            String id,
            String title,
            TaskType type,
            String? notes,
            String? location,
            @JsonKey(name: 'contact_name') String? contactName,
            @JsonKey(name: 'contact_email') String? contactEmail,
            @JsonKey(name: 'contact_phone') String? contactPhone,
            @JsonKey(name: 'hidden_tag') HiddenTagType? hiddenTag,
            List<String> tags,
            @JsonKey(name: 'routine_id') String? routineId,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'earliest_action_date') DateTime? earliestActionDate,
            @JsonKey(name: 'due_date') DateTime? dueDate,
            int duration,
            UrgencyType? urgency)?
        flexible,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_TaskModel value) $default, {
    required TResult Function(FixedTaskModel value) fixed,
    required TResult Function(FlexibleTaskModel value) flexible,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_TaskModel value)? $default, {
    TResult? Function(FixedTaskModel value)? fixed,
    TResult? Function(FlexibleTaskModel value)? flexible,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_TaskModel value)? $default, {
    TResult Function(FixedTaskModel value)? fixed,
    TResult Function(FlexibleTaskModel value)? flexible,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Create a copy of TaskModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaskModelCopyWith<TaskModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskModelCopyWith<$Res> {
  factory $TaskModelCopyWith(TaskModel value, $Res Function(TaskModel) then) =
      _$TaskModelCopyWithImpl<$Res, TaskModel>;
  @useResult
  $Res call(
      {String id,
      String title,
      TaskType type,
      String? notes,
      String? location,
      @JsonKey(name: 'contact_name') String? contactName,
      @JsonKey(name: 'contact_email') String? contactEmail,
      @JsonKey(name: 'contact_phone') String? contactPhone,
      @JsonKey(name: 'hidden_tag') HiddenTagType? hiddenTag,
      List<String> tags,
      @JsonKey(name: 'routine_id') String? routineId,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt});
}

/// @nodoc
class _$TaskModelCopyWithImpl<$Res, $Val extends TaskModel>
    implements $TaskModelCopyWith<$Res> {
  _$TaskModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TaskModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? type = null,
    Object? notes = freezed,
    Object? location = freezed,
    Object? contactName = freezed,
    Object? contactEmail = freezed,
    Object? contactPhone = freezed,
    Object? hiddenTag = freezed,
    Object? tags = null,
    Object? routineId = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as TaskType,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      contactName: freezed == contactName
          ? _value.contactName
          : contactName // ignore: cast_nullable_to_non_nullable
              as String?,
      contactEmail: freezed == contactEmail
          ? _value.contactEmail
          : contactEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      contactPhone: freezed == contactPhone
          ? _value.contactPhone
          : contactPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      hiddenTag: freezed == hiddenTag
          ? _value.hiddenTag
          : hiddenTag // ignore: cast_nullable_to_non_nullable
              as HiddenTagType?,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      routineId: freezed == routineId
          ? _value.routineId
          : routineId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TaskModelImplCopyWith<$Res>
    implements $TaskModelCopyWith<$Res> {
  factory _$$TaskModelImplCopyWith(
          _$TaskModelImpl value, $Res Function(_$TaskModelImpl) then) =
      __$$TaskModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      TaskType type,
      String? notes,
      String? location,
      @JsonKey(name: 'contact_name') String? contactName,
      @JsonKey(name: 'contact_email') String? contactEmail,
      @JsonKey(name: 'contact_phone') String? contactPhone,
      @JsonKey(name: 'hidden_tag') HiddenTagType? hiddenTag,
      List<String> tags,
      @JsonKey(name: 'routine_id') String? routineId,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt});
}

/// @nodoc
class __$$TaskModelImplCopyWithImpl<$Res>
    extends _$TaskModelCopyWithImpl<$Res, _$TaskModelImpl>
    implements _$$TaskModelImplCopyWith<$Res> {
  __$$TaskModelImplCopyWithImpl(
      _$TaskModelImpl _value, $Res Function(_$TaskModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TaskModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? type = null,
    Object? notes = freezed,
    Object? location = freezed,
    Object? contactName = freezed,
    Object? contactEmail = freezed,
    Object? contactPhone = freezed,
    Object? hiddenTag = freezed,
    Object? tags = null,
    Object? routineId = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$TaskModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as TaskType,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      contactName: freezed == contactName
          ? _value.contactName
          : contactName // ignore: cast_nullable_to_non_nullable
              as String?,
      contactEmail: freezed == contactEmail
          ? _value.contactEmail
          : contactEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      contactPhone: freezed == contactPhone
          ? _value.contactPhone
          : contactPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      hiddenTag: freezed == hiddenTag
          ? _value.hiddenTag
          : hiddenTag // ignore: cast_nullable_to_non_nullable
              as HiddenTagType?,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      routineId: freezed == routineId
          ? _value.routineId
          : routineId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$TaskModelImpl extends _TaskModel with DiagnosticableTreeMixin {
  const _$TaskModelImpl(
      {required this.id,
      required this.title,
      required this.type,
      this.notes,
      this.location,
      @JsonKey(name: 'contact_name') this.contactName,
      @JsonKey(name: 'contact_email') this.contactEmail,
      @JsonKey(name: 'contact_phone') this.contactPhone,
      @JsonKey(name: 'hidden_tag') this.hiddenTag,
      final List<String> tags = const [],
      @JsonKey(name: 'routine_id') this.routineId,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt})
      : _tags = tags,
        super._();

  @override
  final String id;
  @override
  final String title;
  @override
  final TaskType type;
  @override
  final String? notes;
  @override
  final String? location;
  @override
  @JsonKey(name: 'contact_name')
  final String? contactName;
  @override
  @JsonKey(name: 'contact_email')
  final String? contactEmail;
  @override
  @JsonKey(name: 'contact_phone')
  final String? contactPhone;
  @override
  @JsonKey(name: 'hidden_tag')
  final HiddenTagType? hiddenTag;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @JsonKey(name: 'routine_id')
  final String? routineId;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'TaskModel(id: $id, title: $title, type: $type, notes: $notes, location: $location, contactName: $contactName, contactEmail: $contactEmail, contactPhone: $contactPhone, hiddenTag: $hiddenTag, tags: $tags, routineId: $routineId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'TaskModel'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('title', title))
      ..add(DiagnosticsProperty('type', type))
      ..add(DiagnosticsProperty('notes', notes))
      ..add(DiagnosticsProperty('location', location))
      ..add(DiagnosticsProperty('contactName', contactName))
      ..add(DiagnosticsProperty('contactEmail', contactEmail))
      ..add(DiagnosticsProperty('contactPhone', contactPhone))
      ..add(DiagnosticsProperty('hiddenTag', hiddenTag))
      ..add(DiagnosticsProperty('tags', tags))
      ..add(DiagnosticsProperty('routineId', routineId))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('updatedAt', updatedAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.contactName, contactName) ||
                other.contactName == contactName) &&
            (identical(other.contactEmail, contactEmail) ||
                other.contactEmail == contactEmail) &&
            (identical(other.contactPhone, contactPhone) ||
                other.contactPhone == contactPhone) &&
            (identical(other.hiddenTag, hiddenTag) ||
                other.hiddenTag == hiddenTag) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.routineId, routineId) ||
                other.routineId == routineId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      type,
      notes,
      location,
      contactName,
      contactEmail,
      contactPhone,
      hiddenTag,
      const DeepCollectionEquality().hash(_tags),
      routineId,
      createdAt,
      updatedAt);

  /// Create a copy of TaskModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskModelImplCopyWith<_$TaskModelImpl> get copyWith =>
      __$$TaskModelImplCopyWithImpl<_$TaskModelImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            String title,
            TaskType type,
            String? notes,
            String? location,
            @JsonKey(name: 'contact_name') String? contactName,
            @JsonKey(name: 'contact_email') String? contactEmail,
            @JsonKey(name: 'contact_phone') String? contactPhone,
            @JsonKey(name: 'hidden_tag') HiddenTagType? hiddenTag,
            List<String> tags,
            @JsonKey(name: 'routine_id') String? routineId,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt)
        $default, {
    required TResult Function(
            String id,
            String title,
            TaskType type,
            String? notes,
            String? location,
            @JsonKey(name: 'contact_name') String? contactName,
            @JsonKey(name: 'contact_email') String? contactEmail,
            @JsonKey(name: 'contact_phone') String? contactPhone,
            @JsonKey(name: 'hidden_tag') HiddenTagType? hiddenTag,
            List<String> tags,
            @JsonKey(name: 'routine_id') String? routineId,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'start_datetime') DateTime? startDatetime,
            @JsonKey(name: 'end_datetime') DateTime? endDatetime,
            @JsonKey(name: 'start_timezone') String? startReadonlyTimezone,
            @JsonKey(name: 'end_timezone') String? endReadonlyTimezone,
            @JsonKey(name: 'start_date') DateTime? startDate,
            @JsonKey(name: 'end_date') DateTime? endDate,
            DateTime? date,
            int? duration)
        fixed,
    required TResult Function(
            String id,
            String title,
            TaskType type,
            String? notes,
            String? location,
            @JsonKey(name: 'contact_name') String? contactName,
            @JsonKey(name: 'contact_email') String? contactEmail,
            @JsonKey(name: 'contact_phone') String? contactPhone,
            @JsonKey(name: 'hidden_tag') HiddenTagType? hiddenTag,
            List<String> tags,
            @JsonKey(name: 'routine_id') String? routineId,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'earliest_action_date') DateTime? earliestActionDate,
            @JsonKey(name: 'due_date') DateTime? dueDate,
            int duration,
            UrgencyType? urgency)
        flexible,
  }) {
    return $default(id, title, type, notes, location, contactName, contactEmail,
        contactPhone, hiddenTag, tags, routineId, createdAt, updatedAt);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            String title,
            TaskType type,
            String? notes,
            String? location,
            @JsonKey(name: 'contact_name') String? contactName,
            @JsonKey(name: 'contact_email') String? contactEmail,
            @JsonKey(name: 'contact_phone') String? contactPhone,
            @JsonKey(name: 'hidden_tag') HiddenTagType? hiddenTag,
            List<String> tags,
            @JsonKey(name: 'routine_id') String? routineId,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt)?
        $default, {
    TResult? Function(
            String id,
            String title,
            TaskType type,
            String? notes,
            String? location,
            @JsonKey(name: 'contact_name') String? contactName,
            @JsonKey(name: 'contact_email') String? contactEmail,
            @JsonKey(name: 'contact_phone') String? contactPhone,
            @JsonKey(name: 'hidden_tag') HiddenTagType? hiddenTag,
            List<String> tags,
            @JsonKey(name: 'routine_id') String? routineId,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'start_datetime') DateTime? startDatetime,
            @JsonKey(name: 'end_datetime') DateTime? endDatetime,
            @JsonKey(name: 'start_timezone') String? startReadonlyTimezone,
            @JsonKey(name: 'end_timezone') String? endReadonlyTimezone,
            @JsonKey(name: 'start_date') DateTime? startDate,
            @JsonKey(name: 'end_date') DateTime? endDate,
            DateTime? date,
            int? duration)?
        fixed,
    TResult? Function(
            String id,
            String title,
            TaskType type,
            String? notes,
            String? location,
            @JsonKey(name: 'contact_name') String? contactName,
            @JsonKey(name: 'contact_email') String? contactEmail,
            @JsonKey(name: 'contact_phone') String? contactPhone,
            @JsonKey(name: 'hidden_tag') HiddenTagType? hiddenTag,
            List<String> tags,
            @JsonKey(name: 'routine_id') String? routineId,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'earliest_action_date') DateTime? earliestActionDate,
            @JsonKey(name: 'due_date') DateTime? dueDate,
            int duration,
            UrgencyType? urgency)?
        flexible,
  }) {
    return $default?.call(
        id,
        title,
        type,
        notes,
        location,
        contactName,
        contactEmail,
        contactPhone,
        hiddenTag,
        tags,
        routineId,
        createdAt,
        updatedAt);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            String title,
            TaskType type,
            String? notes,
            String? location,
            @JsonKey(name: 'contact_name') String? contactName,
            @JsonKey(name: 'contact_email') String? contactEmail,
            @JsonKey(name: 'contact_phone') String? contactPhone,
            @JsonKey(name: 'hidden_tag') HiddenTagType? hiddenTag,
            List<String> tags,
            @JsonKey(name: 'routine_id') String? routineId,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt)?
        $default, {
    TResult Function(
            String id,
            String title,
            TaskType type,
            String? notes,
            String? location,
            @JsonKey(name: 'contact_name') String? contactName,
            @JsonKey(name: 'contact_email') String? contactEmail,
            @JsonKey(name: 'contact_phone') String? contactPhone,
            @JsonKey(name: 'hidden_tag') HiddenTagType? hiddenTag,
            List<String> tags,
            @JsonKey(name: 'routine_id') String? routineId,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'start_datetime') DateTime? startDatetime,
            @JsonKey(name: 'end_datetime') DateTime? endDatetime,
            @JsonKey(name: 'start_timezone') String? startReadonlyTimezone,
            @JsonKey(name: 'end_timezone') String? endReadonlyTimezone,
            @JsonKey(name: 'start_date') DateTime? startDate,
            @JsonKey(name: 'end_date') DateTime? endDate,
            DateTime? date,
            int? duration)?
        fixed,
    TResult Function(
            String id,
            String title,
            TaskType type,
            String? notes,
            String? location,
            @JsonKey(name: 'contact_name') String? contactName,
            @JsonKey(name: 'contact_email') String? contactEmail,
            @JsonKey(name: 'contact_phone') String? contactPhone,
            @JsonKey(name: 'hidden_tag') HiddenTagType? hiddenTag,
            List<String> tags,
            @JsonKey(name: 'routine_id') String? routineId,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'earliest_action_date') DateTime? earliestActionDate,
            @JsonKey(name: 'due_date') DateTime? dueDate,
            int duration,
            UrgencyType? urgency)?
        flexible,
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(
          id,
          title,
          type,
          notes,
          location,
          contactName,
          contactEmail,
          contactPhone,
          hiddenTag,
          tags,
          routineId,
          createdAt,
          updatedAt);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_TaskModel value) $default, {
    required TResult Function(FixedTaskModel value) fixed,
    required TResult Function(FlexibleTaskModel value) flexible,
  }) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_TaskModel value)? $default, {
    TResult? Function(FixedTaskModel value)? fixed,
    TResult? Function(FlexibleTaskModel value)? flexible,
  }) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_TaskModel value)? $default, {
    TResult Function(FixedTaskModel value)? fixed,
    TResult Function(FlexibleTaskModel value)? flexible,
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _TaskModel extends TaskModel {
  const factory _TaskModel(
          {required final String id,
          required final String title,
          required final TaskType type,
          final String? notes,
          final String? location,
          @JsonKey(name: 'contact_name') final String? contactName,
          @JsonKey(name: 'contact_email') final String? contactEmail,
          @JsonKey(name: 'contact_phone') final String? contactPhone,
          @JsonKey(name: 'hidden_tag') final HiddenTagType? hiddenTag,
          final List<String> tags,
          @JsonKey(name: 'routine_id') final String? routineId,
          @JsonKey(name: 'created_at') required final DateTime createdAt,
          @JsonKey(name: 'updated_at') required final DateTime updatedAt}) =
      _$TaskModelImpl;
  const _TaskModel._() : super._();

  @override
  String get id;
  @override
  String get title;
  @override
  TaskType get type;
  @override
  String? get notes;
  @override
  String? get location;
  @override
  @JsonKey(name: 'contact_name')
  String? get contactName;
  @override
  @JsonKey(name: 'contact_email')
  String? get contactEmail;
  @override
  @JsonKey(name: 'contact_phone')
  String? get contactPhone;
  @override
  @JsonKey(name: 'hidden_tag')
  HiddenTagType? get hiddenTag;
  @override
  List<String> get tags;
  @override
  @JsonKey(name: 'routine_id')
  String? get routineId;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of TaskModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaskModelImplCopyWith<_$TaskModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FixedTaskModelImplCopyWith<$Res>
    implements $TaskModelCopyWith<$Res> {
  factory _$$FixedTaskModelImplCopyWith(_$FixedTaskModelImpl value,
          $Res Function(_$FixedTaskModelImpl) then) =
      __$$FixedTaskModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      TaskType type,
      String? notes,
      String? location,
      @JsonKey(name: 'contact_name') String? contactName,
      @JsonKey(name: 'contact_email') String? contactEmail,
      @JsonKey(name: 'contact_phone') String? contactPhone,
      @JsonKey(name: 'hidden_tag') HiddenTagType? hiddenTag,
      List<String> tags,
      @JsonKey(name: 'routine_id') String? routineId,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      @JsonKey(name: 'start_datetime') DateTime? startDatetime,
      @JsonKey(name: 'end_datetime') DateTime? endDatetime,
      @JsonKey(name: 'start_timezone') String? startReadonlyTimezone,
      @JsonKey(name: 'end_timezone') String? endReadonlyTimezone,
      @JsonKey(name: 'start_date') DateTime? startDate,
      @JsonKey(name: 'end_date') DateTime? endDate,
      DateTime? date,
      int? duration});
}

/// @nodoc
class __$$FixedTaskModelImplCopyWithImpl<$Res>
    extends _$TaskModelCopyWithImpl<$Res, _$FixedTaskModelImpl>
    implements _$$FixedTaskModelImplCopyWith<$Res> {
  __$$FixedTaskModelImplCopyWithImpl(
      _$FixedTaskModelImpl _value, $Res Function(_$FixedTaskModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TaskModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? type = null,
    Object? notes = freezed,
    Object? location = freezed,
    Object? contactName = freezed,
    Object? contactEmail = freezed,
    Object? contactPhone = freezed,
    Object? hiddenTag = freezed,
    Object? tags = null,
    Object? routineId = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? startDatetime = freezed,
    Object? endDatetime = freezed,
    Object? startReadonlyTimezone = freezed,
    Object? endReadonlyTimezone = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? date = freezed,
    Object? duration = freezed,
  }) {
    return _then(_$FixedTaskModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as TaskType,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      contactName: freezed == contactName
          ? _value.contactName
          : contactName // ignore: cast_nullable_to_non_nullable
              as String?,
      contactEmail: freezed == contactEmail
          ? _value.contactEmail
          : contactEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      contactPhone: freezed == contactPhone
          ? _value.contactPhone
          : contactPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      hiddenTag: freezed == hiddenTag
          ? _value.hiddenTag
          : hiddenTag // ignore: cast_nullable_to_non_nullable
              as HiddenTagType?,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      routineId: freezed == routineId
          ? _value.routineId
          : routineId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      startDatetime: freezed == startDatetime
          ? _value.startDatetime
          : startDatetime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDatetime: freezed == endDatetime
          ? _value.endDatetime
          : endDatetime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      startReadonlyTimezone: freezed == startReadonlyTimezone
          ? _value.startReadonlyTimezone
          : startReadonlyTimezone // ignore: cast_nullable_to_non_nullable
              as String?,
      endReadonlyTimezone: freezed == endReadonlyTimezone
          ? _value.endReadonlyTimezone
          : endReadonlyTimezone // ignore: cast_nullable_to_non_nullable
              as String?,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      date: freezed == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$FixedTaskModelImpl extends FixedTaskModel with DiagnosticableTreeMixin {
  const _$FixedTaskModelImpl(
      {required this.id,
      required this.title,
      required this.type,
      this.notes,
      this.location,
      @JsonKey(name: 'contact_name') this.contactName,
      @JsonKey(name: 'contact_email') this.contactEmail,
      @JsonKey(name: 'contact_phone') this.contactPhone,
      @JsonKey(name: 'hidden_tag') this.hiddenTag,
      final List<String> tags = const [],
      @JsonKey(name: 'routine_id') this.routineId,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt,
      @JsonKey(name: 'start_datetime') this.startDatetime,
      @JsonKey(name: 'end_datetime') this.endDatetime,
      @JsonKey(name: 'start_timezone') this.startReadonlyTimezone,
      @JsonKey(name: 'end_timezone') this.endReadonlyTimezone,
      @JsonKey(name: 'start_date') this.startDate,
      @JsonKey(name: 'end_date') this.endDate,
      this.date,
      this.duration})
      : _tags = tags,
        super._();

  @override
  final String id;
  @override
  final String title;
  @override
  final TaskType type;
  @override
  final String? notes;
  @override
  final String? location;
  @override
  @JsonKey(name: 'contact_name')
  final String? contactName;
  @override
  @JsonKey(name: 'contact_email')
  final String? contactEmail;
  @override
  @JsonKey(name: 'contact_phone')
  final String? contactPhone;
  @override
  @JsonKey(name: 'hidden_tag')
  final HiddenTagType? hiddenTag;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @JsonKey(name: 'routine_id')
  final String? routineId;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
// FixedTask specific fields
  @override
  @JsonKey(name: 'start_datetime')
  final DateTime? startDatetime;
  @override
  @JsonKey(name: 'end_datetime')
  final DateTime? endDatetime;
  @override
  @JsonKey(name: 'start_timezone')
  final String? startReadonlyTimezone;
  @override
  @JsonKey(name: 'end_timezone')
  final String? endReadonlyTimezone;
  @override
  @JsonKey(name: 'start_date')
  final DateTime? startDate;
  @override
  @JsonKey(name: 'end_date')
  final DateTime? endDate;
  @override
  final DateTime? date;
  @override
  final int? duration;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'TaskModel.fixed(id: $id, title: $title, type: $type, notes: $notes, location: $location, contactName: $contactName, contactEmail: $contactEmail, contactPhone: $contactPhone, hiddenTag: $hiddenTag, tags: $tags, routineId: $routineId, createdAt: $createdAt, updatedAt: $updatedAt, startDatetime: $startDatetime, endDatetime: $endDatetime, startReadonlyTimezone: $startReadonlyTimezone, endReadonlyTimezone: $endReadonlyTimezone, startDate: $startDate, endDate: $endDate, date: $date, duration: $duration)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'TaskModel.fixed'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('title', title))
      ..add(DiagnosticsProperty('type', type))
      ..add(DiagnosticsProperty('notes', notes))
      ..add(DiagnosticsProperty('location', location))
      ..add(DiagnosticsProperty('contactName', contactName))
      ..add(DiagnosticsProperty('contactEmail', contactEmail))
      ..add(DiagnosticsProperty('contactPhone', contactPhone))
      ..add(DiagnosticsProperty('hiddenTag', hiddenTag))
      ..add(DiagnosticsProperty('tags', tags))
      ..add(DiagnosticsProperty('routineId', routineId))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('updatedAt', updatedAt))
      ..add(DiagnosticsProperty('startDatetime', startDatetime))
      ..add(DiagnosticsProperty('endDatetime', endDatetime))
      ..add(DiagnosticsProperty('startReadonlyTimezone', startReadonlyTimezone))
      ..add(DiagnosticsProperty('endReadonlyTimezone', endReadonlyTimezone))
      ..add(DiagnosticsProperty('startDate', startDate))
      ..add(DiagnosticsProperty('endDate', endDate))
      ..add(DiagnosticsProperty('date', date))
      ..add(DiagnosticsProperty('duration', duration));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FixedTaskModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.contactName, contactName) ||
                other.contactName == contactName) &&
            (identical(other.contactEmail, contactEmail) ||
                other.contactEmail == contactEmail) &&
            (identical(other.contactPhone, contactPhone) ||
                other.contactPhone == contactPhone) &&
            (identical(other.hiddenTag, hiddenTag) ||
                other.hiddenTag == hiddenTag) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.routineId, routineId) ||
                other.routineId == routineId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.startDatetime, startDatetime) ||
                other.startDatetime == startDatetime) &&
            (identical(other.endDatetime, endDatetime) ||
                other.endDatetime == endDatetime) &&
            (identical(other.startReadonlyTimezone, startReadonlyTimezone) ||
                other.startReadonlyTimezone == startReadonlyTimezone) &&
            (identical(other.endReadonlyTimezone, endReadonlyTimezone) ||
                other.endReadonlyTimezone == endReadonlyTimezone) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.duration, duration) ||
                other.duration == duration));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        title,
        type,
        notes,
        location,
        contactName,
        contactEmail,
        contactPhone,
        hiddenTag,
        const DeepCollectionEquality().hash(_tags),
        routineId,
        createdAt,
        updatedAt,
        startDatetime,
        endDatetime,
        startReadonlyTimezone,
        endReadonlyTimezone,
        startDate,
        endDate,
        date,
        duration
      ]);

  /// Create a copy of TaskModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FixedTaskModelImplCopyWith<_$FixedTaskModelImpl> get copyWith =>
      __$$FixedTaskModelImplCopyWithImpl<_$FixedTaskModelImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            String title,
            TaskType type,
            String? notes,
            String? location,
            @JsonKey(name: 'contact_name') String? contactName,
            @JsonKey(name: 'contact_email') String? contactEmail,
            @JsonKey(name: 'contact_phone') String? contactPhone,
            @JsonKey(name: 'hidden_tag') HiddenTagType? hiddenTag,
            List<String> tags,
            @JsonKey(name: 'routine_id') String? routineId,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt)
        $default, {
    required TResult Function(
            String id,
            String title,
            TaskType type,
            String? notes,
            String? location,
            @JsonKey(name: 'contact_name') String? contactName,
            @JsonKey(name: 'contact_email') String? contactEmail,
            @JsonKey(name: 'contact_phone') String? contactPhone,
            @JsonKey(name: 'hidden_tag') HiddenTagType? hiddenTag,
            List<String> tags,
            @JsonKey(name: 'routine_id') String? routineId,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'start_datetime') DateTime? startDatetime,
            @JsonKey(name: 'end_datetime') DateTime? endDatetime,
            @JsonKey(name: 'start_timezone') String? startReadonlyTimezone,
            @JsonKey(name: 'end_timezone') String? endReadonlyTimezone,
            @JsonKey(name: 'start_date') DateTime? startDate,
            @JsonKey(name: 'end_date') DateTime? endDate,
            DateTime? date,
            int? duration)
        fixed,
    required TResult Function(
            String id,
            String title,
            TaskType type,
            String? notes,
            String? location,
            @JsonKey(name: 'contact_name') String? contactName,
            @JsonKey(name: 'contact_email') String? contactEmail,
            @JsonKey(name: 'contact_phone') String? contactPhone,
            @JsonKey(name: 'hidden_tag') HiddenTagType? hiddenTag,
            List<String> tags,
            @JsonKey(name: 'routine_id') String? routineId,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'earliest_action_date') DateTime? earliestActionDate,
            @JsonKey(name: 'due_date') DateTime? dueDate,
            int duration,
            UrgencyType? urgency)
        flexible,
  }) {
    return fixed(
        id,
        title,
        type,
        notes,
        location,
        contactName,
        contactEmail,
        contactPhone,
        hiddenTag,
        tags,
        routineId,
        createdAt,
        updatedAt,
        startDatetime,
        endDatetime,
        startReadonlyTimezone,
        endReadonlyTimezone,
        startDate,
        endDate,
        date,
        duration);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            String title,
            TaskType type,
            String? notes,
            String? location,
            @JsonKey(name: 'contact_name') String? contactName,
            @JsonKey(name: 'contact_email') String? contactEmail,
            @JsonKey(name: 'contact_phone') String? contactPhone,
            @JsonKey(name: 'hidden_tag') HiddenTagType? hiddenTag,
            List<String> tags,
            @JsonKey(name: 'routine_id') String? routineId,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt)?
        $default, {
    TResult? Function(
            String id,
            String title,
            TaskType type,
            String? notes,
            String? location,
            @JsonKey(name: 'contact_name') String? contactName,
            @JsonKey(name: 'contact_email') String? contactEmail,
            @JsonKey(name: 'contact_phone') String? contactPhone,
            @JsonKey(name: 'hidden_tag') HiddenTagType? hiddenTag,
            List<String> tags,
            @JsonKey(name: 'routine_id') String? routineId,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'start_datetime') DateTime? startDatetime,
            @JsonKey(name: 'end_datetime') DateTime? endDatetime,
            @JsonKey(name: 'start_timezone') String? startReadonlyTimezone,
            @JsonKey(name: 'end_timezone') String? endReadonlyTimezone,
            @JsonKey(name: 'start_date') DateTime? startDate,
            @JsonKey(name: 'end_date') DateTime? endDate,
            DateTime? date,
            int? duration)?
        fixed,
    TResult? Function(
            String id,
            String title,
            TaskType type,
            String? notes,
            String? location,
            @JsonKey(name: 'contact_name') String? contactName,
            @JsonKey(name: 'contact_email') String? contactEmail,
            @JsonKey(name: 'contact_phone') String? contactPhone,
            @JsonKey(name: 'hidden_tag') HiddenTagType? hiddenTag,
            List<String> tags,
            @JsonKey(name: 'routine_id') String? routineId,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'earliest_action_date') DateTime? earliestActionDate,
            @JsonKey(name: 'due_date') DateTime? dueDate,
            int duration,
            UrgencyType? urgency)?
        flexible,
  }) {
    return fixed?.call(
        id,
        title,
        type,
        notes,
        location,
        contactName,
        contactEmail,
        contactPhone,
        hiddenTag,
        tags,
        routineId,
        createdAt,
        updatedAt,
        startDatetime,
        endDatetime,
        startReadonlyTimezone,
        endReadonlyTimezone,
        startDate,
        endDate,
        date,
        duration);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            String title,
            TaskType type,
            String? notes,
            String? location,
            @JsonKey(name: 'contact_name') String? contactName,
            @JsonKey(name: 'contact_email') String? contactEmail,
            @JsonKey(name: 'contact_phone') String? contactPhone,
            @JsonKey(name: 'hidden_tag') HiddenTagType? hiddenTag,
            List<String> tags,
            @JsonKey(name: 'routine_id') String? routineId,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt)?
        $default, {
    TResult Function(
            String id,
            String title,
            TaskType type,
            String? notes,
            String? location,
            @JsonKey(name: 'contact_name') String? contactName,
            @JsonKey(name: 'contact_email') String? contactEmail,
            @JsonKey(name: 'contact_phone') String? contactPhone,
            @JsonKey(name: 'hidden_tag') HiddenTagType? hiddenTag,
            List<String> tags,
            @JsonKey(name: 'routine_id') String? routineId,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'start_datetime') DateTime? startDatetime,
            @JsonKey(name: 'end_datetime') DateTime? endDatetime,
            @JsonKey(name: 'start_timezone') String? startReadonlyTimezone,
            @JsonKey(name: 'end_timezone') String? endReadonlyTimezone,
            @JsonKey(name: 'start_date') DateTime? startDate,
            @JsonKey(name: 'end_date') DateTime? endDate,
            DateTime? date,
            int? duration)?
        fixed,
    TResult Function(
            String id,
            String title,
            TaskType type,
            String? notes,
            String? location,
            @JsonKey(name: 'contact_name') String? contactName,
            @JsonKey(name: 'contact_email') String? contactEmail,
            @JsonKey(name: 'contact_phone') String? contactPhone,
            @JsonKey(name: 'hidden_tag') HiddenTagType? hiddenTag,
            List<String> tags,
            @JsonKey(name: 'routine_id') String? routineId,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'earliest_action_date') DateTime? earliestActionDate,
            @JsonKey(name: 'due_date') DateTime? dueDate,
            int duration,
            UrgencyType? urgency)?
        flexible,
    required TResult orElse(),
  }) {
    if (fixed != null) {
      return fixed(
          id,
          title,
          type,
          notes,
          location,
          contactName,
          contactEmail,
          contactPhone,
          hiddenTag,
          tags,
          routineId,
          createdAt,
          updatedAt,
          startDatetime,
          endDatetime,
          startReadonlyTimezone,
          endReadonlyTimezone,
          startDate,
          endDate,
          date,
          duration);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_TaskModel value) $default, {
    required TResult Function(FixedTaskModel value) fixed,
    required TResult Function(FlexibleTaskModel value) flexible,
  }) {
    return fixed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_TaskModel value)? $default, {
    TResult? Function(FixedTaskModel value)? fixed,
    TResult? Function(FlexibleTaskModel value)? flexible,
  }) {
    return fixed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_TaskModel value)? $default, {
    TResult Function(FixedTaskModel value)? fixed,
    TResult Function(FlexibleTaskModel value)? flexible,
    required TResult orElse(),
  }) {
    if (fixed != null) {
      return fixed(this);
    }
    return orElse();
  }
}

abstract class FixedTaskModel extends TaskModel {
  const factory FixedTaskModel(
      {required final String id,
      required final String title,
      required final TaskType type,
      final String? notes,
      final String? location,
      @JsonKey(name: 'contact_name') final String? contactName,
      @JsonKey(name: 'contact_email') final String? contactEmail,
      @JsonKey(name: 'contact_phone') final String? contactPhone,
      @JsonKey(name: 'hidden_tag') final HiddenTagType? hiddenTag,
      final List<String> tags,
      @JsonKey(name: 'routine_id') final String? routineId,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(name: 'updated_at') required final DateTime updatedAt,
      @JsonKey(name: 'start_datetime') final DateTime? startDatetime,
      @JsonKey(name: 'end_datetime') final DateTime? endDatetime,
      @JsonKey(name: 'start_timezone') final String? startReadonlyTimezone,
      @JsonKey(name: 'end_timezone') final String? endReadonlyTimezone,
      @JsonKey(name: 'start_date') final DateTime? startDate,
      @JsonKey(name: 'end_date') final DateTime? endDate,
      final DateTime? date,
      final int? duration}) = _$FixedTaskModelImpl;
  const FixedTaskModel._() : super._();

  @override
  String get id;
  @override
  String get title;
  @override
  TaskType get type;
  @override
  String? get notes;
  @override
  String? get location;
  @override
  @JsonKey(name: 'contact_name')
  String? get contactName;
  @override
  @JsonKey(name: 'contact_email')
  String? get contactEmail;
  @override
  @JsonKey(name: 'contact_phone')
  String? get contactPhone;
  @override
  @JsonKey(name: 'hidden_tag')
  HiddenTagType? get hiddenTag;
  @override
  List<String> get tags;
  @override
  @JsonKey(name: 'routine_id')
  String? get routineId;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt; // FixedTask specific fields
  @JsonKey(name: 'start_datetime')
  DateTime? get startDatetime;
  @JsonKey(name: 'end_datetime')
  DateTime? get endDatetime;
  @JsonKey(name: 'start_timezone')
  String? get startReadonlyTimezone;
  @JsonKey(name: 'end_timezone')
  String? get endReadonlyTimezone;
  @JsonKey(name: 'start_date')
  DateTime? get startDate;
  @JsonKey(name: 'end_date')
  DateTime? get endDate;
  DateTime? get date;
  int? get duration;

  /// Create a copy of TaskModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FixedTaskModelImplCopyWith<_$FixedTaskModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FlexibleTaskModelImplCopyWith<$Res>
    implements $TaskModelCopyWith<$Res> {
  factory _$$FlexibleTaskModelImplCopyWith(_$FlexibleTaskModelImpl value,
          $Res Function(_$FlexibleTaskModelImpl) then) =
      __$$FlexibleTaskModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      TaskType type,
      String? notes,
      String? location,
      @JsonKey(name: 'contact_name') String? contactName,
      @JsonKey(name: 'contact_email') String? contactEmail,
      @JsonKey(name: 'contact_phone') String? contactPhone,
      @JsonKey(name: 'hidden_tag') HiddenTagType? hiddenTag,
      List<String> tags,
      @JsonKey(name: 'routine_id') String? routineId,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      @JsonKey(name: 'earliest_action_date') DateTime? earliestActionDate,
      @JsonKey(name: 'due_date') DateTime? dueDate,
      int duration,
      UrgencyType? urgency});
}

/// @nodoc
class __$$FlexibleTaskModelImplCopyWithImpl<$Res>
    extends _$TaskModelCopyWithImpl<$Res, _$FlexibleTaskModelImpl>
    implements _$$FlexibleTaskModelImplCopyWith<$Res> {
  __$$FlexibleTaskModelImplCopyWithImpl(_$FlexibleTaskModelImpl _value,
      $Res Function(_$FlexibleTaskModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TaskModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? type = null,
    Object? notes = freezed,
    Object? location = freezed,
    Object? contactName = freezed,
    Object? contactEmail = freezed,
    Object? contactPhone = freezed,
    Object? hiddenTag = freezed,
    Object? tags = null,
    Object? routineId = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? earliestActionDate = freezed,
    Object? dueDate = freezed,
    Object? duration = null,
    Object? urgency = freezed,
  }) {
    return _then(_$FlexibleTaskModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as TaskType,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      contactName: freezed == contactName
          ? _value.contactName
          : contactName // ignore: cast_nullable_to_non_nullable
              as String?,
      contactEmail: freezed == contactEmail
          ? _value.contactEmail
          : contactEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      contactPhone: freezed == contactPhone
          ? _value.contactPhone
          : contactPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      hiddenTag: freezed == hiddenTag
          ? _value.hiddenTag
          : hiddenTag // ignore: cast_nullable_to_non_nullable
              as HiddenTagType?,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      routineId: freezed == routineId
          ? _value.routineId
          : routineId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      earliestActionDate: freezed == earliestActionDate
          ? _value.earliestActionDate
          : earliestActionDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dueDate: freezed == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int,
      urgency: freezed == urgency
          ? _value.urgency
          : urgency // ignore: cast_nullable_to_non_nullable
              as UrgencyType?,
    ));
  }
}

/// @nodoc

class _$FlexibleTaskModelImpl extends FlexibleTaskModel
    with DiagnosticableTreeMixin {
  const _$FlexibleTaskModelImpl(
      {required this.id,
      required this.title,
      required this.type,
      this.notes,
      this.location,
      @JsonKey(name: 'contact_name') this.contactName,
      @JsonKey(name: 'contact_email') this.contactEmail,
      @JsonKey(name: 'contact_phone') this.contactPhone,
      @JsonKey(name: 'hidden_tag') this.hiddenTag,
      final List<String> tags = const [],
      @JsonKey(name: 'routine_id') this.routineId,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt,
      @JsonKey(name: 'earliest_action_date') this.earliestActionDate,
      @JsonKey(name: 'due_date') this.dueDate,
      this.duration = 30,
      this.urgency})
      : _tags = tags,
        super._();

  @override
  final String id;
  @override
  final String title;
  @override
  final TaskType type;
  @override
  final String? notes;
  @override
  final String? location;
  @override
  @JsonKey(name: 'contact_name')
  final String? contactName;
  @override
  @JsonKey(name: 'contact_email')
  final String? contactEmail;
  @override
  @JsonKey(name: 'contact_phone')
  final String? contactPhone;
  @override
  @JsonKey(name: 'hidden_tag')
  final HiddenTagType? hiddenTag;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @JsonKey(name: 'routine_id')
  final String? routineId;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
// FlexibleTask specific fields
  @override
  @JsonKey(name: 'earliest_action_date')
  final DateTime? earliestActionDate;
  @override
  @JsonKey(name: 'due_date')
  final DateTime? dueDate;
  @override
  @JsonKey()
  final int duration;
// in minutes
  @override
  final UrgencyType? urgency;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'TaskModel.flexible(id: $id, title: $title, type: $type, notes: $notes, location: $location, contactName: $contactName, contactEmail: $contactEmail, contactPhone: $contactPhone, hiddenTag: $hiddenTag, tags: $tags, routineId: $routineId, createdAt: $createdAt, updatedAt: $updatedAt, earliestActionDate: $earliestActionDate, dueDate: $dueDate, duration: $duration, urgency: $urgency)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'TaskModel.flexible'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('title', title))
      ..add(DiagnosticsProperty('type', type))
      ..add(DiagnosticsProperty('notes', notes))
      ..add(DiagnosticsProperty('location', location))
      ..add(DiagnosticsProperty('contactName', contactName))
      ..add(DiagnosticsProperty('contactEmail', contactEmail))
      ..add(DiagnosticsProperty('contactPhone', contactPhone))
      ..add(DiagnosticsProperty('hiddenTag', hiddenTag))
      ..add(DiagnosticsProperty('tags', tags))
      ..add(DiagnosticsProperty('routineId', routineId))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('updatedAt', updatedAt))
      ..add(DiagnosticsProperty('earliestActionDate', earliestActionDate))
      ..add(DiagnosticsProperty('dueDate', dueDate))
      ..add(DiagnosticsProperty('duration', duration))
      ..add(DiagnosticsProperty('urgency', urgency));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FlexibleTaskModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.contactName, contactName) ||
                other.contactName == contactName) &&
            (identical(other.contactEmail, contactEmail) ||
                other.contactEmail == contactEmail) &&
            (identical(other.contactPhone, contactPhone) ||
                other.contactPhone == contactPhone) &&
            (identical(other.hiddenTag, hiddenTag) ||
                other.hiddenTag == hiddenTag) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.routineId, routineId) ||
                other.routineId == routineId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.earliestActionDate, earliestActionDate) ||
                other.earliestActionDate == earliestActionDate) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.urgency, urgency) || other.urgency == urgency));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      type,
      notes,
      location,
      contactName,
      contactEmail,
      contactPhone,
      hiddenTag,
      const DeepCollectionEquality().hash(_tags),
      routineId,
      createdAt,
      updatedAt,
      earliestActionDate,
      dueDate,
      duration,
      urgency);

  /// Create a copy of TaskModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FlexibleTaskModelImplCopyWith<_$FlexibleTaskModelImpl> get copyWith =>
      __$$FlexibleTaskModelImplCopyWithImpl<_$FlexibleTaskModelImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            String title,
            TaskType type,
            String? notes,
            String? location,
            @JsonKey(name: 'contact_name') String? contactName,
            @JsonKey(name: 'contact_email') String? contactEmail,
            @JsonKey(name: 'contact_phone') String? contactPhone,
            @JsonKey(name: 'hidden_tag') HiddenTagType? hiddenTag,
            List<String> tags,
            @JsonKey(name: 'routine_id') String? routineId,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt)
        $default, {
    required TResult Function(
            String id,
            String title,
            TaskType type,
            String? notes,
            String? location,
            @JsonKey(name: 'contact_name') String? contactName,
            @JsonKey(name: 'contact_email') String? contactEmail,
            @JsonKey(name: 'contact_phone') String? contactPhone,
            @JsonKey(name: 'hidden_tag') HiddenTagType? hiddenTag,
            List<String> tags,
            @JsonKey(name: 'routine_id') String? routineId,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'start_datetime') DateTime? startDatetime,
            @JsonKey(name: 'end_datetime') DateTime? endDatetime,
            @JsonKey(name: 'start_timezone') String? startReadonlyTimezone,
            @JsonKey(name: 'end_timezone') String? endReadonlyTimezone,
            @JsonKey(name: 'start_date') DateTime? startDate,
            @JsonKey(name: 'end_date') DateTime? endDate,
            DateTime? date,
            int? duration)
        fixed,
    required TResult Function(
            String id,
            String title,
            TaskType type,
            String? notes,
            String? location,
            @JsonKey(name: 'contact_name') String? contactName,
            @JsonKey(name: 'contact_email') String? contactEmail,
            @JsonKey(name: 'contact_phone') String? contactPhone,
            @JsonKey(name: 'hidden_tag') HiddenTagType? hiddenTag,
            List<String> tags,
            @JsonKey(name: 'routine_id') String? routineId,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'earliest_action_date') DateTime? earliestActionDate,
            @JsonKey(name: 'due_date') DateTime? dueDate,
            int duration,
            UrgencyType? urgency)
        flexible,
  }) {
    return flexible(
        id,
        title,
        type,
        notes,
        location,
        contactName,
        contactEmail,
        contactPhone,
        hiddenTag,
        tags,
        routineId,
        createdAt,
        updatedAt,
        earliestActionDate,
        dueDate,
        duration,
        urgency);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            String title,
            TaskType type,
            String? notes,
            String? location,
            @JsonKey(name: 'contact_name') String? contactName,
            @JsonKey(name: 'contact_email') String? contactEmail,
            @JsonKey(name: 'contact_phone') String? contactPhone,
            @JsonKey(name: 'hidden_tag') HiddenTagType? hiddenTag,
            List<String> tags,
            @JsonKey(name: 'routine_id') String? routineId,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt)?
        $default, {
    TResult? Function(
            String id,
            String title,
            TaskType type,
            String? notes,
            String? location,
            @JsonKey(name: 'contact_name') String? contactName,
            @JsonKey(name: 'contact_email') String? contactEmail,
            @JsonKey(name: 'contact_phone') String? contactPhone,
            @JsonKey(name: 'hidden_tag') HiddenTagType? hiddenTag,
            List<String> tags,
            @JsonKey(name: 'routine_id') String? routineId,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'start_datetime') DateTime? startDatetime,
            @JsonKey(name: 'end_datetime') DateTime? endDatetime,
            @JsonKey(name: 'start_timezone') String? startReadonlyTimezone,
            @JsonKey(name: 'end_timezone') String? endReadonlyTimezone,
            @JsonKey(name: 'start_date') DateTime? startDate,
            @JsonKey(name: 'end_date') DateTime? endDate,
            DateTime? date,
            int? duration)?
        fixed,
    TResult? Function(
            String id,
            String title,
            TaskType type,
            String? notes,
            String? location,
            @JsonKey(name: 'contact_name') String? contactName,
            @JsonKey(name: 'contact_email') String? contactEmail,
            @JsonKey(name: 'contact_phone') String? contactPhone,
            @JsonKey(name: 'hidden_tag') HiddenTagType? hiddenTag,
            List<String> tags,
            @JsonKey(name: 'routine_id') String? routineId,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'earliest_action_date') DateTime? earliestActionDate,
            @JsonKey(name: 'due_date') DateTime? dueDate,
            int duration,
            UrgencyType? urgency)?
        flexible,
  }) {
    return flexible?.call(
        id,
        title,
        type,
        notes,
        location,
        contactName,
        contactEmail,
        contactPhone,
        hiddenTag,
        tags,
        routineId,
        createdAt,
        updatedAt,
        earliestActionDate,
        dueDate,
        duration,
        urgency);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            String title,
            TaskType type,
            String? notes,
            String? location,
            @JsonKey(name: 'contact_name') String? contactName,
            @JsonKey(name: 'contact_email') String? contactEmail,
            @JsonKey(name: 'contact_phone') String? contactPhone,
            @JsonKey(name: 'hidden_tag') HiddenTagType? hiddenTag,
            List<String> tags,
            @JsonKey(name: 'routine_id') String? routineId,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt)?
        $default, {
    TResult Function(
            String id,
            String title,
            TaskType type,
            String? notes,
            String? location,
            @JsonKey(name: 'contact_name') String? contactName,
            @JsonKey(name: 'contact_email') String? contactEmail,
            @JsonKey(name: 'contact_phone') String? contactPhone,
            @JsonKey(name: 'hidden_tag') HiddenTagType? hiddenTag,
            List<String> tags,
            @JsonKey(name: 'routine_id') String? routineId,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'start_datetime') DateTime? startDatetime,
            @JsonKey(name: 'end_datetime') DateTime? endDatetime,
            @JsonKey(name: 'start_timezone') String? startReadonlyTimezone,
            @JsonKey(name: 'end_timezone') String? endReadonlyTimezone,
            @JsonKey(name: 'start_date') DateTime? startDate,
            @JsonKey(name: 'end_date') DateTime? endDate,
            DateTime? date,
            int? duration)?
        fixed,
    TResult Function(
            String id,
            String title,
            TaskType type,
            String? notes,
            String? location,
            @JsonKey(name: 'contact_name') String? contactName,
            @JsonKey(name: 'contact_email') String? contactEmail,
            @JsonKey(name: 'contact_phone') String? contactPhone,
            @JsonKey(name: 'hidden_tag') HiddenTagType? hiddenTag,
            List<String> tags,
            @JsonKey(name: 'routine_id') String? routineId,
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'updated_at') DateTime updatedAt,
            @JsonKey(name: 'earliest_action_date') DateTime? earliestActionDate,
            @JsonKey(name: 'due_date') DateTime? dueDate,
            int duration,
            UrgencyType? urgency)?
        flexible,
    required TResult orElse(),
  }) {
    if (flexible != null) {
      return flexible(
          id,
          title,
          type,
          notes,
          location,
          contactName,
          contactEmail,
          contactPhone,
          hiddenTag,
          tags,
          routineId,
          createdAt,
          updatedAt,
          earliestActionDate,
          dueDate,
          duration,
          urgency);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_TaskModel value) $default, {
    required TResult Function(FixedTaskModel value) fixed,
    required TResult Function(FlexibleTaskModel value) flexible,
  }) {
    return flexible(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_TaskModel value)? $default, {
    TResult? Function(FixedTaskModel value)? fixed,
    TResult? Function(FlexibleTaskModel value)? flexible,
  }) {
    return flexible?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_TaskModel value)? $default, {
    TResult Function(FixedTaskModel value)? fixed,
    TResult Function(FlexibleTaskModel value)? flexible,
    required TResult orElse(),
  }) {
    if (flexible != null) {
      return flexible(this);
    }
    return orElse();
  }
}

abstract class FlexibleTaskModel extends TaskModel {
  const factory FlexibleTaskModel(
      {required final String id,
      required final String title,
      required final TaskType type,
      final String? notes,
      final String? location,
      @JsonKey(name: 'contact_name') final String? contactName,
      @JsonKey(name: 'contact_email') final String? contactEmail,
      @JsonKey(name: 'contact_phone') final String? contactPhone,
      @JsonKey(name: 'hidden_tag') final HiddenTagType? hiddenTag,
      final List<String> tags,
      @JsonKey(name: 'routine_id') final String? routineId,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(name: 'updated_at') required final DateTime updatedAt,
      @JsonKey(name: 'earliest_action_date') final DateTime? earliestActionDate,
      @JsonKey(name: 'due_date') final DateTime? dueDate,
      final int duration,
      final UrgencyType? urgency}) = _$FlexibleTaskModelImpl;
  const FlexibleTaskModel._() : super._();

  @override
  String get id;
  @override
  String get title;
  @override
  TaskType get type;
  @override
  String? get notes;
  @override
  String? get location;
  @override
  @JsonKey(name: 'contact_name')
  String? get contactName;
  @override
  @JsonKey(name: 'contact_email')
  String? get contactEmail;
  @override
  @JsonKey(name: 'contact_phone')
  String? get contactPhone;
  @override
  @JsonKey(name: 'hidden_tag')
  HiddenTagType? get hiddenTag;
  @override
  List<String> get tags;
  @override
  @JsonKey(name: 'routine_id')
  String? get routineId;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt; // FlexibleTask specific fields
  @JsonKey(name: 'earliest_action_date')
  DateTime? get earliestActionDate;
  @JsonKey(name: 'due_date')
  DateTime? get dueDate;
  int get duration; // in minutes
  UrgencyType? get urgency;

  /// Create a copy of TaskModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FlexibleTaskModelImplCopyWith<_$FlexibleTaskModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TaskMembershipModel _$TaskMembershipModelFromJson(Map<String, dynamic> json) {
  return _TaskMembershipModel.fromJson(json);
}

/// @nodoc
mixin _$TaskMembershipModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'task_id')
  String get taskId => throw _privateConstructorUsedError;
  @JsonKey(name: 'member_id')
  String get memberId => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this TaskMembershipModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TaskMembershipModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaskMembershipModelCopyWith<TaskMembershipModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskMembershipModelCopyWith<$Res> {
  factory $TaskMembershipModelCopyWith(
          TaskMembershipModel value, $Res Function(TaskMembershipModel) then) =
      _$TaskMembershipModelCopyWithImpl<$Res, TaskMembershipModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'task_id') String taskId,
      @JsonKey(name: 'member_id') String memberId,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class _$TaskMembershipModelCopyWithImpl<$Res, $Val extends TaskMembershipModel>
    implements $TaskMembershipModelCopyWith<$Res> {
  _$TaskMembershipModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TaskMembershipModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? taskId = null,
    Object? memberId = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      taskId: null == taskId
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as String,
      memberId: null == memberId
          ? _value.memberId
          : memberId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TaskMembershipModelImplCopyWith<$Res>
    implements $TaskMembershipModelCopyWith<$Res> {
  factory _$$TaskMembershipModelImplCopyWith(_$TaskMembershipModelImpl value,
          $Res Function(_$TaskMembershipModelImpl) then) =
      __$$TaskMembershipModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'task_id') String taskId,
      @JsonKey(name: 'member_id') String memberId,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class __$$TaskMembershipModelImplCopyWithImpl<$Res>
    extends _$TaskMembershipModelCopyWithImpl<$Res, _$TaskMembershipModelImpl>
    implements _$$TaskMembershipModelImplCopyWith<$Res> {
  __$$TaskMembershipModelImplCopyWithImpl(_$TaskMembershipModelImpl _value,
      $Res Function(_$TaskMembershipModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TaskMembershipModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? taskId = null,
    Object? memberId = null,
    Object? createdAt = null,
  }) {
    return _then(_$TaskMembershipModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      taskId: null == taskId
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as String,
      memberId: null == memberId
          ? _value.memberId
          : memberId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TaskMembershipModelImpl
    with DiagnosticableTreeMixin
    implements _TaskMembershipModel {
  const _$TaskMembershipModelImpl(
      {required this.id,
      @JsonKey(name: 'task_id') required this.taskId,
      @JsonKey(name: 'member_id') required this.memberId,
      @JsonKey(name: 'created_at') required this.createdAt});

  factory _$TaskMembershipModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TaskMembershipModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'task_id')
  final String taskId;
  @override
  @JsonKey(name: 'member_id')
  final String memberId;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'TaskMembershipModel(id: $id, taskId: $taskId, memberId: $memberId, createdAt: $createdAt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'TaskMembershipModel'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('taskId', taskId))
      ..add(DiagnosticsProperty('memberId', memberId))
      ..add(DiagnosticsProperty('createdAt', createdAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskMembershipModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.taskId, taskId) || other.taskId == taskId) &&
            (identical(other.memberId, memberId) ||
                other.memberId == memberId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, taskId, memberId, createdAt);

  /// Create a copy of TaskMembershipModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskMembershipModelImplCopyWith<_$TaskMembershipModelImpl> get copyWith =>
      __$$TaskMembershipModelImplCopyWithImpl<_$TaskMembershipModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TaskMembershipModelImplToJson(
      this,
    );
  }
}

abstract class _TaskMembershipModel implements TaskMembershipModel {
  const factory _TaskMembershipModel(
          {required final String id,
          @JsonKey(name: 'task_id') required final String taskId,
          @JsonKey(name: 'member_id') required final String memberId,
          @JsonKey(name: 'created_at') required final DateTime createdAt}) =
      _$TaskMembershipModelImpl;

  factory _TaskMembershipModel.fromJson(Map<String, dynamic> json) =
      _$TaskMembershipModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'task_id')
  String get taskId;
  @override
  @JsonKey(name: 'member_id')
  String get memberId;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of TaskMembershipModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaskMembershipModelImplCopyWith<_$TaskMembershipModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TaskViewershipModel _$TaskViewershipModelFromJson(Map<String, dynamic> json) {
  return _TaskViewershipModel.fromJson(json);
}

/// @nodoc
mixin _$TaskViewershipModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'task_id')
  String get taskId => throw _privateConstructorUsedError;
  @JsonKey(name: 'member_id')
  String get memberId => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this TaskViewershipModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TaskViewershipModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaskViewershipModelCopyWith<TaskViewershipModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskViewershipModelCopyWith<$Res> {
  factory $TaskViewershipModelCopyWith(
          TaskViewershipModel value, $Res Function(TaskViewershipModel) then) =
      _$TaskViewershipModelCopyWithImpl<$Res, TaskViewershipModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'task_id') String taskId,
      @JsonKey(name: 'member_id') String memberId,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class _$TaskViewershipModelCopyWithImpl<$Res, $Val extends TaskViewershipModel>
    implements $TaskViewershipModelCopyWith<$Res> {
  _$TaskViewershipModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TaskViewershipModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? taskId = null,
    Object? memberId = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      taskId: null == taskId
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as String,
      memberId: null == memberId
          ? _value.memberId
          : memberId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TaskViewershipModelImplCopyWith<$Res>
    implements $TaskViewershipModelCopyWith<$Res> {
  factory _$$TaskViewershipModelImplCopyWith(_$TaskViewershipModelImpl value,
          $Res Function(_$TaskViewershipModelImpl) then) =
      __$$TaskViewershipModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'task_id') String taskId,
      @JsonKey(name: 'member_id') String memberId,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class __$$TaskViewershipModelImplCopyWithImpl<$Res>
    extends _$TaskViewershipModelCopyWithImpl<$Res, _$TaskViewershipModelImpl>
    implements _$$TaskViewershipModelImplCopyWith<$Res> {
  __$$TaskViewershipModelImplCopyWithImpl(_$TaskViewershipModelImpl _value,
      $Res Function(_$TaskViewershipModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TaskViewershipModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? taskId = null,
    Object? memberId = null,
    Object? createdAt = null,
  }) {
    return _then(_$TaskViewershipModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      taskId: null == taskId
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as String,
      memberId: null == memberId
          ? _value.memberId
          : memberId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TaskViewershipModelImpl
    with DiagnosticableTreeMixin
    implements _TaskViewershipModel {
  const _$TaskViewershipModelImpl(
      {required this.id,
      @JsonKey(name: 'task_id') required this.taskId,
      @JsonKey(name: 'member_id') required this.memberId,
      @JsonKey(name: 'created_at') required this.createdAt});

  factory _$TaskViewershipModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TaskViewershipModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'task_id')
  final String taskId;
  @override
  @JsonKey(name: 'member_id')
  final String memberId;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'TaskViewershipModel(id: $id, taskId: $taskId, memberId: $memberId, createdAt: $createdAt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'TaskViewershipModel'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('taskId', taskId))
      ..add(DiagnosticsProperty('memberId', memberId))
      ..add(DiagnosticsProperty('createdAt', createdAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskViewershipModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.taskId, taskId) || other.taskId == taskId) &&
            (identical(other.memberId, memberId) ||
                other.memberId == memberId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, taskId, memberId, createdAt);

  /// Create a copy of TaskViewershipModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskViewershipModelImplCopyWith<_$TaskViewershipModelImpl> get copyWith =>
      __$$TaskViewershipModelImplCopyWithImpl<_$TaskViewershipModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TaskViewershipModelImplToJson(
      this,
    );
  }
}

abstract class _TaskViewershipModel implements TaskViewershipModel {
  const factory _TaskViewershipModel(
          {required final String id,
          @JsonKey(name: 'task_id') required final String taskId,
          @JsonKey(name: 'member_id') required final String memberId,
          @JsonKey(name: 'created_at') required final DateTime createdAt}) =
      _$TaskViewershipModelImpl;

  factory _TaskViewershipModel.fromJson(Map<String, dynamic> json) =
      _$TaskViewershipModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'task_id')
  String get taskId;
  @override
  @JsonKey(name: 'member_id')
  String get memberId;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of TaskViewershipModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaskViewershipModelImplCopyWith<_$TaskViewershipModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TaskEntityModel _$TaskEntityModelFromJson(Map<String, dynamic> json) {
  return _TaskEntityModel.fromJson(json);
}

/// @nodoc
mixin _$TaskEntityModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'task_id')
  String get taskId => throw _privateConstructorUsedError;
  @JsonKey(name: 'entity_id')
  String get entityId => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this TaskEntityModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TaskEntityModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaskEntityModelCopyWith<TaskEntityModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskEntityModelCopyWith<$Res> {
  factory $TaskEntityModelCopyWith(
          TaskEntityModel value, $Res Function(TaskEntityModel) then) =
      _$TaskEntityModelCopyWithImpl<$Res, TaskEntityModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'task_id') String taskId,
      @JsonKey(name: 'entity_id') String entityId,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class _$TaskEntityModelCopyWithImpl<$Res, $Val extends TaskEntityModel>
    implements $TaskEntityModelCopyWith<$Res> {
  _$TaskEntityModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TaskEntityModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? taskId = null,
    Object? entityId = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      taskId: null == taskId
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as String,
      entityId: null == entityId
          ? _value.entityId
          : entityId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TaskEntityModelImplCopyWith<$Res>
    implements $TaskEntityModelCopyWith<$Res> {
  factory _$$TaskEntityModelImplCopyWith(_$TaskEntityModelImpl value,
          $Res Function(_$TaskEntityModelImpl) then) =
      __$$TaskEntityModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'task_id') String taskId,
      @JsonKey(name: 'entity_id') String entityId,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class __$$TaskEntityModelImplCopyWithImpl<$Res>
    extends _$TaskEntityModelCopyWithImpl<$Res, _$TaskEntityModelImpl>
    implements _$$TaskEntityModelImplCopyWith<$Res> {
  __$$TaskEntityModelImplCopyWithImpl(
      _$TaskEntityModelImpl _value, $Res Function(_$TaskEntityModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TaskEntityModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? taskId = null,
    Object? entityId = null,
    Object? createdAt = null,
  }) {
    return _then(_$TaskEntityModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      taskId: null == taskId
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as String,
      entityId: null == entityId
          ? _value.entityId
          : entityId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TaskEntityModelImpl
    with DiagnosticableTreeMixin
    implements _TaskEntityModel {
  const _$TaskEntityModelImpl(
      {required this.id,
      @JsonKey(name: 'task_id') required this.taskId,
      @JsonKey(name: 'entity_id') required this.entityId,
      @JsonKey(name: 'created_at') required this.createdAt});

  factory _$TaskEntityModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TaskEntityModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'task_id')
  final String taskId;
  @override
  @JsonKey(name: 'entity_id')
  final String entityId;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'TaskEntityModel(id: $id, taskId: $taskId, entityId: $entityId, createdAt: $createdAt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'TaskEntityModel'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('taskId', taskId))
      ..add(DiagnosticsProperty('entityId', entityId))
      ..add(DiagnosticsProperty('createdAt', createdAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskEntityModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.taskId, taskId) || other.taskId == taskId) &&
            (identical(other.entityId, entityId) ||
                other.entityId == entityId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, taskId, entityId, createdAt);

  /// Create a copy of TaskEntityModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskEntityModelImplCopyWith<_$TaskEntityModelImpl> get copyWith =>
      __$$TaskEntityModelImplCopyWithImpl<_$TaskEntityModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TaskEntityModelImplToJson(
      this,
    );
  }
}

abstract class _TaskEntityModel implements TaskEntityModel {
  const factory _TaskEntityModel(
          {required final String id,
          @JsonKey(name: 'task_id') required final String taskId,
          @JsonKey(name: 'entity_id') required final String entityId,
          @JsonKey(name: 'created_at') required final DateTime createdAt}) =
      _$TaskEntityModelImpl;

  factory _TaskEntityModel.fromJson(Map<String, dynamic> json) =
      _$TaskEntityModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'task_id')
  String get taskId;
  @override
  @JsonKey(name: 'entity_id')
  String get entityId;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of TaskEntityModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaskEntityModelImplCopyWith<_$TaskEntityModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RecurrenceModel _$RecurrenceModelFromJson(Map<String, dynamic> json) {
  return _RecurrenceModel.fromJson(json);
}

/// @nodoc
mixin _$RecurrenceModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'task_id')
  String get taskId => throw _privateConstructorUsedError;
  RecurrenceType get recurrence => throw _privateConstructorUsedError;
  @JsonKey(name: 'interval_length')
  int get intervalLength => throw _privateConstructorUsedError;
  @JsonKey(name: 'earliest_occurrence')
  DateTime? get earliestOccurrence => throw _privateConstructorUsedError;
  @JsonKey(name: 'latest_occurrence')
  DateTime? get latestOccurrence => throw _privateConstructorUsedError;

  /// Serializes this RecurrenceModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecurrenceModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecurrenceModelCopyWith<RecurrenceModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecurrenceModelCopyWith<$Res> {
  factory $RecurrenceModelCopyWith(
          RecurrenceModel value, $Res Function(RecurrenceModel) then) =
      _$RecurrenceModelCopyWithImpl<$Res, RecurrenceModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'task_id') String taskId,
      RecurrenceType recurrence,
      @JsonKey(name: 'interval_length') int intervalLength,
      @JsonKey(name: 'earliest_occurrence') DateTime? earliestOccurrence,
      @JsonKey(name: 'latest_occurrence') DateTime? latestOccurrence});
}

/// @nodoc
class _$RecurrenceModelCopyWithImpl<$Res, $Val extends RecurrenceModel>
    implements $RecurrenceModelCopyWith<$Res> {
  _$RecurrenceModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecurrenceModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? taskId = null,
    Object? recurrence = null,
    Object? intervalLength = null,
    Object? earliestOccurrence = freezed,
    Object? latestOccurrence = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      taskId: null == taskId
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as String,
      recurrence: null == recurrence
          ? _value.recurrence
          : recurrence // ignore: cast_nullable_to_non_nullable
              as RecurrenceType,
      intervalLength: null == intervalLength
          ? _value.intervalLength
          : intervalLength // ignore: cast_nullable_to_non_nullable
              as int,
      earliestOccurrence: freezed == earliestOccurrence
          ? _value.earliestOccurrence
          : earliestOccurrence // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      latestOccurrence: freezed == latestOccurrence
          ? _value.latestOccurrence
          : latestOccurrence // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RecurrenceModelImplCopyWith<$Res>
    implements $RecurrenceModelCopyWith<$Res> {
  factory _$$RecurrenceModelImplCopyWith(_$RecurrenceModelImpl value,
          $Res Function(_$RecurrenceModelImpl) then) =
      __$$RecurrenceModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'task_id') String taskId,
      RecurrenceType recurrence,
      @JsonKey(name: 'interval_length') int intervalLength,
      @JsonKey(name: 'earliest_occurrence') DateTime? earliestOccurrence,
      @JsonKey(name: 'latest_occurrence') DateTime? latestOccurrence});
}

/// @nodoc
class __$$RecurrenceModelImplCopyWithImpl<$Res>
    extends _$RecurrenceModelCopyWithImpl<$Res, _$RecurrenceModelImpl>
    implements _$$RecurrenceModelImplCopyWith<$Res> {
  __$$RecurrenceModelImplCopyWithImpl(
      _$RecurrenceModelImpl _value, $Res Function(_$RecurrenceModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of RecurrenceModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? taskId = null,
    Object? recurrence = null,
    Object? intervalLength = null,
    Object? earliestOccurrence = freezed,
    Object? latestOccurrence = freezed,
  }) {
    return _then(_$RecurrenceModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      taskId: null == taskId
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as String,
      recurrence: null == recurrence
          ? _value.recurrence
          : recurrence // ignore: cast_nullable_to_non_nullable
              as RecurrenceType,
      intervalLength: null == intervalLength
          ? _value.intervalLength
          : intervalLength // ignore: cast_nullable_to_non_nullable
              as int,
      earliestOccurrence: freezed == earliestOccurrence
          ? _value.earliestOccurrence
          : earliestOccurrence // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      latestOccurrence: freezed == latestOccurrence
          ? _value.latestOccurrence
          : latestOccurrence // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecurrenceModelImpl
    with DiagnosticableTreeMixin
    implements _RecurrenceModel {
  const _$RecurrenceModelImpl(
      {required this.id,
      @JsonKey(name: 'task_id') required this.taskId,
      required this.recurrence,
      @JsonKey(name: 'interval_length') this.intervalLength = 1,
      @JsonKey(name: 'earliest_occurrence') this.earliestOccurrence,
      @JsonKey(name: 'latest_occurrence') this.latestOccurrence});

  factory _$RecurrenceModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecurrenceModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'task_id')
  final String taskId;
  @override
  final RecurrenceType recurrence;
  @override
  @JsonKey(name: 'interval_length')
  final int intervalLength;
  @override
  @JsonKey(name: 'earliest_occurrence')
  final DateTime? earliestOccurrence;
  @override
  @JsonKey(name: 'latest_occurrence')
  final DateTime? latestOccurrence;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'RecurrenceModel(id: $id, taskId: $taskId, recurrence: $recurrence, intervalLength: $intervalLength, earliestOccurrence: $earliestOccurrence, latestOccurrence: $latestOccurrence)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'RecurrenceModel'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('taskId', taskId))
      ..add(DiagnosticsProperty('recurrence', recurrence))
      ..add(DiagnosticsProperty('intervalLength', intervalLength))
      ..add(DiagnosticsProperty('earliestOccurrence', earliestOccurrence))
      ..add(DiagnosticsProperty('latestOccurrence', latestOccurrence));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecurrenceModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.taskId, taskId) || other.taskId == taskId) &&
            (identical(other.recurrence, recurrence) ||
                other.recurrence == recurrence) &&
            (identical(other.intervalLength, intervalLength) ||
                other.intervalLength == intervalLength) &&
            (identical(other.earliestOccurrence, earliestOccurrence) ||
                other.earliestOccurrence == earliestOccurrence) &&
            (identical(other.latestOccurrence, latestOccurrence) ||
                other.latestOccurrence == latestOccurrence));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, taskId, recurrence,
      intervalLength, earliestOccurrence, latestOccurrence);

  /// Create a copy of RecurrenceModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecurrenceModelImplCopyWith<_$RecurrenceModelImpl> get copyWith =>
      __$$RecurrenceModelImplCopyWithImpl<_$RecurrenceModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecurrenceModelImplToJson(
      this,
    );
  }
}

abstract class _RecurrenceModel implements RecurrenceModel {
  const factory _RecurrenceModel(
      {required final String id,
      @JsonKey(name: 'task_id') required final String taskId,
      required final RecurrenceType recurrence,
      @JsonKey(name: 'interval_length') final int intervalLength,
      @JsonKey(name: 'earliest_occurrence') final DateTime? earliestOccurrence,
      @JsonKey(name: 'latest_occurrence')
      final DateTime? latestOccurrence}) = _$RecurrenceModelImpl;

  factory _RecurrenceModel.fromJson(Map<String, dynamic> json) =
      _$RecurrenceModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'task_id')
  String get taskId;
  @override
  RecurrenceType get recurrence;
  @override
  @JsonKey(name: 'interval_length')
  int get intervalLength;
  @override
  @JsonKey(name: 'earliest_occurrence')
  DateTime? get earliestOccurrence;
  @override
  @JsonKey(name: 'latest_occurrence')
  DateTime? get latestOccurrence;

  /// Create a copy of RecurrenceModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecurrenceModelImplCopyWith<_$RecurrenceModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TaskActionModel _$TaskActionModelFromJson(Map<String, dynamic> json) {
  return _TaskActionModel.fromJson(json);
}

/// @nodoc
mixin _$TaskActionModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'task_id')
  String get taskId => throw _privateConstructorUsedError;
  @JsonKey(name: 'action_timedelta')
  String get actionTimedelta =>
      throw _privateConstructorUsedError; // Stored as string, e.g., '1 day'
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this TaskActionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TaskActionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaskActionModelCopyWith<TaskActionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskActionModelCopyWith<$Res> {
  factory $TaskActionModelCopyWith(
          TaskActionModel value, $Res Function(TaskActionModel) then) =
      _$TaskActionModelCopyWithImpl<$Res, TaskActionModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'task_id') String taskId,
      @JsonKey(name: 'action_timedelta') String actionTimedelta,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class _$TaskActionModelCopyWithImpl<$Res, $Val extends TaskActionModel>
    implements $TaskActionModelCopyWith<$Res> {
  _$TaskActionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TaskActionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? taskId = null,
    Object? actionTimedelta = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      taskId: null == taskId
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as String,
      actionTimedelta: null == actionTimedelta
          ? _value.actionTimedelta
          : actionTimedelta // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TaskActionModelImplCopyWith<$Res>
    implements $TaskActionModelCopyWith<$Res> {
  factory _$$TaskActionModelImplCopyWith(_$TaskActionModelImpl value,
          $Res Function(_$TaskActionModelImpl) then) =
      __$$TaskActionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'task_id') String taskId,
      @JsonKey(name: 'action_timedelta') String actionTimedelta,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class __$$TaskActionModelImplCopyWithImpl<$Res>
    extends _$TaskActionModelCopyWithImpl<$Res, _$TaskActionModelImpl>
    implements _$$TaskActionModelImplCopyWith<$Res> {
  __$$TaskActionModelImplCopyWithImpl(
      _$TaskActionModelImpl _value, $Res Function(_$TaskActionModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TaskActionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? taskId = null,
    Object? actionTimedelta = null,
    Object? createdAt = null,
  }) {
    return _then(_$TaskActionModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      taskId: null == taskId
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as String,
      actionTimedelta: null == actionTimedelta
          ? _value.actionTimedelta
          : actionTimedelta // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TaskActionModelImpl
    with DiagnosticableTreeMixin
    implements _TaskActionModel {
  const _$TaskActionModelImpl(
      {required this.id,
      @JsonKey(name: 'task_id') required this.taskId,
      @JsonKey(name: 'action_timedelta') required this.actionTimedelta,
      @JsonKey(name: 'created_at') required this.createdAt});

  factory _$TaskActionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TaskActionModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'task_id')
  final String taskId;
  @override
  @JsonKey(name: 'action_timedelta')
  final String actionTimedelta;
// Stored as string, e.g., '1 day'
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'TaskActionModel(id: $id, taskId: $taskId, actionTimedelta: $actionTimedelta, createdAt: $createdAt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'TaskActionModel'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('taskId', taskId))
      ..add(DiagnosticsProperty('actionTimedelta', actionTimedelta))
      ..add(DiagnosticsProperty('createdAt', createdAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskActionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.taskId, taskId) || other.taskId == taskId) &&
            (identical(other.actionTimedelta, actionTimedelta) ||
                other.actionTimedelta == actionTimedelta) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, taskId, actionTimedelta, createdAt);

  /// Create a copy of TaskActionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskActionModelImplCopyWith<_$TaskActionModelImpl> get copyWith =>
      __$$TaskActionModelImplCopyWithImpl<_$TaskActionModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TaskActionModelImplToJson(
      this,
    );
  }
}

abstract class _TaskActionModel implements TaskActionModel {
  const factory _TaskActionModel(
      {required final String id,
      @JsonKey(name: 'task_id') required final String taskId,
      @JsonKey(name: 'action_timedelta') required final String actionTimedelta,
      @JsonKey(name: 'created_at')
      required final DateTime createdAt}) = _$TaskActionModelImpl;

  factory _TaskActionModel.fromJson(Map<String, dynamic> json) =
      _$TaskActionModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'task_id')
  String get taskId;
  @override
  @JsonKey(name: 'action_timedelta')
  String get actionTimedelta; // Stored as string, e.g., '1 day'
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of TaskActionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaskActionModelImplCopyWith<_$TaskActionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TaskReminderModel _$TaskReminderModelFromJson(Map<String, dynamic> json) {
  return _TaskReminderModel.fromJson(json);
}

/// @nodoc
mixin _$TaskReminderModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'task_id')
  String get taskId => throw _privateConstructorUsedError;
  String get timedelta =>
      throw _privateConstructorUsedError; // Stored as string, e.g., '1 day'
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this TaskReminderModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TaskReminderModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaskReminderModelCopyWith<TaskReminderModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskReminderModelCopyWith<$Res> {
  factory $TaskReminderModelCopyWith(
          TaskReminderModel value, $Res Function(TaskReminderModel) then) =
      _$TaskReminderModelCopyWithImpl<$Res, TaskReminderModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'task_id') String taskId,
      String timedelta,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class _$TaskReminderModelCopyWithImpl<$Res, $Val extends TaskReminderModel>
    implements $TaskReminderModelCopyWith<$Res> {
  _$TaskReminderModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TaskReminderModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? taskId = null,
    Object? timedelta = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      taskId: null == taskId
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as String,
      timedelta: null == timedelta
          ? _value.timedelta
          : timedelta // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TaskReminderModelImplCopyWith<$Res>
    implements $TaskReminderModelCopyWith<$Res> {
  factory _$$TaskReminderModelImplCopyWith(_$TaskReminderModelImpl value,
          $Res Function(_$TaskReminderModelImpl) then) =
      __$$TaskReminderModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'task_id') String taskId,
      String timedelta,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class __$$TaskReminderModelImplCopyWithImpl<$Res>
    extends _$TaskReminderModelCopyWithImpl<$Res, _$TaskReminderModelImpl>
    implements _$$TaskReminderModelImplCopyWith<$Res> {
  __$$TaskReminderModelImplCopyWithImpl(_$TaskReminderModelImpl _value,
      $Res Function(_$TaskReminderModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TaskReminderModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? taskId = null,
    Object? timedelta = null,
    Object? createdAt = null,
  }) {
    return _then(_$TaskReminderModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      taskId: null == taskId
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as String,
      timedelta: null == timedelta
          ? _value.timedelta
          : timedelta // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TaskReminderModelImpl
    with DiagnosticableTreeMixin
    implements _TaskReminderModel {
  const _$TaskReminderModelImpl(
      {required this.id,
      @JsonKey(name: 'task_id') required this.taskId,
      required this.timedelta,
      @JsonKey(name: 'created_at') required this.createdAt});

  factory _$TaskReminderModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TaskReminderModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'task_id')
  final String taskId;
  @override
  final String timedelta;
// Stored as string, e.g., '1 day'
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'TaskReminderModel(id: $id, taskId: $taskId, timedelta: $timedelta, createdAt: $createdAt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'TaskReminderModel'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('taskId', taskId))
      ..add(DiagnosticsProperty('timedelta', timedelta))
      ..add(DiagnosticsProperty('createdAt', createdAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskReminderModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.taskId, taskId) || other.taskId == taskId) &&
            (identical(other.timedelta, timedelta) ||
                other.timedelta == timedelta) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, taskId, timedelta, createdAt);

  /// Create a copy of TaskReminderModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskReminderModelImplCopyWith<_$TaskReminderModelImpl> get copyWith =>
      __$$TaskReminderModelImplCopyWithImpl<_$TaskReminderModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TaskReminderModelImplToJson(
      this,
    );
  }
}

abstract class _TaskReminderModel implements TaskReminderModel {
  const factory _TaskReminderModel(
          {required final String id,
          @JsonKey(name: 'task_id') required final String taskId,
          required final String timedelta,
          @JsonKey(name: 'created_at') required final DateTime createdAt}) =
      _$TaskReminderModelImpl;

  factory _TaskReminderModel.fromJson(Map<String, dynamic> json) =
      _$TaskReminderModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'task_id')
  String get taskId;
  @override
  String get timedelta; // Stored as string, e.g., '1 day'
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of TaskReminderModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaskReminderModelImplCopyWith<_$TaskReminderModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TaskCompletionFormModel _$TaskCompletionFormModelFromJson(
    Map<String, dynamic> json) {
  return _TaskCompletionFormModel.fromJson(json);
}

/// @nodoc
mixin _$TaskCompletionFormModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'task_id')
  String get taskId => throw _privateConstructorUsedError;
  @JsonKey(name: 'completion_datetime')
  DateTime get completionDatetime => throw _privateConstructorUsedError;
  @JsonKey(name: 'recurrence_index')
  int? get recurrenceIndex => throw _privateConstructorUsedError;
  bool get complete => throw _privateConstructorUsedError;
  bool get partial => throw _privateConstructorUsedError;

  /// Serializes this TaskCompletionFormModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TaskCompletionFormModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaskCompletionFormModelCopyWith<TaskCompletionFormModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskCompletionFormModelCopyWith<$Res> {
  factory $TaskCompletionFormModelCopyWith(TaskCompletionFormModel value,
          $Res Function(TaskCompletionFormModel) then) =
      _$TaskCompletionFormModelCopyWithImpl<$Res, TaskCompletionFormModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'task_id') String taskId,
      @JsonKey(name: 'completion_datetime') DateTime completionDatetime,
      @JsonKey(name: 'recurrence_index') int? recurrenceIndex,
      bool complete,
      bool partial});
}

/// @nodoc
class _$TaskCompletionFormModelCopyWithImpl<$Res,
        $Val extends TaskCompletionFormModel>
    implements $TaskCompletionFormModelCopyWith<$Res> {
  _$TaskCompletionFormModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TaskCompletionFormModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? taskId = null,
    Object? completionDatetime = null,
    Object? recurrenceIndex = freezed,
    Object? complete = null,
    Object? partial = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      taskId: null == taskId
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as String,
      completionDatetime: null == completionDatetime
          ? _value.completionDatetime
          : completionDatetime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      recurrenceIndex: freezed == recurrenceIndex
          ? _value.recurrenceIndex
          : recurrenceIndex // ignore: cast_nullable_to_non_nullable
              as int?,
      complete: null == complete
          ? _value.complete
          : complete // ignore: cast_nullable_to_non_nullable
              as bool,
      partial: null == partial
          ? _value.partial
          : partial // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TaskCompletionFormModelImplCopyWith<$Res>
    implements $TaskCompletionFormModelCopyWith<$Res> {
  factory _$$TaskCompletionFormModelImplCopyWith(
          _$TaskCompletionFormModelImpl value,
          $Res Function(_$TaskCompletionFormModelImpl) then) =
      __$$TaskCompletionFormModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'task_id') String taskId,
      @JsonKey(name: 'completion_datetime') DateTime completionDatetime,
      @JsonKey(name: 'recurrence_index') int? recurrenceIndex,
      bool complete,
      bool partial});
}

/// @nodoc
class __$$TaskCompletionFormModelImplCopyWithImpl<$Res>
    extends _$TaskCompletionFormModelCopyWithImpl<$Res,
        _$TaskCompletionFormModelImpl>
    implements _$$TaskCompletionFormModelImplCopyWith<$Res> {
  __$$TaskCompletionFormModelImplCopyWithImpl(
      _$TaskCompletionFormModelImpl _value,
      $Res Function(_$TaskCompletionFormModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TaskCompletionFormModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? taskId = null,
    Object? completionDatetime = null,
    Object? recurrenceIndex = freezed,
    Object? complete = null,
    Object? partial = null,
  }) {
    return _then(_$TaskCompletionFormModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      taskId: null == taskId
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as String,
      completionDatetime: null == completionDatetime
          ? _value.completionDatetime
          : completionDatetime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      recurrenceIndex: freezed == recurrenceIndex
          ? _value.recurrenceIndex
          : recurrenceIndex // ignore: cast_nullable_to_non_nullable
              as int?,
      complete: null == complete
          ? _value.complete
          : complete // ignore: cast_nullable_to_non_nullable
              as bool,
      partial: null == partial
          ? _value.partial
          : partial // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TaskCompletionFormModelImpl
    with DiagnosticableTreeMixin
    implements _TaskCompletionFormModel {
  const _$TaskCompletionFormModelImpl(
      {required this.id,
      @JsonKey(name: 'task_id') required this.taskId,
      @JsonKey(name: 'completion_datetime') required this.completionDatetime,
      @JsonKey(name: 'recurrence_index') this.recurrenceIndex,
      this.complete = true,
      this.partial = false});

  factory _$TaskCompletionFormModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TaskCompletionFormModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'task_id')
  final String taskId;
  @override
  @JsonKey(name: 'completion_datetime')
  final DateTime completionDatetime;
  @override
  @JsonKey(name: 'recurrence_index')
  final int? recurrenceIndex;
  @override
  @JsonKey()
  final bool complete;
  @override
  @JsonKey()
  final bool partial;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'TaskCompletionFormModel(id: $id, taskId: $taskId, completionDatetime: $completionDatetime, recurrenceIndex: $recurrenceIndex, complete: $complete, partial: $partial)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'TaskCompletionFormModel'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('taskId', taskId))
      ..add(DiagnosticsProperty('completionDatetime', completionDatetime))
      ..add(DiagnosticsProperty('recurrenceIndex', recurrenceIndex))
      ..add(DiagnosticsProperty('complete', complete))
      ..add(DiagnosticsProperty('partial', partial));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskCompletionFormModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.taskId, taskId) || other.taskId == taskId) &&
            (identical(other.completionDatetime, completionDatetime) ||
                other.completionDatetime == completionDatetime) &&
            (identical(other.recurrenceIndex, recurrenceIndex) ||
                other.recurrenceIndex == recurrenceIndex) &&
            (identical(other.complete, complete) ||
                other.complete == complete) &&
            (identical(other.partial, partial) || other.partial == partial));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, taskId, completionDatetime,
      recurrenceIndex, complete, partial);

  /// Create a copy of TaskCompletionFormModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskCompletionFormModelImplCopyWith<_$TaskCompletionFormModelImpl>
      get copyWith => __$$TaskCompletionFormModelImplCopyWithImpl<
          _$TaskCompletionFormModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TaskCompletionFormModelImplToJson(
      this,
    );
  }
}

abstract class _TaskCompletionFormModel implements TaskCompletionFormModel {
  const factory _TaskCompletionFormModel(
      {required final String id,
      @JsonKey(name: 'task_id') required final String taskId,
      @JsonKey(name: 'completion_datetime')
      required final DateTime completionDatetime,
      @JsonKey(name: 'recurrence_index') final int? recurrenceIndex,
      final bool complete,
      final bool partial}) = _$TaskCompletionFormModelImpl;

  factory _TaskCompletionFormModel.fromJson(Map<String, dynamic> json) =
      _$TaskCompletionFormModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'task_id')
  String get taskId;
  @override
  @JsonKey(name: 'completion_datetime')
  DateTime get completionDatetime;
  @override
  @JsonKey(name: 'recurrence_index')
  int? get recurrenceIndex;
  @override
  bool get complete;
  @override
  bool get partial;

  /// Create a copy of TaskCompletionFormModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaskCompletionFormModelImplCopyWith<_$TaskCompletionFormModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

TaskActionCompletionFormModel _$TaskActionCompletionFormModelFromJson(
    Map<String, dynamic> json) {
  return _TaskActionCompletionFormModel.fromJson(json);
}

/// @nodoc
mixin _$TaskActionCompletionFormModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'action_id')
  String get actionId => throw _privateConstructorUsedError;
  @JsonKey(name: 'completion_datetime')
  DateTime get completionDatetime => throw _privateConstructorUsedError;
  @JsonKey(name: 'recurrence_index')
  int? get recurrenceIndex => throw _privateConstructorUsedError;
  bool get ignore => throw _privateConstructorUsedError;
  bool get complete => throw _privateConstructorUsedError;

  /// Serializes this TaskActionCompletionFormModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TaskActionCompletionFormModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaskActionCompletionFormModelCopyWith<TaskActionCompletionFormModel>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskActionCompletionFormModelCopyWith<$Res> {
  factory $TaskActionCompletionFormModelCopyWith(
          TaskActionCompletionFormModel value,
          $Res Function(TaskActionCompletionFormModel) then) =
      _$TaskActionCompletionFormModelCopyWithImpl<$Res,
          TaskActionCompletionFormModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'action_id') String actionId,
      @JsonKey(name: 'completion_datetime') DateTime completionDatetime,
      @JsonKey(name: 'recurrence_index') int? recurrenceIndex,
      bool ignore,
      bool complete});
}

/// @nodoc
class _$TaskActionCompletionFormModelCopyWithImpl<$Res,
        $Val extends TaskActionCompletionFormModel>
    implements $TaskActionCompletionFormModelCopyWith<$Res> {
  _$TaskActionCompletionFormModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TaskActionCompletionFormModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? actionId = null,
    Object? completionDatetime = null,
    Object? recurrenceIndex = freezed,
    Object? ignore = null,
    Object? complete = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      actionId: null == actionId
          ? _value.actionId
          : actionId // ignore: cast_nullable_to_non_nullable
              as String,
      completionDatetime: null == completionDatetime
          ? _value.completionDatetime
          : completionDatetime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      recurrenceIndex: freezed == recurrenceIndex
          ? _value.recurrenceIndex
          : recurrenceIndex // ignore: cast_nullable_to_non_nullable
              as int?,
      ignore: null == ignore
          ? _value.ignore
          : ignore // ignore: cast_nullable_to_non_nullable
              as bool,
      complete: null == complete
          ? _value.complete
          : complete // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TaskActionCompletionFormModelImplCopyWith<$Res>
    implements $TaskActionCompletionFormModelCopyWith<$Res> {
  factory _$$TaskActionCompletionFormModelImplCopyWith(
          _$TaskActionCompletionFormModelImpl value,
          $Res Function(_$TaskActionCompletionFormModelImpl) then) =
      __$$TaskActionCompletionFormModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'action_id') String actionId,
      @JsonKey(name: 'completion_datetime') DateTime completionDatetime,
      @JsonKey(name: 'recurrence_index') int? recurrenceIndex,
      bool ignore,
      bool complete});
}

/// @nodoc
class __$$TaskActionCompletionFormModelImplCopyWithImpl<$Res>
    extends _$TaskActionCompletionFormModelCopyWithImpl<$Res,
        _$TaskActionCompletionFormModelImpl>
    implements _$$TaskActionCompletionFormModelImplCopyWith<$Res> {
  __$$TaskActionCompletionFormModelImplCopyWithImpl(
      _$TaskActionCompletionFormModelImpl _value,
      $Res Function(_$TaskActionCompletionFormModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TaskActionCompletionFormModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? actionId = null,
    Object? completionDatetime = null,
    Object? recurrenceIndex = freezed,
    Object? ignore = null,
    Object? complete = null,
  }) {
    return _then(_$TaskActionCompletionFormModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      actionId: null == actionId
          ? _value.actionId
          : actionId // ignore: cast_nullable_to_non_nullable
              as String,
      completionDatetime: null == completionDatetime
          ? _value.completionDatetime
          : completionDatetime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      recurrenceIndex: freezed == recurrenceIndex
          ? _value.recurrenceIndex
          : recurrenceIndex // ignore: cast_nullable_to_non_nullable
              as int?,
      ignore: null == ignore
          ? _value.ignore
          : ignore // ignore: cast_nullable_to_non_nullable
              as bool,
      complete: null == complete
          ? _value.complete
          : complete // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TaskActionCompletionFormModelImpl
    with DiagnosticableTreeMixin
    implements _TaskActionCompletionFormModel {
  const _$TaskActionCompletionFormModelImpl(
      {required this.id,
      @JsonKey(name: 'action_id') required this.actionId,
      @JsonKey(name: 'completion_datetime') required this.completionDatetime,
      @JsonKey(name: 'recurrence_index') this.recurrenceIndex,
      this.ignore = false,
      this.complete = true});

  factory _$TaskActionCompletionFormModelImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$TaskActionCompletionFormModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'action_id')
  final String actionId;
  @override
  @JsonKey(name: 'completion_datetime')
  final DateTime completionDatetime;
  @override
  @JsonKey(name: 'recurrence_index')
  final int? recurrenceIndex;
  @override
  @JsonKey()
  final bool ignore;
  @override
  @JsonKey()
  final bool complete;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'TaskActionCompletionFormModel(id: $id, actionId: $actionId, completionDatetime: $completionDatetime, recurrenceIndex: $recurrenceIndex, ignore: $ignore, complete: $complete)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'TaskActionCompletionFormModel'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('actionId', actionId))
      ..add(DiagnosticsProperty('completionDatetime', completionDatetime))
      ..add(DiagnosticsProperty('recurrenceIndex', recurrenceIndex))
      ..add(DiagnosticsProperty('ignore', ignore))
      ..add(DiagnosticsProperty('complete', complete));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskActionCompletionFormModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.actionId, actionId) ||
                other.actionId == actionId) &&
            (identical(other.completionDatetime, completionDatetime) ||
                other.completionDatetime == completionDatetime) &&
            (identical(other.recurrenceIndex, recurrenceIndex) ||
                other.recurrenceIndex == recurrenceIndex) &&
            (identical(other.ignore, ignore) || other.ignore == ignore) &&
            (identical(other.complete, complete) ||
                other.complete == complete));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, actionId, completionDatetime,
      recurrenceIndex, ignore, complete);

  /// Create a copy of TaskActionCompletionFormModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskActionCompletionFormModelImplCopyWith<
          _$TaskActionCompletionFormModelImpl>
      get copyWith => __$$TaskActionCompletionFormModelImplCopyWithImpl<
          _$TaskActionCompletionFormModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TaskActionCompletionFormModelImplToJson(
      this,
    );
  }
}

abstract class _TaskActionCompletionFormModel
    implements TaskActionCompletionFormModel {
  const factory _TaskActionCompletionFormModel(
      {required final String id,
      @JsonKey(name: 'action_id') required final String actionId,
      @JsonKey(name: 'completion_datetime')
      required final DateTime completionDatetime,
      @JsonKey(name: 'recurrence_index') final int? recurrenceIndex,
      final bool ignore,
      final bool complete}) = _$TaskActionCompletionFormModelImpl;

  factory _TaskActionCompletionFormModel.fromJson(Map<String, dynamic> json) =
      _$TaskActionCompletionFormModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'action_id')
  String get actionId;
  @override
  @JsonKey(name: 'completion_datetime')
  DateTime get completionDatetime;
  @override
  @JsonKey(name: 'recurrence_index')
  int? get recurrenceIndex;
  @override
  bool get ignore;
  @override
  bool get complete;

  /// Create a copy of TaskActionCompletionFormModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaskActionCompletionFormModelImplCopyWith<
          _$TaskActionCompletionFormModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

RecurrentTaskOverwriteModel _$RecurrentTaskOverwriteModelFromJson(
    Map<String, dynamic> json) {
  return _RecurrentTaskOverwriteModel.fromJson(json);
}

/// @nodoc
mixin _$RecurrentTaskOverwriteModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'task_id')
  String get taskId => throw _privateConstructorUsedError;
  @JsonKey(name: 'recurrence_id')
  String get recurrenceId => throw _privateConstructorUsedError;
  @JsonKey(name: 'recurrence_index')
  int get recurrenceIndex => throw _privateConstructorUsedError;

  /// Serializes this RecurrentTaskOverwriteModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecurrentTaskOverwriteModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecurrentTaskOverwriteModelCopyWith<RecurrentTaskOverwriteModel>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecurrentTaskOverwriteModelCopyWith<$Res> {
  factory $RecurrentTaskOverwriteModelCopyWith(
          RecurrentTaskOverwriteModel value,
          $Res Function(RecurrentTaskOverwriteModel) then) =
      _$RecurrentTaskOverwriteModelCopyWithImpl<$Res,
          RecurrentTaskOverwriteModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'task_id') String taskId,
      @JsonKey(name: 'recurrence_id') String recurrenceId,
      @JsonKey(name: 'recurrence_index') int recurrenceIndex});
}

/// @nodoc
class _$RecurrentTaskOverwriteModelCopyWithImpl<$Res,
        $Val extends RecurrentTaskOverwriteModel>
    implements $RecurrentTaskOverwriteModelCopyWith<$Res> {
  _$RecurrentTaskOverwriteModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecurrentTaskOverwriteModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? taskId = null,
    Object? recurrenceId = null,
    Object? recurrenceIndex = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      taskId: null == taskId
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as String,
      recurrenceId: null == recurrenceId
          ? _value.recurrenceId
          : recurrenceId // ignore: cast_nullable_to_non_nullable
              as String,
      recurrenceIndex: null == recurrenceIndex
          ? _value.recurrenceIndex
          : recurrenceIndex // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RecurrentTaskOverwriteModelImplCopyWith<$Res>
    implements $RecurrentTaskOverwriteModelCopyWith<$Res> {
  factory _$$RecurrentTaskOverwriteModelImplCopyWith(
          _$RecurrentTaskOverwriteModelImpl value,
          $Res Function(_$RecurrentTaskOverwriteModelImpl) then) =
      __$$RecurrentTaskOverwriteModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'task_id') String taskId,
      @JsonKey(name: 'recurrence_id') String recurrenceId,
      @JsonKey(name: 'recurrence_index') int recurrenceIndex});
}

/// @nodoc
class __$$RecurrentTaskOverwriteModelImplCopyWithImpl<$Res>
    extends _$RecurrentTaskOverwriteModelCopyWithImpl<$Res,
        _$RecurrentTaskOverwriteModelImpl>
    implements _$$RecurrentTaskOverwriteModelImplCopyWith<$Res> {
  __$$RecurrentTaskOverwriteModelImplCopyWithImpl(
      _$RecurrentTaskOverwriteModelImpl _value,
      $Res Function(_$RecurrentTaskOverwriteModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of RecurrentTaskOverwriteModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? taskId = null,
    Object? recurrenceId = null,
    Object? recurrenceIndex = null,
  }) {
    return _then(_$RecurrentTaskOverwriteModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      taskId: null == taskId
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as String,
      recurrenceId: null == recurrenceId
          ? _value.recurrenceId
          : recurrenceId // ignore: cast_nullable_to_non_nullable
              as String,
      recurrenceIndex: null == recurrenceIndex
          ? _value.recurrenceIndex
          : recurrenceIndex // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecurrentTaskOverwriteModelImpl
    with DiagnosticableTreeMixin
    implements _RecurrentTaskOverwriteModel {
  const _$RecurrentTaskOverwriteModelImpl(
      {required this.id,
      @JsonKey(name: 'task_id') required this.taskId,
      @JsonKey(name: 'recurrence_id') required this.recurrenceId,
      @JsonKey(name: 'recurrence_index') required this.recurrenceIndex});

  factory _$RecurrentTaskOverwriteModelImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$RecurrentTaskOverwriteModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'task_id')
  final String taskId;
  @override
  @JsonKey(name: 'recurrence_id')
  final String recurrenceId;
  @override
  @JsonKey(name: 'recurrence_index')
  final int recurrenceIndex;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'RecurrentTaskOverwriteModel(id: $id, taskId: $taskId, recurrenceId: $recurrenceId, recurrenceIndex: $recurrenceIndex)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'RecurrentTaskOverwriteModel'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('taskId', taskId))
      ..add(DiagnosticsProperty('recurrenceId', recurrenceId))
      ..add(DiagnosticsProperty('recurrenceIndex', recurrenceIndex));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecurrentTaskOverwriteModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.taskId, taskId) || other.taskId == taskId) &&
            (identical(other.recurrenceId, recurrenceId) ||
                other.recurrenceId == recurrenceId) &&
            (identical(other.recurrenceIndex, recurrenceIndex) ||
                other.recurrenceIndex == recurrenceIndex));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, taskId, recurrenceId, recurrenceIndex);

  /// Create a copy of RecurrentTaskOverwriteModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecurrentTaskOverwriteModelImplCopyWith<_$RecurrentTaskOverwriteModelImpl>
      get copyWith => __$$RecurrentTaskOverwriteModelImplCopyWithImpl<
          _$RecurrentTaskOverwriteModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecurrentTaskOverwriteModelImplToJson(
      this,
    );
  }
}

abstract class _RecurrentTaskOverwriteModel
    implements RecurrentTaskOverwriteModel {
  const factory _RecurrentTaskOverwriteModel(
      {required final String id,
      @JsonKey(name: 'task_id') required final String taskId,
      @JsonKey(name: 'recurrence_id') required final String recurrenceId,
      @JsonKey(name: 'recurrence_index')
      required final int recurrenceIndex}) = _$RecurrentTaskOverwriteModelImpl;

  factory _RecurrentTaskOverwriteModel.fromJson(Map<String, dynamic> json) =
      _$RecurrentTaskOverwriteModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'task_id')
  String get taskId;
  @override
  @JsonKey(name: 'recurrence_id')
  String get recurrenceId;
  @override
  @JsonKey(name: 'recurrence_index')
  int get recurrenceIndex;

  /// Create a copy of RecurrentTaskOverwriteModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecurrentTaskOverwriteModelImplCopyWith<_$RecurrentTaskOverwriteModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
