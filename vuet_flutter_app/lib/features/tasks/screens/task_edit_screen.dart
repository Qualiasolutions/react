// lib/features/tasks/screens/task_edit_screen.dart
// Screen for creating and editing tasks, matching the React Native design

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:uuid/uuid.dart';

import 'package:vuet_flutter/core/constants/app_constants.dart';
import 'package:vuet_flutter/core/theme/app_theme.dart';
import 'package:vuet_flutter/core/utils/logger.dart';
import 'package:vuet_flutter/features/tasks/data/models/task_model.dart';
import 'package:vuet_flutter/features/tasks/providers/tasks_provider.dart';

class TaskEditScreen extends ConsumerStatefulWidget {
  final String? taskId; // Null if creating new task
  final String?
      entityId; // Optional: pre-fill if task is associated with an entity

  const TaskEditScreen({
    super.key,
    this.taskId,
    this.entityId,
  });

  @override
  ConsumerState<TaskEditScreen> createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends ConsumerState<TaskEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDueDate;
  TaskType _selectedTaskType = TaskType.task;
  UrgencyType _selectedUrgency = UrgencyType.medium;

  // Recurrence fields
  RecurrenceType? _selectedRecurrenceType;
  final _recurrenceIntervalController = TextEditingController(text: '1');
  DateTime? _recurrenceEarliestOccurrence;
  DateTime? _recurrenceLatestOccurrence;

  // Reminders fields
  final List<TaskReminder> _reminders = [];
  final _reminderTimeDeltaController = TextEditingController(text: '1 day');

  TaskModel? _initialTask;

  @override
  void initState() {
    super.initState();
    if (widget.taskId != null) {
      // Editing existing task
      _initialTask = ref.read(taskByIdProvider(widget.taskId!));
      if (_initialTask != null) {
        _titleController.text = _initialTask!.title;
        _descriptionController.text = _initialTask!.description ?? '';
        _selectedDueDate = _initialTask!.dueDate;
        _selectedTaskType = _initialTask!.type;
        _selectedUrgency = _initialTask!.urgency ?? UrgencyType.medium;

        if (_initialTask!.recurrence != null) {
          _selectedRecurrenceType = _initialTask!.recurrence!.recurrence;
          _recurrenceIntervalController.text =
              _initialTask!.recurrence!.intervalLength.toString();
          _recurrenceEarliestOccurrence =
              _initialTask!.recurrence!.earliestOccurrence;
          _recurrenceLatestOccurrence =
              _initialTask!.recurrence!.latestOccurrence;
        }
        _reminders.addAll(_initialTask!.reminders);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _recurrenceIntervalController.dispose();
    _reminderTimeDeltaController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: AppTheme.darkTextColor, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryColor, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  void _addReminder() {
    if (_reminderTimeDeltaController.text.isNotEmpty) {
      setState(() {
        _reminders.add(TaskReminder(
          id: const Uuid().v4(),
          timedelta: _reminderTimeDeltaController.text.trim(),
          createdAt: DateTime.now(),
        ));
        _reminderTimeDeltaController.clear();
      });
    }
  }

  void _removeReminder(String id) {
    setState(() {
      _reminders.removeWhere((reminder) => reminder.id == id);
    });
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    EasyLoading.show(status: 'Saving task...');

    try {
      final userId = ref.read(userIdProvider);
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final taskRecurrence = _selectedRecurrenceType != null
          ? TaskRecurrence(
              id: _initialTask?.recurrence?.id ?? const Uuid().v4(),
              recurrence: _selectedRecurrenceType!,
              intervalLength:
                  int.tryParse(_recurrenceIntervalController.text) ?? 1,
              earliestOccurrence: _recurrenceEarliestOccurrence,
              latestOccurrence: _recurrenceLatestOccurrence,
            )
          : null;

      final assignedTo = <String>[];
      if (widget.entityId != null) {
        assignedTo.add(widget.entityId!);
      }
      // Add current user as assigned to if not already there
      if (!assignedTo.contains(userId)) {
        assignedTo.add(userId);
      }

      if (widget.taskId == null) {
        // Create new task
        final newTask = TaskModel(
          id: const Uuid().v4(), // Generate a client-side ID for now
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          type: _selectedTaskType,
          urgency: _selectedUrgency,
          dueDate: _selectedDueDate,
          assignedTo: assignedTo,
          recurrence: taskRecurrence,
          reminders: _reminders,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await ref.read(tasksProvider.notifier).createTask(newTask);
        EasyLoading.showSuccess('Task created successfully!');
      } else {
        // Update existing task
        final updatedTask = _initialTask!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          type: _selectedTaskType,
          urgency: _selectedUrgency,
          dueDate: _selectedDueDate,
          assignedTo: assignedTo,
          recurrence: taskRecurrence,
          reminders: _reminders,
          updatedAt: DateTime.now(),
        );
        await ref.read(tasksProvider.notifier).updateTask(updatedTask);
        EasyLoading.showSuccess('Task updated successfully!');
      }
      if (mounted) {
        context.pop(); // Go back to previous screen
      }
    } catch (e, st) {
      Logger.error('Failed to save task', e, st);
      EasyLoading.showError('Failed to save task: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.taskId != null;
    final title = isEditing ? 'Edit Task' : 'Add New Task';

    return Scaffold(
      backgroundColor: AppTheme.lightBackgroundColor,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppTheme.darkHeaderColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(UIConstants.paddingM.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title Field
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'e.g., Buy groceries, Call mom',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title cannot be empty';
                    }
                    return null;
                  },
                ),
                SizedBox(height: UIConstants.paddingM.h),

                // Description Field
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'Any additional details about the task',
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: UIConstants.paddingM.h),

                // Due Date Field
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: TextEditingController(
                        text: _selectedDueDate == null
                            ? ''
                            : DateFormat('MMM d, yyyy')
                                .format(_selectedDueDate!),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Due Date (Optional)',
                        hintText: 'Select a date',
                        suffixIcon:
                            Icon(Icons.calendar_today, color: Colors.grey[600]),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: UIConstants.paddingM.h),

                // Task Type Dropdown
                DropdownButtonFormField<TaskType>(
                  value: _selectedTaskType,
                  decoration: const InputDecoration(
                    labelText: 'Task Type',
                  ),
                  items: TaskType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.toDbString().replaceAll('_', ' ')),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTaskType = value!;
                    });
                  },
                ),
                SizedBox(height: UIConstants.paddingM.h),

                // Urgency Dropdown
                DropdownButtonFormField<UrgencyType>(
                  value: _selectedUrgency,
                  decoration: const InputDecoration(
                    labelText: 'Urgency',
                  ),
                  items: UrgencyType.values.map((urgency) {
                    return DropdownMenuItem(
                      value: urgency,
                      child: Text(urgency.toDbString()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedUrgency = value!;
                    });
                  },
                ),
                SizedBox(height: UIConstants.paddingXL.h),

                // Recurrence Section
                Text(
                  'Recurrence',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkTextColor,
                  ),
                ),
                SizedBox(height: UIConstants.paddingS.h),
                DropdownButtonFormField<RecurrenceType?>(
                  value: _selectedRecurrenceType,
                  decoration: const InputDecoration(
                    labelText: 'Recurrence Type (Optional)',
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('None')),
                    ...RecurrenceType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.toDbString().replaceAll('_', ' ')),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRecurrenceType = value;
                    });
                  },
                ),
                if (_selectedRecurrenceType != null) ...[
                  SizedBox(height: UIConstants.paddingM.h),
                  TextFormField(
                    controller: _recurrenceIntervalController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Interval Length',
                      hintText: 'e.g., 1 for every day/week/month',
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: UIConstants.paddingM.h),
                  // Earliest Occurrence Date
                  GestureDetector(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate:
                            _recurrenceEarliestOccurrence ?? DateTime.now(),
                        firstDate: DateTime.now()
                            .subtract(const Duration(days: 365 * 5)),
                        lastDate:
                            DateTime.now().add(const Duration(days: 365 * 10)),
                      );
                      if (picked != null &&
                          picked != _recurrenceEarliestOccurrence) {
                        setState(() {
                          _recurrenceEarliestOccurrence = picked;
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: TextEditingController(
                          text: _recurrenceEarliestOccurrence == null
                              ? ''
                              : DateFormat('MMM d, yyyy')
                                  .format(_recurrenceEarliestOccurrence!),
                        ),
                        decoration: InputDecoration(
                          labelText: 'Earliest Occurrence (Optional)',
                          suffixIcon: Icon(Icons.calendar_today,
                              color: Colors.grey[600]),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: UIConstants.paddingM.h),
                  // Latest Occurrence Date
                  GestureDetector(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _recurrenceLatestOccurrence ??
                            DateTime.now().add(const Duration(days: 365)),
                        firstDate: DateTime.now()
                            .subtract(const Duration(days: 365 * 5)),
                        lastDate:
                            DateTime.now().add(const Duration(days: 365 * 10)),
                      );
                      if (picked != null &&
                          picked != _recurrenceLatestOccurrence) {
                        setState(() {
                          _recurrenceLatestOccurrence = picked;
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: TextEditingController(
                          text: _recurrenceLatestOccurrence == null
                              ? ''
                              : DateFormat('MMM d, yyyy')
                                  .format(_recurrenceLatestOccurrence!),
                        ),
                        decoration: InputDecoration(
                          labelText: 'Latest Occurrence (Optional)',
                          suffixIcon: Icon(Icons.calendar_today,
                              color: Colors.grey[600]),
                        ),
                      ),
                    ),
                  ),
                ],
                SizedBox(height: UIConstants.paddingXL.h),

                // Reminders Section
                Text(
                  'Reminders',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkTextColor,
                  ),
                ),
                SizedBox(height: UIConstants.paddingS.h),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _reminderTimeDeltaController,
                        decoration: const InputDecoration(
                          labelText: 'Reminder Time',
                          hintText: 'e.g., 1 day, 30 minutes',
                        ),
                      ),
                    ),
                    SizedBox(width: UIConstants.paddingS.w),
                    ElevatedButton(
                      onPressed: _addReminder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Add'),
                    ),
                  ],
                ),
                SizedBox(height: UIConstants.paddingM.h),
                // Reminder List
                ..._reminders.map((reminder) => Card(
                      margin: EdgeInsets.only(bottom: UIConstants.paddingS.h),
                      child: ListTile(
                        leading: const Icon(Icons.notifications),
                        title: Text('Remind ${reminder.timedelta} before'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeReminder(reminder.id),
                        ),
                      ),
                    )),
                SizedBox(height: UIConstants.paddingXL.h),

                // Save Button
                ElevatedButton(
                  onPressed: _saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(UIConstants.radiusM.r),
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
                SizedBox(height: UIConstants.paddingS.h),

                // Cancel Button
                OutlinedButton(
                  onPressed: () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    side: BorderSide(color: Colors.grey[400]!),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(UIConstants.radiusM.r),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
