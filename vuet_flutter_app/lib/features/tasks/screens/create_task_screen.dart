// lib/features/tasks/screens/create_task_screen.dart
// Task creation screen that works with the actual TaskModel structure

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:uuid/uuid.dart';

import 'package:vuet_flutter/core/theme/app_theme.dart';
import 'package:vuet_flutter/core/utils/logger.dart';
import 'package:vuet_flutter/features/tasks/data/models/task_model.dart';
import 'package:vuet_flutter/features/tasks/providers/tasks_provider.dart';
import 'package:vuet_flutter/features/entities/providers/entities_provider.dart';

enum TaskFormType { fixed, flexible }

class CreateTaskScreen extends ConsumerStatefulWidget {
  final String? entityId; // Optional: pre-associate with entity
  final TaskFormType? initialType;

  const CreateTaskScreen({
    super.key,
    this.entityId,
    this.initialType,
  });

  @override
  ConsumerState<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();

  // Task settings
  TaskFormType _taskType = TaskFormType.flexible;
  TaskType _category = TaskType.task;
  UrgencyType? _urgency;
  final List<String> _tags = [];

  // Fixed task fields
  DateTime? _startDateTime;
  DateTime? _endDateTime;
  int? _fixedDuration;

  // Flexible task fields
  DateTime? _dueDate;
  DateTime? _earliestActionDate;
  int _flexibleDuration = 30;

  // Recurrence
  RecurrenceType? _recurrenceType;
  int _recurrenceInterval = 1;
  DateTime? _recurrenceStart;
  DateTime? _recurrenceEnd;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Set initial type
    if (widget.initialType != null) {
      _taskType = widget.initialType!;
    }

    // Load entities for selection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(entitiesProvider.notifier).fetchEntities();
    });
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

  Future<void> _selectDateTime({
    required DateTime? initial,
    required Function(DateTime) onSelected,
    bool includeTime = false,
  }) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (date != null) {
      if (includeTime) {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(initial ?? DateTime.now()),
        );

        if (time != null) {
          final combined = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
          onSelected(combined);
        }
      } else {
        onSelected(date);
      }
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

  String _formatUrgencyType(UrgencyType type) {
    String label = type.toString().split('.').last;
    return label[0].toUpperCase() + label.substring(1).toLowerCase();
  }

  String _formatRecurrenceType(RecurrenceType type) {
    String label = type.toString().split('.').last;
    label = label.replaceAll('_', ' ');
    return label
        .split(' ')
        .map((word) => word.isNotEmpty
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : '')
        .join(' ');
  }

  Widget _buildTaskTypeSelector() {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Task Type',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            SegmentedButton<TaskFormType>(
              segments: const [
                ButtonSegment(
                  value: TaskFormType.fixed,
                  label: Text('Fixed'),
                  icon: Icon(Icons.schedule),
                ),
                ButtonSegment(
                  value: TaskFormType.flexible,
                  label: Text('Flexible'),
                  icon: Icon(Icons.access_time),
                ),
              ],
              selected: {_taskType},
              onSelectionChanged: (Set<TaskFormType> selection) {
                setState(() {
                  _taskType = selection.first;
                });
              },
            ),
            SizedBox(height: 8.h),
            Text(
              _taskType == TaskFormType.fixed
                  ? 'Tasks with specific start and end times'
                  : 'Tasks with due dates and estimated duration',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicFields() {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'What needs to be done?',
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
                hintText: 'Additional details...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16.h),

            // Category
            DropdownButtonFormField<TaskType>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: TaskType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_formatTaskType(type)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _category = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedTaskFields() {
    if (_taskType != TaskFormType.fixed) return const SizedBox.shrink();

    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fixed Task Schedule',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),

            // Start Date & Time
            InkWell(
              onTap: () => _selectDateTime(
                initial: _startDateTime,
                onSelected: (date) => setState(() => _startDateTime = date),
                includeTime: true,
              ),
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
            SizedBox(height: 16.h),

            // End Date & Time
            InkWell(
              onTap: () => _selectDateTime(
                initial: _endDateTime,
                onSelected: (date) => setState(() => _endDateTime = date),
                includeTime: true,
              ),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'End Date & Time',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.access_time),
                ),
                child: Text(
                  _endDateTime == null
                      ? 'Select end date and time'
                      : DateFormat('MMM d, yyyy h:mm a').format(_endDateTime!),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Duration (optional)
            TextFormField(
              initialValue: _fixedDuration?.toString() ?? '',
              decoration: const InputDecoration(
                labelText: 'Duration (minutes)',
                hintText: 'Leave empty if end time is set',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _fixedDuration = int.tryParse(value);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlexibleTaskFields() {
    if (_taskType != TaskFormType.flexible) return const SizedBox.shrink();

    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Flexible Task Details',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),

            // Due Date
            InkWell(
              onTap: () => _selectDateTime(
                initial: _dueDate,
                onSelected: (date) => setState(() => _dueDate = date),
              ),
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

            // Earliest Action Date
            InkWell(
              onTap: () => _selectDateTime(
                initial: _earliestActionDate,
                onSelected: (date) =>
                    setState(() => _earliestActionDate = date),
              ),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Earliest Start Date (Optional)',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _earliestActionDate == null
                      ? 'Select earliest start date'
                      : DateFormat('MMM d, yyyy').format(_earliestActionDate!),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Duration
            TextFormField(
              initialValue: _flexibleDuration.toString(),
              decoration: const InputDecoration(
                labelText: 'Duration (minutes) *',
                hintText: 'How long will this take?',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    int.tryParse(value) == null) {
                  return 'Please enter a valid duration';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  _flexibleDuration = int.tryParse(value) ?? 30;
                });
              },
            ),
            SizedBox(height: 16.h),

            // Urgency
            DropdownButtonFormField<UrgencyType?>(
              value: _urgency,
              decoration: const InputDecoration(
                labelText: 'Urgency',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(
                    value: null, child: Text('Not specified')),
                ...UrgencyType.values.map((urgency) {
                  return DropdownMenuItem(
                    value: urgency,
                    child: Text(_formatUrgencyType(urgency)),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _urgency = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactFields() {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact & Location (Optional)',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),

            // Location
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                hintText: 'Where will this happen?',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.h),

            // Contact Name
            TextFormField(
              controller: _contactNameController,
              decoration: const InputDecoration(
                labelText: 'Contact Name',
                hintText: 'Person to contact',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.h),

            // Contact Email
            TextFormField(
              controller: _contactEmailController,
              decoration: const InputDecoration(
                labelText: 'Contact Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.isNotEmpty && !value.contains('@')) {
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
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecurrenceFields() {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recurrence (Optional)',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            DropdownButtonFormField<RecurrenceType?>(
              value: _recurrenceType,
              decoration: const InputDecoration(
                labelText: 'Repeat',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(
                    value: null, child: Text('Does not repeat')),
                ...RecurrenceType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_formatRecurrenceType(type)),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _recurrenceType = value;
                });
              },
            ),
            if (_recurrenceType != null) ...[
              SizedBox(height: 16.h),
              TextFormField(
                initialValue: _recurrenceInterval.toString(),
                decoration: const InputDecoration(
                  labelText: 'Repeat every',
                  hintText: 'Number of days/weeks/months',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _recurrenceInterval = int.tryParse(value) ?? 1;
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    EasyLoading.show(status: 'Creating task...');

    try {
      final now = DateTime.now();
      final taskId = const Uuid().v4();

      TaskModel task;

      if (_taskType == TaskFormType.fixed) {
        task = TaskModel.fixed(
          id: taskId,
          title: _titleController.text.trim(),
          type: _category,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          location: _locationController.text.trim().isEmpty
              ? null
              : _locationController.text.trim(),
          contactName: _contactNameController.text.trim().isEmpty
              ? null
              : _contactNameController.text.trim(),
          contactEmail: _contactEmailController.text.trim().isEmpty
              ? null
              : _contactEmailController.text.trim(),
          contactPhone: _contactPhoneController.text.trim().isEmpty
              ? null
              : _contactPhoneController.text.trim(),
          hiddenTag: null,
          tags: _tags,
          routineId: null,
          createdAt: now,
          updatedAt: now,
          startDatetime: _startDateTime,
          endDatetime: _endDateTime,
          startReadonlyTimezone: null,
          endReadonlyTimezone: null,
          startDate: _startDateTime != null
              ? DateTime(_startDateTime!.year, _startDateTime!.month,
                  _startDateTime!.day)
              : null,
          endDate: _endDateTime != null
              ? DateTime(
                  _endDateTime!.year, _endDateTime!.month, _endDateTime!.day)
              : null,
          date: null,
          duration: _fixedDuration,
        );
      } else {
        task = TaskModel.flexible(
          id: taskId,
          title: _titleController.text.trim(),
          type: _category,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          location: _locationController.text.trim().isEmpty
              ? null
              : _locationController.text.trim(),
          contactName: _contactNameController.text.trim().isEmpty
              ? null
              : _contactNameController.text.trim(),
          contactEmail: _contactEmailController.text.trim().isEmpty
              ? null
              : _contactEmailController.text.trim(),
          contactPhone: _contactPhoneController.text.trim().isEmpty
              ? null
              : _contactPhoneController.text.trim(),
          hiddenTag: null,
          tags: _tags,
          routineId: null,
          createdAt: now,
          updatedAt: now,
          earliestActionDate: _earliestActionDate,
          dueDate: _dueDate,
          duration: _flexibleDuration,
          urgency: _urgency,
        );
      }

      final result = await ref.read(tasksProvider.notifier).createTask(task);

      if (result != null) {
        EasyLoading.showSuccess('Task created successfully!');
        if (mounted) {
          context.pop();
        }
      } else {
        EasyLoading.showError('Failed to create task');
      }
    } catch (e, st) {
      Logger.error('Failed to create task', e, st);
      EasyLoading.showError('Failed to create task: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Create Task'),
        backgroundColor: AppTheme.darkHeaderColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    _buildTaskTypeSelector(),
                    _buildBasicFields(),
                    _buildFixedTaskFields(),
                    _buildFlexibleTaskFields(),
                    _buildContactFields(),
                    _buildRecurrenceFields(),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),

            // Bottom buttons
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Create Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveTask,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Create Task',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Cancel Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey[400]!),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
