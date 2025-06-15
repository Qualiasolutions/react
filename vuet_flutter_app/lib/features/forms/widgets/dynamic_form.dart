// lib/features/forms/widgets/dynamic_form.dart
// Dynamic form engine that renders forms based on FormFieldConfig models
// Matches the functionality of React Native's TypedForm.tsx

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:vuet_flutter/core/utils/logger.dart';
import 'package:vuet_flutter/features/forms/models/form_field_config.dart';

// Form field value provider - used to track form values for dependency evaluation
final formValuesProvider = StateProvider.family<Map<String, dynamic>, String>(
  (ref, formId) => {},
);

// Form validation state provider
final formValidationProvider = StateProvider.family<bool, String>(
  (ref, formId) => false,
);

// Form auto-save timer provider
final formAutoSaveTimerProvider = StateProvider.family<Timer?, String>(
  (ref, formId) => null,
);

/// Main dynamic form widget that renders a form based on a FormSchema
class DynamicForm extends ConsumerStatefulWidget {
  final FormSchema schema;
  final Map<String, dynamic>? initialValues;
  final Function(Map<String, dynamic>)? onSubmit;
  final Function(Map<String, dynamic>)? onAutoSave;
  final Function()? onCancel;
  final bool showSubmitButton;
  final bool showCancelButton;
  final String? submitButtonText;
  final String? cancelButtonText;
  final bool validateOnChange;
  final bool autoSave;
  final int autoSaveIntervalSeconds;
  final Widget? customHeader;
  final Widget? customFooter;
  final EdgeInsets? padding;
  final ScrollPhysics? scrollPhysics;
  final bool shrinkWrap;

  const DynamicForm({
    super.key,
    required this.schema,
    this.initialValues,
    this.onSubmit,
    this.onAutoSave,
    this.onCancel,
    this.showSubmitButton = true,
    this.showCancelButton = true,
    this.submitButtonText,
    this.cancelButtonText,
    this.validateOnChange = true,
    this.autoSave = false,
    this.autoSaveIntervalSeconds = 30,
    this.customHeader,
    this.customFooter,
    this.padding,
    this.scrollPhysics,
    this.shrinkWrap = false,
  });

  @override
  ConsumerState<DynamicForm> createState() => _DynamicFormState();
}

class _DynamicFormState extends ConsumerState<DynamicForm> {
  late FormGroup _form;
  bool _isSubmitting = false;
  bool _isAutoSaving = false;
  String? _formError;
  Timer? _autoSaveTimer;
  final Map<String, bool> _visibleFields = {};

  @override
  void initState() {
    super.initState();
    _initForm();
    
    // Setup auto-save if enabled
    if (widget.autoSave && widget.onAutoSave != null) {
      _setupAutoSave();
    }
  }

  @override
  void didUpdateWidget(DynamicForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Reinitialize form if schema changes
    if (oldWidget.schema.id != widget.schema.id) {
      _form.dispose();
      _initForm();
    }
    
    // Update auto-save timer if needed
    if (widget.autoSave != oldWidget.autoSave || 
        widget.autoSaveIntervalSeconds != oldWidget.autoSaveIntervalSeconds) {
      _cancelAutoSave();
      if (widget.autoSave && widget.onAutoSave != null) {
        _setupAutoSave();
      }
    }
  }

  @override
  void dispose() {
    _cancelAutoSave();
    _form.dispose();
    super.dispose();
  }

  void _initForm() {
    // Create form controls from schema
    final controls = <String, AbstractControl<dynamic>>{};
    
    // Process fields from sections if available
    if (widget.schema.sections != null) {
      for (final section in widget.schema.sections!) {
        if (section.fields != null) {
          for (final field in section.fields!) {
            controls[field.name] = _createFormControl(field);
            _visibleFields[field.name] = _shouldShowField(field);
          }
        }
      }
    }
    
    // Process flat fields if available
    if (widget.schema.fields != null) {
      for (final field in widget.schema.fields!) {
        controls[field.name] = _createFormControl(field);
        _visibleFields[field.name] = _shouldShowField(field);
      }
    }
    
    // Create form group
    _form = FormGroup(controls);
    
    // Initialize form with initial values if provided
    if (widget.initialValues != null) {
      _form.patchValue(widget.initialValues!);
    }
    
    // Setup value changes listener
    _form.valueChanges.listen((values) {
      // Update form values provider for dependency evaluation
      ref.read(formValuesProvider.call(widget.schema.id).notifier).state = 
          Map<String, dynamic>.from(values);
      
      // Update validation state
      ref.read(formValidationProvider.call(widget.schema.id).notifier).state = 
          _form.valid;
      
      // Update field visibility based on dependencies
      _updateFieldVisibility();
      
      // Validate on change if enabled
      if (widget.validateOnChange) {
        _form.markAllAsTouched();
      }
    });
  }

  AbstractControl<dynamic> _createFormControl(FormFieldConfig field) {
    // Create validators based on field configuration
    final validators = <Validator>[];
    
    // Add required validator if field is required
    if (field.required == true) {
      validators.add(Validators.required);
    }
    
    // Add other validators based on field validations
    if (field.validations != null) {
      for (final validation in field.validations!) {
        switch (validation.type) {
          case ValidationType.email:
            validators.add(Validators.email);
            break;
          case ValidationType.minLength:
            if (validation.value is int) {
              validators.add(Validators.minLength(validation.value as int));
            }
            break;
          case ValidationType.maxLength:
            if (validation.value is int) {
              validators.add(Validators.maxLength(validation.value as int));
            }
            break;
          case ValidationType.minValue:
            if (validation.value is num) {
              validators.add(Validators.min(validation.value as num));
            }
            break;
          case ValidationType.maxValue:
            if (validation.value is num) {
              validators.add(Validators.max(validation.value as num));
            }
            break;
          case ValidationType.pattern:
            if (validation.value is String) {
              validators.add(Validators.pattern(validation.value as String));
            }
            break;
          case ValidationType.custom:
            // Custom validators would be implemented separately
            break;
          default:
            break;
        }
      }
    }
    
    // Create appropriate control based on field type
    switch (field.type) {
      case FormFieldType.checkbox:
        return FormControl<bool>(
          value: field.defaultValue as bool? ?? false,
          validators: validators,
          disabled: field.disabled == true || field.readOnly == true,
        );
      case FormFieldType.multiSelect:
        return FormArray<String>(
          validators: validators,
          disabled: field.disabled == true || field.readOnly == true,
        );
      case FormFieldType.number:
      case FormFieldType.decimal:
        return FormControl<double>(
          value: field.defaultValue as double?,
          validators: validators,
          disabled: field.disabled == true || field.readOnly == true,
        );
      case FormFieldType.date:
      case FormFieldType.dateTime:
      case FormFieldType.time:
        return FormControl<DateTime>(
          value: field.defaultValue as DateTime?,
          validators: validators,
          disabled: field.disabled == true || field.readOnly == true,
        );
      case FormFieldType.entitySelector:
      case FormFieldType.memberSelector:
        if (field.allowMultipleEntities == true || field.allowMultipleMembers == true) {
          return FormArray<String>(
            validators: validators,
            disabled: field.disabled == true || field.readOnly == true,
          );
        }
        return FormControl<String>(
          value: field.defaultValue as String?,
          validators: validators,
          disabled: field.disabled == true || field.readOnly == true,
        );
      default:
        return FormControl<String>(
          value: field.defaultValue as String?,
          validators: validators,
          disabled: field.disabled == true || field.readOnly == true,
        );
    }
  }

  bool _shouldShowField(FormFieldConfig field) {
    // If no dependencies, always show the field
    if (field.dependencies == null || field.dependencies!.isEmpty) {
      return true;
    }
    
    // Get current form values
    final formValues = ref.read(formValuesProvider.call(widget.schema.id));
    
    // Check each dependency
    for (final dependency in field.dependencies!) {
      final dependentFieldValue = formValues[dependency.field];
      bool conditionsMet = true;
      
      // Check all conditions for this dependency
      for (final condition in dependency.conditions) {
        final fieldValue = dependentFieldValue;
        final conditionValue = condition.value;
        
        // Skip this condition if dependent field doesn't have a value yet
        if (fieldValue == null) {
          conditionsMet = false;
          break;
        }
        
        // Evaluate condition based on operator
        switch (condition.operator) {
          case 'equals':
            conditionsMet = fieldValue == conditionValue;
            break;
          case 'notEquals':
            conditionsMet = fieldValue != conditionValue;
            break;
          case 'contains':
            if (fieldValue is String && conditionValue is String) {
              conditionsMet = fieldValue.contains(conditionValue);
            } else if (fieldValue is List) {
              conditionsMet = fieldValue.contains(conditionValue);
            } else {
              conditionsMet = false;
            }
            break;
          case 'greaterThan':
            if (fieldValue is num && conditionValue is num) {
              conditionsMet = fieldValue > conditionValue;
            } else {
              conditionsMet = false;
            }
            break;
          case 'lessThan':
            if (fieldValue is num && conditionValue is num) {
              conditionsMet = fieldValue < conditionValue;
            } else {
              conditionsMet = false;
            }
            break;
          case 'isNotEmpty':
            if (fieldValue is String) {
              conditionsMet = fieldValue.isNotEmpty;
            } else if (fieldValue is List) {
              conditionsMet = fieldValue.isNotEmpty;
            } else {
              conditionsMet = fieldValue != null;
            }
            break;
          case 'isEmpty':
            if (fieldValue is String) {
              conditionsMet = fieldValue.isEmpty;
            } else if (fieldValue is List) {
              conditionsMet = fieldValue.isEmpty;
            } else {
              conditionsMet = fieldValue == null;
            }
            break;
          default:
            conditionsMet = false;
            break;
        }
        
        // If any condition fails, break the loop
        if (!conditionsMet) {
          break;
        }
      }
      
      // Determine if field should be shown based on conditions and showWhenMatched
      final showWhenMatched = dependency.showWhenMatched ?? true;
      if (conditionsMet == showWhenMatched) {
        return true;
      }
    }
    
    // If no dependencies matched, hide the field
    return false;
  }

  void _updateFieldVisibility() {
    // Get all fields from sections and flat fields
    final allFields = <FormFieldConfig>[];
    
    if (widget.schema.sections != null) {
      for (final section in widget.schema.sections!) {
        if (section.fields != null) {
          allFields.addAll(section.fields!);
        }
      }
    }
    
    if (widget.schema.fields != null) {
      allFields.addAll(widget.schema.fields!);
    }
    
    // Check visibility for each field
    bool hasVisibilityChanges = false;
    for (final field in allFields) {
      final shouldShow = _shouldShowField(field);
      if (_visibleFields[field.name] != shouldShow) {
        _visibleFields[field.name] = shouldShow;
        hasVisibilityChanges = true;
      }
    }
    
    // Rebuild UI if visibility changed
    if (hasVisibilityChanges) {
      setState(() {});
    }
  }

  void _setupAutoSave() {
    _autoSaveTimer = Timer.periodic(
      Duration(seconds: widget.autoSaveIntervalSeconds),
      (_) => _performAutoSave(),
    );
    
    // Store timer reference in provider for potential external cancellation
    ref.read(formAutoSaveTimerProvider.call(widget.schema.id).notifier).state = _autoSaveTimer;
  }

  void _cancelAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
    ref.read(formAutoSaveTimerProvider.call(widget.schema.id).notifier).state = null;
  }

  Future<void> _performAutoSave() async {
    // Skip auto-save if form is invalid or already submitting/auto-saving
    if (!_form.valid || _isSubmitting || _isAutoSaving) {
      return;
    }
    
    setState(() {
      _isAutoSaving = true;
    });
    
    try {
      // Get form values
      final values = Map<String, dynamic>.from(_form.value);
      
      // Call auto-save callback
      await widget.onAutoSave?.call(values);
      
      // Log auto-save
      Logger.debug('Form auto-saved: ${widget.schema.id}');
    } catch (e) {
      Logger.error('Error auto-saving form: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isAutoSaving = false;
        });
      }
    }
  }

  Future<void> _submitForm() async {
    // Mark all fields as touched to show validation errors
    _form.markAllAsTouched();
    
    // Skip submission if form is invalid
    if (!_form.valid) {
      setState(() {
        _formError = 'Please fix the errors in the form';
      });
      return;
    }
    
    setState(() {
      _isSubmitting = true;
      _formError = null;
    });
    
    try {
      // Get form values
      final values = Map<String, dynamic>.from(_form.value);
      
      // Call submit callback
      await widget.onSubmit?.call(values);
    } catch (e) {
      Logger.error('Error submitting form: $e');
      setState(() {
        _formError = 'An error occurred while submitting the form';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ReactiveForm(
      formGroup: _form,
      child: Padding(
        padding: widget.padding ?? EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Custom header if provided
            if (widget.customHeader != null) widget.customHeader!,
            
            // Form title and description
            if (widget.schema.title.isNotEmpty) ...[
              Text(
                widget.schema.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 8.h),
            ],
            
            if (widget.schema.description != null && widget.schema.description!.isNotEmpty) ...[
              Text(
                widget.schema.description!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 16.h),
            ],
            
            // Form error message
            if (_formError != null) ...[
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700, size: 18.r),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        _formError!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
            ],
            
            // Form fields
            Expanded(
              child: SingleChildScrollView(
                physics: widget.scrollPhysics,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Render sections if available
                    if (widget.schema.sections != null) ...[
                      ...widget.schema.sections!.map((section) => _buildSection(section)).toList(),
                    ],
                    
                    // Render flat fields if available
                    if (widget.schema.fields != null) ...[
                      ...widget.schema.fields!
                          .where((field) => _visibleFields[field.name] == true)
                          .map((field) => _buildField(field))
                          .toList(),
                    ],
                  ],
                ),
              ),
            ),
            
            // Auto-save indicator
            if (_isAutoSaving) ...[
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16.r,
                    height: 16.r,
                    child: CircularProgressIndicator(strokeWidth: 2.w),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Saving...',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              SizedBox(height: 8.h),
            ],
            
            // Form buttons
            if (widget.showSubmitButton || widget.showCancelButton) ...[
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (widget.showCancelButton) ...[
                    OutlinedButton(
                      onPressed: widget.onCancel,
                      child: Text(widget.cancelButtonText ?? 'Cancel'),
                    ),
                    SizedBox(width: 16.w),
                  ],
                  if (widget.showSubmitButton) ...[
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitForm,
                      child: _isSubmitting
                          ? SizedBox(
                              width: 20.r,
                              height: 20.r,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.w,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(widget.submitButtonText ?? 'Submit'),
                    ),
                  ],
                ],
              ),
            ],
            
            // Custom footer if provided
            if (widget.customFooter != null) widget.customFooter!,
          ],
        ),
      ),
    );
  }

  Widget _buildSection(FormSectionConfig section) {
    // Filter visible fields
    final visibleFields = section.fields
        ?.where((field) => _visibleFields[field.name] == true)
        .toList() ?? [];
    
    // Skip section if it has no visible fields
    if (visibleFields.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Container(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          margin: EdgeInsets.only(bottom: 8.h),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1.w,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                section.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (section.description != null && section.description!.isNotEmpty) ...[
                SizedBox(height: 4.h),
                Text(
                  section.description!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
        
        // Section fields
        ...visibleFields.map((field) => _buildField(field)).toList(),
        
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildField(FormFieldConfig field) {
    // Skip section fields (they're handled separately)
    if (field.type == FormFieldType.section) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: FormFieldRenderer(
        field: field,
        formGroup: _form,
      ),
    );
  }
}

/// Widget that renders a specific form field based on its type
class FormFieldRenderer extends StatelessWidget {
  final FormFieldConfig field;
  final FormGroup formGroup;

  const FormFieldRenderer({
    super.key,
    required this.field,
    required this.formGroup,
  });

  @override
  Widget build(BuildContext context) {
    // Render appropriate field widget based on type
    switch (field.type) {
      case FormFieldType.text:
      case FormFieldType.email:
      case FormFieldType.password:
        return _buildTextInput(context);
      case FormFieldType.number:
      case FormFieldType.decimal:
        return _buildNumberInput(context);
      case FormFieldType.date:
        return _buildDateInput(context);
      case FormFieldType.dateTime:
        return _buildDateTimeInput(context);
      case FormFieldType.time:
        return _buildTimeInput(context);
      case FormFieldType.dropdown:
        return _buildDropdownInput(context);
      case FormFieldType.checkbox:
        return _buildCheckboxInput(context);
      case FormFieldType.radio:
        return _buildRadioInput(context);
      case FormFieldType.toggle:
        return _buildToggleInput(context);
      case FormFieldType.multiSelect:
        return _buildMultiSelectInput(context);
      case FormFieldType.image:
        return _buildImageInput(context);
      case FormFieldType.color:
        return _buildColorInput(context);
      case FormFieldType.duration:
        return _buildDurationInput(context);
      case FormFieldType.timeDelta:
        return _buildTimeDeltaInput(context);
      case FormFieldType.recurrence:
        return _buildRecurrenceInput(context);
      case FormFieldType.entitySelector:
        return _buildEntitySelectorInput(context);
      case FormFieldType.memberSelector:
        return _buildMemberSelectorInput(context);
      case FormFieldType.tagSelector:
        return _buildTagSelectorInput(context);
      case FormFieldType.routineSelector:
        return _buildRoutineSelectorInput(context);
      case FormFieldType.reminderSelector:
        return _buildReminderSelectorInput(context);
      case FormFieldType.actionSelector:
        return _buildActionSelectorInput(context);
      case FormFieldType.address:
        return _buildAddressInput(context);
      case FormFieldType.timezone:
        return _buildTimezoneInput(context);
      case FormFieldType.richText:
        return _buildRichTextInput(context);
      case FormFieldType.phone:
        return _buildPhoneInput(context);
      default:
        return _buildUnsupportedField(context);
    }
  }

  // Text input (text, email, password)
  Widget _buildTextInput(BuildContext context) {
    return ReactiveTextField<String>(
      formControlName: field.name,
      decoration: InputDecoration(
        labelText: field.label,
        hintText: field.placeholder,
        helperText: field.helperText,
        prefixIcon: _getPrefixIcon(),
        suffixIcon: field.type == FormFieldType.password
            ? ReactivePasswordVisibilityToggleIcon(formControlName: field.name)
            : null,
      ),
      obscureText: field.type == FormFieldType.password,
      keyboardType: _getKeyboardType(),
      maxLines: field.multiline == true ? field.maxLines ?? 3 : 1,
      minLines: field.multiline == true ? field.minLines ?? 1 : null,
      maxLength: field.maxLength,
      textCapitalization: TextCapitalization.sentences,
      validationMessages: _getValidationMessages(),
    );
  }

  // Number input
  Widget _buildNumberInput(BuildContext context) {
    return ReactiveTextField<double>(
      formControlName: field.name,
      decoration: InputDecoration(
        labelText: field.label,
        hintText: field.placeholder,
        helperText: field.helperText,
        prefixIcon: _getPrefixIcon(),
      ),
      keyboardType: field.type == FormFieldType.decimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      validationMessages: _getValidationMessages(),
    );
  }

  // Date input
  Widget _buildDateInput(BuildContext context) {
    return ReactiveDatePicker<DateTime>(
      formControlName: field.name,
      firstDate: field.minDate ?? DateTime(1900),
      lastDate: field.maxDate ?? DateTime(2100),
      builder: (context, picker, child) {
        return ReactiveTextField<DateTime>(
          formControlName: field.name,
          readOnly: true,
          decoration: InputDecoration(
            labelText: field.label,
            hintText: field.placeholder,
            helperText: field.helperText,
            prefixIcon: const Icon(Icons.calendar_today),
            suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_month),
              onPressed: picker.showPicker,
            ),
          ),
          validationMessages: _getValidationMessages(),
          valueAccessor: DateTimeValueAccessor(
            dateTimeFormat: DateFormat(field.dateFormat ?? 'MMM d, yyyy'),
          ),
        );
      },
    );
  }

  // Date & Time input
  Widget _buildDateTimeInput(BuildContext context) {
    return ReactiveTextField<DateTime>(
      formControlName: field.name,
      readOnly: true,
      decoration: InputDecoration(
        labelText: field.label,
        hintText: field.placeholder,
        helperText: field.helperText,
        prefixIcon: const Icon(Icons.event),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_month),
          onPressed: () => _showDateTimePicker(context),
        ),
      ),
      valueAccessor: DateTimeValueAccessor(
        dateTimeFormat: DateFormat(
          '${field.dateFormat ?? 'MMM d, yyyy'} ${field.timeFormat ?? 'h:mm a'}',
        ),
      ),
      validationMessages: _getValidationMessages(),
    );
  }

  // Time input
  Widget _buildTimeInput(BuildContext context) {
    return ReactiveTextField<DateTime>(
      formControlName: field.name,
      readOnly: true,
      decoration: InputDecoration(
        labelText: field.label,
        hintText: field.placeholder,
        helperText: field.helperText,
        prefixIcon: const Icon(Icons.access_time),
        suffixIcon: IconButton(
          icon: const Icon(Icons.schedule),
          onPressed: () => _showTimePicker(context),
        ),
      ),
      valueAccessor: DateTimeValueAccessor(
        dateTimeFormat: DateFormat(field.timeFormat ?? 'h:mm a'),
      ),
      validationMessages: _getValidationMessages(),
    );
  }

  // Dropdown input
  Widget _buildDropdownInput(BuildContext context) {
    if (field.options == null || field.options!.isEmpty) {
      return Text('No options provided for ${field.label}');
    }

    return ReactiveDropdownField<String>(
      formControlName: field.name,
      decoration: InputDecoration(
        labelText: field.label,
        helperText: field.helperText,
        prefixIcon: _getPrefixIcon(),
      ),
      items: field.options!.map((option) {
        return DropdownMenuItem<String>(
          value: option.value,
          child: Text(option.label),
        );
      }).toList(),
      validationMessages: _getValidationMessages(),
    );
  }

  // Checkbox input
  Widget _buildCheckboxInput(BuildContext context) {
    return Row(
      children: [
        ReactiveCheckbox(
          formControlName: field.name,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(field.label),
              if (field.helperText != null)
                Text(
                  field.helperText!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
      ],
    );
  }

  // Radio input
  Widget _buildRadioInput(BuildContext context) {
    if (field.options == null || field.options!.isEmpty) {
      return Text('No options provided for ${field.label}');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (field.helperText != null) ...[
          SizedBox(height: 4.h),
          Text(
            field.helperText!,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        SizedBox(height: 8.h),
        ReactiveRadioListTile.builder<String>(
          formControlName: field.name,
          itemCount: field.options!.length,
          itemBuilder: (context, index) {
            final option = field.options![index];
            return RadioListTile<String>(
              title: Text(option.label),
              subtitle: option.description != null ? Text(option.description!) : null,
              value: option.value,
              groupValue: formGroup.control(field.name).value as String?,
              onChanged: (value) {
                formGroup.control(field.name).value = value;
              },
            );
          },
        ),
        ReactiveFormConsumer(
          builder: (context, form, child) {
            final hasError = form.control(field.name).invalid && form.control(field.name).touched;
            if (!hasError) return const SizedBox.shrink();
            
            return Padding(
              padding: EdgeInsets.only(left: 16.w, top: 4.h),
              child: Text(
                _getErrorMessage(form.control(field.name).errors) ?? 'Invalid selection',
                style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12.sp),
              ),
            );
          },
        ),
      ],
    );
  }

  // Toggle input
  Widget _buildToggleInput(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(field.label),
            if (field.helperText != null)
              Text(
                field.helperText!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        ReactiveSwitch(
          formControlName: field.name,
        ),
      ],
    );
  }

  // Multi-select input
  Widget _buildMultiSelectInput(BuildContext context) {
    if (field.options == null || field.options!.isEmpty) {
      return Text('No options provided for ${field.label}');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (field.helperText != null) ...[
          SizedBox(height: 4.h),
          Text(
            field.helperText!,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        SizedBox(height: 8.h),
        ReactiveFormArray<String>(
          formArrayName: field.name,
          builder: (context, formArray, child) {
            return Column(
              children: field.options!.map((option) {
                final isSelected = (formArray.value as List<dynamic>?)?.contains(option.value) ?? false;
                
                return CheckboxListTile(
                  title: Text(option.label),
                  subtitle: option.description != null ? Text(option.description!) : null,
                  value: isSelected,
                  onChanged: (value) {
                    if (value == true) {
                      // Add value if not already in array
                      if (!isSelected) {
                        final currentValues = List<String>.from(formArray.value ?? []);
                        currentValues.add(option.value);
                        formArray.value = currentValues;
                      }
                    } else {
                      // Remove value if in array
                      if (isSelected) {
                        final currentValues = List<String>.from(formArray.value ?? []);
                        currentValues.remove(option.value);
                        formArray.value = currentValues;
                      }
                    }
                  },
                );
              }).toList(),
            );
          },
        ),
        ReactiveFormConsumer(
          builder: (context, form, child) {
            final hasError = form.control(field.name).invalid && form.control(field.name).touched;
            if (!hasError) return const SizedBox.shrink();
            
            return Padding(
              padding: EdgeInsets.only(left: 16.w, top: 4.h),
              child: Text(
                _getErrorMessage(form.control(field.name).errors) ?? 'Invalid selection',
                style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12.sp),
              ),
            );
          },
        ),
      ],
    );
  }

  // Image input - placeholder implementation
  Widget _buildImageInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (field.helperText != null) ...[
          SizedBox(height: 4.h),
          Text(
            field.helperText!,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        SizedBox(height: 8.h),
        Container(
          height: 150.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image, size: 48.r, color: Colors.grey.shade600),
              SizedBox(height: 8.h),
              Text(
                'Image Picker',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              SizedBox(height: 16.h),
              ElevatedButton.icon(
                onPressed: () {
                  // Image picker implementation would go here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Image picker not implemented yet')),
                  );
                },
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Choose Image'),
              ),
            ],
          ),
        ),
        ReactiveFormConsumer(
          builder: (context, form, child) {
            final hasError = form.control(field.name).invalid && form.control(field.name).touched;
            if (!hasError) return const SizedBox.shrink();
            
            return Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Text(
                _getErrorMessage(form.control(field.name).errors) ?? 'Image is required',
                style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12.sp),
              ),
            );
          },
        ),
      ],
    );
  }

  // Color picker - placeholder implementation
  Widget _buildColorInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (field.helperText != null) ...[
          SizedBox(height: 4.h),
          Text(
            field.helperText!,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        SizedBox(height: 8.h),
        ElevatedButton(
          onPressed: () {
            // Color picker implementation would go here
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Color picker not implemented yet')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Select Color'),
        ),
      ],
    );
  }

  // Duration input - placeholder implementation
  Widget _buildDurationInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (field.helperText != null) ...[
          SizedBox(height: 4.h),
          Text(
            field.helperText!,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: ReactiveTextField<int>(
                formControlName: field.name,
                decoration: const InputDecoration(
                  labelText: 'Hours',
                  prefixIcon: Icon(Icons.access_time),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: ReactiveTextField<int>(
                formControlName: '${field.name}_minutes',
                decoration: const InputDecoration(
                  labelText: 'Minutes',
                  prefixIcon: Icon(Icons.timer),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Time delta input - placeholder implementation
  Widget _buildTimeDeltaInput(BuildContext context) {
    return _buildUnsupportedField(context);
  }

  // Recurrence input - placeholder implementation
  Widget _buildRecurrenceInput(BuildContext context) {
    return _buildUnsupportedField(context);
  }

  // Entity selector - placeholder implementation
  Widget _buildEntitySelectorInput(BuildContext context) {
    return _buildUnsupportedField(context);
  }

  // Member selector - placeholder implementation
  Widget _buildMemberSelectorInput(BuildContext context) {
    return _buildUnsupportedField(context);
  }

  // Tag selector - placeholder implementation
  Widget _buildTagSelectorInput(BuildContext context) {
    return _buildUnsupportedField(context);
  }

  // Routine selector - placeholder implementation
  Widget _buildRoutineSelectorInput(BuildContext context) {
    return _buildUnsupportedField(context);
  }

  // Reminder selector - placeholder implementation
  Widget _buildReminderSelectorInput(BuildContext context) {
    return _buildUnsupportedField(context);
  }

  // Action selector - placeholder implementation
  Widget _buildActionSelectorInput(BuildContext context) {
    return _buildUnsupportedField(context);
  }

  // Address input - placeholder implementation
  Widget _buildAddressInput(BuildContext context) {
    return _buildUnsupportedField(context);
  }

  // Timezone input - placeholder implementation
  Widget _buildTimezoneInput(BuildContext context) {
    return _buildUnsupportedField(context);
  }

  // Rich text input - placeholder implementation
  Widget _buildRichTextInput(BuildContext context) {
    return _buildUnsupportedField(context);
  }

  // Phone input - placeholder implementation
  Widget _buildPhoneInput(BuildContext context) {
    return ReactiveTextField<String>(
      formControlName: field.name,
      decoration: InputDecoration(
        labelText: field.label,
        hintText: field.placeholder,
        helperText: field.helperText,
        prefixIcon: const Icon(Icons.phone),
      ),
      keyboardType: TextInputType.phone,
      validationMessages: _getValidationMessages(),
    );
  }

  // Unsupported field type
  Widget _buildUnsupportedField(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.label,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 4.h),
          Text(
            'Field type ${field.type} is not implemented yet',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  // Helper methods
  Icon? _getPrefixIcon() {
    switch (field.type) {
      case FormFieldType.email:
        return const Icon(Icons.email);
      case FormFieldType.password:
        return const Icon(Icons.lock);
      case FormFieldType.phone:
        return const Icon(Icons.phone);
      case FormFieldType.number:
      case FormFieldType.decimal:
        return const Icon(Icons.numbers);
      case FormFieldType.date:
        return const Icon(Icons.calendar_today);
      case FormFieldType.dateTime:
        return const Icon(Icons.event);
      case FormFieldType.time:
        return const Icon(Icons.access_time);
      default:
        return null;
    }
  }

  TextInputType _getKeyboardType() {
    switch (field.type) {
      case FormFieldType.email:
        return TextInputType.emailAddress;
      case FormFieldType.password:
        return TextInputType.visiblePassword;
      case FormFieldType.phone:
        return TextInputType.phone;
      case FormFieldType.number:
        return TextInputType.number;
      case FormFieldType.decimal:
        return const TextInputType.numberWithOptions(decimal: true);
      default:
        return TextInputType.text;
    }
  }

  Map<String, String Function(Object)> _getValidationMessages() {
    final messages = <String, String Function(Object)>{};
    
    // Basic validation messages
    messages['required'] = (_) => 'This field is required';
    messages['email'] = (_) => 'Please enter a valid email address';
    messages['min'] = (error) => 'Value must be at least ${(error as Map)['min']}';
    messages['max'] = (error) => 'Value must be at most ${(error as Map)['max']}';
    messages['minLength'] = (error) => 'Must be at least ${(error as Map)['requiredLength']} characters';
    messages['maxLength'] = (error) => 'Cannot exceed ${(error as Map)['requiredLength']} characters';
    messages['pattern'] = (_) => 'Invalid format';
    
    // Add custom validation messages from field configuration
    if (field.validations != null) {
      for (final validation in field.validations!) {
        if (validation.message != null) {
          switch (validation.type) {
            case ValidationType.required:
              messages['required'] = (_) => validation.message!;
              break;
            case ValidationType.email:
              messages['email'] = (_) => validation.message!;
              break;
            case ValidationType.minLength:
              messages['minLength'] = (_) => validation.message!;
              break;
            case ValidationType.maxLength:
              messages['maxLength'] = (_) => validation.message!;
              break;
            case ValidationType.minValue:
              messages['min'] = (_) => validation.message!;
              break;
            case ValidationType.maxValue:
              messages['max'] = (_) => validation.message!;
              break;
            case ValidationType.pattern:
              messages['pattern'] = (_) => validation.message!;
              break;
            default:
              break;
          }
        }
      }
    }
    
    return messages;
  }

  String? _getErrorMessage(Map<String, dynamic>? errors) {
    if (errors == null || errors.isEmpty) return null;
    
    // Check for specific error types
    if (errors.containsKey('required')) {
      return 'This field is required';
    } else if (errors.containsKey('email')) {
      return 'Please enter a valid email address';
    } else if (errors.containsKey('min')) {
      return 'Value must be at least ${errors['min']['min']}';
    } else if (errors.containsKey('max')) {
      return 'Value must be at most ${errors['max']['max']}';
    } else if (errors.containsKey('minLength')) {
      return 'Must be at least ${errors['minLength']['requiredLength']} characters';
    } else if (errors.containsKey('maxLength')) {
      return 'Cannot exceed ${errors['maxLength']['requiredLength']} characters';
    } else if (errors.containsKey('pattern')) {
      return 'Invalid format';
    }
    
    // Default error message
    return 'Invalid value';
  }

  // Date/time picker helpers
  Future<void> _showDateTimePicker(BuildContext context) async {
    // Get current value or default to now
    final currentValue = formGroup.control(field.name).value as DateTime? ?? DateTime.now();
    
    // Show date picker
    final date = await showDatePicker(
      context: context,
      initialDate: currentValue,
      firstDate: field.minDate ?? DateTime(1900),
      lastDate: field.maxDate ?? DateTime(2100),
    );
    
    if (date != null) {
      // Show time picker
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(currentValue),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              alwaysUse24HourFormat: field.use24HourFormat ?? false,
            ),
            child: child!,
          );
        },
      );
      
      if (time != null) {
        // Combine date and time
        final dateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        
        // Update form value
        formGroup.control(field.name).value = dateTime;
      }
    }
  }

  Future<void> _showTimePicker(BuildContext context) async {
    // Get current value or default to now
    final currentValue = formGroup.control(field.name).value as DateTime? ?? DateTime.now();
    
    // Show time picker
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentValue),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: field.use24HourFormat ?? false,
          ),
          child: child!,
        );
      },
    );
    
    if (time != null) {
      // Create DateTime with today's date and selected time
      final now = DateTime.now();
      final dateTime = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );
      
      // Update form value
      formGroup.control(field.name).value = dateTime;
    }
  }
}

// Extension to add date/time formatting to reactive forms
class DateTimeValueAccessor extends ControlValueAccessor<DateTime, String> {
  final DateFormat dateTimeFormat;

  DateTimeValueAccessor({
    required this.dateTimeFormat,
  });

  @override
  String modelToViewValue(DateTime? modelValue) {
    return modelValue != null ? dateTimeFormat.format(modelValue) : '';
  }

  @override
  DateTime? viewToModelValue(String? viewValue) {
    if (viewValue == null || viewValue.isEmpty) {
      return null;
    }
    
    try {
      return dateTimeFormat.parse(viewValue);
    } catch (e) {
      return null;
    }
  }
}

// Helper to create a form schema from a list of fields
class FormSchemaBuilder {
  static FormSchema buildSchema({
    required String id,
    required String title,
    String? description,
    List<FormFieldConfig>? fields,
    List<FormSectionConfig>? sections,
    bool? showSubmitButton,
    String? submitButtonText,
    bool? showCancelButton,
    String? cancelButtonText,
    bool? validateOnChange,
    bool? autoSave,
    int? autoSaveInterval,
    FieldStyle? style,
    Map<String, dynamic>? metadata,
  }) {
    return FormSchema(
      id: id,
      title: title,
      description: description,
      fields: fields,
      sections: sections,
      showSubmitButton: showSubmitButton,
      submitButtonText: submitButtonText,
      showCancelButton: showCancelButton,
      cancelButtonText: cancelButtonText,
      validateOnChange: validateOnChange,
      autoSave: autoSave,
      autoSaveInterval: autoSaveInterval,
      style: style,
      metadata: metadata,
    );
  }
}
