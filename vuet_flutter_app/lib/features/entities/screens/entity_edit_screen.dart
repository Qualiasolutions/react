// lib/features/entities/screens/entity_edit_screen.dart
// Screen for creating and editing entities, matching the React Native design

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:vuet_flutter/core/constants/app_constants.dart';
import 'package:vuet_flutter/core/theme/app_theme.dart';
import 'package:vuet_flutter/core/utils/logger.dart';
import 'package:vuet_flutter/data/models/simple_entity_model.dart';
import 'package:vuet_flutter/features/entities/providers/entities_provider.dart';
import 'package:vuet_flutter/features/auth/providers/auth_provider.dart';

class EntityEditScreen extends ConsumerStatefulWidget {
  final String? entityId; // Null if creating new entity
  final int? categoryId; // Required for new entities, pre-filled for existing

  const EntityEditScreen({
    super.key,
    this.entityId,
    this.categoryId,
  });

  @override
  ConsumerState<EntityEditScreen> createState() => _EntityEditScreenState();
}

class _EntityEditScreenState extends ConsumerState<EntityEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  EntityType? _selectedEntityType;
  File? _imageFile;
  String? _existingImageUrl;
  bool _isImageRemoved = false;

  SimpleEntityModel? _initialEntity;

  @override
  void initState() {
    super.initState();
    if (widget.entityId != null) {
      // Editing existing entity
      _initialEntity = ref.read(entityByIdProvider(widget.entityId!));
      if (_initialEntity != null) {
        _nameController.text = _initialEntity!.name;
        _notesController.text = _initialEntity!.notes ?? '';
        _selectedEntityType = _initialEntity!.type;
        _existingImageUrl = _initialEntity!.imagePath;
      }
    } else {
      // Creating new entity, pre-fill category if provided
      if (widget.categoryId != null) {
        // Attempt to find a default entity type for the category
        // This is a simplified mapping; a more robust solution might be needed
        _selectedEntityType = _mapCategoryIdToEntityType(widget.categoryId!);
      }
    }
  }

  EntityType? _mapCategoryIdToEntityType(int categoryId) {
    switch (categoryId) {
      case Categories.family:
        return EntityType.person;
      case Categories.pets:
        return EntityType.pet;
      case Categories.travel:
        return EntityType.trip;
      case Categories.transport:
        return EntityType.car;
      case Categories.food:
        return EntityType.recipe;
      case Categories.home:
        return EntityType.home;
      case Categories.finance:
        return EntityType.account;
      case Categories.education:
        return EntityType.school;
      case Categories.career:
        return EntityType.job;
      case Categories.socialInterests:
        return EntityType.event;
      case Categories.laundry:
        return EntityType.other;
      case Categories.healthBeauty:
        return EntityType.appointment;
      case Categories.garden:
        return EntityType.plant;
      default:
        return null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _isImageRemoved = false; // If picking new image, it's not removed
      });
    }
  }

  void _removeImage() {
    setState(() {
      _imageFile = null;
      _existingImageUrl = null;
      _isImageRemoved = true;
    });
  }

  Future<void> _saveEntity() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedEntityType == null) {
      EasyLoading.showError('Please select an entity type.');
      return;
    }

    EasyLoading.show(status: 'Saving entity...');

    try {
      Uint8List? imageBytes;
      String? imageFileName;

      if (_imageFile != null) {
        imageBytes = await _imageFile!.readAsBytes();
        imageFileName = _imageFile!.path.split('/').last;
      } else if (_isImageRemoved) {
        // If image was explicitly removed, set imagePath to null
        _existingImageUrl = null;
      }

      final userId = ref.read(userIdProvider);
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      if (widget.entityId == null) {
        // Create new entity
        final newEntity = SimpleEntityModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID, Supabase will assign real one
          ownerId: userId,
          categoryId: _initialEntity?.categoryId ?? widget.categoryId!,
          type: _selectedEntityType!,
          name: _nameController.text.trim(),
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          imagePath: _existingImageUrl, // Will be updated after upload
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await ref.read(entitiesProvider.notifier).createEntity(
              newEntity,
              imageBytes: imageBytes,
              imageFileName: imageFileName,
            );
        EasyLoading.showSuccess('Entity created successfully!');
      } else {
        // Update existing entity
        final updatedEntity = _initialEntity!.copyWith(
          name: _nameController.text.trim(),
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          type: _selectedEntityType!,
          imagePath: _existingImageUrl, // Pass current or null if removed
          updatedAt: DateTime.now(),
        );
        await ref.read(entitiesProvider.notifier).updateEntity(
              updatedEntity,
              imageBytes: imageBytes,
              imageFileName: imageFileName,
            );
        EasyLoading.showSuccess('Entity updated successfully!');
      }
      if (mounted) {
        context.pop(); // Go back to previous screen
      }
    } catch (e, st) {
      Logger.error('Failed to save entity', e, st);
      EasyLoading.showError('Failed to save entity: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.entityId != null;
    final title = isEditing ? 'Edit Entity' : 'Add New Entity';

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
                // Image Picker
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 150.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(UIConstants.radiusM.r),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: _imageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(UIConstants.radiusM.r),
                            child: Image.file(
                              _imageFile!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          )
                        : _existingImageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(UIConstants.radiusM.r),
                                child: CachedNetworkImage(
                                  imageUrl: _existingImageUrl!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Icon(
                                    Icons.broken_image,
                                    size: 50.sp,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    size: 50.sp,
                                    color: Colors.grey[600],
                                  ),
                                  SizedBox(height: UIConstants.paddingS.h),
                                  Text(
                                    'Tap to add image',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                  ),
                ),
                if (_imageFile != null || _existingImageUrl != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _removeImage,
                      icon: const Icon(Icons.delete_forever, color: Colors.red),
                      label: const Text('Remove Image', style: TextStyle(color: Colors.red)),
                    ),
                  ),
                SizedBox(height: UIConstants.paddingL.h),

                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'e.g., My Car, Fluffy, Summer Trip',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name cannot be empty';
                    }
                    return null;
                  },
                ),
                SizedBox(height: UIConstants.paddingM.h),

                // Notes Field
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    hintText: 'Any additional details',
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: UIConstants.paddingM.h),

                // Entity Type Dropdown
                DropdownButtonFormField<EntityType>(
                  value: _selectedEntityType,
                  decoration: const InputDecoration(
                    labelText: 'Entity Type',
                  ),
                  items: EntityType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.toString().split('.').last.replaceAll('_', ' ')),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedEntityType = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select an entity type';
                    }
                    return null;
                  },
                ),
                SizedBox(height: UIConstants.paddingXL.h),

                // Save Button
                ElevatedButton(
                  onPressed: _saveEntity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(UIConstants.radiusM.r),
                    ),
                  ),
                  child: Text(
                    isEditing ? 'Save Changes' : 'Create Entity',
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
                      borderRadius: BorderRadius.circular(UIConstants.radiusM.r),
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
