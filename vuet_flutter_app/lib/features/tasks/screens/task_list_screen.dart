// lib/features/tasks/screens/task_list_screen.dart
// Task list screen that displays tasks based on different filters (e.g., overdue, today, upcoming)
// Matches the React Native design from screenshots

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:vuet_flutter/core/constants/app_constants.dart';
import 'package:vuet_flutter/core/theme/app_theme.dart';
import 'package:vuet_flutter/core/utils/logger.dart';
import 'package:vuet_flutter/features/tasks/data/models/task_model.dart';
import 'package:vuet_flutter/features/tasks/providers/tasks_provider.dart';

class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    // Initial fetch for all tasks
    _fetchTasks();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      _fetchTasks(); // Refresh tasks when tab changes
    }
  }

  Future<void> _fetchTasks() async {
    final tasksNotifier = ref.read(tasksProvider.notifier);
    switch (_tabController.index) {
      case 0: // Overdue
        await tasksNotifier.fetchOverdueTasks();
        break;
      case 1: // Today
        // Today's tasks are filtered from the main task list, so no separate fetch needed
        break;
      case 2: // Upcoming
        await tasksNotifier.fetchUpcomingTasks();
        break;
    }
  }

  Future<void> _toggleTaskCompletion(TaskModel task) async {
    try {
      EasyLoading.show(status: 'Updating task...');
      final tasksNotifier = ref.read(tasksProvider.notifier);
      await tasksNotifier.completeTask(task.id);
      EasyLoading.showSuccess('Task completed!');
    } catch (e, st) {
      Logger.error('Failed to toggle task completion', e, st);
      EasyLoading.showError('Failed to update task: $e');
    }
  }

  Color _getTaskTypeColor(TaskType type) {
    switch (type) {
      case TaskType.task:
        return const Color(0xFF4CAF50);
      case TaskType.appointment:
        return const Color(0xFF9C27B0);
      case TaskType.dueDate:
        return const Color(0xFFF44336);
      case TaskType.flight:
        return const Color(0xFF2196F3);
      case TaskType.train:
        return const Color(0xFF009688);
      case TaskType.hotel:
        return const Color(0xFFFF9800);
      default:
        return Colors.grey;
    }
  }

  String _formatTaskType(TaskType type) {
    String label = type.toString().split('.').last;
    label = label.replaceAll('_', ' ');
    return label
        .split(' ')
        .map((word) => word.isNotEmpty
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : '')
        .join(' ');
  }

  Widget _buildTaskDateInfo(TaskModel task) {
    return task.when(
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
        if (startDatetime != null) {
          return Text(
            'Start: ${DateFormat('MMM d, yyyy h:mm a').format(startDatetime)}',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          );
        } else if (startDate != null) {
          return Text(
            'Date: ${DateFormat('MMM d, yyyy').format(startDate)}',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          );
        }
        return const SizedBox.shrink();
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
        if (dueDate != null) {
          final isOverdue = dueDate.isBefore(DateTime.now());
          return Text(
            'Due: ${DateFormat('MMM d, yyyy').format(dueDate)}',
            style: TextStyle(
              fontSize: 12.sp,
              color: isOverdue ? Colors.red : Colors.grey[600],
              fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
            ),
          );
        } else if (earliestActionDate != null) {
          return Text(
            'Earliest: ${DateFormat('MMM d, yyyy').format(earliestActionDate)}',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasksState = ref.watch(tasksProvider);
    final overdueTasks = ref.watch(overdueTasksProvider).value ?? [];
    final todayTasks = ref.watch(todayTasksProvider);
    final upcomingTasks = ref.watch(upcomingTasksProvider).value ?? [];

    return Scaffold(
      backgroundColor: AppTheme.lightBackgroundColor,
      appBar: AppBar(
        title: const Text('Tasks'),
        backgroundColor: AppTheme.darkHeaderColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.white70,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'Overdue'),
            Tab(text: 'Today'),
            Tab(text: 'Upcoming'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTaskList(
              overdueTasks, tasksState.isLoading, 'No overdue tasks.'),
          _buildTaskList(
              todayTasks, tasksState.isLoading, 'No tasks for today.'),
          _buildTaskList(
              upcomingTasks, tasksState.isLoading, 'No upcoming tasks.'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add new task screen
          context.push('/tasks/new');
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTaskList(
      List<TaskModel> tasks, bool isLoading, String emptyMessage) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
        ),
      );
    }

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 64.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: UIConstants.paddingM.h),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: UIConstants.paddingS.h),
            Text(
              'Tap the + button to add a new task.',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(UIConstants.paddingM.w),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Card(
          margin: EdgeInsets.only(bottom: UIConstants.paddingM.h),
          elevation: AppTheme.lightTheme.cardTheme.elevation ?? 2,
          shape: AppTheme.lightTheme.cardTheme.shape,
          child: ListTile(
            contentPadding: EdgeInsets.all(UIConstants.paddingM.w),
            leading: Icon(
              Icons.task_alt,
              color: _getTaskTypeColor(task.type),
              size: 24.sp,
            ),
            title: Text(
              task.title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkTextColor,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatTaskType(task.type),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: _getTaskTypeColor(task.type),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (task.notes != null && task.notes!.isNotEmpty)
                  Text(
                    task.notes!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[700],
                    ),
                  ),
                _buildTaskDateInfo(task),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to task detail screen
              context.push('/tasks/${task.id}');
            },
          ),
        );
      },
    );
  }
}
