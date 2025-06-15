// lib/features/tasks/data/repositories/tasks_repository.dart
// Tasks repository that handles CRUD operations for tasks with Supabase

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import 'package:vuet_flutter/core/utils/logger.dart';
import 'package:vuet_flutter/data/models/task_model.dart';
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
  Future<void> addReminder(String taskId, TaskReminder reminder);
  Future<void> removeReminder(String reminderId);
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

      var query = _supabase.from('tasks').select('''
        *,
        recurrences!left(*),
        completions:task_completion_forms!left(*),
        reminders:task_reminders!left(*),
        task_members!left(member_id),
        task_entities!left(entity_id)
      ''');

      // Filter by current user's tasks (either owner or member)
      query = query.or(
          'task_members.member_id.eq.$_currentUserId,task_entities.entity_id.in.(select id from entities where owner_id.eq.$_currentUserId)');

      if (userId != null) {
        query = query.eq('task_members.member_id', userId);
      }

      if (entityId != null) {
        query = query.eq('task_entities.entity_id', entityId);
      }

      if (dueDate != null) {
        query = query.eq('due_date', dueDate.toIso8601String().split('T').first);
      }

      if (!includeCompleted) {
        // This is a simplified check. A more robust solution would involve
        // checking if the latest completion form marks it as incomplete.
        // For now, we assume tasks without completion forms are incomplete.
        query = query.eq('completed', false);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.ilike('title', '%$searchQuery%');
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List).map((json) => TaskModel.fromJson(json)).toList();
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

      final taskData = task.toJson();
      // Remove nested objects for initial task insert
      final Map<String, dynamic> insertData = {
        ...taskData,
        'recurrence': null, // Handle separately if needed
        'completions': null,
        'reminders': null,
        'assigned_to': null, // Handle task_members/task_entities separately
      };

      final response = await _supabase.from('tasks').insert(insertData).select().single();
      final newTask = TaskModel.fromJson(response);

      // Add current user as a member by default
      await _supabase.from('task_members').insert({
        'task_id': newTask.id,
        'member_id': _currentUserId,
      });

      // Handle recurrence if present
      if (task.recurrence != null) {
        await _supabase.from('recurrences').insert({
          ...task.recurrence!.toJson(),
          'task_id': newTask.id,
        });
      }

      // Handle reminders if present
      for (var reminder in task.reminders) {
        await _supabase.from('task_reminders').insert({
          ...reminder.toJson(),
          'task_id': newTask.id,
        });
      }

      // Handle assigned entities/users
      for (var assignedId in task.assignedTo) {
        // Determine if this is a user or entity ID and insert accordingly
        final userExists = await _supabase.from('profiles').select('id').eq('id', assignedId).maybeSingle();
        
        if (userExists != null) {
          // This is a user ID
          await _supabase.from('task_members').insert({
            'task_id': newTask.id,
            'member_id': assignedId,
          });
        } else {
          // This is an entity ID
          await _supabase.from('task_entities').insert({
            'task_id': newTask.id,
            'entity_id': assignedId,
          });
        }
      }

      // Re-fetch the task with all its relations to return a complete model
      return (await fetchTasks(searchQuery: newTask.id)).first;
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
      // Remove nested objects for update
      final Map<String, dynamic> updateData = {
        ...taskData,
        'recurrence': null,
        'completions': null,
        'reminders': null,
        'assigned_to': null,
      };

      final response = await _supabase.from('tasks').update(updateData).eq('id', task.id).select().single();
      final updatedTask = TaskModel.fromJson(response);

      // Update recurrence if present (upsert logic)
      if (task.recurrence != null) {
        await _supabase.from('recurrences').upsert({
          ...task.recurrence!.toJson(),
          'task_id': updatedTask.id,
        });
      } else {
        // If recurrence is removed, delete it
        await _supabase.from('recurrences').delete().eq('task_id', updatedTask.id);
      }

      // Update assigned entities/users
      // First, clear existing assignments
      await _supabase.from('task_members').delete().eq('task_id', task.id);
      await _supabase.from('task_entities').delete().eq('task_id', task.id);
      
      // Then re-add current assignments
      for (var assignedId in task.assignedTo) {
        // Determine if this is a user or entity ID and insert accordingly
        final userExists = await _supabase.from('profiles').select('id').eq('id', assignedId).maybeSingle();
        
        if (userExists != null) {
          // This is a user ID
          await _supabase.from('task_members').insert({
            'task_id': task.id,
            'member_id': assignedId,
          });
        } else {
          // This is an entity ID
          await _supabase.from('task_entities').insert({
            'task_id': task.id,
            'entity_id': assignedId,
          });
        }
      }

      // Re-fetch the task with all its relations to return a complete model
      return (await fetchTasks(searchQuery: updatedTask.id)).first;
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
      // Update the 'completed' status on the main task table
      await _supabase.from('tasks').update({'completed': true}).eq('id', taskId);
    } catch (e, st) {
      Logger.error('Failed to complete task', e, st);
      rethrow;
    }
  }

  /// Marks a task as partially complete
  @override
  Future<void> markTaskPartiallyComplete(String taskId, {int? recurrenceIndex}) async {
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
      // Do not update the 'completed' status on the main task table since it's only partial
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

      final response = await _supabase.from('tasks').select('''
        *,
        recurrences!left(*),
        completions:task_completion_forms!left(*),
        reminders:task_reminders!left(*),
        task_members!left(member_id),
        task_entities!left(entity_id)
      ''').or('title.ilike.%$query%,notes.ilike.%$query%').order('created_at', ascending: false);

      return (response as List).map((json) => TaskModel.fromJson(json)).toList();
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

      final response = await _supabase.from('tasks').select('''
        *,
        recurrences!left(*),
        completions:task_completion_forms!left(*),
        reminders:task_reminders!left(*),
        task_members!left(member_id),
        task_entities!left(entity_id)
      ''').eq('task_entities.entity_id', entityId).order('due_date', ascending: true);

      return (response as List).map((json) => TaskModel.fromJson(json)).toList();
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
      
      final response = await _supabase.from('tasks').select('''
        *,
        recurrences!left(*),
        completions:task_completion_forms!left(*),
        reminders:task_reminders!left(*),
        task_members!left(member_id),
        task_entities!left(entity_id)
      ''')
      .lt('due_date', today)
      .eq('completed', false)
      .or('task_members.member_id.eq.$_currentUserId,task_entities.entity_id.in.(select id from entities where owner_id.eq.$_currentUserId)')
      .order('due_date', ascending: true);

      return (response as List).map((json) => TaskModel.fromJson(json)).toList();
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
      final futureDate = DateTime.now().add(Duration(days: days)).toIso8601String().split('T').first;
      
      final response = await _supabase.from('tasks').select('''
        *,
        recurrences!left(*),
        completions:task_completion_forms!left(*),
        reminders:task_reminders!left(*),
        task_members!left(member_id),
        task_entities!left(entity_id)
      ''')
      .gte('due_date', today)
      .lte('due_date', futureDate)
      .eq('completed', false)
      .or('task_members.member_id.eq.$_currentUserId,task_entities.entity_id.in.(select id from entities where owner_id.eq.$_currentUserId)')
      .order('due_date', ascending: true);

      return (response as List).map((json) => TaskModel.fromJson(json)).toList();
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
