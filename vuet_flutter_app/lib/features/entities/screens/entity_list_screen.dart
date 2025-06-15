// lib/features/entities/screens/entity_list_screen.dart
// Entity list screen that displays entities for a given category, matching the React Native design

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vuet_flutter/core/constants/app_constants.dart';
import 'package:vuet_flutter/core/theme/app_theme.dart';
import 'package:vuet_flutter/features/entities/providers/entities_provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class EntityListScreen extends ConsumerStatefulWidget {
  final int categoryId;
  final String categoryName;

  const EntityListScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  ConsumerState<EntityListScreen> createState() => _EntityListScreenState();
}

class _EntityListScreenState extends ConsumerState<EntityListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _currentSearchQuery = '';

  @override
  void initState() {
    super.initState();
    // Fetch entities for the current category when the screen initializes
    _fetchEntities();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchEntities() async {
    await ref.read(entitiesProvider.notifier).fetchEntities(
          categoryId: widget.categoryId,
          searchQuery: _currentSearchQuery.isEmpty ? null : _currentSearchQuery,
          forceRefresh: true,
        );
  }

  void _onSearchChanged(String query) {
    setState(() {
      _currentSearchQuery = query;
    });
    _fetchEntities(); // Re-fetch entities with the new search query
  }

  Future<void> _deleteEntity(String entityId) async {
    try {
      EasyLoading.show(status: 'Deleting entity...');
      await ref.read(entitiesProvider.notifier).deleteEntity(entityId);
      EasyLoading.showSuccess('Entity deleted!');
    } catch (e) {
      EasyLoading.showError('Failed to delete entity: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final entitiesState = ref.watch(entitiesProvider);
    final entities = entitiesState.entities.where((entity) {
      final matchesCategory = entity.categoryId == widget.categoryId;
      final matchesSearch = _currentSearchQuery.isEmpty ||
          entity.name.toLowerCase().contains(_currentSearchQuery.toLowerCase()) ||
          (entity.notes?.toLowerCase().contains(_currentSearchQuery.toLowerCase()) ?? false);
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.lightBackgroundColor,
      appBar: AppBar(
        title: Text(widget.categoryName),
        backgroundColor: AppTheme.darkHeaderColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(UIConstants.paddingM.w),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search entities...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(UIConstants.radiusL.r),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: EdgeInsets.symmetric(
                  horizontal: UIConstants.paddingM.w,
                  vertical: UIConstants.paddingS.h,
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          
          // Loading Indicator
          if (entitiesState.isLoading)
            const LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              backgroundColor: Colors.transparent,
            ),

          // Entity List or Empty State
          Expanded(
            child: entities.isEmpty && !entitiesState.isLoading
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.all(UIConstants.paddingM.w),
                    itemCount: entities.length,
                    itemBuilder: (context, index) {
                      final entity = entities[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: UIConstants.paddingM.h),
                        elevation: AppTheme.lightTheme.cardTheme.elevation ?? 2,
                        shape: AppTheme.lightTheme.cardTheme.shape,
                        child: ListTile(
                          contentPadding: EdgeInsets.all(UIConstants.paddingM.w),
                          leading: CircleAvatar(
                            backgroundColor: entity.type.color,
                            child: Icon(
                              entity.type.icon,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            entity.name,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: UIConstants.paddingXS.h),
                              Text(
                                entity.type.toDbString().replaceAll('_', ' '),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (entity.notes != null && entity.notes!.isNotEmpty)
                                Text(
                                  entity.notes!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey[700],
                                  ),
                                ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _deleteEntity(entity.id),
                          ),
                          onTap: () {
                            // Navigate to entity detail screen
                            context.push('/entities/${entity.id}');
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add new entity screen
          context.push('/entities/new', extra: widget.categoryId);
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 64.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: UIConstants.paddingM.h),
          Text(
            'No ${widget.categoryName} entities yet',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: UIConstants.paddingS.h),
          Text(
            'Tap the + button to add your first entity.',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: UIConstants.paddingL.h),
          ElevatedButton.icon(
            onPressed: () {
              context.push('/entities/new', extra: widget.categoryId);
            },
            icon: const Icon(Icons.add),
            label: const Text('Add New Entity'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: UIConstants.paddingL.w,
                vertical: UIConstants.paddingS.h,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
