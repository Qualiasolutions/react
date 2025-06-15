// lib/features/entities/screens/entity_create_screen.dart
// Entity creation screen that works directly with Supabase

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:vuet_flutter/core/theme/app_theme.dart';
import 'package:vuet_flutter/core/utils/logger.dart';
import 'package:vuet_flutter/data/models/simple_entity_model.dart';

class EntityCreateScreen extends ConsumerStatefulWidget {
  final int? categoryId;
  final String? categoryName;

  const EntityCreateScreen({
    super.key,
    this.categoryId,
    this.categoryName,
  });

  @override
  ConsumerState<EntityCreateScreen> createState() => _EntityCreateScreenState();
}

class _EntityCreateScreenState extends ConsumerState<EntityCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();

  int? _selectedCategoryId;
  EntityType _selectedEntityType = EntityType.other;
  bool _isLoading = false;

  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.categoryId;
    _loadCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final response = await Supabase.instance.client
          .from('categories')
          .select('id, name, readable_name')
          .eq('is_enabled', true)
          .order('id');

      setState(() {
        _categories = List<Map<String, dynamic>>.from(response);
      });
    } catch (e, st) {
      Logger.error('Failed to load categories', e, st);
    }
  }

  Future<void> _createEntity() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final entityData = {
        'id': const Uuid().v4(),
        'owner_id': Supabase.instance.client.auth.currentUser?.id,
        'category_id': _selectedCategoryId,
        'type': _selectedEntityType.toDbString(),
        'name': _nameController.text.trim(),
        'notes': _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        'hidden': false,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await Supabase.instance.client.from('entities').insert(entityData);

      EasyLoading.showSuccess('Entity created successfully!');
      Navigator.of(context).pop(true);
    } catch (e, st) {
      Logger.error('Failed to create entity', e, st);
      EasyLoading.showError('Failed to create entity: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<EntityType> _getEntityTypesForCategory(int? categoryId) {
    if (categoryId == null) return EntityType.values;

    // Map categories to appropriate entity types
    switch (categoryId) {
      case 1: // Family
        return [EntityType.person, EntityType.pet];
      case 2: // Pets
        return [EntityType.pet];
      case 3: // Social & Interests
        return [EntityType.event, EntityType.club, EntityType.hobby];
      case 4: // Education
        return [EntityType.school, EntityType.course, EntityType.assignment];
      case 5: // Career
        return [
          EntityType.job,
          EntityType.project,
          EntityType.professionalEntity
        ];
      case 6: // Travel
        return [EntityType.trip, EntityType.flight, EntityType.accommodation];
      case 7: // Health & Beauty
        return [
          EntityType.medication,
          EntityType.appointment,
          EntityType.exercise
        ];
      case 8: // Home
        return [EntityType.home, EntityType.room, EntityType.appliance];
      case 9: // Garden
        return [EntityType.plant, EntityType.gardenArea];
      case 10: // Food
        return [EntityType.recipe, EntityType.mealPlan];
      case 11: // Laundry
        return [EntityType.appliance, EntityType.other];
      case 12: // Finance
        return [EntityType.account, EntityType.subscription];
      case 13: // Transport
        return [EntityType.car, EntityType.bicycle, EntityType.publicTransport];
      default:
        return EntityType.values;
    }
  }

  String _formatEntityType(EntityType type) {
    String label = type.toString().split('.').last;
    return label.split('').map((char) {
      if (char == char.toUpperCase() && label.indexOf(char) > 0) {
        return ' ${char.toLowerCase()}';
      }
      return char == label[0] ? char.toUpperCase() : char.toLowerCase();
    }).join('');
  }

  @override
  Widget build(BuildContext context) {
    final availableEntityTypes =
        _getEntityTypesForCategory(_selectedCategoryId);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.categoryName != null
            ? 'Add ${widget.categoryName} Entity'
            : 'Create Entity'),
        backgroundColor: AppTheme.darkHeaderColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Category Selection
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      DropdownButtonFormField<int>(
                        value: _selectedCategoryId,
                        decoration: const InputDecoration(
                          labelText: 'Select Category',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a category';
                          }
                          return null;
                        },
                        items: _categories.map((category) {
                          return DropdownMenuItem<int>(
                            value: category['id'],
                            child: Text(category['readable_name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategoryId = value;
                            // Reset entity type when category changes
                            final newAvailableTypes =
                                _getEntityTypesForCategory(value);
                            if (!newAvailableTypes
                                .contains(_selectedEntityType)) {
                              _selectedEntityType = newAvailableTypes.first;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Basic Information
              Card(
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

                      // Entity Type
                      DropdownButtonFormField<EntityType>(
                        value: _selectedEntityType,
                        decoration: const InputDecoration(
                          labelText: 'Entity Type',
                          border: OutlineInputBorder(),
                        ),
                        items: availableEntityTypes.map((type) {
                          return DropdownMenuItem<EntityType>(
                            value: type,
                            child: Row(
                              children: [
                                Icon(type.icon, color: type.color, size: 20),
                                SizedBox(width: 8.w),
                                Text(_formatEntityType(type)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedEntityType = value!;
                          });
                        },
                      ),

                      SizedBox(height: 16.h),

                      // Name
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name *',
                          hintText: 'Enter entity name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Name is required';
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
                          hintText: 'Additional information...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              // Create Button
              ElevatedButton(
                onPressed: _isLoading ? null : _createEntity,
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
                        'Create Entity',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),

              SizedBox(height: 16.h),

              // Cancel Button
              OutlinedButton(
                onPressed:
                    _isLoading ? null : () => Navigator.of(context).pop(),
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
            ],
          ),
        ),
      ),
    );
  }
}

// Dialog version for quick entity creation
class CreateEntityDialog extends StatefulWidget {
  final VoidCallback onEntityCreated;
  final int? categoryId;

  const CreateEntityDialog({
    super.key,
    required this.onEntityCreated,
    this.categoryId,
  });

  @override
  State<CreateEntityDialog> createState() => _CreateEntityDialogState();
}

class _CreateEntityDialogState extends State<CreateEntityDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();

  int? _selectedCategoryId;
  EntityType _selectedEntityType = EntityType.other;
  bool _isLoading = false;

  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.categoryId;
    _loadCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final response = await Supabase.instance.client
          .from('categories')
          .select('id, name, readable_name')
          .eq('is_enabled', true)
          .order('id');

      setState(() {
        _categories = List<Map<String, dynamic>>.from(response);
      });
    } catch (e, st) {
      Logger.error('Failed to load categories', e, st);
    }
  }

  Future<void> _createEntity() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final entityData = {
        'id': const Uuid().v4(),
        'owner_id': Supabase.instance.client.auth.currentUser?.id,
        'category_id': _selectedCategoryId,
        'type': _selectedEntityType.toDbString(),
        'name': _nameController.text.trim(),
        'notes': _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        'hidden': false,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await Supabase.instance.client.from('entities').insert(entityData);

      EasyLoading.showSuccess('Entity created successfully!');
      widget.onEntityCreated();
      Navigator.of(context).pop();
    } catch (e, st) {
      Logger.error('Failed to create entity', e, st);
      EasyLoading.showError('Failed to create entity: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<EntityType> _getEntityTypesForCategory(int? categoryId) {
    if (categoryId == null) return [EntityType.other];

    // Map categories to appropriate entity types
    switch (categoryId) {
      case 1: // Family
        return [EntityType.person, EntityType.pet];
      case 2: // Pets
        return [EntityType.pet];
      case 3: // Social & Interests
        return [EntityType.event, EntityType.club, EntityType.hobby];
      case 4: // Education
        return [EntityType.school, EntityType.course, EntityType.assignment];
      case 5: // Career
        return [
          EntityType.job,
          EntityType.project,
          EntityType.professionalEntity
        ];
      case 6: // Travel
        return [EntityType.trip, EntityType.flight, EntityType.accommodation];
      case 7: // Health & Beauty
        return [
          EntityType.medication,
          EntityType.appointment,
          EntityType.exercise
        ];
      case 8: // Home
        return [EntityType.home, EntityType.room, EntityType.appliance];
      case 9: // Garden
        return [EntityType.plant, EntityType.gardenArea];
      case 10: // Food
        return [EntityType.recipe, EntityType.mealPlan];
      case 11: // Laundry
        return [EntityType.appliance, EntityType.other];
      case 12: // Finance
        return [EntityType.account, EntityType.subscription];
      case 13: // Transport
        return [EntityType.car, EntityType.bicycle, EntityType.publicTransport];
      default:
        return [EntityType.other];
    }
  }

  String _formatEntityType(EntityType type) {
    String label = type.toString().split('.').last;
    return label.split('').map((char) {
      if (char == char.toUpperCase() && label.indexOf(char) > 0) {
        return ' ${char.toLowerCase()}';
      }
      return char == label[0] ? char.toUpperCase() : char.toLowerCase();
    }).join('');
  }

  @override
  Widget build(BuildContext context) {
    final availableEntityTypes =
        _getEntityTypesForCategory(_selectedCategoryId);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
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
                  'Create New Entity',
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
                        // Category Selection
                        if (widget.categoryId == null)
                          DropdownButtonFormField<int>(
                            value: _selectedCategoryId,
                            decoration: const InputDecoration(
                              labelText: 'Category *',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a category';
                              }
                              return null;
                            },
                            items: _categories.map((category) {
                              return DropdownMenuItem<int>(
                                value: category['id'],
                                child: Text(category['readable_name']),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategoryId = value;
                                final newAvailableTypes =
                                    _getEntityTypesForCategory(value);
                                if (!newAvailableTypes
                                    .contains(_selectedEntityType)) {
                                  _selectedEntityType = newAvailableTypes.first;
                                }
                              });
                            },
                          ),

                        if (widget.categoryId == null) SizedBox(height: 16.h),

                        // Entity Type
                        DropdownButtonFormField<EntityType>(
                          value: _selectedEntityType,
                          decoration: const InputDecoration(
                            labelText: 'Type',
                            border: OutlineInputBorder(),
                          ),
                          items: availableEntityTypes.map((type) {
                            return DropdownMenuItem<EntityType>(
                              value: type,
                              child: Row(
                                children: [
                                  Icon(type.icon, color: type.color, size: 20),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                      child: Text(_formatEntityType(type))),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedEntityType = value!;
                            });
                          },
                        ),

                        SizedBox(height: 16.h),

                        // Name
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Name is required';
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
                        onPressed: _isLoading ? null : _createEntity,
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
