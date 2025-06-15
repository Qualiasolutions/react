// lib/features/categories/screens/categories_screen.dart
// Categories screen that exactly matches the React Native design from screenshots

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vuet_flutter/core/constants/app_constants.dart';
import 'package:vuet_flutter/core/utils/logger.dart';
import 'package:vuet_flutter/features/categories/providers/categories_provider.dart';

// Provider for professional categories (would be replaced with real data from Supabase)
final professionalCategoriesProvider = FutureProvider<List<ProfessionalCategory>>((ref) async {
  // In a real app, this would fetch from Supabase
  await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
  return [
    ProfessionalCategory(id: '1', name: 'Doctors', entityCount: 3),
    ProfessionalCategory(id: '2', name: 'Contractors', entityCount: 1),
    ProfessionalCategory(id: '3', name: 'Schools', entityCount: 2),
  ];
});

// Provider for entities in each category (would be replaced with real data from Supabase)
final categoryEntitiesProvider = FutureProvider.family<int, int>((ref, categoryId) async {
  // In a real app, this would fetch from Supabase
  await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
  
  // Return random count for demo purposes
  return [0, 3, 1, 0, 5, 2, 0, 4, 1, 0, 3, 2, 1][categoryId % 13];
});

// Model for professional category
class ProfessionalCategory {
  final String id;
  final String name;
  final int entityCount;

  ProfessionalCategory({
    required this.id,
    required this.name,
    required this.entityCount,
  });
}

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  // Selected category for quick navigation
  String? _selectedQuickNavCategory;
  
  // Controller for professional category name input
  final TextEditingController _newCategoryController = TextEditingController();
  
  @override
  void dispose() {
    _newCategoryController.dispose();
    super.dispose();
  }
  
  // Show dialog to add a new professional category
  void _showAddProfessionalCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Professional Category'),
        content: TextField(
          controller: _newCategoryController,
          decoration: const InputDecoration(
            hintText: 'Category Name',
            border: OutlineInputBorder(),
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
              // In a real app, this would save to Supabase
              if (_newCategoryController.text.isNotEmpty) {
                Logger.debug('Adding professional category: ${_newCategoryController.text}');
                // Close dialog and clear text
                Navigator.of(context).pop();
                _newCategoryController.clear();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
  
  // Show quick navigation dropdown
  void _showQuickNavigation() {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    
    showMenu<String>(
      context: context,
      position: position,
      items: [
        for (final entry in Categories.names.entries)
          PopupMenuItem<String>(
            value: entry.key.toString(),
            child: Text(entry.value),
          ),
      ],
    ).then((value) {
      if (value != null) {
        setState(() {
          _selectedQuickNavCategory = value;
        });
        // Navigate to category entities
        final categoryId = int.parse(value);
        context.push('/categories/$categoryId');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get professional categories
    final professionalCategoriesAsync = ref.watch(professionalCategoriesProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          // Quick navigation header
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  // Quick navigation button
                  ElevatedButton.icon(
                    onPressed: _showQuickNavigation,
                    icon: const Icon(Icons.sort, size: 18),
                    label: const Text('Quick Nav'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Core categories grid
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Core categories header
                  Text(
                    'Core Categories',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12.h),
                ],
              ),
            ),
          ),
          
          // Core categories grid
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  // Get category details
                  final categoryId = Categories.names.keys.elementAt(index);
                  final categoryName = Categories.names[categoryId]!;
                  final categoryIcon = Categories.icons[categoryId]!;
                  final categoryColor = Categories.colors[categoryId]!;
                  
                  // Get entity count for this category
                  final entityCountAsync = ref.watch(categoryEntitiesProvider(categoryId));
                  
                  return GestureDetector(
                    onTap: () {
                      // Navigate to category entities
                      context.push('/categories/$categoryId');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Category icon
                          Icon(
                            categoryIcon,
                            size: 32.sp,
                            color: categoryColor,
                          ),
                          SizedBox(height: 8.h),
                          // Category name
                          Text(
                            categoryName,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          // Entity count
                          entityCountAsync.when(
                            data: (count) => Text(
                              count == 0 ? 'No entities' : '$count entities',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                            loading: () => SizedBox(
                              height: 12.h,
                              width: 12.h,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                            error: (_, __) => Text(
                              'Error',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: Categories.names.length,
              ),
            ),
          ),
          
          // Professional categories section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Professional categories header with add button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Professional Categories',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      // Add button
                      IconButton(
                        icon: const Icon(Icons.add_circle),
                        color: const Color(0xFFD2691E),
                        onPressed: _showAddProfessionalCategoryDialog,
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  
                  // Professional categories list
                  professionalCategoriesAsync.when(
                    data: (categories) {
                      if (categories.isEmpty) {
                        // Empty state
                        return Container(
                          padding: EdgeInsets.symmetric(vertical: 24.h),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Icon(
                                Icons.category_outlined,
                                size: 48.sp,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'No professional categories yet',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Add your first professional category',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[500],
                                ),
                              ),
                              SizedBox(height: 16.h),
                              ElevatedButton.icon(
                                onPressed: _showAddProfessionalCategoryDialog,
                                icon: const Icon(Icons.add),
                                label: const Text('Add Category'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD2691E),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      // List of professional categories
                      return Column(
                        children: categories.map((category) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 8.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: ListTile(
                              title: Text(
                                category.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16.sp,
                                ),
                              ),
                              subtitle: Text(
                                '${category.entityCount} entities',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                              trailing: const Icon(
                                Icons.chevron_right,
                                color: Colors.grey,
                              ),
                              onTap: () {
                                // Navigate to professional category
                                context.push('/professional-categories/${category.id}');
                              },
                            ),
                          );
                        }).toList(),
                      );
                    },
                    loading: () => Center(
                      child: SizedBox(
                        height: 24.h,
                        width: 24.h,
                        child: const CircularProgressIndicator(),
                      ),
                    ),
                    error: (_, __) => Container(
                      padding: EdgeInsets.symmetric(vertical: 24.h),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48.sp,
                            color: Colors.red[400],
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Error loading categories',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.red[600],
                            ),
                          ),
                          SizedBox(height: 16.h),
                          ElevatedButton(
                            onPressed: () {
                              // Refresh the data
                              ref.refresh(professionalCategoriesProvider);
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
