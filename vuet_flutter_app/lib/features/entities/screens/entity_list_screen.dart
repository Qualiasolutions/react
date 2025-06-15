// lib/features/entities/screens/entity_list_screen.dart
// Comprehensive entity list screen that shows entities for a specific category.
// Matches the functionality from the React Native EntityListScreen, with filtering,
// search, and create entity options. Includes proper state management with Riverpod providers.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vuet_flutter/core/utils/logger.dart';
import 'package:vuet_flutter/features/entities/data/models/entity_model.dart';
import 'package:vuet_flutter/features/entities/providers/entities_provider.dart';
import 'package:vuet_flutter/features/categories/data/models/category_model.dart';
import 'package:vuet_flutter/features/categories/providers/categories_provider.dart';

// Provider for the search query
final entitySearchQueryProvider = StateProvider<String>((ref) => '');

class EntityListScreen extends ConsumerStatefulWidget {
  final String categoryId;

  const EntityListScreen({
    super.key,
    required this.categoryId,
  });

  @override
  ConsumerState<EntityListScreen> createState() => _EntityListScreenState();
}

class _EntityListScreenState extends ConsumerState<EntityListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Clear search query when screen initializes
    _searchController.addListener(() {
      ref.read(entitySearchQueryProvider.notifier).state = _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryIdInt = int.tryParse(widget.categoryId);
    if (categoryIdInt == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Invalid Category ID')),
      );
    }

    final categoryAsync = ref.watch(categoryByIdProvider(categoryIdInt));
    final entitiesAsync = ref.watch(entitiesProvider);
    final searchQuery = ref.watch(entitySearchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: categoryAsync.when(
          data: (category) => Text('${category.readableName} Entities'),
          loading: () => const Text('Loading Category...'),
          error: (err, st) => const Text('Error'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to entity creation screen
              context.push('/entities/create?categoryId=${widget.categoryId}');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(16.w),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search entities...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
          Expanded(
            child: entitiesAsync.when(
              data: (entities) {
                // Filter entities by category and search query
                final filteredEntities = entities.where((entity) {
                  final matchesCategory = entity.categoryId == categoryIdInt;
                  final matchesSearch = entity.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                      (entity.notes?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false);
                  return matchesCategory && matchesSearch;
                }).toList();

                if (filteredEntities.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open, size: 64.sp, color: Colors.grey[400]),
                        SizedBox(height: 16.h),
                        Text(
                          'No entities found for this category.',
                          style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Tap the + button to add a new one!',
                          style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredEntities.length,
                  itemBuilder: (context, index) {
                    final entity = filteredEntities[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      child: ListTile(
                        leading: Icon(entity.icon, color: entity.color, size: 32.sp),
                        title: Text(
                          entity.name,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                        ),
                        subtitle: Text(
                          entity.type.name.toUpperCase(),
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Navigate to entity detail screen
                          context.push('/entities/${entity.id}');
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) {
                Logger.error('Error loading entities', err, st);
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                      SizedBox(height: 16.h),
                      Text(
                        'Failed to load entities.',
                        style: TextStyle(fontSize: 16.sp, color: Colors.red),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        err.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () {
                          ref.invalidate(entitiesProvider); // Retry fetching entities
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/entities/create?categoryId=${widget.categoryId}');
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
