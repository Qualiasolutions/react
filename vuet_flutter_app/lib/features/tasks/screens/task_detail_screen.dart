// lib/features/tasks/screens/task_detail_screen.dart
// Task detail screen that displays the details of a selected task, matching the React Native design

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:vuet_flutter/core/constants/app_constants.dart';
import 'package:vuet_flutter/core/theme/app_theme.dart';
import 'package:vuet_flutter/core/utils/logger.dart';
import 'package:vuet_flutter/data/models/task_model.dart';
import 'package:vuet_flutter/features/tasks/providers/tasks_provider.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final String taskId;

  const TaskDetailScreen({
    Key? key,
    required this.taskId,
  }) : super(key: key);

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure tasks are fetched so the specific task is available in state
    ref.read(tasksProvider.notifier).fetchTasks(forceRefresh: false);
  }

  Future<void> _deleteTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        EasyLoading.show(status: 'Deleting task...');
        await ref.read(tasksProvider.notifier).deleteTask(widget.taskId);
        EasyLoading.showSuccess('Task deleted!');
        if (mounted) {
          context.pop(); // Go back to the previous screen (task list)
        }
      } catch (e, st) {
        Logger.error('Failed to delete task', e, st);
        EasyLoading.showError('Failed to delete task: $e');
      }
    }
  }

  Future<void> _toggleCompletion(TaskModel task) async {
    try {
      EasyLoading.show(status: 'Updating task...');
      if (task.completed) {
        // In a real app, you'd have an uncompleteTask method or similar
        EasyLoading.showInfo('Uncompleting tasks is not yet supported.');
      } else {
        await ref.read(tasksProvider.notifier).completeTask(task.id);
        EasyLoading.showSuccess('Task completed!');
      }
    } catch (e, st) {
      Logger.error('Failed to toggle task completion', e, st);
      EasyLoading.showError('Failed to update task: $e');
    }
  }

  void _editTask(TaskModel task) {
    // Navigate to an edit screen, passing the task ID
    context.push('/tasks/edit/${task.id}', extra: task);
  }

  @override
  Widget build(BuildContext context) {
    final task = ref.watch(taskByIdProvider(widget.taskId));

    return Scaffold(
      backgroundColor: AppTheme.lightBackgroundColor,
      appBar: AppBar(
        title: Text(task?.title ?? 'Task Details'),
        backgroundColor: AppTheme.darkHeaderColor,
        foregroundColor: Colors.white,
        actions: [
          if (task != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editTask(task),
            ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteTask,
          ),
        ],
      ),
      body: task == null
          ? Center(
              child: Text(
                'Task not found.',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(UIConstants.paddingM.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Details Card
                  Card(
                    elevation: AppTheme.lightTheme.cardTheme.elevation,
                    shape: AppTheme.lightTheme.cardTheme.shape,
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: EdgeInsets.all(UIConstants.paddingM.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(
                            icon: Icons.title,
                            label: 'Title',
                            value: task.title,
                          ),
                          _buildDetailRow(
                            icon: Icons.category,
                            label: 'Type',
                            value: task.type.toDbString().replaceAll('_', ' '),
                          ),
                          if (task.description != null && task.description!.isNotEmpty)
                            _buildDetailRow(
                              icon: Icons.notes,
                              label: 'Description',
                              value: task.description!,
                            ),
                          if (task.location != null && task.location!.isNotEmpty)
                            _buildDetailRow(
                              icon: Icons.location_on,
                              label: 'Location',
                              value: task.location!,
                            ),
                          if (task.contactName != null && task.contactName!.isNotEmpty)
                            _buildDetailRow(
                              icon: Icons.person,
                              label: 'Contact',
                              value: task.contactName!,
                            ),
                          if (task.contactEmail != null && task.contactEmail!.isNotEmpty)
                            _buildDetailRow(
                              icon: Icons.email,
                              label: 'Contact Email',
                              value: task.contactEmail!,
                            ),
                          if (task.contactPhone != null && task.contactPhone!.isNotEmpty)
                            _buildDetailRow(
                              icon: Icons.phone,
                              label: 'Contact Phone',
                              value: task.contactPhone!,
                            ),
                          if (task.dueDate != null)
                            _buildDetailRow(
                              icon: Icons.calendar_today,
                              label: 'Due Date',
                              value: DateFormat('MMM d, yyyy').format(task.dueDate!),
                            ),
                          if (task.urgency != null)
                            _buildDetailRow(
                              icon: Icons.priority_high,
                              label: 'Urgency',
                              value: task.urgency!.toDbString(),
                            ),
                          _buildDetailRow(
                            icon: Icons.check_circle_outline,
                            label: 'Completed',
                            value: task.completed ? 'Yes' : 'No',
                            valueColor: task.completed ? Colors.green : Colors.red,
                          ),
                          _buildDetailRow(
                            icon: Icons.calendar_today,
                            label: 'Created At',
                            value: DateFormat('MMM d, yyyy HH:mm').format(task.createdAt),
                          ),
                          _buildDetailRow(
                            icon: Icons.update,
                            label: 'Last Updated',
                            value: DateFormat('MMM d, yyyy HH:mm').format(task.updatedAt),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: UIConstants.paddingL.h),

                  // Completion Toggle
                  Card(
                    elevation: AppTheme.lightTheme.cardTheme.elevation,
                    shape: AppTheme.lightTheme.cardTheme.shape,
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: EdgeInsets.all(UIConstants.paddingM.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Mark as Completed',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkTextColor,
                            ),
                          ),
                          Switch(
                            value: task.completed,
                            onChanged: (value) => _toggleCompletion(task),
                            activeColor: AppTheme.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: UIConstants.paddingL.h),

                  // Recurrence Information
                  if (task.recurrence != null)
                    Card(
                      elevation: AppTheme.lightTheme.cardTheme.elevation,
                      shape: AppTheme.lightTheme.cardTheme.shape,
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: EdgeInsets.all(UIConstants.paddingM.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recurrence',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.darkTextColor,
                              ),
                            ),
                            SizedBox(height: UIConstants.paddingS.h),
                            _buildDetailRow(
                              icon: Icons.repeat,
                              label: 'Type',
                              value: task.recurrence!.recurrence.toDbString(),
                            ),
                            _buildDetailRow(
                              icon: Icons.numbers,
                              label: 'Interval',
                              value: '${task.recurrence!.intervalLength} ${task.recurrence!.recurrence.toDbString().toLowerCase()}',
                            ),
                            if (task.recurrence!.earliestOccurrence != null)
                              _buildDetailRow(
                                icon: Icons.date_range,
                                label: 'Starts',
                                value: DateFormat('MMM d, yyyy').format(task.recurrence!.earliestOccurrence!),
                              ),
                            if (task.recurrence!.latestOccurrence != null)
                              _buildDetailRow(
                                icon: Icons.date_range,
                                label: 'Ends',
                                value: DateFormat('MMM d, yyyy').format(task.recurrence!.latestOccurrence!),
                              ),
                          ],
                        ),
                      ),
                    ),
                  SizedBox(height: UIConstants.paddingL.h),

                  // Reminders
                  if (task.reminders.isNotEmpty)
                    Card(
                      elevation: AppTheme.lightTheme.cardTheme.elevation,
                      shape: AppTheme.lightTheme.cardTheme.shape,
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: EdgeInsets.all(UIConstants.paddingM.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reminders',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.darkTextColor,
                              ),
                            ),
                            SizedBox(height: UIConstants.paddingS.h),
                            ...task.reminders.map((reminder) => _buildDetailRow(
                                  icon: Icons.notifications,
                                  label: 'Reminder',
                                  value: 'Before: ${reminder.timedelta}',
                                )),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: UIConstants.paddingXS.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20.sp, color: Colors.grey[600]),
          SizedBox(width: UIConstants.paddingS.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: valueColor ?? AppTheme.darkTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
