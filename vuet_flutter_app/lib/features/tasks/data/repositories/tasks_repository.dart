// lib/features/tasks/data/repositories/tasks_repository.dart
// Tasks repository that handles CRUD operations for tasks with Supabase

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import 'package:vuet_flutter/core/utils/logger.dart';
import 'package:vuet_flutter/features/tasks/data/models/task_model.dart';
import 'package:vuet_flutter/features/auth/providers/auth_provider.dart';

/// Abstract class for Task Repository
abstract class BaseTasksRepository {
  Future<List<TaskModel>> fetchTasks({
    String? userId,
    String? entityId,
    DateTime? dueDate,
    bool includeCompleted = false,
    String? searchQuery,
  });

  Future<TaskModel> createTask(TaskModel task);
  Future<TaskModel> updateTask(TaskModel task);
  Future<void> deleteTask(String taskId);
  Future<void> completeTask(String taskId, {int? recurrenceIndex});
  Future<void> markTaskPartiallyComplete(String taskId, {int? recurrenceIndex});

  Future<List<TaskModel>> searchTasks(String query);
  Future<List<TaskModel>> fetchTasksForEntity(String entityId);
  Future<List<TaskModel>> fetchOverdueTasks();
  Future<List<TaskModel>> fetchUpcomingTasks({int days = 7});
}

/// Supabase implementation of the Task Repository
class SupabaseTasksRepository implements BaseTasksRepository {
  final SupabaseClient _supabase;
  final String? _currentUserId;

  SupabaseTasksRepository(this._supabase, this._currentUserId);

  /// Fetches tasks based on various criteria
  @override
  Future<List<TaskModel>> fetchTasks({
    String? userId,
    String? entityId,
    DateTime? dueDate,
    bool includeCompleted = false,
    String? searchQuery,
  }) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      var query = _supabase.from('tasks').select('*');

      if (userId != null) {
        // Filter by user tasks through task_members table
        query = query.eq('user_id', userId);
      }

      if (entityId != null) {
        // Filter by entity tasks through task_entities table
        query = query.eq('entity_id', entityId);
      }

      if (dueDate != null) {
        query =
            query.eq('due_date', dueDate.toIso8601String().split('T').first);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.ilike('title', '%$searchQuery%');
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List)
          .map((json) => TaskModel.fromJson(json))
          .toList();
    } catch (e, st) {
      Logger.error('Failed to fetch tasks', e, st);
      rethrow;
    }
  }

  /// Creates a new task
  @override
  Future<TaskModel> createTask(TaskModel task) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Build task data manually since TaskModel doesn't have toJson()
      final Map<String, dynamic> taskData = {
        'id': task.id,
        'title': task.title,
        'type': task.type.name.toUpperCase(),
        'notes': task.notes,
        'location': task.location,
        'contact_name': task.contactName,
        'contact_email': task.contactEmail,
        'contact_phone': task.contactPhone,
        'hidden_tag': task.hiddenTag?.name.toUpperCase(),
        'tags': task.tags,
        'routine_id': task.routineId,
        'created_at': task.createdAt.toIso8601String(),
        'updated_at': task.updatedAt.toIso8601String(),
      };

      // Add specific fields based on task type
      task.when(
        (id, title, type, notes, location, contactName, contactEmail,
            contactPhone, hiddenTag, tags, routineId, createdAt, updatedAt) {
          // Base case - no additional fields needed
        },
        fixed: (id,
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
            startTimezone,
            endTimezone,
            startDate,
            endDate,
            date,
            duration) {
          taskData.addAll({
            'start_datetime': startDatetime?.toIso8601String(),
            'end_datetime': endDatetime?.toIso8601String(),
            'start_timezone': startTimezone,
            'end_timezone': endTimezone,
            'start_date': startDate?.toIso8601String(),
            'end_date': endDate?.toIso8601String(),
            'date': date?.toIso8601String(),
            'duration': duration,
          });
        },
        flexible: (id,
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
            urgency) {
          taskData.addAll({
            'earliest_action_date': earliestActionDate?.toIso8601String(),
            'due_date': dueDate?.toIso8601String(),
            'duration': duration,
            'urgency': urgency?.name.toUpperCase(),
          });
        },
      );

      final response =
          await _supabase.from('tasks').insert(taskData).select().single();

      return TaskModel.fromJson(response);
    } catch (e, st) {
      Logger.error('Failed to create task', e, st);
      rethrow;
    }
  }

  /// Updates an existing task
  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final taskData = task.toJson();

      final response = await _supabase
          .from('tasks')
          .update(taskData)
          .eq('id', task.id)
          .select()
          .single();

      return TaskModel.fromJson(response);
    } catch (e, st) {
      Logger.error('Failed to update task', e, st);
      rethrow;
    }
  }

  /// Deletes a task
  @override
  Future<void> deleteTask(String taskId) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }
      await _supabase.from('tasks').delete().eq('id', taskId);
    } catch (e, st) {
      Logger.error('Failed to delete task', e, st);
      rethrow;
    }
  }

  /// Marks a task as complete
  @override
  Future<void> completeTask(String taskId, {int? recurrenceIndex}) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      await _supabase.from('task_completion_forms').insert({
        'task_id': taskId,
        'completion_datetime': DateTime.now().toIso8601String(),
        'recurrence_index': recurrenceIndex,
        'complete': true,
        'partial': false,
      });
    } catch (e, st) {
      Logger.error('Failed to complete task', e, st);
      rethrow;
    }
  }

  /// Marks a task as partially complete
  @override
  Future<void> markTaskPartiallyComplete(String taskId,
      {int? recurrenceIndex}) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      await _supabase.from('task_completion_forms').insert({
        'task_id': taskId,
        'completion_datetime': DateTime.now().toIso8601String(),
        'recurrence_index': recurrenceIndex,
        'complete': false,
        'partial': true,
      });
    } catch (e, st) {
      Logger.error('Failed to mark task as partially complete', e, st);
      rethrow;
    }
  }

  /// Adds a reminder to a task
  @override
  Future<void> addReminder(String taskId, TaskReminder reminder) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }
      await _supabase.from('task_reminders').insert({
        ...reminder.toJson(),
        'task_id': taskId,
      });
    } catch (e, st) {
      Logger.error('Failed to add reminder', e, st);
      rethrow;
    }
  }

  /// Removes a reminder from a task
  @override
  Future<void> removeReminder(String reminderId) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }
      await _supabase.from('task_reminders').delete().eq('id', reminderId);
    } catch (e, st) {
      Logger.error('Failed to remove reminder', e, st);
      rethrow;
    }
  }

  /// Searches tasks by title or notes
  @override
  Future<List<TaskModel>> searchTasks(String query) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('tasks')
          .select('*')
          .or('title.ilike.%$query%,notes.ilike.%$query%')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => TaskModel.fromJson(json))
          .toList();
    } catch (e, st) {
      Logger.error('Failed to search tasks', e, st);
      rethrow;
    }
  }

  /// Fetches tasks for a specific entity
  @override
  Future<List<TaskModel>> fetchTasksForEntity(String entityId) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('tasks')
          .select('*')
          .eq('entity_id', entityId)
          .order('due_date', ascending: true);

      return (response as List)
          .map((json) => TaskModel.fromJson(json))
          .toList();
    } catch (e, st) {
      Logger.error('Failed to fetch tasks for entity', e, st);
      rethrow;
    }
  }

  /// Fetches overdue tasks
  @override
  Future<List<TaskModel>> fetchOverdueTasks() async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final today = DateTime.now().toIso8601String().split('T').first;

      final response = await _supabase
          .from('tasks')
          .select('*')
          .lt('due_date', today)
          .order('due_date', ascending: true);

      return (response as List)
          .map((json) => TaskModel.fromJson(json))
          .toList();
    } catch (e, st) {
      Logger.error('Failed to fetch overdue tasks', e, st);
      rethrow;
    }
  }

  /// Fetches upcoming tasks for the next X days
  @override
  Future<List<TaskModel>> fetchUpcomingTasks({int days = 7}) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final today = DateTime.now().toIso8601String().split('T').first;
      final futureDate = DateTime.now()
          .add(Duration(days: days))
          .toIso8601String()
          .split('T')
          .first;

      final response = await _supabase
          .from('tasks')
          .select('*')
          .gte('due_date', today)
          .lte('due_date', futureDate)
          .order('due_date', ascending: true);

      return (response as List)
          .map((json) => TaskModel.fromJson(json))
          .toList();
    } catch (e, st) {
      Logger.error('Failed to fetch upcoming tasks', e, st);
      rethrow;
    }
  }
}

/// Provider for the Tasks Repository
final tasksRepositoryProvider = Provider<BaseTasksRepository>((ref) {
  final supabase = Supabase.instance.client;
  final currentUserId = ref.watch(userIdProvider);
  return SupabaseTasksRepository(supabase, currentUserId);
});
