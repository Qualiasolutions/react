// lib/features/categories/screens/categories_screen.dart
// Categories screen that shows entity lists and category navigation
// Exactly matches the React Native UI from the screenshots

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vuet_flutter/core/constants/app_constants.dart';
import 'package:vuet_flutter/core/utils/logger.dart';
import 'package:vuet_flutter/features/categories/providers/categories_provider.dart';

// Selected category provider
final selectedCategoryProvider = StateProvider<int>((ref) => Categories.family);

// Entity list provider (mock data - would be replaced with Supabase data)
final entityListProvider = Provider.family<List<EntityItem>?, int>((ref, categoryId) {
  // In a real app, this would fetch entities from Supabase
  // For now, return empty lists to show empty states
  return [];
});

// Entity item model
class EntityItem {
  final String id;
  final String name;
  final String? imagePath;
  final int categoryId;
  
  EntityItem({
    required this.id,
    required this.name,
    this.imagePath,
    required this.categoryId,
  });
}

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  String? _quickNavValue;
  String? _actionValue;
  
  // Quick Nav options
  final List<String> _quickNavOptions = [
    'All Categories',
    'Family',
    'Pets',
    'Social & Interests',
    'Education',
    'Career',
    'Travel',
    'Health & Beauty',
    'Home',
    'Garden',
    'Food',
    'Laundry',
    'Finance',
    'Transport',
  ];
  
  // Action options
  final List<String> _actionOptions = [
    'Add New',
    'View All',
    'Filter',
    'Sort',
    'Search',
  ];

  @override
  Widget build(BuildContext context) {
    final selectedCategoryId = ref.watch(selectedCategoryProvider);
    final category = ref.watch(categoryByIdProvider(selectedCategoryId));
    final entities = ref.watch(entityListProvider(selectedCategoryId)) ?? [];
    final allCategories = ref.watch(coreCategoriesProvider);
    
    // Get category name for title
    final categoryName = category?.readableName ?? 
                        Categories.names[selectedCategoryId] ?? 
                        'Categories';
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A4A4A),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(categoryName),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Quick Nav and Action Dropdowns
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                // Quick Nav Dropdown
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _quickNavValue,
                        hint: const Text('Quick Nav'),
                        icon: const Icon(Icons.keyboard_arrow_down),
                        isExpanded: true,
                        onChanged: (String? newValue) {
                          setState(() {
                            _quickNavValue = newValue;
                            
                            // Navigate to selected category
                            if (newValue != null && newValue != 'All Categories') {
                              final categoryId = allCategories.firstWhere(
                                (c) => c.readableName == newValue,
                                orElse: () => allCategories.first,
                              ).id;
                              
                              ref.read(selectedCategoryProvider.notifier).state = categoryId;
                            }
                          });
                        },
                        items: _quickNavOptions.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                
                SizedBox(width: 8.w),
                
                // I Want To Dropdown
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _actionValue,
                        hint: const Text('I Want To'),
                        icon: const Icon(Icons.keyboard_arrow_down),
                        isExpanded: true,
                        onChanged: (String? newValue) {
                          setState(() {
                            _actionValue = newValue;
                            
                            // Handle action selection
                            if (newValue == 'Add New') {
                              _handleAddEntity();
                            }
                          });
                        },
                        items: _actionOptions.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Divider
          Divider(height: 1, color: Colors.grey[300]),
          
          // Entity List or Empty State
          Expanded(
            child: entities.isEmpty
                ? _buildEmptyState(categoryName)
                : _buildEntityList(entities),
          ),
        ],
      ),
    );
  }
  
  // Empty state widget that matches the screenshot
  Widget _buildEmptyState(String categoryName) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'You don\'t currently have any $categoryName.',
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'Click the + button below to add some',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  // Entity list widget
  Widget _buildEntityList(List<EntityItem> entities) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      itemCount: entities.length,
      itemBuilder: (context, index) {
        final entity = entities[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: ListTile(
            leading: entity.imagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: Image.network(
                      entity.imagePath!,
                      width: 50.w,
                      height: 50.w,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 50.w,
                          height: 50.w,
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    ),
                  )
                : Container(
                    width: 50.w,
                    height: 50.w,
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey[600],
                    ),
                  ),
            title: Text(
              entity.name,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to entity details
              Logger.debug('Navigate to entity details: ${entity.id}');
            },
          ),
        );
      },
    );
  }
  
  // Handle add entity action
  void _handleAddEntity() {
    final categoryId = ref.read(selectedCategoryProvider);
    final categoryName = ref.read(categoryByIdProvider(categoryId))?.readableName ?? 
                        Categories.names[categoryId] ?? 
                        'Item';
    
    // In a real app, this would navigate to the appropriate entity form
    // For now, just show a dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add $categoryName'),
        content: Text('Add $categoryName form coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
