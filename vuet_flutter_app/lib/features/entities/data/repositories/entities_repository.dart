// lib/features/entities/data/repositories/entities_repository.dart
// Entities repository that handles CRUD operations for entities with Supabase

import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Hide Supabase's `Provider` enum to avoid name clash with Riverpod's Provider
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import 'package:vuet_flutter/core/constants/app_constants.dart';
import 'package:vuet_flutter/core/utils/logger.dart';
import 'package:vuet_flutter/features/auth/providers/auth_provider.dart';
import 'package:vuet_flutter/data/models/simple_entity_model.dart';

/// Abstract class for Entity Repository
abstract class BaseEntitiesRepository {
  Future<List<SimpleEntityModel>> fetchEntities({
    String? userId,
    int? categoryId,
    String? searchQuery,
    bool includeShared = false,
  });

  Future<SimpleEntityModel> createEntity(SimpleEntityModel entity, {Uint8List? imageBytes, String? imageFileName});
  Future<SimpleEntityModel> updateEntity(SimpleEntityModel entity, {Uint8List? imageBytes, String? imageFileName});
  Future<void> deleteEntity(String entityId);
  Future<void> bulkDeleteEntities(List<String> entityIds);
  Future<String> uploadImage(Uint8List imageBytes, String fileName, String entityId);
  Future<void> addEntityMember(String entityId, String memberId, String role);
  Future<void> removeEntityMember(String entityId, String memberId);
  Future<List<SimpleEntityModel>> searchEntities(String searchQuery);
}

/// Supabase implementation of the Entity Repository
class SupabaseEntitiesRepository implements BaseEntitiesRepository {
  final SupabaseClient _supabase;
  final String? _currentUserId;

  SupabaseEntitiesRepository(this._supabase, this._currentUserId);

  /// Fetches entities based on various criteria
  @override
  Future<List<SimpleEntityModel>> fetchEntities({
    String? userId,
    int? categoryId,
    String? searchQuery,
    bool includeShared = false,
  }) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      var query = _supabase.from('entities').select('''
        *,
        entity_members!left(member_id, role)
      ''');

      // Filter by owner or member
      if (userId != null) {
        query = query.or('owner_id.eq.$userId,entity_members.member_id.eq.$userId');
      } else {
        // Default to current user's entities if no specific userId is provided
        query = query.or('owner_id.eq.$_currentUserId,entity_members.member_id.eq.$_currentUserId');
      }

      // Filter by category
      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }

      // Search functionality (example: search by name or notes)
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.ilike('name', '%$searchQuery%'); // Case-insensitive search
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List).map((json) => SimpleEntityModel.fromJson(json)).toList();
    } catch (e, st) {
      Logger.error('Failed to fetch entities', e, st);
      rethrow;
    }
  }

  /// Creates a new entity
  @override
  Future<SimpleEntityModel> createEntity(SimpleEntityModel entity, {Uint8List? imageBytes, String? imageFileName}) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Upload image if provided
      String? imageUrl;
      if (imageBytes != null && imageFileName != null) {
        imageUrl = await uploadImage(imageBytes, imageFileName, entity.id);
      }

      final newEntityData = entity.toJson();
      newEntityData['owner_id'] = _currentUserId; // Ensure owner is current user
      newEntityData['image_path'] = imageUrl; // Add image URL

      final response = await _supabase
          .from('entities')
          .insert(newEntityData)
          .select()
          .single();

      return SimpleEntityModel.fromJson(response);
    } catch (e, st) {
      Logger.error('Failed to create entity', e, st);
      rethrow;
    }
  }

  /// Updates an existing entity
  @override
  Future<SimpleEntityModel> updateEntity(SimpleEntityModel entity, {Uint8List? imageBytes, String? imageFileName}) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Upload new image if provided, or delete old one if imageBytes is null and imagePath is null
      String? imageUrl = entity.imagePath;
      if (imageBytes != null && imageFileName != null) {
        imageUrl = await uploadImage(imageBytes, imageFileName, entity.id);
      } else if (imageBytes == null && imageFileName == null && entity.imagePath != null) {
        // If imageBytes is null and imageFileName is null, it means user wants to remove the image
        await _supabase.storage.from(SupabaseConfig.entityBucket).remove(['${entity.ownerId}/${entity.id}/${entity.imagePath!.split('/').last}']);
        imageUrl = null;
      }

      final updatedEntityData = entity.toJson();
      updatedEntityData['image_path'] = imageUrl; // Update image URL

      final response = await _supabase
          .from('entities')
          .update(updatedEntityData)
          .eq('id', entity.id)
          .select()
          .single();

      return SimpleEntityModel.fromJson(response);
    } catch (e, st) {
      Logger.error('Failed to update entity', e, st);
      rethrow;
    }
  }

  /// Deletes an entity
  @override
  Future<void> deleteEntity(String entityId) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Optionally delete associated image from storage
      // First, fetch the entity to get the image path
      final entityData = await _supabase.from('entities').select('image_path').eq('id', entityId).single();
      final imagePath = entityData['image_path'] as String?;

      await _supabase
          .from('entities')
          .delete()
          .eq('id', entityId);

      if (imagePath != null && imagePath.isNotEmpty) {
        // Extract the file path within the bucket
        final fileName = imagePath.split('/').last;
        await _supabase.storage.from(SupabaseConfig.entityBucket).remove(['$_currentUserId/$entityId/$fileName']);
      }
    } catch (e, st) {
      Logger.error('Failed to delete entity', e, st);
      rethrow;
    }
  }

  /// Uploads an image to Supabase Storage
  @override
  Future<String> uploadImage(Uint8List imageBytes, String fileName, String entityId) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final filePath = '$_currentUserId/$entityId/$fileName';
      final response = await _supabase.storage.from(SupabaseConfig.entityBucket).uploadBinary(
        filePath,
        imageBytes,
        fileOptions: const FileOptions(
          cacheControl: '3600',
          upsert: true, // Overwrite if file exists
        ),
      );

      // Get public URL
      final publicUrl = _supabase.storage.from(SupabaseConfig.entityBucket).getPublicUrl(filePath);
      return publicUrl;
    } catch (e, st) {
      Logger.error('Failed to upload image', e, st);
      rethrow;
    }
  }

  /// Adds a member to an entity for sharing
  @override
  Future<void> addEntityMember(String entityId, String memberId, String role) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      await _supabase.from('entity_members').insert({
        'entity_id': entityId,
        'member_id': memberId,
        'role': role,
      });
    } catch (e, st) {
      Logger.error('Failed to add entity member', e, st);
      rethrow;
    }
  }

  /// Removes a member from an entity
  @override
  Future<void> removeEntityMember(String entityId, String memberId) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      await _supabase.from('entity_members').delete().eq('entity_id', entityId).eq('member_id', memberId);
    } catch (e, st) {
      Logger.error('Failed to remove entity member', e, st);
      rethrow;
    }
  }

  /// Searches entities by name or notes
  @override
  Future<List<SimpleEntityModel>> searchEntities(String searchQuery) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('entities')
          .select('''
            *,
            entity_members!left(member_id, role)
          ''')
          .or('owner_id.eq.$_currentUserId,entity_members.member_id.eq.$_currentUserId')
          .ilike('name', '%$searchQuery%')
          .order('created_at', ascending: false);

      return (response as List).map((json) => SimpleEntityModel.fromJson(json)).toList();
    } catch (e, st) {
      Logger.error('Failed to search entities', e, st);
      rethrow;
    }
  }

  /// Performs bulk deletion of entities
  @override
  Future<void> bulkDeleteEntities(List<String> entityIds) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Fetch image paths for entities to be deleted
      final entitiesToDelete = await _supabase.from('entities').select('id, image_path').in_('id', entityIds);

      // Delete entities from database
      await _supabase
          .from('entities')
          .delete()
          .in_('id', entityIds);

      // Delete associated images from storage
      for (final entityData in entitiesToDelete) {
        final imagePath = entityData['image_path'] as String?;
        if (imagePath != null && imagePath.isNotEmpty) {
          final fileName = imagePath.split('/').last;
          await _supabase.storage.from(SupabaseConfig.entityBucket).remove(['$_currentUserId/${entityData['id']}/$fileName']);
        }
      }
    } catch (e, st) {
      Logger.error('Failed to bulk delete entities', e, st);
      rethrow;
    }
  }
}

/// Provider for the Entities Repository
final entitiesRepositoryProvider = Provider<BaseEntitiesRepository>((ref) {
  final supabase = Supabase.instance.client;
  final currentUserId = ref.watch(userIdProvider);
  return SupabaseEntitiesRepository(supabase, currentUserId);
});
