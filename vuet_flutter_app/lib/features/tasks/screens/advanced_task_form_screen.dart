// lib/features/tasks/screens/advanced_task_form_screen.dart
// Advanced task form screen using the dynamic forms engine.
// Matches functionality of React Native's GenericTaskForm.tsx

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vuet_flutter/core/utils/logger.dart';
import 'package:vuet_flutter/features/forms/models/form_field_config.dart';
import 'package:vuet_flutter/features/forms/widgets/dynamic_form.dart';
import 'package:vuet_flutter/features/tasks/data/repositories/tasks_repository.dart';
import 'package:vuet_flutter/features/tasks/models/task_model.dart'; // Assuming TaskModel is defined here

// Enum for task types, matching React Native's TaskType
enum TaskType {
  fixed,
  flexible,
  anniversary,
  holiday,
  transport,
  accommodation,
  activity,
  userBirthday,
  // Add other task types as needed
}

// Provider for selected task type in the form
final selectedTaskTypeProvider = StateProvider<TaskType>((ref) => TaskType.fixed);

class AdvancedTaskFormScreen extends ConsumerStatefulWidget {
  final TaskModel? initialTask; // For edit mode
  final bool isEdit;

  const AdvancedTaskFormScreen({
    super.key,
    this.initialTask,
    this.isEdit = false,
  });

  @override
  ConsumerState<AdvancedTaskFormScreen> createState() => _AdvancedTaskFormScreenState();
}

class _AdvancedTaskFormScreenState extends ConsumerState<AdvancedTaskFormScreen> {
  late FormSchema _taskFormSchema;
  late Map<String, dynamic> _initialFormValues;
  bool _isSubmitting = false;
  String? _formError;
  bool _showRecurrenceModal = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  @override
  void didUpdateWidget(covariant AdvancedTaskFormScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTask != widget.initialTask || oldWidget.isEdit != widget.isEdit) {
      _initializeForm();
    }
  }

  void _initializeForm() {
    _initialFormValues = _mapTaskModelToFormValues(widget.initialTask);
    _taskFormSchema = _buildTaskFormSchema();
  }

  Map<String, dynamic> _mapTaskModelToFormValues(TaskModel? task) {
    if (task == null) return {};
    
    // Map task model to form values
    final values = <String, dynamic>{
      'title': task.title,
      'notes': task.notes,
      'location': task.location,
      'contact_name': task.contactName,
      'contact_email': task.contactEmail,
      'contact_phone': task.contactPhone,
      'duration': task.duration,
      'earliest_action_date': task.earliestActionDate,
      'due_date': task.dueDate,
      'start_datetime': task.startDatetime,
      'end_datetime': task.endDatetime,
      'start_date': task.startDate,
      'end_date': task.endDate,
      'task_type_selection': task.type.name, // Map enum to string for dropdown
      'is_flexible': task.type == TaskType.flexible,
    };

    // Add any other fields from TaskModel as needed
    return values;
  }

  FormSchema _buildTaskFormSchema() {
    final selectedType = ref.watch(selectedTaskTypeProvider);
    final isFlexible = selectedType == TaskType.flexible;

    return FormSchemaBuilder.buildSchema(
      id: 'task_form',
      title: widget.isEdit ? 'Edit Task' : 'Create New Task',
      description: 'Fill in the details for your task.',
      sections: [
        // Basic information section
        FormSectionConfig(
          id: 'basic_info',
          title: 'Basic Information',
          fields: [
            // Task type selection
            FormFieldBuilder.dropdownField(
              name: 'task_type_selection',
              label: 'Task Type',
              options: TaskType.values.map((type) => FieldOption(
                value: type.name,
                label: type.name.replaceAll(RegExp(r'(?<!^)(?=[A-Z])'), ' '), // Convert camelCase to readable string
              )).toList(),
              defaultValue: selectedType.name,
              required: true,
            ),
            
            // Title field
            FormFieldBuilder.textField(
              name: 'title',
              label: 'Title',
              placeholder: 'e.g., Buy groceries',
              required: true,
            ),
            
            // Notes field
            FormFieldBuilder.textField(
              name: 'notes',
              label: 'Notes',
              placeholder: 'Add any additional details',
              multiline: true,
              maxLines: 5,
            ),
            
            // Category selection
            FormFieldBuilder.dropdownField(
              name: 'category',
              label: 'Category',
              options: [
                FieldOption(value: 'home', label: 'Home'),
                FieldOption(value: 'work', label: 'Work'),
                FieldOption(value: 'health', label: 'Health'),
                FieldOption(value: 'finance', label: 'Finance'),
                FieldOption(value: 'social', label: 'Social'),
                FieldOption(value: 'transport', label: 'Transport'),
                FieldOption(value: 'travel', label: 'Travel'),
              ],
              required: true,
            ),
            
            // Task color
            FormFieldBuilder.textField(
              name: 'color',
              label: 'Task Color',
              type: FormFieldType.color, // Custom color picker field
            ),
          ],
        ),
        
        // Scheduling section - different fields based on task type
        FormSectionConfig(
          id: 'scheduling',
          title: 'Scheduling',
          fields: [
            // For fixed tasks: start date and end date
            FormFieldBuilder.dateField(
              name: 'start_date',
              label: 'Start Date',
              placeholder: 'Select start date',
              dependencies: [
                FieldDependency(
                  field: 'task_type_selection',
                  conditions: [
                    FieldCondition(field: 'task_type_selection', operator: 'equals', value: TaskType.fixed.name),
                    FieldCondition(field: 'task_type_selection', operator: 'equals', value: TaskType.anniversary.name),
                    FieldCondition(field: 'task_type_selection', operator: 'equals', value: TaskType.holiday.name),
                    FieldCondition(field: 'task_type_selection', operator: 'equals', value: TaskType.transport.name),
                    FieldCondition(field: 'task_type_selection', operator: 'equals', value: TaskType.accommodation.name),
                    FieldCondition(field: 'task_type_selection', operator: 'equals', value: TaskType.activity.name),
                  ],
                  showWhenMatched: true,
                ),
              ],
              required: true,
            ),
            
            // Start time for fixed tasks
            FormFieldBuilder.textField(
              name: 'start_time',
              label: 'Start Time',
              type: FormFieldType.time,
              dependencies: [
                FieldDependency(
                  field: 'task_type_selection',
                  conditions: [
                    FieldCondition(field: 'task_type_selection', operator: 'equals', value: TaskType.fixed.name),
                    FieldCondition(field: 'task_type_selection', operator: 'equals', value: TaskType.transport.name),
                    FieldCondition(field: 'task_type_selection', operator: 'equals', value: TaskType.accommodation.name),
                    FieldCondition(field: 'task_type_selection', operator: 'equals', value: TaskType.activity.name),
                  ],
                  showWhenMatched: true,
                ),
              ],
            ),
            
            // End date for fixed tasks
            FormFieldBuilder.dateField(
              name: 'end_date',
              label: 'End Date',
              placeholder: 'Select end date',
              dependencies: [
                FieldDependency(
                  field: 'task_type_selection',
                  conditions: [
                    FieldCondition(field: 'task_type_selection', operator: 'equals', value: TaskType.fixed.name),
                    FieldCondition(field: 'task_type_selection', operator: 'equals', value: TaskType.holiday.name),
                    FieldCondition(field: 'task_type_selection', operator: 'equals', value: TaskType.transport.name),
                    FieldCondition(field: 'task_type_selection', operator: 'equals', value: TaskType.accommodation.name),
                    FieldCondition(field: 'task_type_selection', operator: 'equals', value: TaskType.activity.name),
                  ],
                  showWhenMatched: true,
                ),
              ],
            ),
            
            // End time for fixed tasks
            FormFieldBuilder.textField(
              name: 'end_time',
              label: 'End Time',
              type: FormFieldType.time,
              dependencies: [
                FieldDependency(
                  field: 'task_type_selection',
                  conditions: [
                    FieldCondition(field: 'task_type_selection', operator: 'equals', value: TaskType.fixed.name),
                    FieldCondition(field: 'task_type_selection', operator: 'equals', value: TaskType.transport.name),
                    FieldCondition(field: 'task_type_selection', operator: 'equals', value: TaskType.accommodation.name),
                    FieldCondition(field: 'task_type_selection', operator: 'equals', value: TaskType.activity.name),
                  ],
                  showWhenMatched: true,
                ),
              ],
            ),
            
            // For flexible tasks: due date and earliest action date
            FormFieldBuilder.dateField(
              name: 'due_date',
              label: 'Due Date',
              placeholder: 'Select due date',
              dependencies: [
                FieldDependency(
                  field: 'task_type_selection',
                  conditions: [
                    FieldCondition(field: 'task_type_selection', operator: 'equals', value: TaskType.flexible.name),
                  ],
                  showWhenMatched: true,
                ),
              ],
              required: true,
            ),
            
            FormFieldBuilder.dateField(
              name: 'earliest_action_date',
              label: 'Earliest Action Date',
              placeholder: 'Select earliest date',
              dependencies: [
                FieldDependency(
                  field: 'task_type_selection',
                  conditions: [
                    FieldCondition(field: 'task_type_selection', operator: 'equals', value: TaskType.flexible.name),
                  ],
                  showWhenMatched: true,
                ),
              ],
            ),
            
            // Duration for flexible tasks
            FormFieldBuilder.textField(
              name: 'duration',
              label: 'Duration (minutes)',
              placeholder: 'e.g., 60',
              type: FormFieldType.number,
              dependencies: [
                FieldDependency(
                  field: 'task_type_selection',
                  conditions: [
                    FieldCondition(field: 'task_type_selection', operator: 'equals', value: TaskType.flexible.name),
                  ],
                  showWhenMatched: true,
                ),
              ],
              required: true,
            ),
            
            // Recurrence for fixed and flexible tasks
            FormFieldBuilder.textField(
              name: 'recurrence',
              label: 'Recurrence',
              type: FormFieldType.recurrence, // Custom recurrence field
              dependencies: [
                FieldDependency(
                  field: 'task_type_selection',
                  conditions: [
                    FieldCondition(field: 'task_type_selection', operator: 'equals', value: TaskType.fixed.name),
                    FieldCondition(field: 'task_type_selection', operator: 'equals', value: TaskType.flexible.name),
                  ],
                  showWhenMatched: true,
                ),
              ],
            ),
          ],
        ),
        
        // Contact information section
        FormSectionConfig(
          id: 'contact_info',
          title: 'Contact Information',
          fields: [
            FormFieldBuilder.textField(
              name: 'location',
              label: 'Location',
              placeholder: 'e.g., Home, Office, Park',
            ),
            
            FormFieldBuilder.textField(
              name: 'contact_name',
              label: 'Contact Name',
              placeholder: 'e.g., John Doe',
            ),
            
            FormFieldBuilder.textField(
              name: 'contact_email',
              label: 'Contact Email',
              placeholder: 'e.g., john.doe@example.com',
              type: FormFieldType.email,
            ),
            
            FormFieldBuilder.textField(
              name: 'contact_phone',
              label: 'Contact Phone',
              placeholder: 'e.g., +15551234567',
              type: FormFieldType.phone,
            ),
          ],
        ),
        
        // Associated items section
        FormSectionConfig(
          id: 'associated_items',
          title: 'Associated Items',
          fields: [
            FormFieldBuilder.entitySelectorField(
              name: 'entities',
              label: 'Related Entities',
              allowMultipleEntities: true,
              entityTypes: ['CAR', 'PET', 'TRIP', 'HOME'], // Example entity types
            ),
            
            FormFieldBuilder.memberSelectorField(
              name: 'members',
              label: 'Assigned Members',
              allowMultipleMembers: true,
              includeFamily: true,
              includeFriends: true,
            ),
            
            FormFieldBuilder.textField(
              name: 'tags',
              label: 'Tags',
              type: FormFieldType.tagSelector, // Custom tag selector
            ),
          ],
        ),
        
        // Reminders and actions section
        FormSectionConfig(
          id: 'reminders_actions',
          title: 'Reminders & Actions',
          fields: [
            FormFieldBuilder.textField(
              name: 'reminders',
              label: 'Reminders',
              type: FormFieldType.reminderSelector, // Custom reminder selector
            ),
            
            FormFieldBuilder.textField(
              name: 'actions',
              label: 'Actions',
              type: FormFieldType.actionSelector, // Custom action selector
            ),
          ],
        ),
      ],
    );
  }

  void _handleFormValueChanges(Map<String, dynamic> values) {
    // Update selected task type based on form selection
    final selectedTypeString = values['task_type_selection'] as String?;
    if (selectedTypeString != null) {
      try {
        final newTaskType = TaskType.values.firstWhere(
          (type) => type.name == selectedTypeString,
          orElse: () => TaskType.fixed,
        );
        
        if (ref.read(selectedTaskTypeProvider) != newTaskType) {
          ref.read(selectedTaskTypeProvider.notifier).state = newTaskType;
        }
      } catch (e) {
        Logger.error('Error updating task type: $e');
      }
    }

    // Handle date/time synchronization similar to GenericTaskForm.tsx
    if (values.containsKey('start_datetime') || values.containsKey('end_datetime')) {
      // Update related date fields when datetime changes
      final startDateTime = values['start_datetime'] as DateTime?;
      final endDateTime = values['end_datetime'] as DateTime?;
      
      if (startDateTime != null) {
        values['start_date'] = startDateTime;
        values['date'] = startDateTime;
        values['due_date'] = startDateTime;
      }
      
      if (endDateTime != null) {
        values['end_date'] = endDateTime;
      }
    }

    if (values.containsKey('start_date') || values.containsKey('end_date')) {
      // Update related datetime fields when date changes
      final startDate = values['start_date'] as DateTime?;
      final endDate = values['end_date'] as DateTime?;
      
      if (startDate != null) {
        values['start_datetime'] = startDate;
        values['date'] = startDate;
        values['due_date'] = startDate;
      }
      
      if (endDate != null) {
        values['end_datetime'] = endDate;
      }
    }

    if (values.containsKey('date')) {
      // Update all date fields when primary date changes
      final date = values['date'] as DateTime?;
      
      if (date != null) {
        values['start_datetime'] = date;
        values['end_datetime'] = date;
        values['start_date'] = date;
        values['end_date'] = date;
        values['due_date'] = date;
      }
    }
  }

  Future<void> _submitForm(Map<String, dynamic> formValues) async {
    // Don't proceed if already submitting
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _formError = null;
    });

    try {
      // Update the selected task type based on form input
      final selectedTypeString = formValues['task_type_selection'] as String?;
      final selectedType = selectedTypeString != null
          ? TaskType.values.firstWhere(
              (type) => type.name == selectedTypeString,
              orElse: () => TaskType.fixed,
            )
          : TaskType.fixed;

      // Parse form values into task model
      final taskData = _parseFormValues(formValues, selectedType);

      if (widget.isEdit && widget.initialTask != null) {
        // Handle recurrence update if this is a recurring task
        final hasRecurrence = formValues['recurrence'] != null;
        if (hasRecurrence && !_showRecurrenceModal) {
          // Show recurrence update modal for existing recurring tasks
          setState(() {
            _showRecurrenceModal = true;
          });
          return;
        }

        // Update existing task
        await _updateTask(taskData);
      } else {
        // Create new task
        await _createTask(taskData);
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEdit ? 'Task updated successfully!' : 'Task created successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Navigate back
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      Logger.error('Error submitting task form: $e');
      setState(() {
        _formError = 'Failed to ${widget.isEdit ? 'update' : 'create'} task. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Map<String, dynamic> _parseFormValues(Map<String, dynamic> formValues, TaskType taskType) {
    // Start with basic fields
    final parsedValues = <String, dynamic>{
      'title': formValues['title'],
      'notes': formValues['notes'],
      'location': formValues['location'],
      'contact_name': formValues['contact_name'],
      'contact_email': formValues['contact_email'],
      'contact_phone': formValues['contact_phone'],
      'type': taskType,
    };

    // Add fields based on task type
    if (taskType == TaskType.flexible) {
      parsedValues['duration'] = formValues['duration'];
      parsedValues['due_date'] = formValues['due_date'];
      parsedValues['earliest_action_date'] = formValues['earliest_action_date'];
    } else {
      parsedValues['start_date'] = formValues['start_date'];
      parsedValues['end_date'] = formValues['end_date'] ?? formValues['start_date'];
      
      // Handle start/end times if provided
      if (formValues['start_time'] != null) {
        final startDate = formValues['start_date'] as DateTime;
        final startTime = formValues['start_time'] as DateTime;
        parsedValues['start_datetime'] = DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
          startTime.hour,
          startTime.minute,
        );
      }
      
      if (formValues['end_time'] != null) {
        final endDate = (formValues['end_date'] ?? formValues['start_date']) as DateTime;
        final endTime = formValues['end_time'] as DateTime;
        parsedValues['end_datetime'] = DateTime(
          endDate.year,
          endDate.month,
          endDate.day,
          endTime.hour,
          endTime.minute,
        );
      }
    }

    // Add recurrence if provided
    if (formValues['recurrence'] != null) {
      parsedValues['recurrence'] = formValues['recurrence'];
    }

    // Add entities, members, tags if provided
    if (formValues['entities'] != null) {
      parsedValues['entities'] = formValues['entities'];
    }
    
    if (formValues['members'] != null) {
      parsedValues['members'] = formValues['members'];
    }
    
    if (formValues['tags'] != null) {
      parsedValues['tags'] = formValues['tags'];
    }

    // Add reminders and actions if provided
    if (formValues['reminders'] != null) {
      parsedValues['reminders'] = formValues['reminders'];
    }
    
    if (formValues['actions'] != null) {
      parsedValues['actions'] = formValues['actions'];
    }

    // Add category and color if provided
    if (formValues['category'] != null) {
      parsedValues['category'] = formValues['category'];
    }
    
    if (formValues['color'] != null) {
      parsedValues['color'] = formValues['color'];
    }

    return parsedValues;
  }

  Future<void> _createTask(Map<String, dynamic> taskData) async {
    final taskType = taskData['type'] as TaskType;
    
    if (taskType == TaskType.flexible) {
      // Create flexible task
      await ref.read(tasksRepositoryProvider).createFlexibleTask(taskData);
    } else {
      // Create fixed task
      await ref.read(tasksRepositoryProvider).createTask(taskData);
    }
  }

  Future<void> _updateTask(Map<String, dynamic> taskData) async {
    if (widget.initialTask == null) return;
    
    // Create updated task model
    final updatedTask = widget.initialTask!.copyWith(
      title: taskData['title'],
      notes: taskData['notes'],
      location: taskData['location'],
      contactName: taskData['contact_name'],
      contactEmail: taskData['contact_email'],
      contactPhone: taskData['contact_phone'],
      duration: taskData['duration'],
      earliestActionDate: taskData['earliest_action_date'],
      dueDate: taskData['due_date'],
      startDatetime: taskData['start_datetime'],
      endDatetime: taskData['end_datetime'],
      startDate: taskData['start_date'],
      endDate: taskData['end_date'],
      type: taskData['type'],
      // Update other fields as needed
    );
    
    await ref.read(tasksRepositoryProvider).updateTask(updatedTask);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Task' : 'Create Task'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Form error message
            if (_formError != null)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(8.r),
                color: Colors.red.shade100,
                child: Text(
                  _formError!,
                  style: TextStyle(color: Colors.red.shade900),
                  textAlign: TextAlign.center,
                ),
              ),
            
            // Dynamic form
            Expanded(
              child: DynamicForm(
                schema: _taskFormSchema,
                initialValues: _initialFormValues,
                onSubmit: _submitForm,
                onFormValuesChange: _handleFormValueChanges,
                submitButtonText: widget.isEdit ? 'Update Task' : 'Create Task',
                cancelButtonText: 'Cancel',
                onCancel: () => context.pop(),
                validateOnChange: true,
                padding: EdgeInsets.all(16.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Recurrence update modal - would be implemented separately
class RecurrenceUpdateModal extends ConsumerWidget {
  final bool visible;
  final VoidCallback onClose;
  final int recurrenceIndex;
  final int taskId;
  final Map<String, dynamic> updatedValues;

  const RecurrenceUpdateModal({
    super.key,
    required this.visible,
    required this.onClose,
    required this.recurrenceIndex,
    required this.taskId,
    required this.updatedValues,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!visible) return const SizedBox.shrink();
    
    return AlertDialog(
      title: const Text('Update Recurring Task'),
      content: const Text(
        'Do you want to update just this occurrence or all future occurrences?'
      ),
      actions: [
        TextButton(
          onPressed: onClose,
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: () {
            // Update this occurrence only
            // Implementation would go here
            onClose();
          },
          child: const Text('THIS OCCURRENCE'),
        ),
        TextButton(
          onPressed: () {
            // Update all future occurrences
            // Implementation would go here
            onClose();
          },
          child: const Text('ALL FUTURE'),
        ),
      ],
    );
  }
}
