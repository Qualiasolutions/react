// lib/features/categories/providers/categories_provider.dart
// Categories provider that replicates the Redux categories slice from React Native

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vuet_flutter/core/constants/app_constants.dart';
import 'package:vuet_flutter/core/utils/logger.dart';
import 'package:vuet_flutter/features/auth/providers/auth_provider.dart';

/// Category model representing a core or professional category
class Category {
  final int id;
  final String name;
  final String readableName;
  final bool isPremium;
  final IconData icon;
  final Color color;
  final bool isProfessional;
  final String? userId; // Only for professional categories

  const Category({
    required this.id,
    required this.name,
    required this.readableName,
    this.isPremium = false,
    required this.icon,
    required this.color,
    this.isProfessional = false,
    this.userId,
  });

  /// Create from Supabase JSON response for core categories
  factory Category.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int;
    return Category(
      id: id,
      name: json['name'] as String,
      readableName: json['readable_name'] as String,
      isPremium: json['is_premium'] as bool? ?? false,
      // Get icon and color from constants based on id
      icon: Categories.icons[id] ?? Icons.category,
      color: Categories.colors[id] ?? const Color(0xFF9E9E9E),
    );
  }

  /// Create from Supabase JSON response for professional categories
  factory Category.fromProfessionalJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      readableName: json['name'] as String, // Same as name for professional categories
      isProfessional: true,
      userId: json['user_id'] as String?,
      // Professional categories use a default icon and color
      icon: Icons.work,
      color: const Color(0xFF607D8B), // Blue Grey
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'readable_name': readableName,
      'is_premium': isPremium,
    };
  }

  /// Convert professional category to JSON for Supabase
  Map<String, dynamic> toProfessionalJson() {
    return {
      'name': name,
      'user_id': userId,
    };
  }
}

/// Categories state class
class CategoriesState {
  final List<Category> coreCategories;
  final List<Category> professionalCategories;
  final bool isLoading;
  final String? error;

  const CategoriesState({
    this.coreCategories = const [],
    this.professionalCategories = const [],
    this.isLoading = false,
    this.error,
  });

  /// Create a loading state
  CategoriesState loading() {
    return CategoriesState(
      coreCategories: coreCategories,
      professionalCategories: professionalCategories,
      isLoading: true,
      error: null,
    );
  }

  /// Create an error state
  CategoriesState withError(String errorMessage) {
    return CategoriesState(
      coreCategories: coreCategories,
      professionalCategories: professionalCategories,
      isLoading: false,
      error: errorMessage,
    );
  }

  /// Create a state with updated core categories
  CategoriesState withCoreCategories(List<Category> categories) {
    return CategoriesState(
      coreCategories: categories,
      professionalCategories: professionalCategories,
      isLoading: false,
      error: null,
    );
  }

  /// Create a state with updated professional categories
  CategoriesState withProfessionalCategories(List<Category> categories) {
    return CategoriesState(
      coreCategories: coreCategories,
      professionalCategories: categories,
      isLoading: false,
      error: null,
    );
  }

  /// Get all categories (core + professional)
  List<Category> get allCategories => [...coreCategories, ...professionalCategories];

  /// Check if a category exists by ID
  bool hasCategory(int id) {
    return allCategories.any((category) => category.id == id);
  }

  /// Get a category by ID
  Category? getCategoryById(int id) {
    try {
      return allCategories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }
}

/// Categories notifier for state management
class CategoriesNotifier extends StateNotifier<CategoriesState> {
  final SupabaseClient _supabase;
  final String? _userId;

  CategoriesNotifier(this._supabase, this._userId) : super(const CategoriesState()) {
    // Load categories on initialization
    if (_userId != null) {
      fetchAllCategories();
    }
  }

  /// Fetch all categories (core + professional)
  Future<void> fetchAllCategories() async {
    await Future.wait([
      fetchCoreCategories(),
      fetchProfessionalCategories(),
    ]);
  }

  /// Fetch core categories from Supabase
  Future<void> fetchCoreCategories() async {
    try {
      state = state.loading();

      final response = await _supabase
          .from('categories')
          .select()
          .order('id', ascending: true);

      if (response == null) {
        state = state.withError('Failed to load categories');
        return;
      }

      final categories = List<Map<String, dynamic>>.from(response)
          .map((data) => Category.fromJson(data))
          .toList();

      state = state.withCoreCategories(categories);
    } catch (e, st) {
      Logger.error('Failed to fetch core categories', e, st);
      state = state.withError('Failed to load categories: ${e.toString()}');
    }
  }

  /// Fetch professional categories from Supabase
  Future<void> fetchProfessionalCategories() async {
    if (_userId == null) return;

    try {
      final response = await _supabase
          .from('professional_categories')
          .select()
          .eq('user_id', _userId)
          .order('name', ascending: true);

      if (response == null) {
        return;
      }

      final categories = List<Map<String, dynamic>>.from(response)
          .map((data) => Category.fromProfessionalJson(data))
          .toList();

      state = state.withProfessionalCategories(categories);
    } catch (e, st) {
      Logger.error('Failed to fetch professional categories', e, st);
      // Don't update error state here to avoid overriding core categories error
    }
  }

  /// Create a new professional category
  Future<void> createProfessionalCategory(String name) async {
    if (_userId == null) return;

    try {
      state = state.loading();

      final data = {
        'name': name,
        'user_id': _userId,
      };

      final response = await _supabase
          .from('professional_categories')
          .insert(data)
          .select()
          .single();

      if (response == null) {
        state = state.withError('Failed to create category');
        return;
      }

      final newCategory = Category.fromProfessionalJson(response);
      final updatedCategories = [...state.professionalCategories, newCategory];

      state = state.withProfessionalCategories(updatedCategories);
    } catch (e, st) {
      Logger.error('Failed to create professional category', e, st);
      state = state.withError('Failed to create category: ${e.toString()}');
    }
  }

  /// Update a professional category
  Future<void> updateProfessionalCategory(int id, String name) async {
    if (_userId == null) return;

    try {
      state = state.loading();

      final data = {
        'name': name,
      };

      await _supabase
          .from('professional_categories')
          .update(data)
          .eq('id', id)
          .eq('user_id', _userId);

      // Update the category in the state
      final updatedCategories = state.professionalCategories.map((category) {
        if (category.id == id) {
          return Category(
            id: category.id,
            name: name,
            readableName: name,
            icon: category.icon,
            color: category.color,
            isProfessional: true,
            userId: category.userId,
          );
        }
        return category;
      }).toList();

      state = state.withProfessionalCategories(updatedCategories);
    } catch (e, st) {
      Logger.error('Failed to update professional category', e, st);
      state = state.withError('Failed to update category: ${e.toString()}');
    }
  }

  /// Delete a professional category
  Future<void> deleteProfessionalCategory(int id) async {
    if (_userId == null) return;

    try {
      state = state.loading();

      await _supabase
          .from('professional_categories')
          .delete()
          .eq('id', id)
          .eq('user_id', _userId);

      // Remove the category from the state
      final updatedCategories = state.professionalCategories
          .where((category) => category.id != id)
          .toList();

      state = state.withProfessionalCategories(updatedCategories);
    } catch (e, st) {
      Logger.error('Failed to delete professional category', e, st);
      state = state.withError('Failed to delete category: ${e.toString()}');
    }
  }

  /// Get category by ID (core or professional)
  Category? getCategoryById(int id) {
    return state.getCategoryById(id);
  }

  /// Check if a category exists
  bool hasCategory(int id) {
    return state.hasCategory(id);
  }

  /// Get all categories (core + professional)
  List<Category> get allCategories => state.allCategories;
}

/// Categories provider
final categoriesProvider = StateNotifierProvider<CategoriesNotifier, CategoriesState>((ref) {
  final userId = ref.watch(userIdProvider);
  return CategoriesNotifier(Supabase.instance.client, userId);
});

/// Convenience providers
final allCategoriesProvider = Provider<List<Category>>((ref) {
  return ref.watch(categoriesProvider).allCategories;
});

final coreCategoriesProvider = Provider<List<Category>>((ref) {
  return ref.watch(categoriesProvider).coreCategories;
});

final professionalCategoriesProvider = Provider<List<Category>>((ref) {
  return ref.watch(categoriesProvider).professionalCategories;
});

final categoriesLoadingProvider = Provider<bool>((ref) {
  return ref.watch(categoriesProvider).isLoading;
});

final categoriesErrorProvider = Provider<String?>((ref) {
  return ref.watch(categoriesProvider).error;
});

/// Provider to get a category by ID
final categoryByIdProvider = Provider.family<Category?, int>((ref, id) {
  return ref.watch(categoriesProvider).getCategoryById(id);
});
