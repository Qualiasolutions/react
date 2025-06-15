// lib/features/entities/screens/entity_detail_screen.dart
// Entity detail screen that displays the details of a selected entity, matching the React Native design

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';

import 'package:vuet_flutter/core/constants/app_constants.dart';
import 'package:vuet_flutter/core/theme/app_theme.dart';
import 'package:vuet_flutter/core/utils/logger.dart';
import 'package:vuet_flutter/data/models/simple_entity_model.dart';
import 'package:vuet_flutter/data/models/task_model.dart';
import 'package:vuet_flutter/features/entities/providers/entities_provider.dart';
import 'package:vuet_flutter/features/tasks/providers/tasks_provider.dart';
import 'package:vuet_flutter/features/user/providers/user_provider.dart';

class EntityDetailScreen extends ConsumerStatefulWidget {
  final String entityId;

  const EntityDetailScreen({
    Key? key,
    required this.entityId,
  }) : super(key: key);

  @override
  ConsumerState<EntityDetailScreen> createState() => _EntityDetailScreenState();
}

class _EntityDetailScreenState extends ConsumerState<EntityDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch entities to ensure the specific entity is available in the state
    // This might be redundant if already fetched by EntityListScreen, but ensures data presence
    ref.read(entitiesProvider.notifier).fetchEntities(forceRefresh: false);
    // Fetch tasks associated with this entity
    ref.read(tasksProvider.notifier).fetchTasksForEntity(widget.entityId);
  }

  Future<void> _deleteEntity() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entity'),
        content: const Text('Are you sure you want to delete this entity? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        EasyLoading.show(status: 'Deleting entity...');
        await ref.read(entitiesProvider.notifier).deleteEntity(widget.entityId);
        EasyLoading.showSuccess('Entity deleted!');
        if (mounted) {
          context.pop(); // Go back to the previous screen (entity list)
        }
      } catch (e, st) {
        Logger.error('Failed to delete entity', e, st);
        EasyLoading.showError('Failed to delete entity: $e');
      }
    }
  }

  void _editEntity(SimpleEntityModel entity) {
    // Navigate to an edit screen, passing the entity ID
    context.push('/entities/edit/${entity.id}', extra: entity);
  }

  Future<void> _showAddMemberDialog(SimpleEntityModel entity) async {
    final TextEditingController emailController = TextEditingController();
    
    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                hintText: 'Enter member email',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16.h),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Role',
              ),
              items: const [
                DropdownMenuItem(value: 'VIEWER', child: Text('Viewer')),
                DropdownMenuItem(value: 'EDITOR', child: Text('Editor')),
              ],
              value: 'VIEWER',
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop({
                'email': emailController.text,
                'role': 'VIEWER', // Default role
              });
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null && result['email'] != null && result['email'].isNotEmpty) {
      try {
        EasyLoading.show(status: 'Adding member...');
        // In a real app, you would:
        // 1. Look up the user by email
        // 2. Add them as a member with the specified role
        // For now, we'll just show a success message
        await Future.delayed(const Duration(seconds: 1)); // Simulate API call
        EasyLoading.showSuccess('Member invited!');
        // In a real implementation, you would refresh the entity data here
      } catch (e, st) {
        Logger.error('Failed to add member', e, st);
        EasyLoading.showError('Failed to add member: $e');
      }
    }
  }

  Future<void> _removeMember(SimpleEntityModel entity, String memberId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member'),
        content: const Text('Are you sure you want to remove this member?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        EasyLoading.show(status: 'Removing member...');
        await ref.read(entitiesProvider.notifier).removeEntityMember(entity.id, memberId);
        EasyLoading.showSuccess('Member removed!');
      } catch (e, st) {
        Logger.error('Failed to remove member', e, st);
        EasyLoading.showError('Failed to remove member: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final entityAsync = ref.watch(entityByIdProvider(widget.entityId));
    final tasksAsync = ref.watch(tasksByEntityProvider(widget.entityId));
    final currentUserId = ref.watch(userIdProvider);

    return Scaffold(
      backgroundColor: AppTheme.lightBackgroundColor,
      appBar: AppBar(
        title: Text(entityAsync.when(
          data: (entity) => entity?.name ?? 'Entity Details',
          loading: () => 'Loading...',
          error: (_, __) => 'Error',
        )),
        backgroundColor: AppTheme.darkHeaderColor,
        foregroundColor: Colors.white,
        actions: [
          entityAsync.when(
            data: (entity) => entity != null
                ? IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editEntity(entity),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteEntity,
          ),
        ],
      ),
      body: entityAsync.when(
        data: (entity) {
          if (entity == null) {
            return Center(
              child: Text(
                'Entity not found.',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
              ),
            );
          }
          return SingleChildScrollView(
            padding: EdgeInsets.all(UIConstants.paddingM.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Entity Image
                if (entity.imagePath != null && entity.imagePath!.isNotEmpty)
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(bottom: UIConstants.paddingM.h),
                      width: 200.w,
                      height: 200.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(UIConstants.radiusL.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(UIConstants.radiusL.r),
                        child: CachedNetworkImage(
                          imageUrl: entity.imagePath!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                            ),
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.broken_image,
                            size: 100.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Basic Details Card
                Card(
                  elevation: AppTheme.lightTheme.cardTheme.elevation,
                  shape: AppTheme.lightTheme.cardTheme.shape,
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: EdgeInsets.all(UIConstants.paddingM.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(
                          icon: Icons.label,
                          label: 'Name',
                          value: entity.name,
                        ),
                        _buildDetailRow(
                          icon: Icons.category,
                          label: 'Type',
                          value: entity.type.toDbString().replaceAll('_', ' '),
                        ),
                        if (entity.subtype != null && entity.subtype!.isNotEmpty)
                          _buildDetailRow(
                            icon: Icons.subtitles,
                            label: 'Subtype',
                            value: entity.subtype!,
                          ),
                        if (entity.notes != null && entity.notes!.isNotEmpty)
                          _buildDetailRow(
                            icon: Icons.notes,
                            label: 'Notes',
                            value: entity.notes!,
                          ),
                        _buildDetailRow(
                          icon: Icons.calendar_today,
                          label: 'Created At',
                          value: DateFormat('MMM d, yyyy HH:mm').format(entity.createdAt),
                        ),
                        _buildDetailRow(
                          icon: Icons.update,
                          label: 'Last Updated',
                          value: DateFormat('MMM d, yyyy HH:mm').format(entity.updatedAt),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: UIConstants.paddingL.h),

                // Dynamic Fields (Dates, Contact Info, Location, Metadata)
                _buildDynamicFieldsSection(entity),
                SizedBox(height: UIConstants.paddingL.h),

                // Members Section
                _buildMembersSection(entity, currentUserId),
                SizedBox(height: UIConstants.paddingL.h),

                // Associated Tasks Section
                _buildAssociatedTasksSection(tasksAsync),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
        ),
        error: (error, stack) {
          Logger.error('Error loading entity details', error, stack);
          return Center(
            child: Text(
              'Failed to load entity details: ${error.toString()}',
              style: TextStyle(fontSize: 16.sp, color: Colors.red),
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: UIConstants.paddingXS.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20.sp, color: Colors.grey[600]),
          SizedBox(width: UIConstants.paddingS.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppTheme.darkTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicFieldsSection(SimpleEntityModel entity) {
    final dynamicFields = <String, Map<String, dynamic>?>{
      'Dates': entity.dates,
      'Contact Info': entity.contactInfo,
      'Location': entity.location,
      'Metadata': entity.metadata,
    };

    final hasDynamicFields = dynamicFields.values.any((map) => map != null && map.isNotEmpty);

    if (!hasDynamicFields) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: AppTheme.lightTheme.cardTheme.elevation,
      shape: AppTheme.lightTheme.cardTheme.shape,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(UIConstants.paddingM.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Details',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkTextColor,
              ),
            ),
            SizedBox(height: UIConstants.paddingS.h),
            ...dynamicFields.entries.map((entry) {
              final sectionName = entry.key;
              final data = entry.value;
              if (data == null || data.isEmpty) {
                return const SizedBox.shrink();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: UIConstants.paddingXS.h),
                    child: Text(
                      sectionName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  ...data.entries.map((item) {
                    return _buildDetailRow(
                      icon: Icons.info_outline, // Generic icon for dynamic fields
                      label: item.key.replaceAll('_', ' ').capitalize(),
                      value: item.value.toString(),
                    );
                  }).toList(),
                  SizedBox(height: UIConstants.paddingS.h),
                ],
              );
            }).toList(),
            // Placeholder for dynamic form editing
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  // TODO: Implement dynamic form editing based on entity type
                  EasyLoading.showInfo('Dynamic form editing coming soon!');
                },
                icon: const Icon(Icons.edit_note),
                label: const Text('Edit Dynamic Fields'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersSection(SimpleEntityModel entity, String? currentUserId) {
    final isOwner = entity.ownerId == currentUserId;

    return Card(
      elevation: AppTheme.lightTheme.cardTheme.elevation,
      shape: AppTheme.lightTheme.cardTheme.shape,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(UIConstants.paddingM.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Members',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkTextColor,
                  ),
                ),
                if (isOwner)
                  TextButton.icon(
                    onPressed: () => _showAddMemberDialog(entity),
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add Member'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                    ),
                  ),
              ],
            ),
            SizedBox(height: UIConstants.paddingS.h),
            // Owner row
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue,
                child: const Icon(Icons.person, color: Colors.white),
              ),
              title: Text(
                'Owner', // In a real app, fetch the owner's name
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
              subtitle: Text(
                entity.ownerId == currentUserId ? 'You' : entity.ownerId,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
              trailing: const Text('OWNER', style: TextStyle(color: Colors.grey)),
            ),
            // Members list
            ...entity.members.map((member) {
              final isCurrentUser = member.userId == currentUserId;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                title: Text(
                  'Member', // In a real app, fetch the member's name
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                subtitle: Text(
                  isCurrentUser ? 'You' : member.userId,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(member.role, style: TextStyle(color: Colors.grey)),
                    if (isOwner && !isCurrentUser)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        onPressed: () => _removeMember(entity, member.userId),
                      ),
                  ],
                ),
              );
            }).toList(),
            if (entity.members.isEmpty)
              Padding(
                padding: EdgeInsets.all(UIConstants.paddingM.w),
                child: Center(
                  child: Text(
                    'No additional members',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssociatedTasksSection(AsyncValue<List<TaskModel>> tasksAsync) {
    return Card(
      elevation: AppTheme.lightTheme.cardTheme.elevation,
      shape: AppTheme.lightTheme.cardTheme.shape,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(UIConstants.paddingM.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tasks',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkTextColor,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // Navigate to add task screen for this entity
                    context.push('/tasks/new', extra: {'entityId': widget.entityId});
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Task'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: UIConstants.paddingS.h),
            tasksAsync.when(
              data: (tasks) {
                if (tasks.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: UIConstants.paddingL.h),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.task_alt,
                            size: 48.sp,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: UIConstants.paddingM.h),
                          Text(
                            'No tasks associated with this entity',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        vertical: UIConstants.paddingXS.h,
                        horizontal: UIConstants.paddingS.w,
                      ),
                      leading: Icon(
                        Icons.task_alt,
                        color: task.completed ? Colors.green : Colors.grey,
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          decoration: task.completed ? TextDecoration.lineThrough : null,
                          color: task.completed ? Colors.grey : Colors.black87,
                        ),
                      ),
                      subtitle: task.dueDate != null
                          ? Text(
                              'Due: ${DateFormat('MMM d, yyyy').format(task.dueDate!)}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            )
                          : null,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Navigate to task detail screen
                        context.push('/tasks/${task.id}');
                      },
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Text(
                  'Failed to load tasks: ${error.toString()}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension for string capitalization
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
