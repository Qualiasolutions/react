// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TaskMembershipModelImpl _$$TaskMembershipModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TaskMembershipModelImpl(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      memberId: json['member_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$TaskMembershipModelImplToJson(
        _$TaskMembershipModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'task_id': instance.taskId,
      'member_id': instance.memberId,
      'created_at': instance.createdAt.toIso8601String(),
    };

_$TaskViewershipModelImpl _$$TaskViewershipModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TaskViewershipModelImpl(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      memberId: json['member_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$TaskViewershipModelImplToJson(
        _$TaskViewershipModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'task_id': instance.taskId,
      'member_id': instance.memberId,
      'created_at': instance.createdAt.toIso8601String(),
    };

_$TaskEntityModelImpl _$$TaskEntityModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TaskEntityModelImpl(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      entityId: json['entity_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$TaskEntityModelImplToJson(
        _$TaskEntityModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'task_id': instance.taskId,
      'entity_id': instance.entityId,
      'created_at': instance.createdAt.toIso8601String(),
    };

_$RecurrenceModelImpl _$$RecurrenceModelImplFromJson(
        Map<String, dynamic> json) =>
    _$RecurrenceModelImpl(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      recurrence: $enumDecode(_$RecurrenceTypeEnumMap, json['recurrence']),
      intervalLength: (json['interval_length'] as num?)?.toInt() ?? 1,
      earliestOccurrence: json['earliest_occurrence'] == null
          ? null
          : DateTime.parse(json['earliest_occurrence'] as String),
      latestOccurrence: json['latest_occurrence'] == null
          ? null
          : DateTime.parse(json['latest_occurrence'] as String),
    );

Map<String, dynamic> _$$RecurrenceModelImplToJson(
        _$RecurrenceModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'task_id': instance.taskId,
      'recurrence': _$RecurrenceTypeEnumMap[instance.recurrence]!,
      'interval_length': instance.intervalLength,
      'earliest_occurrence': instance.earliestOccurrence?.toIso8601String(),
      'latest_occurrence': instance.latestOccurrence?.toIso8601String(),
    };

const _$RecurrenceTypeEnumMap = {
  RecurrenceType.daily: 'DAILY',
  RecurrenceType.weekdaily: 'WEEKDAILY',
  RecurrenceType.weekly: 'WEEKLY',
  RecurrenceType.monthly: 'MONTHLY',
  RecurrenceType.yearly: 'YEARLY',
  RecurrenceType.monthWeekly: 'MONTH_WEEKLY',
  RecurrenceType.yearMonthWeekly: 'YEAR_MONTH_WEEKLY',
  RecurrenceType.monthlyLastWeek: 'MONTHLY_LAST_WEEK',
};

_$TaskActionModelImpl _$$TaskActionModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TaskActionModelImpl(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      actionTimedelta: json['action_timedelta'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$TaskActionModelImplToJson(
        _$TaskActionModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'task_id': instance.taskId,
      'action_timedelta': instance.actionTimedelta,
      'created_at': instance.createdAt.toIso8601String(),
    };

_$TaskReminderModelImpl _$$TaskReminderModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TaskReminderModelImpl(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      timedelta: json['timedelta'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$TaskReminderModelImplToJson(
        _$TaskReminderModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'task_id': instance.taskId,
      'timedelta': instance.timedelta,
      'created_at': instance.createdAt.toIso8601String(),
    };

_$TaskCompletionFormModelImpl _$$TaskCompletionFormModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TaskCompletionFormModelImpl(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      completionDatetime: DateTime.parse(json['completion_datetime'] as String),
      recurrenceIndex: (json['recurrence_index'] as num?)?.toInt(),
      complete: json['complete'] as bool? ?? true,
      partial: json['partial'] as bool? ?? false,
    );

Map<String, dynamic> _$$TaskCompletionFormModelImplToJson(
        _$TaskCompletionFormModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'task_id': instance.taskId,
      'completion_datetime': instance.completionDatetime.toIso8601String(),
      'recurrence_index': instance.recurrenceIndex,
      'complete': instance.complete,
      'partial': instance.partial,
    };

_$TaskActionCompletionFormModelImpl
    _$$TaskActionCompletionFormModelImplFromJson(Map<String, dynamic> json) =>
        _$TaskActionCompletionFormModelImpl(
          id: json['id'] as String,
          actionId: json['action_id'] as String,
          completionDatetime:
              DateTime.parse(json['completion_datetime'] as String),
          recurrenceIndex: (json['recurrence_index'] as num?)?.toInt(),
          ignore: json['ignore'] as bool? ?? false,
          complete: json['complete'] as bool? ?? true,
        );

Map<String, dynamic> _$$TaskActionCompletionFormModelImplToJson(
        _$TaskActionCompletionFormModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'action_id': instance.actionId,
      'completion_datetime': instance.completionDatetime.toIso8601String(),
      'recurrence_index': instance.recurrenceIndex,
      'ignore': instance.ignore,
      'complete': instance.complete,
    };

_$RecurrentTaskOverwriteModelImpl _$$RecurrentTaskOverwriteModelImplFromJson(
        Map<String, dynamic> json) =>
    _$RecurrentTaskOverwriteModelImpl(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      recurrenceId: json['recurrence_id'] as String,
      recurrenceIndex: (json['recurrence_index'] as num).toInt(),
    );

Map<String, dynamic> _$$RecurrentTaskOverwriteModelImplToJson(
        _$RecurrentTaskOverwriteModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'task_id': instance.taskId,
      'recurrence_id': instance.recurrenceId,
      'recurrence_index': instance.recurrenceIndex,
    };
