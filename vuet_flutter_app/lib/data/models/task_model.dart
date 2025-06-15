// lib/data/models/task_model.dart
// Simplified task model without freezed dependencies for basic operations

import 'package:flutter/material.dart';
import 'package:vuet_flutter/core/constants/app_constants.dart';

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
  icalEvent;

  /// Convert from string (from Supabase)
  static TaskType fromString(String value) {
    try {
      return TaskType.values.firstWhere(
        (e) => e.toString().split('.').last.toUpperCase() == value.toUpperCase(),
        orElse: () => TaskType.task,
      );
    } catch (_) {
      return TaskType.task;
    }
  }

  /// Convert to string (for Supabase)
  String toDbString() {
    return toString().split('.').last.toUpperCase();
  }
}

/// Enum for task urgency levels.
/// Corresponds to `URGENCY_CHOICES` in Django.
enum UrgencyType {
  @JsonValue('LOW')
  low,
  @JsonValue('MEDIUM')
  medium,
  @JsonValue('HIGH')
  high;

  /// Convert from string (from Supabase)
  static UrgencyType fromString(String value) {
    try {
      return UrgencyType.values.firstWhere(
        (e) => e.toString().split('.').last.toUpperCase() == value.toUpperCase(),
        orElse: () => UrgencyType.medium,
      );
    } catch (_) {
      return UrgencyType.medium;
    }
  }

  /// Convert to string (for Supabase)
  String toDbString() {
    return toString().split('.').last.toUpperCase();
  }
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
  monthlyLastWeek;

  /// Convert from string (from Supabase)
  static RecurrenceType fromString(String value) {
    try {
      return RecurrenceType.values.firstWhere(
        (e) => e.toString().split('.').last.toUpperCase() == value.toUpperCase(),
        orElse: () => RecurrenceType.daily,
      );
    } catch (_) {
      return RecurrenceType.daily;
    }
  }

  /// Convert to string (for Supabase)
  String toDbString() {
    return toString().split('.').last.toUpperCase();
  }
}

/// Model for task recurrence information.
class TaskRecurrence {
  final String id;
  final RecurrenceType recurrence;
  final int intervalLength;
  final DateTime? earliestOccurrence;
  final DateTime? latestOccurrence;

  TaskRecurrence({
    required this.id,
    required this.recurrence,
    this.intervalLength = 1,
    this.earliestOccurrence,
    this.latestOccurrence,
  });

  factory TaskRecurrence.fromJson(Map<String, dynamic> json) {
    return TaskRecurrence(
      id: json['id'] as String,
      recurrence: RecurrenceType.fromString(json['recurrence'] as String),
      intervalLength: json['interval_length'] as int? ?? 1,
      earliestOccurrence: json['earliest_occurrence'] != null
          ? DateTime.parse(json['earliest_occurrence'] as String)
          : null,
      latestOccurrence: json['latest_occurrence'] != null
          ? DateTime.parse(json['latest_occurrence'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recurrence': recurrence.toDbString(),
      'interval_length': intervalLength,
      'earliest_occurrence': earliestOccurrence?.toIso8601String(),
      'latest_occurrence': latestOccurrence?.toIso8601String(),
    };
  }
}

/// Model for task reminder settings.
class TaskReminder {
  final String id;
  final String timedelta; // e.g., '1 day', '30 minutes'
  final DateTime createdAt;

  TaskReminder({
    required this.id,
    required this.timedelta,
    required this.createdAt,
  });

  factory TaskReminder.fromJson(Map<String, dynamic> json) {
    return TaskReminder(
      id: json['id'] as String,
      timedelta: json['timedelta'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timedelta': timedelta,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Model for task completion tracking.
class TaskCompletion {
  final String id;
  final DateTime completionDatetime;
  final int? recurrenceIndex;
  final bool complete;
  final bool partial;

  TaskCompletion({
    required this.id,
    required this.completionDatetime,
    this.recurrenceIndex,
    this.complete = true,
    this.partial = false,
  });

  factory TaskCompletion.fromJson(Map<String, dynamic> json) {
    return TaskCompletion(
      id: json['id'] as String,
      completionDatetime: DateTime.parse(json['completion_datetime'] as String),
      recurrenceIndex: json['recurrence_index'] as int?,
      complete: json['complete'] as bool? ?? true,
      partial: json['partial'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'completion_datetime': completionDatetime.toIso8601String(),
      'recurrence_index': recurrenceIndex,
      'complete': complete,
      'partial': partial,
    };
  }
}

/// Main Task Model
class TaskModel {
  final String id;
  final String title;
  final String? description;
  final TaskType type;
  final UrgencyType? urgency;
  final DateTime? dueDate;
  final bool completed;
  final List<String> assignedTo; // List of user or entity IDs
  final TaskRecurrence? recurrence;
  final List<TaskCompletion> completions;
  final List<TaskReminder> reminders;
  final DateTime createdAt;
  final DateTime updatedAt;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    this.urgency,
    this.dueDate,
    this.completed = false,
    this.assignedTo = const [],
    this.recurrence,
    this.completions = const [],
    this.reminders = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['notes'] as String?, // Mapping notes to description
      type: TaskType.fromString(json['type'] as String),
      urgency: json['urgency'] != null
          ? UrgencyType.fromString(json['urgency'] as String)
          : null,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      completed: json['completed'] as bool? ?? false, // Assuming a 'completed' field in DB
      assignedTo: (json['assigned_to'] as List?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      recurrence: json['recurrence'] != null
          ? TaskRecurrence.fromJson(json['recurrence'] as Map<String, dynamic>)
          : null,
      completions: (json['completions'] as List?)
              ?.map((e) => TaskCompletion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      reminders: (json['reminders'] as List?)
              ?.map((e) => TaskReminder.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'notes': description, // Mapping description back to notes
      'type': type.toDbString(),
      'urgency': urgency?.toDbString(),
      'due_date': dueDate?.toIso8601String(),
      'completed': completed,
      'assigned_to': assignedTo,
      'recurrence': recurrence?.toJson(),
      'completions': completions.map((e) => e.toJson()).toList(),
      'reminders': reminders.map((e) => e.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    TaskType? type,
    UrgencyType? urgency,
    DateTime? dueDate,
    bool? completed,
    List<String>? assignedTo,
    TaskRecurrence? recurrence,
    List<TaskCompletion>? completions,
    List<TaskReminder>? reminders,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      urgency: urgency ?? this.urgency,
      dueDate: dueDate ?? this.dueDate,
      completed: completed ?? this.completed,
      assignedTo: assignedTo ?? this.assignedTo,
      recurrence: recurrence ?? this.recurrence,
      completions: completions ?? this.completions,
      reminders: reminders ?? this.reminders,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
