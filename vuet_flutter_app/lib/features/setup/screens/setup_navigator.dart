// lib/features/setup/screens/setup_navigator.dart
// Setup navigator that handles the "Add family members" flow

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vuet_flutter/core/utils/logger.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:vuet_flutter/features/auth/providers/auth_provider.dart';

class SetupNavigator extends ConsumerStatefulWidget {
  const SetupNavigator({super.key});

  @override
  ConsumerState<SetupNavigator> createState() => _SetupNavigatorState();
}

class _SetupNavigatorState extends ConsumerState<SetupNavigator> {
  // Family image
  File? _familyImage;
  
  // Family members list
  final List<FamilyMember> _familyMembers = [];
  
  // Registration data passed from previous screen
  Map<String, dynamic>? _registrationData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get registration data from route
    final data = GoRouterState.of(context).extra as Map<String, dynamic>?;
    if (data != null) {
      _registrationData = data;
      
      // Add current user as first family member
      if (_familyMembers.isEmpty) {
        _familyMembers.add(
          FamilyMember(
            name: data['fullName'] ?? 'You',
            color: Color(int.parse(data['memberColor'] ?? '0xFFE91E63')),
            isCurrentUser: true,
          ),
        );
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _familyImage = File(image.path);
        });
      }
    } catch (e, st) {
      Logger.error('Error picking image', e, st);
      EasyLoading.showError('Error selecting image');
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddMemberDialog() {
    final nameController = TextEditingController();
    Color selectedColor = const Color(0xFF2196F3); // Default blue
    
    // Available colors for member selection
    final List<Color> availableColors = [
      const Color(0xFFE91E63), // Pink/Magenta
      const Color(0xFF2196F3), // Blue
      const Color(0xFF4CAF50), // Green
      const Color(0xFFFF9800), // Orange
      const Color(0xFF9C27B0), // Purple
      const Color(0xFF795548), // Brown
      const Color(0xFF607D8B), // Blue Grey
    ];
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Family Member'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    const Text('Select Color:'),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: availableColors.map((color) {
                        final isSelected = selectedColor == color;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedColor = color;
                            });
                          },
                          child: Container(
                            width: 36.w,
                            height: 36.w,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(
                                      color: Colors.black,
                                      width: 2.w,
                                    )
                                  : null,
                            ),
                            child: isSelected
                                ? Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20.sp,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isNotEmpty) {
                      setState(() {
                        _familyMembers.add(
                          FamilyMember(
                            name: nameController.text.trim(),
                            color: selectedColor,
                          ),
                        );
                      });
                      Navigator.of(context).pop();
                    } else {
                      EasyLoading.showToast('Please enter a name');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A2E5D), // Dark purple
                  ),
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _removeFamilyMember(int index) {
    // Don't allow removing current user
    if (_familyMembers[index].isCurrentUser) return;
    
    setState(() {
      _familyMembers.removeAt(index);
    });
  }

  Future<void> _completeSetup() async {
    try {
      EasyLoading.show(status: 'Setting up your account...');
      
      // Mark user setup as complete
      await ref.read(authStateProvider.notifier).completeUserSetup();
      
      // In a real app, you would:
      // 1. Upload family image to storage
      // 2. Create family record in database
      // 3. Add family members to database
      
      EasyLoading.dismiss();
      
      // Navigate to main app
      context.go('/');
    } catch (e, st) {
      Logger.error('Setup completion error', e, st);
      EasyLoading.showError('Setup failed: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A4A4A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Add family members'),
        centerTitle: true,
        automaticallyImplyLeading: false, // No back button in setup flow
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 24.h),
                
                // Subtitle text
                Text(
                  'Start by adding a thumbnail to your group',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 24.h),
                
                // Family image picker
                Center(
                  child: GestureDetector(
                    onTap: _showImagePickerOptions,
                    child: Container(
                      width: 120.w,
                      height: 120.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: _familyImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: Image.file(
                                _familyImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Center(
                              child: Icon(
                                Icons.camera_alt,
                                size: 50.sp,
                                color: const Color(0xFFD2691E).withOpacity(0.7),
                              ),
                            ),
                    ),
                  ),
                ),
                
                SizedBox(height: 32.h),
                
                // Family members list
                if (_familyMembers.isNotEmpty) ...[
                  Text(
                    'Family Members:',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _familyMembers.length,
                    itemBuilder: (context, index) {
                      final member = _familyMembers[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 8.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: member.color,
                            child: Text(
                              member.name.isNotEmpty
                                  ? member.name[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                              ),
                            ),
                          ),
                          title: Text(
                            member.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16.sp,
                            ),
                          ),
                          subtitle: member.isCurrentUser
                              ? Text(
                                  'You',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[600],
                                  ),
                                )
                              : null,
                          trailing: member.isCurrentUser
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  color: Colors.red[400],
                                  onPressed: () => _removeFamilyMember(index),
                                ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16.h),
                ],
                
                // Add member button
                ElevatedButton(
                  onPressed: _showAddMemberDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A2E5D), // Dark purple
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Add member',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                SizedBox(height: 32.h),
                
                // Next button
                ElevatedButton(
                  onPressed: _completeSetup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A2E5D), // Dark purple
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Family member model
class FamilyMember {
  final String name;
  final Color color;
  final bool isCurrentUser;
  
  FamilyMember({
    required this.name,
    required this.color,
    this.isCurrentUser = false,
  });
}
