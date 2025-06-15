// lib/features/entities/providers/entities_provider.dart
// Riverpod provider for managing entity state, including CRUD, filtering, and search.

import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vuet_flutter/core/utils/logger.dart';
import 'package:vuet_flutter/data/models/simple_entity_model.dart';
import 'package:vuet_flutter/features/auth/providers/auth_provider.dart';
import 'package:vuet_flutter/features/entities/data/repositories/entities_repository.dart';

/// Represents the state of entities in the application.
class EntitiesState {
  final List<SimpleEntityModel> entities;
  final bool isLoading;
  final String? error;
  final String? lastSearchQuery;
  final int? lastCategoryId;

  const EntitiesState({
    this.entities = const [],
    this.isLoading = false,
    this.error,
    this.lastSearchQuery,
    this.lastCategoryId,
  });

  EntitiesState copyWith({
    List<SimpleEntityModel>? entities,
    bool? isLoading,
    String? error,
    String? lastSearchQuery,
    int? lastCategoryId,
  }) {
    return EntitiesState(
      entities: entities ?? this.entities,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastSearchQuery: lastSearchQuery ?? this.lastSearchQuery,
      lastCategoryId: lastCategoryId ?? this.lastCategoryId,
    );
  }
}

/// Notifier for managing entity state.
class EntitiesNotifier extends StateNotifier<EntitiesState> {
  final BaseEntitiesRepository _repository;
  final String? _currentUserId;

  EntitiesNotifier(this._repository, this._currentUserId) : super(const EntitiesState());

  /// Fetches entities based on optional category and search query.
  Future<void> fetchEntities({int? categoryId, String? searchQuery, bool forceRefresh = false}) async {
    if (_currentUserId == null) {
      state = state.copyWith(error: 'User not authenticated');
      return;
    }

    // Only fetch if parameters change or forceRefresh is true
    if (!forceRefresh &&
        state.lastCategoryId == categoryId &&
        state.lastSearchQuery == searchQuery &&
        !state.isLoading &&
        state.error == null &&
        state.entities.isNotEmpty) {
      return; // Data is already cached and up-to-date
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final fetchedEntities = await _repository.fetchEntities(
        userId: _currentUserId,
        categoryId: categoryId,
        searchQuery: searchQuery,
        includeShared: true, // Always include shared entities for the current user
      );
      state = state.copyWith(
        entities: fetchedEntities,
        isLoading: false,
        lastCategoryId: categoryId,
        lastSearchQuery: searchQuery,
      );
    } catch (e, st) {
      Logger.error('Failed to fetch entities', e, st);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Creates a new entity.
  Future<void> createEntity(SimpleEntityModel entity, {Uint8List? imageBytes, String? imageFileName}) async {
    if (_currentUserId == null) {
      state = state.copyWith(error: 'User not authenticated');
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newEntity = await _repository.createEntity(entity, imageBytes: imageBytes, imageFileName: imageFileName);
      state = state.copyWith(
        entities: [...state.entities, newEntity],
        isLoading: false,
      );
    } catch (e, st) {
      Logger.error('Failed to create entity', e, st);
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Updates an existing entity.
  Future<void> updateEntity(SimpleEntityModel entity, {Uint8List? imageBytes, String? imageFileName}) async {
    if (_currentUserId == null) {
      state = state.copyWith(error: 'User not authenticated');
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedEntity = await _repository.updateEntity(entity, imageBytes: imageBytes, imageFileName: imageFileName);
      state = state.copyWith(
        entities: state.entities.map((e) => e.id == updatedEntity.id ? updatedEntity : e).toList(),
        isLoading: false,
      );
    } catch (e, st) {
      Logger.error('Failed to update entity', e, st);
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Deletes an entity.
  Future<void> deleteEntity(String entityId) async {
    if (_currentUserId == null) {
      state = state.copyWith(error: 'User not authenticated');
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.deleteEntity(entityId);
      state = state.copyWith(
        entities: state.entities.where((e) => e.id != entityId).toList(),
        isLoading: false,
      );
    } catch (e, st) {
      Logger.error('Failed to delete entity', e, st);
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Performs bulk deletion of entities.
  Future<void> bulkDeleteEntities(List<String> entityIds) async {
    if (_currentUserId == null) {
      state = state.copyWith(error: 'User not authenticated');
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.bulkDeleteEntities(entityIds);
      state = state.copyWith(
        entities: state.entities.where((e) => !entityIds.contains(e.id)).toList(),
        isLoading: false,
      );
    } catch (e, st) {
      Logger.error('Failed to bulk delete entities', e, st);
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Adds a member to an entity.
  Future<void> addEntityMember(String entityId, String memberId, String role) async {
    if (_currentUserId == null) {
      state = state.copyWith(error: 'User not authenticated');
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.addEntityMember(entityId, memberId, role);
      // Refresh the specific entity to reflect new members
      await fetchEntities(forceRefresh: true); // Simpler to refetch all for now
      state = state.copyWith(isLoading: false);
    } catch (e, st) {
      Logger.error('Failed to add entity member', e, st);
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Removes a member from an entity.
  Future<void> removeEntityMember(String entityId, String memberId) async {
    if (_currentUserId == null) {
      state = state.copyWith(error: 'User not authenticated');
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.removeEntityMember(entityId, memberId);
      // Refresh the specific entity to reflect removed members
      await fetchEntities(forceRefresh: true); // Simpler to refetch all for now
      state = state.copyWith(isLoading: false);
    } catch (e, st) {
      Logger.error('Failed to remove entity member', e, st);
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Searches entities by name or notes.
  Future<void> searchEntities(String query) async {
    await fetchEntities(searchQuery: query, forceRefresh: true);
  }

  /// Gets a single entity by ID from the current state.
  SimpleEntityModel? getEntityById(String id) {
    try {
      return state.entities.firstWhere((entity) => entity.id == id);
    } catch (e) {
      return null;
    }
  }
}

/// Main entities provider.
final entitiesProvider = StateNotifierProvider<EntitiesNotifier, EntitiesState>((ref) {
  final repository = ref.watch(entitiesRepositoryProvider);
  final currentUserId = ref.watch(userIdProvider);
  return EntitiesNotifier(repository, currentUserId);
});

/// Provider for filtered entities based on category.
final filteredEntitiesProvider = Provider.family<List<SimpleEntityModel>, int?>((ref, categoryId) {
  final entitiesState = ref.watch(entitiesProvider);
  if (categoryId == null) {
    return entitiesState.entities;
  }
  return entitiesState.entities.where((entity) => entity.categoryId == categoryId).toList();
});

/// Provider for a single entity by ID.
final entityByIdProvider = Provider.family<SimpleEntityModel?, String>((ref, entityId) {
  final entitiesState = ref.watch(entitiesProvider);
  try {
    return entitiesState.entities.firstWhere((entity) => entity.id == entityId);
  } catch (e) {
    return null;
  }
});

/// Provider for entities owned by the current user.
final ownedEntitiesProvider = Provider<List<SimpleEntityModel>>((ref) {
  final entitiesState = ref.watch(entitiesProvider);
  final currentUserId = ref.watch(userIdProvider);
  if (currentUserId == null) return [];
  
  return entitiesState.entities.where((entity) => entity.ownerId == currentUserId).toList();
});

/// Provider for entities shared with the current user.
final sharedEntitiesProvider = Provider<List<SimpleEntityModel>>((ref) {
  final entitiesState = ref.watch(entitiesProvider);
  final currentUserId = ref.watch(userIdProvider);
  if (currentUserId == null) return [];
  
  return entitiesState.entities.where((entity) => 
    entity.ownerId != currentUserId && 
    entity.members.any((member) => member.userId == currentUserId)
  ).toList();
});

/// Provider for entities by type.
final entitiesByTypeProvider = Provider.family<List<SimpleEntityModel>, EntityType>((ref, type) {
  final entitiesState = ref.watch(entitiesProvider);
  return entitiesState.entities.where((entity) => entity.type == type).toList();
});

/// Provider for entity loading state
final entitiesLoadingProvider = Provider<bool>((ref) {
  return ref.watch(entitiesProvider).isLoading;
});

/// Provider for entity error state
final entitiesErrorProvider = Provider<String?>((ref) {
  return ref.watch(entitiesProvider).error;
});
