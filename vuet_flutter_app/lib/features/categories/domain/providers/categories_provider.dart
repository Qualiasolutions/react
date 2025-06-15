import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vuet_flutter/core/utils/error_handler.dart';
import 'package:vuet_flutter/features/auth/domain/providers/auth_provider.dart';
import 'package:vuet_flutter/features/categories/data/models/category_model.dart';
import 'package:vuet_flutter/features/categories/data/repositories/categories_repository.dart';

/// Represents the state of the categories system.
/// This will hold both core categories and user-specific professional categories.
class CategoriesState {
  final List<CategoryModel> coreCategories;
  final List<ProfessionalCategoryModel> professionalCategories;
  final bool isLoading;
  final String? errorMessage;

  CategoriesState({
    this.coreCategories = const [],
    this.professionalCategories = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  CategoriesState copyWith({
    List<CategoryModel>? coreCategories,
    List<ProfessionalCategoryModel>? professionalCategories,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CategoriesState(
      coreCategories: coreCategories ?? this.coreCategories,
      professionalCategories: professionalCategories ?? this.professionalCategories,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Notifier for managing the state of categories.
class CategoriesNotifier extends AsyncNotifier<CategoriesState> {
  late final CategoriesRepository _categoriesRepository;
  late final String? _currentUserId;

  @override
  Future<CategoriesState> build() async {
    _categoriesRepository = ref.watch(categoriesRepositoryProvider);
    _currentUserId = ref.watch(currentUserProvider.select((user) => user?.id));

    if (_currentUserId == null) {
      // If no user is logged in, return initial state with only core categories
      final core = await _categoriesRepository.getAllCategories();
      return CategoriesState(coreCategories: core);
    }

    // Fetch initial data
    final coreCategories = await _categoriesRepository.getAllCategories();
    final professionalCategories = await _categoriesRepository.getProfessionalCategories(_currentUserId!);

    // Listen to real-time updates for professional categories
    ref.listen(professionalCategoriesStreamProvider, (previous, next) {
      if (next.hasValue) {
        state = AsyncValue.data(state.value!.copyWith(professionalCategories: next.value!));
      } else if (next.hasError) {
        ErrorHandler.reportError(
          'Error in professional categories stream',
          next.error,
          stackTrace: next.stackTrace,
        );
        state = AsyncValue.error(next.error!, next.stackTrace!);
      }
    });

    return CategoriesState(
      coreCategories: coreCategories,
      professionalCategories: professionalCategories,
    );
  }

  /// Creates a new professional category.
  Future<void> createProfessionalCategory(String name) async {
    if (_currentUserId == null) {
      ErrorHandler.reportError('Attempted to create professional category without authenticated user', null);
      state = AsyncValue.error('User not authenticated.', StackTrace.current);
      return;
    }

    state = AsyncValue.data(state.value!.copyWith(isLoading: true, errorMessage: null));
    try {
      await _categoriesRepository.createProfessionalCategory(name);
      // The stream listener will update the state automatically
      state = AsyncValue.data(state.value!.copyWith(isLoading: false));
    } catch (e, stackTrace) {
      ErrorHandler.reportError('Failed to create professional category', e, stackTrace: stackTrace);
      state = AsyncValue.error(ErrorHandler.handleSupabaseError(e), stackTrace);
    }
  }

  /// Updates an existing professional category.
  Future<void> updateProfessionalCategory(ProfessionalCategoryModel category) async {
    if (_currentUserId == null) {
      ErrorHandler.reportError('Attempted to update professional category without authenticated user', null);
      state = AsyncValue.error('User not authenticated.', StackTrace.current);
      return;
    }

    state = AsyncValue.data(state.value!.copyWith(isLoading: true, errorMessage: null));
    try {
      await _categoriesRepository.updateProfessionalCategory(category);
      // The stream listener will update the state automatically
      state = AsyncValue.data(state.value!.copyWith(isLoading: false));
    } catch (e, stackTrace) {
      ErrorHandler.reportError('Failed to update professional category', e, stackTrace: stackTrace);
      state = AsyncValue.error(ErrorHandler.handleSupabaseError(e), stackTrace);
    }
  }

  /// Deletes a professional category.
  Future<void> deleteProfessionalCategory(int categoryId) async {
    if (_currentUserId == null) {
      ErrorHandler.reportError('Attempted to delete professional category without authenticated user', null);
      state = AsyncValue.error('User not authenticated.', StackTrace.current);
      return;
    }

    state = AsyncValue.data(state.value!.copyWith(isLoading: true, errorMessage: null));
    try {
      await _categoriesRepository.deleteProfessionalCategory(categoryId);
      // The stream listener will update the state automatically
      state = AsyncValue.data(state.value!.copyWith(isLoading: false));
    } catch (e, stackTrace) {
      ErrorHandler.reportError('Failed to delete professional category', e, stackTrace: stackTrace);
      state = AsyncValue.error(ErrorHandler.handleSupabaseError(e), stackTrace);
    }
  }
}

/// Main provider for the categories system.
final categoriesProvider = AsyncNotifierProvider<CategoriesNotifier, CategoriesState>(
  CategoriesNotifier.new,
);

/// Provider for accessing all core categories.
final allCoreCategoriesProvider = Provider<List<CategoryModel>>((ref) {
  return ref.watch(categoriesProvider).value?.coreCategories ?? [];
});

/// Provider for accessing professional categories for the current user.
final userProfessionalCategoriesProvider = Provider<List<ProfessionalCategoryModel>>((ref) {
  return ref.watch(categoriesProvider).value?.professionalCategories ?? [];
});

/// Provider for checking if categories data is loading.
final categoriesLoadingProvider = Provider<bool>((ref) {
  return ref.watch(categoriesProvider).isLoading;
});

/// Provider for accessing categories error messages.
final categoriesErrorProvider = Provider<String?>((ref) {
  return ref.watch(categoriesProvider).error?.toString();
});
