import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

part 'task_model.freezed.dart';
part 'task_model.g.dart';

/// Enum representing the different types of tasks in the application.
/// Corresponds to `TASK_TYPE_CHOICES` in Django.
enum TaskType {
  @JsonValue('TASK')
  task,
  @JsonValue('APPOINTMENT')
  appointment,
  @JsonValue('DUE_DATE')
  dueDate,
  @JsonValue('FLIGHT')
  flight,
  @JsonValue('TRAIN')
  train,
  @JsonValue('RENTAL_CAR')
  rentalCar,
  @JsonValue('TAXI')
  taxi,
  @JsonValue('DRIVE_TIME')
  driveTime,
  @JsonValue('HOTEL')
  hotel,
  @JsonValue('STAY_WITH_FRIEND')
  stayWithFriend,
  @JsonValue('ACTIVITY')
  activity,
  @JsonValue('FOOD_ACTIVITY')
  foodActivity,
  @JsonValue('OTHER_ACTIVITY')
  otherActivity,
  @JsonValue('ANNIVERSARY')
  anniversary,
  @JsonValue('BIRTHDAY')
  birthday,
  @JsonValue('USER_BIRTHDAY')
  userBirthday,
  @JsonValue('HOLIDAY')
  holiday,
  @JsonValue('ICAL_EVENT')
  icalEvent,
}

/// Enum for hidden tags, e.g., for vehicle maintenance.
/// Corresponds to `HIDDEN_TAG_CHOICES` in Django.
enum HiddenTagType {
  @JsonValue('MOT_DUE')
  motDue,
  @JsonValue('INSURANCE_DUE')
  insuranceDue,
  @JsonValue('WARRANTY_DUE')
  warrantyDue,
  @JsonValue('SERVICE_DUE')
  serviceDue,
  @JsonValue('TAX_DUE')
  taxDue,
}

/// Enum for task urgency levels.
/// Corresponds to `URGENCY_CHOICES` in Django.
enum UrgencyType {
  @JsonValue('LOW')
  low,
  @JsonValue('MEDIUM')
  medium,
  @JsonValue('HIGH')
  high,
}

/// Enum for recurrence types.
/// Corresponds to `RECURRENCE_CHOICES` in Django.
enum RecurrenceType {
  @JsonValue('DAILY')
  daily,
  @JsonValue('WEEKDAILY')
  weekdaily,
  @JsonValue('WEEKLY')
  weekly,
  @JsonValue('MONTHLY')
  monthly,
  @JsonValue('YEARLY')
  yearly,
  @JsonValue('MONTH_WEEKLY')
  monthWeekly,
  @JsonValue('YEAR_MONTH_WEEKLY')
  yearMonthWeekly,
  @JsonValue('MONTHLY_LAST_WEEK')
  monthlyLastWeek,
}

/// Base data model for all tasks in the application.
/// Uses Freezed unions to represent polymorphic task types (FixedTask, FlexibleTask).
@freezed
class TaskModel with _$TaskModel {
  const TaskModel._();

  // Base task fields common to all task types
  const factory TaskModel({
    required String id,
    required String title,
    required TaskType type,
    String? notes,
    String? location,
    @JsonKey(name: 'contact_name') String? contactName,
    @JsonKey(name: 'contact_email') String? contactEmail,
    @JsonKey(name: 'contact_phone') String? contactPhone,
    @JsonKey(name: 'hidden_tag') HiddenTagType? hiddenTag,
    @Default([]) List<String> tags,
    @JsonKey(name: 'routine_id') String? routineId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _TaskModel;

  // Fixed Task variant
  const factory TaskModel.fixed({
    required String id,
    required String title,
    required TaskType type,
    String? notes,
    String? location,
    @JsonKey(name: 'contact_name') String? contactName,
    @JsonKey(name: 'contact_email') String? contactEmail,
    @JsonKey(name: 'contact_phone') String? contactPhone,
    @JsonKey(name: 'hidden_tag') HiddenTagType? hiddenTag,
    @Default([]) List<String> tags,
    @JsonKey(name: 'routine_id') String? routineId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,

    // FixedTask specific fields
    @JsonKey(name: 'start_datetime') DateTime? startDatetime,
    @JsonKey(name: 'end_datetime') DateTime? endDatetime,
    @JsonKey(name: 'start_timezone') String? startReadonlyTimezone,
    @JsonKey(name: 'end_timezone') String? endReadonlyTimezone,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'end_date') DateTime? endDate,
    DateTime? date,
    int? duration, // in minutes
  }) = FixedTaskModel;

  // Flexible Task variant
  const factory TaskModel.flexible({
    required String id,
    required String title,
    required TaskType type,
    String? notes,
    String? location,
    @JsonKey(name: 'contact_name') String? contactName,
    @JsonKey(name: 'contact_email') String? contactEmail,
    @JsonKey(name: 'contact_phone') String? contactPhone,
    @JsonKey(name: 'hidden_tag') HiddenTagType? hiddenTag,
    @Default([]) List<String> tags,
    @JsonKey(name: 'routine_id') String? routineId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,

    // FlexibleTask specific fields
    @JsonKey(name: 'earliest_action_date') DateTime? earliestActionDate,
    @JsonKey(name: 'due_date') DateTime? dueDate,
    @Default(30) int duration, // in minutes
    UrgencyType? urgency,
  }) = FlexibleTaskModel;

  // Factory constructor to deserialize from JSON, handling polymorphism
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final type = _parseTaskType(json['type']);

    // Delegate to the appropriate Freezed union constructor based on 'type'
    switch (type) {
      case TaskType.task:
      case TaskType.appointment:
      case TaskType.dueDate:
        // These are typically flexible tasks in the original app logic
        return FlexibleTaskModel.fromJson(json);
      default:
        // All other types are fixed tasks
        return FixedTaskModel.fromJson(json);
    }
  }

  // Helper to parse task type from JSON
  static TaskType _parseTaskType(dynamic typeValue) {
    if (typeValue == null) return TaskType.task;

    try {
      if (typeValue is TaskType) return typeValue;

      if (typeValue is String) {
        return TaskType.values.firstWhere(
          (e) => e.toString().split('.').last.toUpperCase() == typeValue.toUpperCase(),
          orElse: () => TaskType.task,
        );
      }
    } catch (_) {
      // Fallback to default if parsing fails
    }

    return TaskType.task;
  }
}

/// Model for task membership (many-to-many relationship between tasks and users).
@freezed
class TaskMembershipModel with _$TaskMembershipModel {
  const factory TaskMembershipModel({
    required String id,
    @JsonKey(name: 'task_id') required String taskId,
    @JsonKey(name: 'member_id') required String memberId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _TaskMembershipModel;

  factory TaskMembershipModel.fromJson(Map<String, dynamic> json) =>
      _$TaskMembershipModelFromJson(json);
}

/// Model for task viewership (many-to-many relationship between tasks and users).
@freezed
class TaskViewershipModel with _$TaskViewershipModel {
  const factory TaskViewershipModel({
    required String id,
    @JsonKey(name: 'task_id') required String taskId,
    @JsonKey(name: 'member_id') required String memberId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _TaskViewershipModel;

  factory TaskViewershipModel.fromJson(Map<String, dynamic> json) =>
      _$TaskViewershipModelFromJson(json);
}

/// Model for task entities (many-to-many relationship between tasks and entities).
@freezed
class TaskEntityModel with _$TaskEntityModel {
  const factory TaskEntityModel({
    required String id,
    @JsonKey(name: 'task_id') required String taskId,
    @JsonKey(name: 'entity_id') required String entityId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _TaskEntityModel;

  factory TaskEntityModel.fromJson(Map<String, dynamic> json) =>
      _$TaskEntityModelFromJson(json);
}

/// Model for task recurrence.
@freezed
class RecurrenceModel with _$RecurrenceModel {
  const factory RecurrenceModel({
    required String id,
    @JsonKey(name: 'task_id') required String taskId,
    required RecurrenceType recurrence,
    @JsonKey(name: 'interval_length') @Default(1) int intervalLength,
    @JsonKey(name: 'earliest_occurrence') DateTime? earliestOccurrence,
    @JsonKey(name: 'latest_occurrence') DateTime? latestOccurrence,
  }) = _RecurrenceModel;

  factory RecurrenceModel.fromJson(Map<String, dynamic> json) =>
      _$RecurrenceModelFromJson(json);
}

/// Model for task actions.
@freezed
class TaskActionModel with _$TaskActionModel {
  const factory TaskActionModel({
    required String id,
    @JsonKey(name: 'task_id') required String taskId,
    @JsonKey(name: 'action_timedelta') required String actionTimedelta, // Stored as string, e.g., '1 day'
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _TaskActionModel;

  factory TaskActionModel.fromJson(Map<String, dynamic> json) =>
      _$TaskActionModelFromJson(json);
}

/// Model for task reminders.
@freezed
class TaskReminderModel with _$TaskReminderModel {
  const factory TaskReminderModel({
    required String id,
    @JsonKey(name: 'task_id') required String taskId,
    required String timedelta, // Stored as string, e.g., '1 day'
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _TaskReminderModel;

  factory TaskReminderModel.fromJson(Map<String, dynamic> json) =>
      _$TaskReminderModelFromJson(json);
}

/// Model for task completion forms.
@freezed
class TaskCompletionFormModel with _$TaskCompletionFormModel {
  const factory TaskCompletionFormModel({
    required String id,
    @JsonKey(name: 'task_id') required String taskId,
    @JsonKey(name: 'completion_datetime') required DateTime completionDatetime,
    @JsonKey(name: 'recurrence_index') int? recurrenceIndex,
    @Default(true) bool complete,
    @Default(false) bool partial,
  }) = _TaskCompletionFormModel;

  factory TaskCompletionFormModel.fromJson(Map<String, dynamic> json) =>
      _$TaskCompletionFormModelFromJson(json);
}

/// Model for task action completion forms.
@freezed
class TaskActionCompletionFormModel with _$TaskActionCompletionFormModel {
  const factory TaskActionCompletionFormModel({
    required String id,
    @JsonKey(name: 'action_id') required String actionId,
    @JsonKey(name: 'completion_datetime') required DateTime completionDatetime,
    @JsonKey(name: 'recurrence_index') int? recurrenceIndex,
    @Default(false) bool ignore,
    @Default(true) bool complete,
  }) = _TaskActionCompletionFormModel;

  factory TaskActionCompletionFormModel.fromJson(Map<String, dynamic> json) =>
      _$TaskActionCompletionFormModelFromJson(json);
}

/// Model for recurrent task overwrites.
@freezed
class RecurrentTaskOverwriteModel with _$RecurrentTaskOverwriteModel {
  const factory RecurrentTaskOverwriteModel({
    required String id,
    @JsonKey(name: 'task_id') required String taskId,
    @JsonKey(name: 'recurrence_id') required String recurrenceId,
    @JsonKey(name: 'recurrence_index') required int recurrenceIndex,
  }) = _RecurrentTaskOverwriteModel;

  factory RecurrentTaskOverwriteModel.fromJson(Map<String, dynamic> json) =>
      _$RecurrentTaskOverwriteModelFromJson(json);
}
