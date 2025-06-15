import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

part 'entity_model.freezed.dart';
part 'entity_model.g.dart';

/// Enum representing the different types of entities in the application.
/// This corresponds to the 'type' column in the 'entities' Supabase table.
enum EntityType {
  @JsonValue('CAR')
  car,
  @JsonValue('PET')
  pet,
  @JsonValue('EVENT')
  event,
  @JsonValue('TRIP')
  trip,
  @JsonValue('ANNIVERSARY')
  anniversary,
  @JsonValue('HEALTH')
  health,
  @JsonValue('FOOD')
  food,
  @JsonValue('HOME')
  home,
  @JsonValue('GARDEN')
  garden,
  @JsonValue('LAUNDRY')
  laundry,
  @JsonValue('FINANCE')
  finance,
  @JsonValue('EDUCATION')
  education,
  @JsonValue('CAREER')
  career,
  @JsonValue('LIST')
  list,
  @JsonValue('PROFESSIONAL')
  professional,
  @JsonValue('OTHER')
  other, // For generic or unclassified entities
}

/// Base data model for all entities in the application.
/// This uses Freezed unions to represent polymorphic entity types,
/// mapping to a single 'entities' table in Supabase with a 'type' column
/// and JSONB fields for type-specific data.
@freezed
class EntityModel with _$EntityModel {
  const EntityModel._(); // Private constructor for common methods

  // Base entity - common fields for all entity types
  const factory EntityModel({
    required String id,
    @JsonKey(name: 'owner_id') required String ownerId,
    @JsonKey(name: 'category_id') required int categoryId,
    required EntityType type,
    String? subtype,
    required String name,
    String? notes,
    @JsonKey(name: 'image_path') String? imagePath,
    @Default(false) bool hidden,
    @JsonKey(name: 'parent_id') String? parentId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    
    // JSONB fields for type-specific data
    Map<String, dynamic>? dates,
    @JsonKey(name: 'contact_info') Map<String, dynamic>? contactInfo,
    Map<String, dynamic>? location,
    Map<String, dynamic>? metadata,
  }) = _EntityModel;

  // Car entity
  const factory EntityModel.car({
    required String id,
    @JsonKey(name: 'owner_id') required String ownerId,
    @JsonKey(name: 'category_id') required int categoryId,
    @Default(EntityType.car) EntityType type,
    String? subtype,
    required String name,
    String? notes,
    @JsonKey(name: 'image_path') String? imagePath,
    @Default(false) bool hidden,
    @JsonKey(name: 'parent_id') String? parentId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    
    // Car-specific fields
    String? make,
    String? model,
    int? year,
    @JsonKey(name: 'license_plate') String? licensePlate,
    @JsonKey(name: 'registration_date') DateTime? registrationDate,
    @JsonKey(name: 'insurance_date') DateTime? insuranceDate,
    @JsonKey(name: 'mot_date') DateTime? motDate,
    @JsonKey(name: 'service_date') DateTime? serviceDate,
    
    // Base JSONB fields
    Map<String, dynamic>? dates,
    @JsonKey(name: 'contact_info') Map<String, dynamic>? contactInfo,
    Map<String, dynamic>? location,
    Map<String, dynamic>? metadata,
  }) = CarEntity;

  // Pet entity
  const factory EntityModel.pet({
    required String id,
    @JsonKey(name: 'owner_id') required String ownerId,
    @JsonKey(name: 'category_id') required int categoryId,
    @Default(EntityType.pet) EntityType type,
    String? subtype,
    required String name,
    String? notes,
    @JsonKey(name: 'image_path') String? imagePath,
    @Default(false) bool hidden,
    @JsonKey(name: 'parent_id') String? parentId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    
    // Pet-specific fields
    String? species,
    String? breed,
    @JsonKey(name: 'date_of_birth') DateTime? dateOfBirth,
    @JsonKey(name: 'microchip_number') String? microchipNumber,
    @JsonKey(name: 'vaccination_date') DateTime? vaccinationDate,
    
    // Base JSONB fields
    Map<String, dynamic>? dates,
    @JsonKey(name: 'contact_info') Map<String, dynamic>? contactInfo,
    Map<String, dynamic>? location,
    Map<String, dynamic>? metadata,
  }) = PetEntity;

  // Event entity
  const factory EntityModel.event({
    required String id,
    @JsonKey(name: 'owner_id') required String ownerId,
    @JsonKey(name: 'category_id') required int categoryId,
    @Default(EntityType.event) EntityType type,
    String? subtype,
    required String name,
    String? notes,
    @JsonKey(name: 'image_path') String? imagePath,
    @Default(false) bool hidden,
    @JsonKey(name: 'parent_id') String? parentId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    
    // Event-specific fields
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'end_date') DateTime? endDate,
    String? location,
    String? organizer,
    
    // Base JSONB fields
    Map<String, dynamic>? dates,
    @JsonKey(name: 'contact_info') Map<String, dynamic>? contactInfo,
    @JsonKey(name: 'location') Map<String, dynamic>? locationData,
    Map<String, dynamic>? metadata,
  }) = EventEntity;

  // Trip entity
  const factory EntityModel.trip({
    required String id,
    @JsonKey(name: 'owner_id') required String ownerId,
    @JsonKey(name: 'category_id') required int categoryId,
    @Default(EntityType.trip) EntityType type,
    String? subtype,
    required String name,
    String? notes,
    @JsonKey(name: 'image_path') String? imagePath,
    @Default(false) bool hidden,
    @JsonKey(name: 'parent_id') String? parentId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    
    // Trip-specific fields
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'end_date') DateTime? endDate,
    String? destination,
    @JsonKey(name: 'accommodation_name') String? accommodationName,
    @JsonKey(name: 'accommodation_address') String? accommodationAddress,
    @JsonKey(name: 'booking_reference') String? bookingReference,
    
    // Base JSONB fields
    Map<String, dynamic>? dates,
    @JsonKey(name: 'contact_info') Map<String, dynamic>? contactInfo,
    Map<String, dynamic>? location,
    Map<String, dynamic>? metadata,
  }) = TripEntity;

  // Anniversary entity
  const factory EntityModel.anniversary({
    required String id,
    @JsonKey(name: 'owner_id') required String ownerId,
    @JsonKey(name: 'category_id') required int categoryId,
    @Default(EntityType.anniversary) EntityType type,
    String? subtype,
    required String name,
    String? notes,
    @JsonKey(name: 'image_path') String? imagePath,
    @Default(false) bool hidden,
    @JsonKey(name: 'parent_id') String? parentId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    
    // Anniversary-specific fields
    DateTime? date,
    @JsonKey(name: 'anniversary_type') String? anniversaryType,
    @JsonKey(name: 'recurring_yearly') @Default(true) bool recurringYearly,
    
    // Base JSONB fields
    Map<String, dynamic>? dates,
    @JsonKey(name: 'contact_info') Map<String, dynamic>? contactInfo,
    Map<String, dynamic>? location,
    Map<String, dynamic>? metadata,
  }) = AnniversaryEntity;

  // Health entity
  const factory EntityModel.health({
    required String id,
    @JsonKey(name: 'owner_id') required String ownerId,
    @JsonKey(name: 'category_id') required int categoryId,
    @Default(EntityType.health) EntityType type,
    String? subtype,
    required String name,
    String? notes,
    @JsonKey(name: 'image_path') String? imagePath,
    @Default(false) bool hidden,
    @JsonKey(name: 'parent_id') String? parentId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    
    // Health-specific fields
    @JsonKey(name: 'appointment_date') DateTime? appointmentDate,
    @JsonKey(name: 'provider_name') String? providerName,
    @JsonKey(name: 'medical_condition') String? medicalCondition,
    
    // Base JSONB fields
    Map<String, dynamic>? dates,
    @JsonKey(name: 'contact_info') Map<String, dynamic>? contactInfo,
    Map<String, dynamic>? location,
    Map<String, dynamic>? metadata,
  }) = HealthEntity;

  // Food entity
  const factory EntityModel.food({
    required String id,
    @JsonKey(name: 'owner_id') required String ownerId,
    @JsonKey(name: 'category_id') required int categoryId,
    @Default(EntityType.food) EntityType type,
    String? subtype,
    required String name,
    String? notes,
    @JsonKey(name: 'image_path') String? imagePath,
    @Default(false) bool hidden,
    @JsonKey(name: 'parent_id') String? parentId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    
    // Food-specific fields
    @JsonKey(name: 'recipe_url') String? recipeUrl,
    List<String>? ingredients,
    @JsonKey(name: 'preparation_time') int? preparationTime,
    @JsonKey(name: 'cooking_time') int? cookingTime,
    
    // Base JSONB fields
    Map<String, dynamic>? dates,
    @JsonKey(name: 'contact_info') Map<String, dynamic>? contactInfo,
    Map<String, dynamic>? location,
    Map<String, dynamic>? metadata,
  }) = FoodEntity;

  // Home entity
  const factory EntityModel.home({
    required String id,
    @JsonKey(name: 'owner_id') required String ownerId,
    @JsonKey(name: 'category_id') required int categoryId,
    @Default(EntityType.home) EntityType type,
    String? subtype,
    required String name,
    String? notes,
    @JsonKey(name: 'image_path') String? imagePath,
    @Default(false) bool hidden,
    @JsonKey(name: 'parent_id') String? parentId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    
    // Home-specific fields
    String? address,
    @JsonKey(name: 'property_type') String? propertyType,
    @JsonKey(name: 'move_in_date') DateTime? moveInDate,
    
    // Base JSONB fields
    Map<String, dynamic>? dates,
    @JsonKey(name: 'contact_info') Map<String, dynamic>? contactInfo,
    Map<String, dynamic>? location,
    Map<String, dynamic>? metadata,
  }) = HomeEntity;

  // Garden entity
  const factory EntityModel.garden({
    required String id,
    @JsonKey(name: 'owner_id') required String ownerId,
    @JsonKey(name: 'category_id') required int categoryId,
    @Default(EntityType.garden) EntityType type,
    String? subtype,
    required String name,
    String? notes,
    @JsonKey(name: 'image_path') String? imagePath,
    @Default(false) bool hidden,
    @JsonKey(name: 'parent_id') String? parentId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    
    // Garden-specific fields
    @JsonKey(name: 'plant_type') String? plantType,
    @JsonKey(name: 'planting_date') DateTime? plantingDate,
    @JsonKey(name: 'watering_frequency') int? wateringFrequency,
    
    // Base JSONB fields
    Map<String, dynamic>? dates,
    @JsonKey(name: 'contact_info') Map<String, dynamic>? contactInfo,
    Map<String, dynamic>? location,
    Map<String, dynamic>? metadata,
  }) = GardenEntity;

  // Laundry entity
  const factory EntityModel.laundry({
    required String id,
    @JsonKey(name: 'owner_id') required String ownerId,
    @JsonKey(name: 'category_id') required int categoryId,
    @Default(EntityType.laundry) EntityType type,
    String? subtype,
    required String name,
    String? notes,
    @JsonKey(name: 'image_path') String? imagePath,
    @Default(false) bool hidden,
    @JsonKey(name: 'parent_id') String? parentId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    
    // Laundry-specific fields
    @JsonKey(name: 'fabric_type') String? fabricType,
    @JsonKey(name: 'washing_instructions') String? washingInstructions,
    @JsonKey(name: 'dry_cleaning_only') @Default(false) bool dryCleaningOnly,
    
    // Base JSONB fields
    Map<String, dynamic>? dates,
    @JsonKey(name: 'contact_info') Map<String, dynamic>? contactInfo,
    Map<String, dynamic>? location,
    Map<String, dynamic>? metadata,
  }) = LaundryEntity;

  // Finance entity
  const factory EntityModel.finance({
    required String id,
    @JsonKey(name: 'owner_id') required String ownerId,
    @JsonKey(name: 'category_id') required int categoryId,
    @Default(EntityType.finance) EntityType type,
    String? subtype,
    required String name,
    String? notes,
    @JsonKey(name: 'image_path') String? imagePath,
    @Default(false) bool hidden,
    @JsonKey(name: 'parent_id') String? parentId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    
    // Finance-specific fields
    double? amount,
    String? currency,
    @JsonKey(name: 'due_date') DateTime? dueDate,
    @JsonKey(name: 'payment_status') String? paymentStatus,
    @JsonKey(name: 'account_number') String? accountNumber,
    
    // Base JSONB fields
    Map<String, dynamic>? dates,
    @JsonKey(name: 'contact_info') Map<String, dynamic>? contactInfo,
    Map<String, dynamic>? location,
    Map<String, dynamic>? metadata,
  }) = FinanceEntity;

  // Education entity
  const factory EntityModel.education({
    required String id,
    @JsonKey(name: 'owner_id') required String ownerId,
    @JsonKey(name: 'category_id') required int categoryId,
    @Default(EntityType.education) EntityType type,
    String? subtype,
    required String name,
    String? notes,
    @JsonKey(name: 'image_path') String? imagePath,
    @Default(false) bool hidden,
    @JsonKey(name: 'parent_id') String? parentId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    
    // Education-specific fields
    @JsonKey(name: 'institution_name') String? institutionName,
    @JsonKey(name: 'course_name') String? courseName,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'end_date') DateTime? endDate,
    @JsonKey(name: 'qualification') String? qualification,
    
    // Base JSONB fields
    Map<String, dynamic>? dates,
    @JsonKey(name: 'contact_info') Map<String, dynamic>? contactInfo,
    Map<String, dynamic>? location,
    Map<String, dynamic>? metadata,
  }) = EducationEntity;

  // Career entity
  const factory EntityModel.career({
    required String id,
    @JsonKey(name: 'owner_id') required String ownerId,
    @JsonKey(name: 'category_id') required int categoryId,
    @Default(EntityType.career) EntityType type,
    String? subtype,
    required String name,
    String? notes,
    @JsonKey(name: 'image_path') String? imagePath,
    @Default(false) bool hidden,
    @JsonKey(name: 'parent_id') String? parentId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    
    // Career-specific fields
    @JsonKey(name: 'company_name') String? companyName,
    @JsonKey(name: 'job_title') String? jobTitle,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'end_date') DateTime? endDate,
    @JsonKey(name: 'employment_type') String? employmentType,
    
    // Base JSONB fields
    Map<String, dynamic>? dates,
    @JsonKey(name: 'contact_info') Map<String, dynamic>? contactInfo,
    Map<String, dynamic>? location,
    Map<String, dynamic>? metadata,
  }) = CareerEntity;

  // List entity
  const factory EntityModel.list({
    required String id,
    @JsonKey(name: 'owner_id') required String ownerId,
    @JsonKey(name: 'category_id') required int categoryId,
    @Default(EntityType.list) EntityType type,
    String? subtype,
    required String name,
    String? notes,
    @JsonKey(name: 'image_path') String? imagePath,
    @Default(false) bool hidden,
    @JsonKey(name: 'parent_id') String? parentId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    
    // List-specific fields
    @JsonKey(name: 'list_type') String? listType,
    @JsonKey(name: 'is_template') @Default(false) bool isTemplate,
    List<Map<String, dynamic>>? items,
    
    // Base JSONB fields
    Map<String, dynamic>? dates,
    @JsonKey(name: 'contact_info') Map<String, dynamic>? contactInfo,
    Map<String, dynamic>? location,
    Map<String, dynamic>? metadata,
  }) = ListEntity;

  // Professional entity
  const factory EntityModel.professional({
    required String id,
    @JsonKey(name: 'owner_id') required String ownerId,
    @JsonKey(name: 'category_id') @Default(-1) int categoryId, // Professional entities use -1 as category
    @Default(EntityType.professional) EntityType type,
    String? subtype,
    required String name,
    String? notes,
    @JsonKey(name: 'image_path') String? imagePath,
    @Default(false) bool hidden,
    @JsonKey(name: 'parent_id') String? parentId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    
    // Professional-specific fields
    @JsonKey(name: 'professional_category_id') int? professionalCategoryId,
    @JsonKey(name: 'business_name') String? businessName,
    @JsonKey(name: 'profession') String? profession,
    
    // Base JSONB fields
    Map<String, dynamic>? dates,
    @JsonKey(name: 'contact_info') Map<String, dynamic>? contactInfo,
    Map<String, dynamic>? location,
    Map<String, dynamic>? metadata,
  }) = ProfessionalEntity;

  // Generic entity for types not explicitly modeled
  const factory EntityModel.other({
    required String id,
    @JsonKey(name: 'owner_id') required String ownerId,
    @JsonKey(name: 'category_id') required int categoryId,
    @Default(EntityType.other) EntityType type,
    String? subtype,
    required String name,
    String? notes,
    @JsonKey(name: 'image_path') String? imagePath,
    @Default(false) bool hidden,
    @JsonKey(name: 'parent_id') String? parentId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    
    // Base JSONB fields
    Map<String, dynamic>? dates,
    @JsonKey(name: 'contact_info') Map<String, dynamic>? contactInfo,
    Map<String, dynamic>? location,
    Map<String, dynamic>? metadata,
  }) = OtherEntity;

  // Factory constructor to deserialize from JSON, handling polymorphism
  factory EntityModel.fromJson(Map<String, dynamic> json) {
    final type = _parseEntityType(json['type']);
    
    // Delegate to the appropriate Freezed union constructor based on 'type'
    switch (type) {
      case EntityType.car:
        return EntityModel.car.fromJson(json);
      case EntityType.pet:
        return EntityModel.pet.fromJson(json);
      case EntityType.event:
        return EntityModel.event.fromJson(json);
      case EntityType.trip:
        return EntityModel.trip.fromJson(json);
      case EntityType.anniversary:
        return EntityModel.anniversary.fromJson(json);
      case EntityType.health:
        return EntityModel.health.fromJson(json);
      case EntityType.food:
        return EntityModel.food.fromJson(json);
      case EntityType.home:
        return EntityModel.home.fromJson(json);
      case EntityType.garden:
        return EntityModel.garden.fromJson(json);
      case EntityType.laundry:
        return EntityModel.laundry.fromJson(json);
      case EntityType.finance:
        return EntityModel.finance.fromJson(json);
      case EntityType.education:
        return EntityModel.education.fromJson(json);
      case EntityType.career:
        return EntityModel.career.fromJson(json);
      case EntityType.list:
        return EntityModel.list.fromJson(json);
      case EntityType.professional:
        return EntityModel.professional.fromJson(json);
      case EntityType.other:
      default:
        return EntityModel.other.fromJson(json);
    }
  }

  // Helper to parse entity type from JSON
  static EntityType _parseEntityType(dynamic typeValue) {
    if (typeValue == null) return EntityType.other;
    
    try {
      if (typeValue is EntityType) return typeValue;
      
      if (typeValue is String) {
        return EntityType.values.firstWhere(
          (e) => e.toString().split('.').last.toUpperCase() == typeValue.toUpperCase(),
          orElse: () => EntityType.other,
        );
      }
    } catch (_) {
      // Fallback to other if parsing fails
    }
    
    return EntityType.other;
  }

  // Helper to get the display name of the entity
  String get displayName => name;

  // Helper to get the icon for the entity type
  IconData get icon {
    switch (type) {
      case EntityType.car:
        return Icons.directions_car;
      case EntityType.pet:
        return Icons.pets;
      case EntityType.event:
        return Icons.event;
      case EntityType.trip:
        return Icons.flight;
      case EntityType.anniversary:
        return Icons.cake;
      case EntityType.health:
        return Icons.health_and_safety;
      case EntityType.food:
        return Icons.restaurant;
      case EntityType.home:
        return Icons.home;
      case EntityType.garden:
        return Icons.grass;
      case EntityType.laundry:
        return Icons.local_laundry_service;
      case EntityType.finance:
        return Icons.account_balance_wallet;
      case EntityType.education:
        return Icons.school;
      case EntityType.career:
        return Icons.work;
      case EntityType.list:
        return Icons.list;
      case EntityType.professional:
        return Icons.business_center;
      case EntityType.other:
      default:
        return Icons.category;
    }
  }

  // Helper to get the color for the entity type
  Color get color {
    switch (type) {
      case EntityType.car:
        return Colors.blue;
      case EntityType.pet:
        return Colors.amber;
      case EntityType.event:
        return Colors.purple;
      case EntityType.trip:
        return Colors.orange;
      case EntityType.anniversary:
        return Colors.pink;
      case EntityType.health:
        return Colors.red;
      case EntityType.food:
        return Colors.green;
      case EntityType.home:
        return Colors.brown;
      case EntityType.garden:
        return Colors.lightGreen;
      case EntityType.laundry:
        return Colors.indigo;
      case EntityType.finance:
        return Colors.teal;
      case EntityType.education:
        return Colors.cyan;
      case EntityType.career:
        return Colors.deepPurple;
      case EntityType.list:
        return Colors.blueGrey;
      case EntityType.professional:
        return Colors.grey;
      case EntityType.other:
      default:
        return Colors.grey;
    }
  }
}

/// Model for entity membership (many-to-many relationship)
@freezed
class EntityMembershipModel with _$EntityMembershipModel {
  const factory EntityMembershipModel({
    required String id,
    @JsonKey(name: 'entity_id') required String entityId,
    @JsonKey(name: 'member_id') required String memberId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _EntityMembershipModel;

  factory EntityMembershipModel.fromJson(Map<String, dynamic> json) =>
      _$EntityMembershipModelFromJson(json);
}

/// Model for entity references
@freezed
class ReferenceGroupModel with _$ReferenceGroupModel {
  const factory ReferenceGroupModel({
    required String id,
    @JsonKey(name: 'created_by') required String createdBy,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    required String name,
    @Default([]) List<String> tags,
    @Default([]) List<String> entityIds,
    @Default([]) List<ReferenceModel> references,
  }) = _ReferenceGroupModel;

  factory ReferenceGroupModel.fromJson(Map<String, dynamic> json) =>
      _$ReferenceGroupModelFromJson(json);
}

/// Reference type enum
enum ReferenceType {
  @JsonValue('NAME')
  name,
  @JsonValue('ACCOUNT_NUMBER')
  accountNumber,
  @JsonValue('USERNAME')
  username,
  @JsonValue('PASSWORD')
  password,
  @JsonValue('WEBSITE')
  website,
  @JsonValue('NOTE')
  note,
  @JsonValue('ADDRESS')
  address,
  @JsonValue('PHONE_NUMBER')
  phoneNumber,
  @JsonValue('DATE')
  date,
  @JsonValue('OTHER')
  other,
}

/// Model for individual references
@freezed
class ReferenceModel with _$ReferenceModel {
  const factory ReferenceModel({
    required String id,
    @JsonKey(name: 'created_by') required String createdBy,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    required String name,
    required String value,
    required ReferenceType type,
    @JsonKey(name: 'group_id') String? groupId,
  }) = _ReferenceModel;

  factory ReferenceModel.fromJson(Map<String, dynamic> json) =>
      _$ReferenceModelFromJson(json);
}
