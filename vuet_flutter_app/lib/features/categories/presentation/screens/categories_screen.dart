import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vuet_flutter/core/theme/app_theme.dart';
import 'package:vuet_flutter/core/utils/error_handler.dart';
import 'package:vuet_flutter/features/categories/data/models/category_model.dart';
import 'package:vuet_flutter/features/categories/domain/providers/categories_provider.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Function to filter categories based on search query
  List<CategoryModel> _filterCoreCategories(List<CategoryModel> categories) {
    if (_searchQuery.isEmpty) {
      return categories;
    }
    return categories.where((category) {
      return category.readableName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  List<ProfessionalCategoryModel> _filterProfessionalCategories(
      List<ProfessionalCategoryModel> categories) {
    if (_searchQuery.isEmpty) {
      return categories;
    }
    return categories.where((category) {
      return category.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  // Function to show dialog for adding new professional category
  Future<void> _showAddProfessionalCategoryDialog() async {
    String newCategoryName = '';
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to close
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Add New Professional Category'),
          content: TextField(
            onChanged: (value) {
              newCategoryName = value;
            },
            decoration: const InputDecoration(hintText: 'Category Name'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () async {
                if (newCategoryName.isNotEmpty) {
                  try {
                    await ref.read(categoriesProvider.notifier).createProfessionalCategory(newCategoryName);
                    if (mounted) Navigator.of(dialogContext).pop();
                  } catch (e, st) {
                    ErrorHandler.reportError('Failed to add professional category', e, stackTrace: st);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${ErrorHandler.handleSupabaseError(e)}')),
                      );
                    }
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        centerTitle: true,
      ),
      body: categoriesState.when(
        data: (state) {
          final filteredCoreCategories = _filterCoreCategories(state.coreCategories);
          final filteredProfessionalCategories = _filterProfessionalCategories(state.professionalCategories);

          return SingleChildScrollView(
            padding: EdgeInsets.all(AppTheme.spacingM.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search categories...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusM.r),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                    contentPadding: EdgeInsets.symmetric(vertical: AppTheme.spacingS.h),
                  ),
                ),
                SizedBox(height: AppTheme.spacingL.h),

                // Core Categories Section
                Text(
                  'Core Categories',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(height: AppTheme.spacingM.h),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppTheme.spacingM.w,
                    mainAxisSpacing: AppTheme.spacingM.h,
                    childAspectRatio: 1.0, // Adjust as needed for card content
                  ),
                  itemCount: filteredCoreCategories.length,
                  itemBuilder: (context, index) {
                    final category = filteredCoreCategories[index];
                    return _CategoryCard(
                      category: category,
                      onTap: () {
                        // Navigate to entity list for this category
                        context.go('/entities/${category.id}');
                      },
                    );
                  },
                ),
                SizedBox(height: AppTheme.spacingXl.h),

                // Professional Categories Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Professional Categories',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryColor),
                      onPressed: _showAddProfessionalCategoryDialog,
                    ),
                  ],
                ),
                SizedBox(height: AppTheme.spacingM.h),
                filteredProfessionalCategories.isEmpty
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: AppTheme.spacingL.h),
                          child: Text(
                            'No professional categories added yet.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredProfessionalCategories.length,
                        itemBuilder: (context, index) {
                          final profCategory = filteredProfessionalCategories[index];
                          return _ProfessionalCategoryItem(
                            category: profCategory,
                            onTap: () {
                              // Navigate to entity list for this professional category
                              // Assuming professional categories also link to entities
                              context.go('/entities/professional/${profCategory.id}');
                            },
                            onEdit: () {
                              // TODO: Implement edit functionality
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Edit professional category coming soon!')),
                              );
                            },
                            onDelete: () async {
                              try {
                                await ref.read(categoriesProvider.notifier).deleteProfessionalCategory(profCategory.id);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${profCategory.name} deleted.')),
                                  );
                                }
                              } catch (e, st) {
                                ErrorHandler.reportError('Failed to delete professional category', e, stackTrace: st);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error deleting: ${ErrorHandler.handleSupabaseError(e)}')),
                                  );
                                }
                              }
                            },
                          );
                        },
                      ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Error loading categories: ${ErrorHandler.handleSupabaseError(error)}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.errorColor),
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color categoryColor = AppTheme.getCategoryColor(category.name.name);
    IconData categoryIcon;

    // Map category names to appropriate icons
    switch (category.name) {
      case CategoryName.family:
        categoryIcon = Icons.family_restroom;
        break;
      case CategoryName.pets:
        categoryIcon = Icons.pets;
        break;
      case CategoryName.socialInterests:
        categoryIcon = Icons.people;
        break;
      case CategoryName.education:
        categoryIcon = Icons.school;
        break;
      case CategoryName.career:
        categoryIcon = Icons.work;
        break;
      case CategoryName.travel:
        categoryIcon = Icons.flight;
        break;
      case CategoryName.healthBeauty:
        categoryIcon = Icons.health_and_safety;
        break;
      case CategoryName.home:
        categoryIcon = Icons.home;
        break;
      case CategoryName.garden:
        categoryIcon = Icons.grass;
        break;
      case CategoryName.food:
        categoryIcon = Icons.restaurant;
        break;
      case CategoryName.laundry:
        categoryIcon = Icons.local_laundry_service;
        break;
      case CategoryName.finance:
        categoryIcon = Icons.account_balance_wallet;
        break;
      case CategoryName.transport:
        categoryIcon = Icons.directions_car;
        break;
      default:
        categoryIcon = Icons.category;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusL.r),
      child: Card(
        elevation: AppTheme.elevationS,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusL.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(AppTheme.spacingM.w),
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                categoryIcon,
                size: 40.w,
                color: categoryColor,
              ),
            ),
            SizedBox(height: AppTheme.spacingS.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingS.w),
              child: Text(
                category.readableName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfessionalCategoryItem extends StatelessWidget {
  final ProfessionalCategoryModel category;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProfessionalCategoryItem({
    required this.category,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppTheme.elevationXs,
      margin: EdgeInsets.only(bottom: AppTheme.spacingS.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusM.r),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM.w,
          vertical: AppTheme.spacingXs.h,
        ),
        leading: Icon(Icons.business_center, color: AppTheme.secondaryColor, size: 28.w),
        title: Text(
          category.name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, size: 20.w, color: AppTheme.textMuted),
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(Icons.delete, size: 20.w, color: AppTheme.errorColor),
              onPressed: onDelete,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
