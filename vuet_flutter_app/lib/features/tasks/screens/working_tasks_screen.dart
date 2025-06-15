// lib/features/tasks/screens/working_tasks_screen.dart
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
class WorkingTask {
  final String id;
  final String title;
  final String type;
  final String? notes;
  final DateTime? dueDate;
  final DateTime? startDatetime;
  final DateTime? earliestActionDate;
  final int? duration;
  final String? urgency;
  final String? location;
  final String? contactName;
  final String? contactEmail;
  final String? contactPhone;
  final DateTime createdAt;

  WorkingTask({
    required this.id,
    required this.title,
    required this.type,
    this.notes,
    this.dueDate,
    this.startDatetime,
    this.earliestActionDate,
    this.duration,
    this.urgency,
    this.location,
    this.contactName,
    this.contactEmail,
    this.contactPhone,
    required this.createdAt,
  });

  factory WorkingTask.fromJson(Map<String, dynamic> json) {
    return WorkingTask(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      notes: json['notes'],
      dueDate:
          json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      startDatetime: json['start_datetime'] != null
          ? DateTime.parse(json['start_datetime'])
          : null,
      earliestActionDate: json['earliest_action_date'] != null
          ? DateTime.parse(json['earliest_action_date'])
          : null,
      duration: json['duration'],
      urgency: json['urgency'],
      location: json['location'],
      contactName: json['contact_name'],
      contactEmail: json['contact_email'],
      contactPhone: json['contact_phone'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'notes': notes,
      'due_date': dueDate?.toIso8601String().split('T').first,
      'start_datetime': startDatetime?.toIso8601String(),
      'earliest_action_date':
          earliestActionDate?.toIso8601String().split('T').first,
      'duration': duration,
      'urgency': urgency,
      'location': location,
      'contact_name': contactName,
      'contact_email': contactEmail,
      'contact_phone': contactPhone,
      'created_at': createdAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  bool get isFlexibleTask => ['TASK', 'APPOINTMENT', 'DUE_DATE'].contains(type);
  bool get isFixedTask => !isFlexibleTask;
}

class WorkingTasksScreen extends ConsumerStatefulWidget {
  const WorkingTasksScreen({super.key});

  @override
  ConsumerState<WorkingTasksScreen> createState() => _WorkingTasksScreenState();
}

class _WorkingTasksScreenState extends ConsumerState<WorkingTasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<WorkingTask> _allTasks = [];
  List<WorkingTask> _todayTasks = [];
  List<WorkingTask> _upcomingTasks = [];
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
          (response as List).map((json) => WorkingTask.fromJson(json)).toList();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
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
      builder: (context) => CreateWorkingTaskDialog(
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

  Widget _buildTaskList(List<WorkingTask> tasks, String emptyMessage) {
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

  Widget _buildTaskCard(WorkingTask task) {
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
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: _getTaskTypeColor(task.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    _formatTaskType(task.type),
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: _getTaskTypeColor(task.type),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (task.isFlexibleTask)
                  Container(
                    margin: EdgeInsets.only(left: 6.w),
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      'Flexible',
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                else
                  Container(
                    margin: EdgeInsets.only(left: 6.w),
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      'Fixed',
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
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
            if (value == 'edit') {
              _showEditTaskDialog(task);
            } else if (value == 'delete') {
              _deleteTask(task);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
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

  Widget _buildTaskDateInfo(WorkingTask task) {
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
        if (task.duration != null) ...[
          SizedBox(width: 8.w),
          Text(
            '${task.duration}min',
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey[500],
            ),
          ),
        ],
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

  Future<void> _showEditTaskDialog(WorkingTask task) async {
    await showDialog(
      context: context,
      builder: (context) => CreateWorkingTaskDialog(
        existingTask: task,
        onTaskCreated: () {
          _loadTasks(); // Refresh the task list
        },
      ),
    );
  }

  Future<void> _deleteTask(WorkingTask task) async {
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

// Task Creation/Edit Dialog
class CreateWorkingTaskDialog extends StatefulWidget {
  final VoidCallback onTaskCreated;
  final WorkingTask? existingTask;

  const CreateWorkingTaskDialog({
    super.key,
    required this.onTaskCreated,
    this.existingTask,
  });

  @override
  State<CreateWorkingTaskDialog> createState() =>
      _CreateWorkingTaskDialogState();
}

class _CreateWorkingTaskDialogState extends State<CreateWorkingTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();

  String _taskType = 'TASK';
  DateTime? _dueDate;
  DateTime? _startDateTime;
  DateTime? _earliestActionDate;
  String? _urgency;
  int _duration = 30;
  bool _isLoading = false;

  final List<String> _taskTypes = [
    'TASK',
    'APPOINTMENT',
    'DUE_DATE',
    'FLIGHT',
    'TRAIN',
    'HOTEL',
    'ACTIVITY'
  ];
  final List<String> _urgencyLevels = ['LOW', 'MEDIUM', 'HIGH'];

  @override
  void initState() {
    super.initState();
    if (widget.existingTask != null) {
      _populateFromExistingTask();
    }
  }

  void _populateFromExistingTask() {
    final task = widget.existingTask!;
    _titleController.text = task.title;
    _notesController.text = task.notes ?? '';
    _locationController.text = task.location ?? '';
    _contactNameController.text = task.contactName ?? '';
    _contactEmailController.text = task.contactEmail ?? '';
    _contactPhoneController.text = task.contactPhone ?? '';
    _taskType = task.type;
    _dueDate = task.dueDate;
    _startDateTime = task.startDatetime;
    _earliestActionDate = task.earliestActionDate;
    _urgency = task.urgency;
    _duration = task.duration ?? 30;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _locationController.dispose();
    _contactNameController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  bool get _isFlexibleTaskType =>
      ['TASK', 'APPOINTMENT', 'DUE_DATE'].contains(_taskType);

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
        if (_isFlexibleTaskType) {
          _dueDate = date;
        } else {
          _startDateTime = date;
        }
      });
    }
  }

  Future<void> _selectEarliestActionDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _earliestActionDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _earliestActionDate = date;
      });
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final taskData = {
        if (widget.existingTask == null) 'id': const Uuid().v4(),
        'title': _titleController.text.trim(),
        'type': _taskType,
        'notes': _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        'location': _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        'contact_name': _contactNameController.text.trim().isEmpty
            ? null
            : _contactNameController.text.trim(),
        'contact_email': _contactEmailController.text.trim().isEmpty
            ? null
            : _contactEmailController.text.trim(),
        'contact_phone': _contactPhoneController.text.trim().isEmpty
            ? null
            : _contactPhoneController.text.trim(),
        'due_date': _dueDate?.toIso8601String().split('T').first,
        'start_datetime': _startDateTime?.toIso8601String(),
        'earliest_action_date':
            _earliestActionDate?.toIso8601String().split('T').first,
        'duration': _duration,
        'urgency': _urgency,
        'updated_at': DateTime.now().toIso8601String(),
        if (widget.existingTask == null)
          'created_at': DateTime.now().toIso8601String(),
      };

      if (widget.existingTask != null) {
        // Update existing task
        await Supabase.instance.client
            .from('tasks')
            .update(taskData)
            .eq('id', widget.existingTask!.id);
        EasyLoading.showSuccess('Task updated successfully!');
      } else {
        // Create new task
        await Supabase.instance.client.from('tasks').insert(taskData);
        EasyLoading.showSuccess('Task created successfully!');
      }

      widget.onTaskCreated();
      Navigator.of(context).pop();
    } catch (e, st) {
      Logger.error('Failed to save task', e, st);
      EasyLoading.showError('Failed to save task: $e');
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
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          maxWidth: 500.w,
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.existingTask != null ? 'Edit Task' : 'Create New Task',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20.h),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
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
                                      ? word[0].toUpperCase() +
                                          word.substring(1)
                                      : '')
                                  .join(' ')),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _taskType = value!;
                              // Clear inappropriate dates when switching types
                              if (_isFlexibleTaskType) {
                                _startDateTime = null;
                              } else {
                                _dueDate = null;
                                _earliestActionDate = null;
                                _urgency = null;
                              }
                            });
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

                        // Date selection based on type
                        if (_isFlexibleTaskType) ...[
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
                                    : DateFormat('MMM d, yyyy')
                                        .format(_dueDate!),
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),

                          // Earliest Action Date
                          InkWell(
                            onTap: _selectEarliestActionDate,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Earliest Start Date (Optional)',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                _earliestActionDate == null
                                    ? 'Select earliest start date'
                                    : DateFormat('MMM d, yyyy')
                                        .format(_earliestActionDate!),
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
                                  child:
                                      Text(urgency.toLowerCase().capitalize()),
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

                        SizedBox(height: 16.h),

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
                        SizedBox(height: 16.h),

                        // Location
                        TextFormField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                            labelText: 'Location',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on),
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // Contact Name
                        TextFormField(
                          controller: _contactNameController,
                          decoration: const InputDecoration(
                            labelText: 'Contact Name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // Contact Email
                        TextFormField(
                          controller: _contactEmailController,
                          decoration: const InputDecoration(
                            labelText: 'Contact Email',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value != null &&
                                value.isNotEmpty &&
                                !value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),

                        // Contact Phone
                        TextFormField(
                          controller: _contactPhoneController,
                          decoration: const InputDecoration(
                            labelText: 'Contact Phone',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.phone),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                  ),
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
                        onPressed: _isLoading ? null : _saveTask,
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
                            : Text(widget.existingTask != null
                                ? 'Update'
                                : 'Create'),
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
