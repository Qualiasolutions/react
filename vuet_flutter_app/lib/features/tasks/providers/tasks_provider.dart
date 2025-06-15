// lib/features/tasks/providers/tasks_provider.dart
// Riverpod provider for managing task state, including CRUD, filtering, and search.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vuet_flutter/core/utils/logger.dart';
import 'package:vuet_flutter/features/tasks/data/models/task_model.dart';
import 'package:vuet_flutter/features/auth/providers/auth_provider.dart';
import 'package:vuet_flutter/features/tasks/data/repositories/tasks_repository.dart';

/// Represents the state of tasks in the application.
class TasksState {
  final List<TaskModel> tasks;
  final bool isLoading;
  final String? error;
  final String? lastSearchQuery;
  final String? lastEntityId;
  final DateTime? lastDueDate;
  final bool lastIncludeCompleted;
  final bool isCached;

  const TasksState({
    this.tasks = const [],
    this.isLoading = false,
    this.error,
    this.lastSearchQuery,
    this.lastEntityId,
    this.lastDueDate,
    this.lastIncludeCompleted = false,
    this.isCached = false,
  });

  TasksState copyWith({
    List<TaskModel>? tasks,
    bool? isLoading,
    String? error,
    String? lastSearchQuery,
    String? lastEntityId,
    DateTime? lastDueDate,
    bool? lastIncludeCompleted,
    bool? isCached,
  }) {
    return TasksState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastSearchQuery: lastSearchQuery ?? this.lastSearchQuery,
      lastEntityId: lastEntityId ?? this.lastEntityId,
      lastDueDate: lastDueDate ?? this.lastDueDate,
      lastIncludeCompleted: lastIncludeCompleted ?? this.lastIncludeCompleted,
      isCached: isCached ?? this.isCached,
    );
  }
}

/// Notifier for managing task state.
class TasksNotifier extends StateNotifier<TasksState> {
  final BaseTasksRepository _repository;
  final String? _currentUserId;

  TasksNotifier(this._repository, this._currentUserId)
      : super(const TasksState());

  /// Fetches tasks based on optional filters.
  Future<void> fetchTasks({
    String? entityId,
    DateTime? dueDate,
    bool includeCompleted = false,
    String? searchQuery,
    bool forceRefresh = false,
  }) async {
    if (_currentUserId == null) {
      state = state.copyWith(error: 'User not authenticated');
      return;
    }

    // Check if we can use cached data
    if (!forceRefresh &&
        state.isCached &&
        state.lastEntityId == entityId &&
        state.lastDueDate == dueDate &&
        state.lastIncludeCompleted == includeCompleted &&
        state.lastSearchQuery == searchQuery &&
        !state.isLoading &&
        state.error == null &&
        state.tasks.isNotEmpty) {
      return; // Use cached data
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final fetchedTasks = await _repository.fetchTasks(
        userId: _currentUserId,
        entityId: entityId,
        dueDate: dueDate,
        includeCompleted: includeCompleted,
        searchQuery: searchQuery,
      );
      state = state.copyWith(
        tasks: fetchedTasks,
        isLoading: false,
        lastEntityId: entityId,
        lastDueDate: dueDate,
        lastIncludeCompleted: includeCompleted,
        lastSearchQuery: searchQuery,
        isCached: true,
      );
    } catch (e, st) {
      Logger.error('Failed to fetch tasks', e, st);
      state = state.copyWith(
          isLoading: false, error: e.toString(), isCached: false);
    }
  }

  /// Creates a new task.
  Future<TaskModel?> createTask(TaskModel task) async {
    if (_currentUserId == null) {
      state = state.copyWith(error: 'User not authenticated');
      return null;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newTask = await _repository.createTask(task);
      state = state.copyWith(
        tasks: [...state.tasks, newTask],
        isLoading: false,
      );
      return newTask;
    } catch (e, st) {
      Logger.error('Failed to create task', e, st);
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  /// Updates an existing task.
  Future<TaskModel?> updateTask(TaskModel task) async {
    if (_currentUserId == null) {
      state = state.copyWith(error: 'User not authenticated');
      return null;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedTask = await _repository.updateTask(task);
      state = state.copyWith(
        tasks: state.tasks
            .map((t) => t.id == updatedTask.id ? updatedTask : t)
            .toList(),
        isLoading: false,
      );
      return updatedTask;
    } catch (e, st) {
      Logger.error('Failed to update task', e, st);
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  /// Deletes a task.
  Future<bool> deleteTask(String taskId) async {
    if (_currentUserId == null) {
      state = state.copyWith(error: 'User not authenticated');
      return false;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.deleteTask(taskId);
      state = state.copyWith(
        tasks: state.tasks.where((t) => t.id != taskId).toList(),
        isLoading: false,
      );
      return true;
    } catch (e, st) {
      Logger.error('Failed to delete task', e, st);
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Marks a task as complete.
  Future<bool> completeTask(String taskId, {int? recurrenceIndex}) async {
    if (_currentUserId == null) {
      state = state.copyWith(error: 'User not authenticated');
      return false;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.completeTask(taskId, recurrenceIndex: recurrenceIndex);

      // Update the task in state
      state = state.copyWith(
        tasks: state.tasks.map((task) {
          if (task.id == taskId) {
            // Create a new completion record
            final newCompletion = TaskCompletion(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              completionDatetime: DateTime.now(),
              recurrenceIndex: recurrenceIndex,
              complete: true,
              partial: false,
            );

            // Add to existing completions
            final updatedCompletions = [...task.completions, newCompletion];

            // Return updated task
            return task.copyWith(
              completed: true,
              completions: updatedCompletions,
            );
          }
          return task;
        }).toList(),
        isLoading: false,
      );
      return true;
    } catch (e, st) {
      Logger.error('Failed to complete task', e, st);
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Marks a task as partially complete.
  Future<bool> markTaskPartiallyComplete(String taskId,
      {int? recurrenceIndex}) async {
    if (_currentUserId == null) {
      state = state.copyWith(error: 'User not authenticated');
      return false;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.markTaskPartiallyComplete(taskId,
          recurrenceIndex: recurrenceIndex);

      // Update the task in state
      state = state.copyWith(
        tasks: state.tasks.map((task) {
          if (task.id == taskId) {
            // Create a new completion record
            final newCompletion = TaskCompletion(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              completionDatetime: DateTime.now(),
              recurrenceIndex: recurrenceIndex,
              complete: false,
              partial: true,
            );

            // Add to existing completions
            final updatedCompletions = [...task.completions, newCompletion];

            // Return updated task (note: completed status remains false)
            return task.copyWith(
              completions: updatedCompletions,
            );
          }
          return task;
        }).toList(),
        isLoading: false,
      );
      return true;
    } catch (e, st) {
      Logger.error('Failed to mark task partially complete', e, st);
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Adds a reminder to a task.
  Future<bool> addReminder(String taskId, TaskReminder reminder) async {
    if (_currentUserId == null) {
      state = state.copyWith(error: 'User not authenticated');
      return false;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.addReminder(taskId, reminder);

      // Update the task in state
      state = state.copyWith(
        tasks: state.tasks.map((task) {
          if (task.id == taskId) {
            return task.copyWith(
              reminders: [...task.reminders, reminder],
            );
          }
          return task;
        }).toList(),
        isLoading: false,
      );
      return true;
    } catch (e, st) {
      Logger.error('Failed to add reminder', e, st);
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Removes a reminder from a task.
  Future<bool> removeReminder(String reminderId) async {
    if (_currentUserId == null) {
      state = state.copyWith(error: 'User not authenticated');
      return false;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.removeReminder(reminderId);

      // Update all tasks in state to remove this reminder
      state = state.copyWith(
        tasks: state.tasks.map((task) {
          return task.copyWith(
            reminders: task.reminders.where((r) => r.id != reminderId).toList(),
          );
        }).toList(),
        isLoading: false,
      );
      return true;
    } catch (e, st) {
      Logger.error('Failed to remove reminder', e, st);
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Searches tasks by title or notes.
  Future<void> searchTasks(String query) async {
    await fetchTasks(searchQuery: query, forceRefresh: true);
  }

  /// Fetches tasks for a specific entity.
  Future<void> fetchTasksForEntity(String entityId) async {
    if (_currentUserId == null) {
      state = state.copyWith(error: 'User not authenticated');
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final fetchedTasks = await _repository.fetchTasksForEntity(entityId);
      state = state.copyWith(
        tasks: fetchedTasks,
        isLoading: false,
        lastEntityId: entityId,
        isCached: true,
      );
    } catch (e, st) {
      Logger.error('Failed to fetch tasks for entity', e, st);
      state = state.copyWith(
          isLoading: false, error: e.toString(), isCached: false);
    }
  }

  /// Fetches overdue tasks.
  Future<void> fetchOverdueTasks() async {
    if (_currentUserId == null) {
      state = state.copyWith(error: 'User not authenticated');
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final fetchedTasks = await _repository.fetchOverdueTasks();
      state = state.copyWith(
        tasks: fetchedTasks,
        isLoading: false,
        isCached: true,
      );
    } catch (e, st) {
      Logger.error('Failed to fetch overdue tasks', e, st);
      state = state.copyWith(
          isLoading: false, error: e.toString(), isCached: false);
    }
  }

  /// Fetches upcoming tasks for the next X days.
  Future<void> fetchUpcomingTasks({int days = 7}) async {
    if (_currentUserId == null) {
      state = state.copyWith(error: 'User not authenticated');
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final fetchedTasks = await _repository.fetchUpcomingTasks(days: days);
      state = state.copyWith(
        tasks: fetchedTasks,
        isLoading: false,
        isCached: true,
      );
    } catch (e, st) {
      Logger.error('Failed to fetch upcoming tasks', e, st);
      state = state.copyWith(
          isLoading: false, error: e.toString(), isCached: false);
    }
  }

  /// Gets a single task by ID from the current state.
  TaskModel? getTaskById(String id) {
    try {
      return state.tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Filters tasks by type.
  List<TaskModel> filterTasksByType(TaskType type) {
    return state.tasks.where((task) => task.type == type).toList();
  }

  /// Filters tasks by urgency.
  List<TaskModel> filterTasksByUrgency(UrgencyType urgency) {
    return state.tasks.where((task) => task.urgency == urgency).toList();
  }

  /// Filters tasks by completion status.
  List<TaskModel> filterTasksByCompletion(bool isCompleted) {
    return state.tasks.where((task) => task.completed == isCompleted).toList();
  }

  /// Filters tasks by due date.
  List<TaskModel> filterTasksByDueDate(DateTime date) {
    return state.tasks.where((task) {
      if (task.dueDate == null) return false;
      return task.dueDate!.year == date.year &&
          task.dueDate!.month == date.month &&
          task.dueDate!.day == date.day;
    }).toList();
  }

  /// Gets tasks due today.
  List<TaskModel> getTasksDueToday() {
    final today = DateTime.now();
    return filterTasksByDueDate(today);
  }
}

/// Main tasks provider.
final tasksProvider = StateNotifierProvider<TasksNotifier, TasksState>((ref) {
  final repository = ref.watch(tasksRepositoryProvider);
  final currentUserId = ref.watch(userIdProvider);
  return TasksNotifier(repository, currentUserId);
});

/// Provider for overdue tasks.
final overdueTasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  final tasksNotifier = ref.watch(tasksProvider.notifier);
  await tasksNotifier.fetchOverdueTasks();
  return ref.watch(tasksProvider).tasks;
});

/// Provider for upcoming tasks.
final upcomingTasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  final tasksNotifier = ref.watch(tasksProvider.notifier);
  await tasksNotifier.fetchUpcomingTasks();
  return ref.watch(tasksProvider).tasks;
});

/// Provider for tasks due today.
final todayTasksProvider = Provider<List<TaskModel>>((ref) {
  final tasksState = ref.watch(tasksProvider);
  final today = DateTime.now();
  return tasksState.tasks.where((task) {
    if (task.dueDate == null) return false;
    return task.dueDate!.year == today.year &&
        task.dueDate!.month == today.month &&
        task.dueDate!.day == today.day;
  }).toList();
});

/// Provider for tasks by entity.
final tasksByEntityProvider =
    FutureProvider.family<List<TaskModel>, String>((ref, entityId) async {
  final tasksNotifier = ref.watch(tasksProvider.notifier);
  await tasksNotifier.fetchTasksForEntity(entityId);
  return ref.watch(tasksProvider).tasks;
});

/// Provider for a single task by ID.
final taskByIdProvider = Provider.family<TaskModel?, String>((ref, taskId) {
  final tasksState = ref.watch(tasksProvider);
  try {
    return tasksState.tasks.firstWhere((task) => task.id == taskId);
  } catch (e) {
    return null;
  }
});

/// Provider for tasks by type.
final tasksByTypeProvider =
    Provider.family<List<TaskModel>, TaskType>((ref, type) {
  final tasksState = ref.watch(tasksProvider);
  return tasksState.tasks.where((task) => task.type == type).toList();
});

/// Provider for tasks by urgency.
final tasksByUrgencyProvider =
    Provider.family<List<TaskModel>, UrgencyType>((ref, urgency) {
  final tasksState = ref.watch(tasksProvider);
  return tasksState.tasks.where((task) => task.urgency == urgency).toList();
});

/// Provider for tasks by completion status.
final tasksByCompletionProvider =
    Provider.family<List<TaskModel>, bool>((ref, isCompleted) {
  final tasksState = ref.watch(tasksProvider);
  return tasksState.tasks
      .where((task) => task.completed == isCompleted)
      .toList();
});

/// Provider for tasks loading state.
final tasksLoadingProvider = Provider<bool>((ref) {
  return ref.watch(tasksProvider).isLoading;
});

/// Provider for tasks error state.
final tasksErrorProvider = Provider<String?>((ref) {
  return ref.watch(tasksProvider).error;
});
