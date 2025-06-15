// lib/features/tasks/screens/task_create_edit_screen.dart
// Comprehensive task creation and editing screen supporting Fixed and Flexible tasks

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

class TaskCreateEditScreen extends ConsumerStatefulWidget {
  final String? taskId; // Null if creating new task
  final String?
      entityId; // Optional: pre-fill if task is associated with an entity
  final TaskFormType? initialType; // Optional: suggest initial type

  const TaskCreateEditScreen({
    super.key,
    this.taskId,
    this.entityId,
    this.initialType,
  });

  @override
  ConsumerState<TaskCreateEditScreen> createState() =>
      _TaskCreateEditScreenState();
}

class _TaskCreateEditScreenState extends ConsumerState<TaskCreateEditScreen> {
  final _formKey = GlobalKey<FormState>();

  // Basic fields
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();

  // Task type selection
  TaskFormType _formType = TaskFormType.flexible;
  TaskType _taskType = TaskType.task;
  UrgencyType? _urgency;
  HiddenTagType? _hiddenTag;
  List<String> _tags = [];

  // Fixed task fields
  DateTime? _startDateTime;
  DateTime? _endDateTime;
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _date;
  int? _fixedDuration;

  // Flexible task fields
  DateTime? _earliestActionDate;
  DateTime? _dueDate;
  int _flexibleDuration = 30;

  // Recurrence
  RecurrenceType? _recurrenceType;
  int _recurrenceInterval = 1;
  DateTime? _earliestOccurrence;
  DateTime? _latestOccurrence;

  // Entity associations
  final List<String> _selectedEntityIds = [];

  TaskModel? _initialTask;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Set initial form type
    if (widget.initialType != null) {
      _formType = widget.initialType!;
    }

    // Pre-select entity if provided
    if (widget.entityId != null) {
      _selectedEntityIds.add(widget.entityId!);
    }

    // Load existing task if editing
    if (widget.taskId != null) {
      _loadExistingTask();
    }
  }

  void _loadExistingTask() {
    final task = ref.read(taskByIdProvider(widget.taskId!));
    if (task != null) {
      _initialTask = task;
      _populateFormFromTask(task);
    }
  }

  void _populateFormFromTask(TaskModel task) {
    setState(() {
      _titleController.text = task.title;
      _notesController.text = task.notes ?? '';
      _locationController.text = task.location ?? '';
      _contactNameController.text = task.contactName ?? '';
      _contactEmailController.text = task.contactEmail ?? '';
      _contactPhoneController.text = task.contactPhone ?? '';

      _taskType = task.type;
      _hiddenTag = task.hiddenTag;
      _tags = List.from(task.tags);

      // Determine form type and populate specific fields
      task.when(
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
          _formType = TaskFormType.fixed;
          _startDateTime = startDatetime;
          _endDateTime = endDatetime;
          _startDate = startDate;
          _endDate = endDate;
          _date = date;
          _fixedDuration = duration;
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
          _formType = TaskFormType.flexible;
          _earliestActionDate = earliestActionDate;
          _dueDate = dueDate;
          _flexibleDuration = duration;
          _urgency = urgency;
        },
      );
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

  Future<void> _selectDateTime(
    BuildContext context, {
    required DateTime? initialDate,
    required Function(DateTime) onSelected,
    bool includeTime = false,
  }) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (pickedDate != null) {
      if (includeTime) {
        final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(initialDate ?? DateTime.now()),
        );

        if (pickedTime != null) {
          final combinedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          onSelected(combinedDateTime);
        }
      } else {
        onSelected(pickedDate);
      }
    }
  }

  Widget _buildDateTimeField({
    required String label,
    required DateTime? value,
    required Function(DateTime) onChanged,
    bool includeTime = false,
    String? helperText,
  }) {
    final format = includeTime
        ? DateFormat('MMM d, yyyy h:mm a')
        : DateFormat('MMM d, yyyy');

    return GestureDetector(
      onTap: () => _selectDateTime(
        context,
        initialDate: value,
        onSelected: onChanged,
        includeTime: includeTime,
      ),
      child: AbsorbPointer(
        child: TextFormField(
          controller: TextEditingController(
            text: value == null ? '' : format.format(value),
          ),
          decoration: InputDecoration(
            labelText: label,
            helperText: helperText,
            suffixIcon: Icon(
              includeTime ? Icons.access_time : Icons.calendar_today,
              color: Colors.grey[600],
            ),
          ),
        ),
      ),
    );
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
            Row(
              children: [
                Expanded(
                  child: RadioListTile<TaskFormType>(
                    title: const Text('Fixed Task'),
                    subtitle: const Text('Specific time & date'),
                    value: TaskFormType.fixed,
                    groupValue: _formType,
                    onChanged: (value) {
                      setState(() {
                        _formType = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<TaskFormType>(
                    title: const Text('Flexible Task'),
                    subtitle: const Text('Due date & duration'),
                    value: TaskFormType.flexible,
                    groupValue: _formType,
                    onChanged: (value) {
                      setState(() {
                        _formType = value!;
                      });
                    },
                  ),
                ),
              ],
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
            SizedBox(height: 12.h),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'What needs to be done?',
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
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16.h),

            // Task Type Dropdown
            DropdownButtonFormField<TaskType>(
              value: _taskType,
              decoration: const InputDecoration(
                labelText: 'Category',
              ),
              items: TaskType.values.map((type) {
                String label = type.toString().split('.').last;
                label = label.replaceAll('_', ' ').toLowerCase();
                label = label
                    .split(' ')
                    .map((word) => word.isNotEmpty
                        ? word[0].toUpperCase() + word.substring(1)
                        : '')
                    .join(' ');

                return DropdownMenuItem(
                  value: type,
                  child: Text(label),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _taskType = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedTaskFields() {
    if (_formType != TaskFormType.fixed) return const SizedBox.shrink();

    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fixed Task Details',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),

            // Start Date/Time
            _buildDateTimeField(
              label: 'Start Date & Time',
              value: _startDateTime,
              onChanged: (value) => setState(() => _startDateTime = value),
              includeTime: true,
              helperText: 'When does this task start?',
            ),
            SizedBox(height: 16.h),

            // End Date/Time
            _buildDateTimeField(
              label: 'End Date & Time',
              value: _endDateTime,
              onChanged: (value) => setState(() => _endDateTime = value),
              includeTime: true,
              helperText: 'When does this task end?',
            ),
            SizedBox(height: 16.h),

            // Duration (if no end time)
            TextFormField(
              initialValue: _fixedDuration?.toString() ?? '',
              decoration: const InputDecoration(
                labelText: 'Duration (minutes)',
                helperText: 'Leave empty if end time is specified',
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
    if (_formType != TaskFormType.flexible) return const SizedBox.shrink();

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
            SizedBox(height: 12.h),

            // Due Date
            _buildDateTimeField(
              label: 'Due Date',
              value: _dueDate,
              onChanged: (value) => setState(() => _dueDate = value),
              includeTime: false,
              helperText: 'When should this be completed by?',
            ),
            SizedBox(height: 16.h),

            // Earliest Action Date
            _buildDateTimeField(
              label: 'Earliest Start Date',
              value: _earliestActionDate,
              onChanged: (value) => setState(() => _earliestActionDate = value),
              includeTime: false,
              helperText: 'Earliest date you can start working on this',
            ),
            SizedBox(height: 16.h),

            // Duration
            TextFormField(
              initialValue: _flexibleDuration.toString(),
              decoration: const InputDecoration(
                labelText: 'Duration (minutes) *',
                helperText: 'How long will this task take?',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Duration is required';
                }
                if (int.tryParse(value) == null || int.parse(value) <= 0) {
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
              ),
              items: [
                const DropdownMenuItem(
                    value: null, child: Text('Not specified')),
                ...UrgencyType.values.map((urgency) {
                  String label = urgency.toString().split('.').last;
                  label =
                      label[0].toUpperCase() + label.substring(1).toLowerCase();

                  return DropdownMenuItem(
                    value: urgency,
                    child: Text(label),
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
              'Contact Information',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),

            // Location
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                hintText: 'Where will this task take place?',
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            SizedBox(height: 16.h),

            // Contact Name
            TextFormField(
              controller: _contactNameController,
              decoration: const InputDecoration(
                labelText: 'Contact Name',
                hintText: 'Who to contact about this task',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 16.h),

            // Contact Email
            TextFormField(
              controller: _contactEmailController,
              decoration: const InputDecoration(
                labelText: 'Contact Email',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.isNotEmpty && !value.contains('@')) {
                  return 'Please enter a valid email address';
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
              'Recurrence',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),

            // Recurrence Type
            DropdownButtonFormField<RecurrenceType?>(
              value: _recurrenceType,
              decoration: const InputDecoration(
                labelText: 'Repeat',
              ),
              items: [
                const DropdownMenuItem(
                    value: null, child: Text('Does not repeat')),
                ...RecurrenceType.values.map((type) {
                  String label = type.toString().split('.').last;
                  label = label.replaceAll('_', ' ').toLowerCase();
                  label = label
                      .split(' ')
                      .map((word) => word.isNotEmpty
                          ? word[0].toUpperCase() + word.substring(1)
                          : '')
                      .join(' ');

                  return DropdownMenuItem(
                    value: type,
                    child: Text(label),
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

              // Interval
              TextFormField(
                initialValue: _recurrenceInterval.toString(),
                decoration: InputDecoration(
                  labelText: 'Every',
                  helperText: _getRecurrenceHelperText(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Interval is required';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Please enter a valid interval';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _recurrenceInterval = int.tryParse(value) ?? 1;
                  });
                },
              ),
              SizedBox(height: 16.h),

              // Earliest Occurrence
              _buildDateTimeField(
                label: 'Start Repeating',
                value: _earliestOccurrence,
                onChanged: (value) =>
                    setState(() => _earliestOccurrence = value),
                includeTime: false,
                helperText: 'When should the recurrence start?',
              ),
              SizedBox(height: 16.h),

              // Latest Occurrence
              _buildDateTimeField(
                label: 'Stop Repeating',
                value: _latestOccurrence,
                onChanged: (value) => setState(() => _latestOccurrence = value),
                includeTime: false,
                helperText: 'When should the recurrence end?',
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getRecurrenceHelperText() {
    switch (_recurrenceType) {
      case RecurrenceType.daily:
        return 'Repeat every $_recurrenceInterval day(s)';
      case RecurrenceType.weekly:
        return 'Repeat every $_recurrenceInterval week(s)';
      case RecurrenceType.monthly:
        return 'Repeat every $_recurrenceInterval month(s)';
      case RecurrenceType.yearly:
        return 'Repeat every $_recurrenceInterval year(s)';
      default:
        return 'Custom recurrence interval';
    }
  }

  Widget _buildEntityAssignments() {
    final entitiesState = ref.watch(entitiesProvider);

    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assign to Entities',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            if (entitiesState.entities.isEmpty)
              const Text('No entities available')
            else
              ...entitiesState.entities.map((entity) {
                final isSelected = _selectedEntityIds.contains(entity.id);

                return CheckboxListTile(
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedEntityIds.add(entity.id);
                      } else {
                        _selectedEntityIds.remove(entity.id);
                      }
                    });
                  },
                  title: Text(entity.name),
                  subtitle: Text(entity.type.toString().split('.').last),
                );
              }),
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
    EasyLoading.show(status: 'Saving task...');

    try {
      final now = DateTime.now();
      final taskId = widget.taskId ?? const Uuid().v4();

      TaskModel task;

      if (_formType == TaskFormType.fixed) {
        task = TaskModel.fixed(
          id: taskId,
          title: _titleController.text.trim(),
          type: _taskType,
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
          hiddenTag: _hiddenTag,
          tags: _tags,
          routineId: null,
          createdAt: _initialTask?.createdAt ?? now,
          updatedAt: now,
          startDatetime: _startDateTime,
          endDatetime: _endDateTime,
          startReadonlyTimezone: null,
          endReadonlyTimezone: null,
          startDate: _startDate,
          endDate: _endDate,
          date: _date,
          duration: _fixedDuration,
        );
      } else {
        task = TaskModel.flexible(
          id: taskId,
          title: _titleController.text.trim(),
          type: _taskType,
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
          hiddenTag: _hiddenTag,
          tags: _tags,
          routineId: null,
          createdAt: _initialTask?.createdAt ?? now,
          updatedAt: now,
          earliestActionDate: _earliestActionDate,
          dueDate: _dueDate,
          duration: _flexibleDuration,
          urgency: _urgency,
        );
      }

      TaskModel? result;
      if (widget.taskId == null) {
        result = await ref.read(tasksProvider.notifier).createTask(task);
        EasyLoading.showSuccess('Task created successfully!');
      } else {
        result = await ref.read(tasksProvider.notifier).updateTask(task);
        EasyLoading.showSuccess('Task updated successfully!');
      }

      if (result != null && mounted) {
        context.pop();
      }
    } catch (e, st) {
      Logger.error('Failed to save task', e, st);
      EasyLoading.showError('Failed to save task: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.taskId != null;
    final title = isEditing ? 'Edit Task' : 'Create Task';

    return Scaffold(
      backgroundColor: AppTheme.lightBackgroundColor,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppTheme.darkHeaderColor,
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTaskTypeSelector(),
                _buildBasicFields(),
                _buildFixedTaskFields(),
                _buildFlexibleTaskFields(),
                _buildContactFields(),
                _buildRecurrenceFields(),
                _buildEntityAssignments(),

                SizedBox(height: 24.h),

                // Save Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    isEditing ? 'Save Changes' : 'Create Task',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(height: 12.h),

                // Cancel Button
                OutlinedButton(
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
                    style: TextStyle(
                      fontSize: 16.sp,
                    ),
                  ),
                ),

                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
