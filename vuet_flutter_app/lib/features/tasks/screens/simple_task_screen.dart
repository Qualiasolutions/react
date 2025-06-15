// lib/features/tasks/screens/simple_task_screen.dart
// Complete working task management screen that directly integrates with Supabase

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:vuet_flutter/core/theme/app_theme.dart';
import 'package:vuet_flutter/core/utils/logger.dart';

// Simple task data class for UI
class SimpleTask {
  final String id;
  final String title;
  final String type;
  final String? notes;
  final DateTime? dueDate;
  final DateTime? startDatetime;
  final int? duration;
  final String? urgency;
  final DateTime createdAt;

  SimpleTask({
    required this.id,
    required this.title,
    required this.type,
    this.notes,
    this.dueDate,
    this.startDatetime,
    this.duration,
    this.urgency,
    required this.createdAt,
  });

  factory SimpleTask.fromJson(Map<String, dynamic> json) {
    return SimpleTask(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      notes: json['notes'],
      dueDate:
          json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      startDatetime: json['start_datetime'] != null
          ? DateTime.parse(json['start_datetime'])
          : null,
      duration: json['duration'],
      urgency: json['urgency'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'notes': notes,
      'due_date': dueDate?.toIso8601String(),
      'start_datetime': startDatetime?.toIso8601String(),
      'duration': duration,
      'urgency': urgency,
      'created_at': createdAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}

class SimpleTaskScreen extends ConsumerStatefulWidget {
  const SimpleTaskScreen({super.key});

  @override
  ConsumerState<SimpleTaskScreen> createState() => _SimpleTaskScreenState();
}

class _SimpleTaskScreenState extends ConsumerState<SimpleTaskScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<SimpleTask> _allTasks = [];
  List<SimpleTask> _todayTasks = [];
  List<SimpleTask> _upcomingTasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTasks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client
          .from('tasks')
          .select()
          .order('created_at', ascending: false);

      final tasks =
          (response as List).map((json) => SimpleTask.fromJson(json)).toList();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));
      final nextWeek = today.add(const Duration(days: 7));

      setState(() {
        _allTasks = tasks;
        _todayTasks = tasks.where((task) {
          if (task.dueDate != null) {
            final taskDate = DateTime(
                task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
            return taskDate.isAtSameMomentAs(today);
          }
          if (task.startDatetime != null) {
            final taskDate = DateTime(task.startDatetime!.year,
                task.startDatetime!.month, task.startDatetime!.day);
            return taskDate.isAtSameMomentAs(today);
          }
          return false;
        }).toList();

        _upcomingTasks = tasks.where((task) {
          if (task.dueDate != null) {
            final taskDate = DateTime(
                task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
            return taskDate.isAfter(today) && taskDate.isBefore(nextWeek);
          }
          if (task.startDatetime != null) {
            final taskDate = DateTime(task.startDatetime!.year,
                task.startDatetime!.month, task.startDatetime!.day);
            return taskDate.isAfter(today) && taskDate.isBefore(nextWeek);
          }
          return false;
        }).toList();

        _isLoading = false;
      });
    } catch (e, st) {
      Logger.error('Failed to load tasks', e, st);
      setState(() => _isLoading = false);
      EasyLoading.showError('Failed to load tasks: $e');
    }
  }

  Future<void> _showCreateTaskDialog() async {
    await showDialog(
      context: context,
      builder: (context) => CreateTaskDialog(
        onTaskCreated: () {
          _loadTasks(); // Refresh the task list
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Tasks'),
        backgroundColor: AppTheme.darkHeaderColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: AppTheme.primaryColor,
          tabs: [
            Tab(text: 'All (${_allTasks.length})'),
            Tab(text: 'Today (${_todayTasks.length})'),
            Tab(text: 'Upcoming (${_upcomingTasks.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTaskList(_allTasks, 'No tasks yet'),
                _buildTaskList(_todayTasks, 'No tasks for today'),
                _buildTaskList(_upcomingTasks, 'No upcoming tasks'),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateTaskDialog,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTaskList(List<SimpleTask> tasks, String emptyMessage) {
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
            SizedBox(height: 16.h),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Tap the + button to add a new task',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTasks,
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return _buildTaskCard(task);
        },
      ),
    );
  }

  Widget _buildTaskCard(SimpleTask task) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16.w),
        leading: Container(
          width: 4.w,
          height: 60.h,
          decoration: BoxDecoration(
            color: _getTaskTypeColor(task.type),
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4.h),
            Text(
              _formatTaskType(task.type),
              style: TextStyle(
                fontSize: 12.sp,
                color: _getTaskTypeColor(task.type),
                fontWeight: FontWeight.w600,
              ),
            ),
            if (task.notes != null && task.notes!.isNotEmpty) ...[
              SizedBox(height: 4.h),
              Text(
                task.notes!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[700],
                ),
              ),
            ],
            SizedBox(height: 6.h),
            _buildTaskDateInfo(task),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              _deleteTask(task);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
          child: Icon(
            Icons.more_vert,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskDateInfo(SimpleTask task) {
    if (task.dueDate != null) {
      final isOverdue = task.dueDate!.isBefore(DateTime.now());
      return Row(
        children: [
          Icon(
            Icons.schedule,
            size: 14.sp,
            color: isOverdue ? Colors.red : Colors.grey[600],
          ),
          SizedBox(width: 4.w),
          Text(
            'Due: ${DateFormat('MMM d, yyyy').format(task.dueDate!)}',
            style: TextStyle(
              fontSize: 12.sp,
              color: isOverdue ? Colors.red : Colors.grey[600],
              fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          if (task.urgency != null) ...[
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: _getUrgencyColor(task.urgency!).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                task.urgency!.toLowerCase(),
                style: TextStyle(
                  fontSize: 10.sp,
                  color: _getUrgencyColor(task.urgency!),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      );
    } else if (task.startDatetime != null) {
      return Row(
        children: [
          Icon(
            Icons.access_time,
            size: 14.sp,
            color: Colors.grey[600],
          ),
          SizedBox(width: 4.w),
          Text(
            'Start: ${DateFormat('MMM d, yyyy h:mm a').format(task.startDatetime!)}',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Icon(
          Icons.info_outline,
          size: 14.sp,
          color: Colors.grey[500],
        ),
        SizedBox(width: 4.w),
        Text(
          'Created ${DateFormat('MMM d').format(task.createdAt)}',
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Color _getTaskTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'TASK':
        return const Color(0xFF4CAF50);
      case 'APPOINTMENT':
        return const Color(0xFF9C27B0);
      case 'DUE_DATE':
        return const Color(0xFFF44336);
      case 'FLIGHT':
        return const Color(0xFF2196F3);
      case 'TRAIN':
        return const Color(0xFF009688);
      case 'HOTEL':
        return const Color(0xFFFF9800);
      default:
        return Colors.grey;
    }
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toUpperCase()) {
      case 'HIGH':
        return Colors.red;
      case 'MEDIUM':
        return Colors.orange;
      case 'LOW':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatTaskType(String type) {
    return type
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .map((word) =>
            word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
        .join(' ');
  }

  Future<void> _deleteTask(SimpleTask task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
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
        await Supabase.instance.client.from('tasks').delete().eq('id', task.id);

        EasyLoading.showSuccess('Task deleted');
        _loadTasks();
      } catch (e, st) {
        Logger.error('Failed to delete task', e, st);
        EasyLoading.showError('Failed to delete task: $e');
      }
    }
  }
}

// Task Creation Dialog
class CreateTaskDialog extends StatefulWidget {
  final VoidCallback onTaskCreated;

  const CreateTaskDialog({
    super.key,
    required this.onTaskCreated,
  });

  @override
  State<CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends State<CreateTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  String _taskType = 'TASK';
  DateTime? _dueDate;
  DateTime? _startDateTime;
  String? _urgency;
  int _duration = 30;
  bool _isLoading = false;

  final List<String> _taskTypes = [
    'TASK',
    'APPOINTMENT',
    'DUE_DATE',
    'FLIGHT',
    'TRAIN',
    'HOTEL'
  ];
  final List<String> _urgencyLevels = ['LOW', 'MEDIUM', 'HIGH'];

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate({bool includeTime = false}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && includeTime) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          _startDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    } else if (date != null) {
      setState(() {
        _dueDate = date;
      });
    }
  }

  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final taskData = {
        'id': const Uuid().v4(),
        'title': _titleController.text.trim(),
        'type': _taskType,
        'notes': _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        'due_date': _dueDate?.toIso8601String().split('T').first,
        'start_datetime': _startDateTime?.toIso8601String(),
        'duration': _duration,
        'urgency': _urgency,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await Supabase.instance.client.from('tasks').insert(taskData);

      EasyLoading.showSuccess('Task created successfully!');
      widget.onTaskCreated();
      Navigator.of(context).pop();
    } catch (e, st) {
      Logger.error('Failed to create task', e, st);
      EasyLoading.showError('Failed to create task: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Create New Task',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20.h),

                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Notes
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 16.h),

                // Task Type
                DropdownButtonFormField<String>(
                  value: _taskType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: _taskTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type
                          .replaceAll('_', ' ')
                          .toLowerCase()
                          .split(' ')
                          .map((word) => word.isNotEmpty
                              ? word[0].toUpperCase() + word.substring(1)
                              : '')
                          .join(' ')),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _taskType = value!;
                    });
                  },
                ),
                SizedBox(height: 16.h),

                // Date selection based on type
                if (['TASK', 'APPOINTMENT', 'DUE_DATE']
                    .contains(_taskType)) ...[
                  // Due Date for flexible tasks
                  InkWell(
                    onTap: () => _selectDate(),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Due Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _dueDate == null
                            ? 'Select due date'
                            : DateFormat('MMM d, yyyy').format(_dueDate!),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Urgency
                  DropdownButtonFormField<String?>(
                    value: _urgency,
                    decoration: const InputDecoration(
                      labelText: 'Urgency',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('Not specified')),
                      ..._urgencyLevels.map((urgency) {
                        return DropdownMenuItem(
                          value: urgency,
                          child: Text(urgency.toLowerCase().capitalize()),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _urgency = value;
                      });
                    },
                  ),
                ] else ...[
                  // Start Date/Time for fixed tasks
                  InkWell(
                    onTap: () => _selectDate(includeTime: true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Start Date & Time',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.access_time),
                      ),
                      child: Text(
                        _startDateTime == null
                            ? 'Select start date and time'
                            : DateFormat('MMM d, yyyy h:mm a')
                                .format(_startDateTime!),
                      ),
                    ),
                  ),
                ],

                SizedBox(height: 20.h),

                // Duration
                TextFormField(
                  initialValue: _duration.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Duration (minutes)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _duration = int.tryParse(value) ?? 30;
                    });
                  },
                ),

                SizedBox(height: 24.h),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _createTask,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text('Create'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Extension for string capitalization
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
