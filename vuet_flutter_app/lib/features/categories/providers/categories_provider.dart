// lib/features/categories/providers/categories_provider.dart
// Provider for managing categories and professional categories

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vuet_flutter/core/constants/app_constants.dart';
import 'package:vuet_flutter/core/utils/logger.dart';
import 'package:vuet_flutter/features/auth/providers/auth_provider.dart';

/// Category model representing a core category
class Category {
  final int id;
  final String name;
  final String readableName;
  final bool isPremium;
  final bool isEnabled;
  final IconData icon;
  final Color color;

  Category({
    required this.id,
    required this.name,
    required this.readableName,
    this.isPremium = false,
    this.isEnabled = true,
    required this.icon,
    required this.color,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int;
    return Category(
      id: id,
      name: json['name'] as String,
      readableName: json['readable_name'] as String,
      isPremium: json['is_premium'] as bool? ?? false,
      isEnabled: json['is_enabled'] as bool? ?? true,
      // Get icon and color from constants
      icon: Categories.icons[id] ?? Icons.category,
      color: Categories.colors[id] ?? Colors.grey,
    );
  }
}

/// Professional category model
class ProfessionalCategory {
  final int id;
  final String userId;
  final String name;
  final DateTime createdAt;
  final int entityCount; // Not stored, calculated on fetch

  ProfessionalCategory({
    required this.id,
    required this.userId,
    required this.name,
    required this.createdAt,
    this.entityCount = 0,
  });

  factory ProfessionalCategory.fromJson(Map<String, dynamic> json) {
    return ProfessionalCategory(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      entityCount: json['entity_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ProfessionalCategory copyWith({
    int? id,
    String? userId,
    String? name,
    DateTime? createdAt,
    int? entityCount,
  }) {
    return ProfessionalCategory(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      entityCount: entityCount ?? this.entityCount,
    );
  }
}

/// State for core categories
class CategoriesState {
  final List<Category> categories;
  final bool isLoading;
  final String? error;

  const CategoriesState({
    this.categories = const [],
    this.isLoading = false,
    this.error,
  });

  CategoriesState copyWith({
    List<Category>? categories,
    bool? isLoading,
    String? error,
  }) {
    return CategoriesState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// State for professional categories
class ProfessionalCategoriesState {
  final List<ProfessionalCategory> categories;
  final bool isLoading;
  final String? error;

  const ProfessionalCategoriesState({
    this.categories = const [],
    this.isLoading = false,
    this.error,
  });

  ProfessionalCategoriesState copyWith({
    List<ProfessionalCategory>? categories,
    bool? isLoading,
    String? error,
  }) {
    return ProfessionalCategoriesState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for core categories
class CategoriesNotifier extends StateNotifier<CategoriesState> {
  final SupabaseClient _supabase;

  CategoriesNotifier(this._supabase) : super(const CategoriesState()) {
    fetchCategories();
  }

  /// Fetch categories from Supabase
  Future<void> fetchCategories() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Fetch categories from Supabase
      final response = await _supabase.from('categories').select().order('id');

      // Parse response
      final categories = (response as List)
          .map((json) => Category.fromJson(json))
          .toList();

      state = state.copyWith(
        categories: categories,
        isLoading: false,
      );
    } catch (e, st) {
      Logger.error('Failed to fetch categories', e, st);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Get category by ID
  Category? getCategoryById(int id) {
    try {
      return state.categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get category by name
  Category? getCategoryByName(String name) {
    try {
      return state.categories.firstWhere(
        (category) => category.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
}

/// Notifier for professional categories
class ProfessionalCategoriesNotifier extends StateNotifier<ProfessionalCategoriesState> {
  final SupabaseClient _supabase;
  final String userId;

  ProfessionalCategoriesNotifier(this._supabase, this.userId)
      : super(const ProfessionalCategoriesState()) {
    fetchProfessionalCategories();
  }

  /// Fetch professional categories from Supabase
  Future<void> fetchProfessionalCategories() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Fetch professional categories with entity count
      final response = await _supabase
          .rpc('get_professional_categories_with_count', params: {
        'user_id_param': userId,
      });

      // Parse response
      final categories = (response as List)
          .map((json) => ProfessionalCategory.fromJson(json))
          .toList();

      state = state.copyWith(
        categories: categories,
        isLoading: false,
      );
    } catch (e, st) {
      Logger.error('Failed to fetch professional categories', e, st);
      
      // Try fallback method if RPC fails
      try {
        // Fetch just the categories without counts
        final response = await _supabase
            .from('professional_categories')
            .select()
            .eq('user_id', userId)
            .order('name');

        // Parse response
        final categories = (response as List)
            .map((json) => ProfessionalCategory.fromJson(json))
            .toList();

        state = state.copyWith(
          categories: categories,
          isLoading: false,
        );
      } catch (fallbackError, fallbackSt) {
        Logger.error('Fallback fetch also failed', fallbackError, fallbackSt);
        state = state.copyWith(
          isLoading: false,
          error: e.toString(),
        );
      }
    }
  }

  /// Create a new professional category
  Future<void> createProfessionalCategory(String name) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Create new professional category
      final response = await _supabase.from('professional_categories').insert({
        'user_id': userId,
        'name': name,
      }).select().single();

      // Add to state
      final newCategory = ProfessionalCategory.fromJson(response);
      state = state.copyWith(
        categories: [...state.categories, newCategory],
        isLoading: false,
      );
    } catch (e, st) {
      Logger.error('Failed to create professional category', e, st);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Update a professional category
  Future<void> updateProfessionalCategory(int id, String name) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Update professional category
      await _supabase
          .from('professional_categories')
          .update({'name': name})
          .eq('id', id)
          .eq('user_id', userId);

      // Update in state
      final updatedCategories = state.categories.map((category) {
        if (category.id == id) {
          return category.copyWith(name: name);
        }
        return category;
      }).toList();

      state = state.copyWith(
        categories: updatedCategories,
        isLoading: false,
      );
    } catch (e, st) {
      Logger.error('Failed to update professional category', e, st);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Delete a professional category
  Future<void> deleteProfessionalCategory(int id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Delete professional category
      await _supabase
          .from('professional_categories')
          .delete()
          .eq('id', id)
          .eq('user_id', userId);

      // Remove from state
      final updatedCategories = state.categories
          .where((category) => category.id != id)
          .toList();

      state = state.copyWith(
        categories: updatedCategories,
        isLoading: false,
      );
    } catch (e, st) {
      Logger.error('Failed to delete professional category', e, st);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Get professional category by ID
  ProfessionalCategory? getProfessionalCategoryById(int id) {
    try {
      return state.categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }
}

/// Provider for core categories
final categoriesProvider = StateNotifierProvider<CategoriesNotifier, CategoriesState>((ref) {
  return CategoriesNotifier(Supabase.instance.client);
});

/// Provider for professional categories
final professionalCategoriesProvider = StateNotifierProvider<ProfessionalCategoriesNotifier, ProfessionalCategoriesState>((ref) {
  final userId = ref.watch(userIdProvider);
  if (userId == null) {
    throw Exception('User ID is null, cannot fetch professional categories');
  }
  return ProfessionalCategoriesNotifier(Supabase.instance.client, userId);
});

/// Provider for a specific category by ID
final categoryByIdProvider = Provider.family<Category?, int>((ref, id) {
  return ref.watch(categoriesProvider.notifier).getCategoryById(id);
});

/// Provider for entities count by category
final entityCountByCategoryProvider = FutureProvider.family<int, int>((ref, categoryId) async {
  final supabase = Supabase.instance.client;
  try {
    final response = await supabase.rpc(
      'get_entity_count_by_category',
      params: {'category_id_param': categoryId},
    );
    return response as int? ?? 0;
  } catch (e, st) {
    Logger.error('Failed to get entity count for category $categoryId', e, st);
    return 0;
  }
});
