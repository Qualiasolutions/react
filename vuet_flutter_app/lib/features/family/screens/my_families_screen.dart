// lib/features/family/screens/my_families_screen.dart
// Screen to display user's families, allow creation, and navigation to family details.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vuet_flutter/core/constants/app_constants.dart';
import 'package:vuet_flutter/core/theme/app_theme.dart';
import 'package:vuet_flutter/core/utils/logger.dart';
import 'package:vuet_flutter/data/models/family_model.dart';
import 'package:vuet_flutter/features/family/providers/family_provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class MyFamiliesScreen extends ConsumerStatefulWidget {
  const MyFamiliesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MyFamiliesScreen> createState() => _MyFamiliesScreenState();
}

class _MyFamiliesScreenState extends ConsumerState<MyFamiliesScreen> {
  final TextEditingController _newFamilyNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch user's families when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(familyProvider.notifier).fetchUserFamilies();
    });
  }

  @override
  void dispose() {
    _newFamilyNameController.dispose();
    super.dispose();
  }

  Future<void> _showCreateFamilyDialog() async {
    _newFamilyNameController.clear();
    final newFamilyName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Family'),
        content: TextField(
          controller: _newFamilyNameController,
          decoration: const InputDecoration(
            labelText: 'Family Name',
            hintText: 'e.g., The Smiths, Our Household',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_newFamilyNameController.text.trim().isNotEmpty) {
                Navigator.of(context).pop(_newFamilyNameController.text.trim());
              } else {
                EasyLoading.showError('Family name cannot be empty.');
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (newFamilyName != null && newFamilyName.isNotEmpty) {
      EasyLoading.show(status: 'Creating family...');
      final success = await ref.read(familyProvider.notifier).createFamily(newFamilyName);
      if (success) {
        EasyLoading.showSuccess('Family created successfully!');
        // Optionally navigate to the new family's detail screen
        final newFamily = ref.read(familyProvider).userFamilies.firstWhere((f) => f.name == newFamilyName, orElse: () => ref.read(familyProvider).userFamilies.last);
        if (mounted) {
          context.push('/family/${newFamily.id}');
        }
      } else {
        final error = ref.read(familyErrorProvider);
        EasyLoading.showError('Failed to create family: ${error ?? "Unknown error"}');
      }
    }
  }

  void _navigateToFamilyDetails(Family family) {
    ref.read(familyProvider.notifier).selectFamily(family.id);
    context.push('/family/${family.id}'); // Placeholder for family detail route
  }

  @override
  Widget build(BuildContext context) {
    final familyState = ref.watch(familyProvider);
    final families = familyState.userFamilies;

    return Scaffold(
      backgroundColor: AppTheme.lightBackgroundColor,
      appBar: AppBar(
        title: const Text('My Families'),
        backgroundColor: AppTheme.darkHeaderColor,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(familyProvider.notifier).fetchUserFamilies(),
        child: Column(
          children: [
            if (familyState.isLoading && families.isEmpty)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                ),
              )
            else if (families.isEmpty)
              Expanded(child: _buildEmptyState())
            else
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(UIConstants.paddingM.w),
                  itemCount: families.length,
                  itemBuilder: (context, index) {
                    final family = families[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: UIConstants.paddingM.h),
                      elevation: AppTheme.lightTheme.cardTheme.elevation ?? 2,
                      shape: AppTheme.lightTheme.cardTheme.shape,
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: UIConstants.paddingM.w,
                          vertical: UIConstants.paddingS.h,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                          child: Icon(
                            Icons.group,
                            color: AppTheme.primaryColor,
                            size: 24.sp,
                          ),
                        ),
                        title: Text(
                          family.name,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkTextColor,
                          ),
                        ),
                        // You might want to show member count or user's role here
                        // subtitle: Text('${family.memberCount ?? 0} members'),
                        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                        onTap: () => _navigateToFamilyDetails(family),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateFamilyDialog,
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Create Family', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(UIConstants.paddingXL.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.no_accounts_outlined,
              size: 80.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: UIConstants.paddingL.h),
            Text(
              'No Families Yet',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: UIConstants.paddingM.h),
            Text(
              'You are not part of any family. Create one to start sharing tasks and entities!',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: UIConstants.paddingXL.h),
            ElevatedButton.icon(
              onPressed: _showCreateFamilyDialog,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Create Your First Family'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: UIConstants.paddingL.w,
                  vertical: UIConstants.paddingM.h,
                ),
                textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
