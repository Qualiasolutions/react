import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart'; // Required for kDebugMode if used

part 'category_model.freezed.dart';
part 'category_model.g.dart';

/// Enum representing the fixed core category names in the application.
/// These correspond to the `name` field in the `categories` table.
enum CategoryName {
  @JsonValue('FAMILY')
  family,
  @JsonValue('PETS')
  pets,
  @JsonValue('SOCIAL_INTERESTS')
  socialInterests,
  @JsonValue('EDUCATION')
  education,
  @JsonValue('CAREER')
  career,
  @JsonValue('TRAVEL')
  travel,
  @JsonValue('HEALTH_BEAUTY')
  healthBeauty,
  @JsonValue('HOME')
  home,
  @JsonValue('GARDEN')
  garden,
  @JsonValue('FOOD')
  food,
  @JsonValue('LAUNDRY')
  laundry,
  @JsonValue('FINANCE')
  finance,
  @JsonValue('TRANSPORT')
  transport,
}

/// Data model for a core category.
/// These are predefined categories in the application.
@freezed
class CategoryModel with _$CategoryModel {
  const factory CategoryModel({
    required int id,
    required CategoryName name,
    required String readableName,
    @Default(false) bool isPremium,
    @Default(true) bool isEnabled,
  }) = _CategoryModel;

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);
}

/// Data model for a professional category.
/// These are user-defined categories for professional entities.
@freezed
class ProfessionalCategoryModel with _$ProfessionalCategoryModel {
  const factory ProfessionalCategoryModel({
    required int id,
    @JsonKey(name: 'user_id') required String userId,
    required String name,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _ProfessionalCategoryModel;

  factory ProfessionalCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$ProfessionalCategoryModelFromJson(json);
}

/// Constants for the predefined core categories, matching their IDs and names.
/// These are used for seeding the database and for consistent lookup.
class AppCategories {
  static const CategoryModel family = CategoryModel(
    id: 1,
    name: CategoryName.family,
    readableName: 'Family',
    isPremium: false,
    isEnabled: true,
  );
  static const CategoryModel pets = CategoryModel(
    id: 2,
    name: CategoryName.pets,
    readableName: 'Pets',
    isPremium: false,
    isEnabled: true,
  );
  static const CategoryModel socialInterests = CategoryModel(
    id: 3,
    name: CategoryName.socialInterests,
    readableName: 'Social & Interests',
    isPremium: false,
    isEnabled: true,
  );
  static const CategoryModel education = CategoryModel(
    id: 4,
    name: CategoryName.education,
    readableName: 'Education',
    isPremium: false,
    isEnabled: true,
  );
  static const CategoryModel career = CategoryModel(
    id: 5,
    name: CategoryName.career,
    readableName: 'Career',
    isPremium: false,
    isEnabled: true,
  );
  static const CategoryModel travel = CategoryModel(
    id: 6,
    name: CategoryName.travel,
    readableName: 'Travel',
    isPremium: false,
    isEnabled: true,
  );
  static const CategoryModel healthBeauty = CategoryModel(
    id: 7,
    name: CategoryName.healthBeauty,
    readableName: 'Health & Beauty',
    isPremium: true, // Assuming premium based on original app's structure
    isEnabled: true,
  );
  static const CategoryModel home = CategoryModel(
    id: 8,
    name: CategoryName.home,
    readableName: 'Home',
    isPremium: true, // Assuming premium
    isEnabled: true,
  );
  static const CategoryModel garden = CategoryModel(
    id: 9,
    name: CategoryName.garden,
    readableName: 'Garden',
    isPremium: true, // Assuming premium
    isEnabled: true,
  );
  static const CategoryModel food = CategoryModel(
    id: 10,
    name: CategoryName.food,
    readableName: 'Food',
    isPremium: true, // Assuming premium
    isEnabled: true,
  );
  static const CategoryModel laundry = CategoryModel(
    id: 11,
    name: CategoryName.laundry,
    readableName: 'Laundry',
    isPremium: true, // Assuming premium
    isEnabled: true,
  );
  static const CategoryModel finance = CategoryModel(
    id: 12,
    name: CategoryName.finance,
    readableName: 'Finance',
    isPremium: true, // Assuming premium
    isEnabled: true,
  );
  static const CategoryModel transport = CategoryModel(
    id: 13,
    name: CategoryName.transport,
    readableName: 'Transport',
    isPremium: true, // Assuming premium
    isEnabled: true,
  );

  /// A list of all predefined core categories.
  static const List<CategoryModel> allCategories = [
    family,
    pets,
    socialInterests,
    education,
    career,
    travel,
    healthBeauty,
    home,
    garden,
    food,
    laundry,
    finance,
    transport,
  ];

  /// Get a category by its ID.
  static CategoryModel? getCategoryById(int id) {
    try {
      return allCategories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null; // Category not found
    }
  }

  /// Get a category by its name.
  static CategoryModel? getCategoryByName(CategoryName name) {
    try {
      return allCategories.firstWhere((category) => category.name == name);
    } catch (e) {
      return null; // Category not found
    }
  }
}
