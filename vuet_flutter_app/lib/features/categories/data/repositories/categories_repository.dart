import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vuet_flutter/core/config/supabase_config.dart';
import 'package:vuet_flutter/core/utils/error_handler.dart';
import 'package:vuet_flutter/features/auth/domain/providers/auth_provider.dart';
import 'package:vuet_flutter/features/categories/data/models/category_model.dart';

/// Provider for the CategoriesRepository
final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  return CategoriesRepository(ref);
});

/// Provider for streaming all core categories
final allCategoriesStreamProvider = StreamProvider<List<CategoryModel>>((ref) {
  final repository = ref.watch(categoriesRepositoryProvider);
  return repository.watchAllCategories();
});

/// Provider for streaming professional categories for the current user
final professionalCategoriesStreamProvider =
    StreamProvider<List<ProfessionalCategoryModel>>((ref) {
  final repository = ref.watch(categoriesRepositoryProvider);
  final userId = ref.watch(currentUserProvider.select((user) => user?.id));

  if (userId == null) {
    return Stream.value([]); // Return empty list if no user is logged in
  }
  return repository.watchProfessionalCategories(userId);
});

/// Repository for handling all category-related operations,
/// including core categories and user-defined professional categories.
class CategoriesRepository {
  final Ref _ref;
  final SupabaseClient _supabase;

  CategoriesRepository(this._ref) : _supabase = SupabaseConfig.client;

  /// Fetches all predefined core categories from the database.
  /// These are static and seeded.
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final response = await _supabase.from('categories').select();
      return response
          .map((json) => CategoryModel.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      ErrorHandler.reportError(
        'Failed to fetch all categories',
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Watches for changes in all core categories (for real-time updates if needed, though less common for static data).
  Stream<List<CategoryModel>> watchAllCategories() {
    return _supabase
        .from('categories')
        .stream(primaryKey: ['id'])
        .map((data) => data.map((json) => CategoryModel.fromJson(json)).toList())
        .handleError((e, stackTrace) {
          ErrorHandler.reportError(
            'Error watching all categories',
            e,
            stackTrace: stackTrace,
          );
        });
  }

  /// Fetches professional categories for a specific user.
  Future<List<ProfessionalCategoryModel>> getProfessionalCategories(
      String userId) async {
    try {
      final response = await _supabase
          .from('professional_categories')
          .select()
          .eq('user_id', userId);
      return response
          .map((json) => ProfessionalCategoryModel.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      ErrorHandler.reportError(
        'Failed to fetch professional categories for user $userId',
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Watches for real-time changes in professional categories for a specific user.
  Stream<List<ProfessionalCategoryModel>> watchProfessionalCategories(
      String userId) {
    return _supabase
        .from('professional_categories')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((data) =>
            data.map((json) => ProfessionalCategoryModel.fromJson(json)).toList())
        .handleError((e, stackTrace) {
          ErrorHandler.reportError(
            'Error watching professional categories for user $userId',
            e,
            stackTrace: stackTrace,
          );
        });
  }

  /// Creates a new professional category for the current user.
  Future<ProfessionalCategoryModel> createProfessionalCategory(String name) async {
    try {
      final userId = _ref.read(currentUserProvider)?.id;
      if (userId == null) {
        throw Exception('User not authenticated.');
      }

      final response = await _supabase
          .from('professional_categories')
          .insert({
            'user_id': userId,
            'name': name,
          })
          .select()
          .single();

      return ProfessionalCategoryModel.fromJson(response);
    } catch (e, stackTrace) {
      ErrorHandler.reportError(
        'Failed to create professional category: $name',
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Updates an existing professional category.
  Future<ProfessionalCategoryModel> updateProfessionalCategory(
      ProfessionalCategoryModel category) async {
    try {
      final userId = _ref.read(currentUserProvider)?.id;
      if (userId == null) {
        throw Exception('User not authenticated.');
      }

      final response = await _supabase
          .from('professional_categories')
          .update({
            'name': category.name,
          })
          .eq('id', category.id)
          .eq('user_id', userId) // Ensure user owns the category
          .select()
          .single();

      return ProfessionalCategoryModel.fromJson(response);
    } catch (e, stackTrace) {
      ErrorHandler.reportError(
        'Failed to update professional category: ${category.name}',
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Deletes a professional category by its ID.
  Future<void> deleteProfessionalCategory(int categoryId) async {
    try {
      final userId = _ref.read(currentUserProvider)?.id;
      if (userId == null) {
        throw Exception('User not authenticated.');
      }

      await _supabase
          .from('professional_categories')
          .delete()
          .eq('id', categoryId)
          .eq('user_id', userId); // Ensure user owns the category
    } catch (e, stackTrace) {
      ErrorHandler.reportError(
        'Failed to delete professional category with ID: $categoryId',
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
