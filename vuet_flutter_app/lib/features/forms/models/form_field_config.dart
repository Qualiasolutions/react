// lib/features/forms/models/form_field_config.dart
// Dynamic form field configuration model based on React Native TypedForm.tsx

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'form_field_config.freezed.dart';
part 'form_field_config.g.dart';

/// Enum for all supported form field types
/// Maps directly to React Native formFieldTypes
enum FormFieldType {
  text,
  email,
  password,
  phone,
  number,
  decimal,
  date,
  dateTime,
  time,
  dropdown,
  checkbox,
  radio,
  toggle,
  multiSelect,
  image,
  color,
  duration,
  timeDelta,
  recurrence,
  entitySelector,
  memberSelector,
  tagSelector,
  routineSelector,
  reminderSelector,
  actionSelector,
  address,
  timezone,
  richText,
  section,
}

/// Enum for validation types
enum ValidationType {
  required,
  email,
  minLength,
  maxLength,
  minValue,
  maxValue,
  pattern,
  custom,
}

/// Validation rule configuration
@freezed
class ValidationRule with _$ValidationRule {
  const factory ValidationRule({
    required ValidationType type,
    String? message,
    dynamic value, // Can be a value or a function for custom validation
  }) = _ValidationRule;

  factory ValidationRule.fromJson(Map<String, dynamic> json) =>
      _$ValidationRuleFromJson(json);
}

/// Condition for showing/hiding fields
@freezed
class FieldCondition with _$FieldCondition {
  const factory FieldCondition({
    required String field, // Field name to check
    required String operator, // equals, notEquals, contains, greaterThan, etc.
    required dynamic value, // Value to compare against
  }) = _FieldCondition;

  factory FieldCondition.fromJson(Map<String, dynamic> json) =>
      _$FieldConditionFromJson(json);
}

/// Options for dropdown, radio, checkbox fields
@freezed
class FieldOption with _$FieldOption {
  const factory FieldOption({
    required String value,
    required String label,
    String? description,
    bool? disabled,
    IconData? icon,
    Color? color,
  }) = _FieldOption;

  factory FieldOption.fromJson(Map<String, dynamic> json) =>
      _$FieldOptionFromJson(json);
}

/// Field dependency configuration
@freezed
class FieldDependency with _$FieldDependency {
  const factory FieldDependency({
    required String field, // Field that this field depends on
    required List<FieldCondition> conditions, // Conditions to check
    bool? showWhenMatched, // Show when conditions match (true) or don't match (false)
  }) = _FieldDependency;

  factory FieldDependency.fromJson(Map<String, dynamic> json) =>
      _$FieldDependencyFromJson(json);
}

/// Style configuration for form fields
@freezed
class FieldStyle with _$FieldStyle {
  const factory FieldStyle({
    // Basic styling
    double? width,
    double? height,
    EdgeInsets? padding,
    EdgeInsets? margin,
    
    // Text styling
    TextStyle? labelStyle,
    TextStyle? inputStyle,
    TextStyle? helperStyle,
    TextStyle? errorStyle,
    
    // Colors
    Color? backgroundColor,
    Color? borderColor,
    Color? focusColor,
    Color? errorColor,
    
    // Border styling
    double? borderWidth,
    double? borderRadius,
    
    // Icon styling
    double? iconSize,
    Color? iconColor,
  }) = _FieldStyle;

  factory FieldStyle.fromJson(Map<String, dynamic> json) =>
      _$FieldStyleFromJson(json);
}

/// Main form field configuration class
@freezed
class FormFieldConfig with _$FormFieldConfig {
  const factory FormFieldConfig({
    required String name, // Field identifier
    required String label, // Display label
    required FormFieldType type, // Field type
    
    // Field properties
    String? placeholder,
    String? helperText,
    dynamic defaultValue,
    bool? required,
    bool? readOnly,
    bool? disabled,
    
    // Validation
    List<ValidationRule>? validations,
    
    // Conditional display
    List<FieldDependency>? dependencies,
    
    // Options for select fields
    List<FieldOption>? options,
    
    // Styling
    FieldStyle? style,
    
    // Special field properties
    bool? multiline,
    int? maxLines,
    int? minLines,
    String? dateFormat,
    String? timeFormat,
    bool? showSeconds,
    bool? use24HourFormat,
    bool? showCalendarIcon,
    bool? allowFutureDate,
    bool? allowPastDate,
    
    // Min/max values
    DateTime? minDate,
    DateTime? maxDate,
    double? minValue,
    double? maxValue,
    int? minLength,
    int? maxLength,
    
    // Advanced properties
    Map<String, dynamic>? metadata,
    bool? isPremiumFeature,
    
    // Section properties (for section type)
    String? sectionTitle,
    String? sectionDescription,
    bool? collapsible,
    bool? initiallyCollapsed,
    
    // Entity selector properties
    List<String>? entityTypes,
    bool? allowMultipleEntities,
    
    // Member selector properties
    bool? includeFamily,
    bool? includeFriends,
    bool? allowMultipleMembers,
    
    // Image field properties
    bool? allowMultipleImages,
    bool? allowCameraCapture,
    bool? allowGalleryPick,
    double? aspectRatio,
    bool? enableCropping,
    
    // Custom field renderer
    String? customRenderer,
  }) = _FormFieldConfig;

  factory FormFieldConfig.fromJson(Map<String, dynamic> json) =>
      _$FormFieldConfigFromJson(json);
}

/// Form section configuration
@freezed
class FormSectionConfig with _$FormSectionConfig {
  const factory FormSectionConfig({
    required String id,
    required String title,
    String? description,
    List<FormFieldConfig>? fields,
    bool? collapsible,
    bool? initiallyCollapsed,
    FieldStyle? style,
  }) = _FormSectionConfig;

  factory FormSectionConfig.fromJson(Map<String, dynamic> json) =>
      _$FormSectionConfigFromJson(json);
}

/// Overall form schema configuration
@freezed
class FormSchema with _$FormSchema {
  const factory FormSchema({
    required String id,
    required String title,
    String? description,
    
    // Fields can be organized in sections or flat
    List<FormFieldConfig>? fields,
    List<FormSectionConfig>? sections,
    
    // Form-level settings
    bool? showSubmitButton,
    String? submitButtonText,
    bool? showCancelButton,
    String? cancelButtonText,
    
    // Form styling
    FieldStyle? style,
    
    // Form behavior
    bool? validateOnChange,
    bool? validateOnBlur,
    bool? autoSave,
    int? autoSaveInterval, // in seconds
    
    // Form metadata
    Map<String, dynamic>? metadata,
  }) = _FormSchema;

  factory FormSchema.fromJson(Map<String, dynamic> json) =>
      _$FormSchemaFromJson(json);
}

/// Helper class for creating form field configurations
class FormFieldBuilder {
  /// Create a text input field
  static FormFieldConfig textField({
    required String name,
    required String label,
    String? placeholder,
    String? helperText,
    String? defaultValue,
    bool? required,
    bool? multiline,
    int? maxLines,
    int? minLines,
    int? minLength,
    int? maxLength,
    List<ValidationRule>? validations,
    List<FieldDependency>? dependencies,
    FieldStyle? style,
  }) {
    return FormFieldConfig(
      name: name,
      label: label,
      type: FormFieldType.text,
      placeholder: placeholder,
      helperText: helperText,
      defaultValue: defaultValue,
      required: required,
      multiline: multiline,
      maxLines: maxLines,
      minLines: minLines,
      minLength: minLength,
      maxLength: maxLength,
      validations: validations,
      dependencies: dependencies,
      style: style,
    );
  }

  /// Create a dropdown select field
  static FormFieldConfig dropdownField({
    required String name,
    required String label,
    required List<FieldOption> options,
    String? placeholder,
    String? helperText,
    dynamic defaultValue,
    bool? required,
    List<ValidationRule>? validations,
    List<FieldDependency>? dependencies,
    FieldStyle? style,
  }) {
    return FormFieldConfig(
      name: name,
      label: label,
      type: FormFieldType.dropdown,
      placeholder: placeholder,
      helperText: helperText,
      defaultValue: defaultValue,
      required: required,
      options: options,
      validations: validations,
      dependencies: dependencies,
      style: style,
    );
  }

  /// Create a date picker field
  static FormFieldConfig dateField({
    required String name,
    required String label,
    String? placeholder,
    String? helperText,
    DateTime? defaultValue,
    bool? required,
    String? dateFormat,
    bool? allowFutureDate,
    bool? allowPastDate,
    DateTime? minDate,
    DateTime? maxDate,
    List<ValidationRule>? validations,
    List<FieldDependency>? dependencies,
    FieldStyle? style,
  }) {
    return FormFieldConfig(
      name: name,
      label: label,
      type: FormFieldType.date,
      placeholder: placeholder,
      helperText: helperText,
      defaultValue: defaultValue,
      required: required,
      dateFormat: dateFormat,
      allowFutureDate: allowFutureDate,
      allowPastDate: allowPastDate,
      minDate: minDate,
      maxDate: maxDate,
      validations: validations,
      dependencies: dependencies,
      style: style,
    );
  }

  /// Create a member selector field
  static FormFieldConfig memberSelectorField({
    required String name,
    required String label,
    String? helperText,
    List<String>? defaultValue,
    bool? required,
    bool includeFamily = true,
    bool includeFriends = true,
    bool allowMultipleMembers = true,
    List<ValidationRule>? validations,
    List<FieldDependency>? dependencies,
    FieldStyle? style,
  }) {
    return FormFieldConfig(
      name: name,
      label: label,
      type: FormFieldType.memberSelector,
      helperText: helperText,
      defaultValue: defaultValue,
      required: required,
      includeFamily: includeFamily,
      includeFriends: includeFriends,
      allowMultipleMembers: allowMultipleMembers,
      validations: validations,
      dependencies: dependencies,
      style: style,
    );
  }

  /// Create an entity selector field
  static FormFieldConfig entitySelectorField({
    required String name,
    required String label,
    String? helperText,
    List<String>? defaultValue,
    bool? required,
    List<String>? entityTypes,
    bool allowMultipleEntities = false,
    List<ValidationRule>? validations,
    List<FieldDependency>? dependencies,
    FieldStyle? style,
  }) {
    return FormFieldConfig(
      name: name,
      label: label,
      type: FormFieldType.entitySelector,
      helperText: helperText,
      defaultValue: defaultValue,
      required: required,
      entityTypes: entityTypes,
      allowMultipleEntities: allowMultipleEntities,
      validations: validations,
      dependencies: dependencies,
      style: style,
    );
  }

  /// Create a section header
  static FormFieldConfig sectionField({
    required String name,
    required String sectionTitle,
    String? sectionDescription,
    bool collapsible = false,
    bool initiallyCollapsed = false,
    FieldStyle? style,
  }) {
    return FormFieldConfig(
      name: name,
      label: sectionTitle,
      type: FormFieldType.section,
      sectionTitle: sectionTitle,
      sectionDescription: sectionDescription,
      collapsible: collapsible,
      initiallyCollapsed: initiallyCollapsed,
      style: style,
    );
  }
}
