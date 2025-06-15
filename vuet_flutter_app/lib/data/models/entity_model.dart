// lib/data/models/entity_model.dart
// Polymorphic entity model that replicates the Django entity system
// Handles all entity types with their specific fields using JSON serialization

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'entity_model.freezed.dart';
part 'entity_model.g.dart';

/// Entity types enum matching the Django model
enum EntityType {
  // Family
  @JsonValue('PERSON')
  person,
  @JsonValue('PET')
  pet,
  
  // Social
  @JsonValue('EVENT')
  event,
  @JsonValue('CLUB')
  club,
  @JsonValue('HOBBY')
  hobby,
  
  // Education
  @JsonValue('SCHOOL')
  school,
  @JsonValue('COURSE')
  course,
  @JsonValue('ASSIGNMENT')
  assignment,
  
  // Career
  @JsonValue('JOB')
  job,
  @JsonValue('PROJECT')
  project,
  @JsonValue('PROFESSIONAL_ENTITY')
  professionalEntity,
  
  // Travel
  @JsonValue('TRIP')
  trip,
  @JsonValue('FLIGHT')
  flight,
  @JsonValue('ACCOMMODATION')
  accommodation,
  
  // Health
  @JsonValue('MEDICATION')
  medication,
  @JsonValue('APPOINTMENT')
  appointment,
  @JsonValue('EXERCISE')
  exercise,
  
  // Home
  @JsonValue('HOME')
  home,
  @JsonValue('ROOM')
  room,
  @JsonValue('APPLIANCE')
  appliance,
  
  // Garden
  @JsonValue('PLANT')
  plant,
  @JsonValue('GARDEN_AREA')
  gardenArea,
  
  // Food
  @JsonValue('RECIPE')
  recipe,
  @JsonValue('MEAL_PLAN')
  mealPlan,
  
  // Transport
  @JsonValue('CAR')
  car,
  @JsonValue('BICYCLE')
  bicycle,
  @JsonValue('PUBLIC_TRANSPORT')
  publicTransport,
  
  // Finance
  @JsonValue('ACCOUNT')
  account,
  @JsonValue('SUBSCRIPTION')
  subscription,
}

/// Base entity model with common fields
@freezed
class EntityModel with _$EntityModel {
  // Private constructor to enforce factory usage
  const EntityModel._();

  // Base entity with common fields
  @JsonSerializable(explicitToJson: true)
  const factory EntityModel({
    required String id,
    required String ownerId,
    required int categoryId,
    required EntityType type,
    String? subtype,
    required String name,
    @Default('') String notes,
    String? imagePath,
    @Default(false) bool hidden,
    String? parentId,
    required DateTime createdAt,
    required DateTime updatedAt,
    
    // JSON fields for specialized entity data
    Map<String, dynamic>? dates,
    Map<String, dynamic>? contactInfo,
    Map<String, dynamic>? location,
    Map<String, dynamic>? metadata,
    
    // Relationships (not stored in DB, populated by app)
    @Default([]) List<String> memberIds,
  }) = _EntityModel;

  // Factory constructor for creating a new entity
  factory EntityModel.create({
    required String ownerId,
    required int categoryId,
    required EntityType type,
    String? subtype,
    required String name,
    String? notes,
    String? imagePath,
    String? parentId,
    Map<String, dynamic>? dates,
    Map<String, dynamic>? contactInfo,
    Map<String, dynamic>? location,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    return EntityModel(
      id: const Uuid().v4(),
      ownerId: ownerId,
      categoryId: categoryId,
      type: type,
      subtype: subtype,
      name: name,
      notes: notes ?? '',
      imagePath: imagePath,
      hidden: false,
      parentId: parentId,
      createdAt: now,
      updatedAt: now,
      dates: dates,
      contactInfo: contactInfo,
      location: location,
      metadata: metadata,
    );
  }

  // Create from JSON
  factory EntityModel.fromJson(Map<String, dynamic> json) => _$EntityModelFromJson(json);

  // Helper methods for specialized entity types
  // These create the appropriate entity with type-specific fields

  // PERSON entity
  factory EntityModel.person({
    required String ownerId,
    required String name,
    String? notes,
    String? imagePath,
    String? parentId,
    DateTime? dateOfBirth,
    String? relationship,
    String? phone,
    String? email,
    String? address,
  }) {
    return EntityModel.create(
      ownerId: ownerId,
      categoryId: 1, // Family category
      type: EntityType.person,
      name: name,
      notes: notes,
      imagePath: imagePath,
      parentId: parentId,
      dates: dateOfBirth != null ? {'dateOfBirth': dateOfBirth.toIso8601String()} : null,
      contactInfo: {
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
      },
      location: address != null ? {'address': address} : null,
      metadata: relationship != null ? {'relationship': relationship} : null,
    );
  }

  // PET entity
  factory EntityModel.pet({
    required String ownerId,
    required String name,
    String? notes,
    String? imagePath,
    String? parentId,
    String? species,
    String? breed,
    DateTime? dateOfBirth,
    String? vetName,
    String? vetPhone,
    DateTime? lastCheckup,
  }) {
    return EntityModel.create(
      ownerId: ownerId,
      categoryId: 2, // Pets category
      type: EntityType.pet,
      name: name,
      notes: notes,
      imagePath: imagePath,
      parentId: parentId,
      dates: {
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth.toIso8601String(),
        if (lastCheckup != null) 'lastCheckup': lastCheckup.toIso8601String(),
      },
      contactInfo: vetPhone != null ? {'vetPhone': vetPhone} : null,
      metadata: {
        if (species != null) 'species': species,
        if (breed != null) 'breed': breed,
        if (vetName != null) 'vetName': vetName,
      },
    );
  }

  // CAR entity (from screenshot)
  factory EntityModel.car({
    required String ownerId,
    required String name,
    required String make,
    required String model,
    String? registration,
    DateTime? dateRegistered,
    DateTime? motDue,
    DateTime? taxDue,
    DateTime? serviceDue,
    DateTime? insuranceDue,
    DateTime? warrantyDue,
    String? notes,
    String? imagePath,
  }) {
    return EntityModel.create(
      ownerId: ownerId,
      categoryId: 13, // Transport category
      type: EntityType.car,
      name: name,
      notes: notes,
      imagePath: imagePath,
      dates: {
        if (dateRegistered != null) 'dateRegistered': dateRegistered.toIso8601String(),
        if (motDue != null) 'motDue': motDue.toIso8601String(),
        if (taxDue != null) 'taxDue': taxDue.toIso8601String(),
        if (serviceDue != null) 'serviceDue': serviceDue.toIso8601String(),
        if (insuranceDue != null) 'insuranceDue': insuranceDue.toIso8601String(),
        if (warrantyDue != null) 'warrantyDue': warrantyDue.toIso8601String(),
      },
      metadata: {
        'make': make,
        'model': model,
        if (registration != null) 'registration': registration,
      },
    );
  }

  // EVENT entity
  factory EntityModel.event({
    required String ownerId,
    required String name,
    String? notes,
    String? imagePath,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    String? organizer,
  }) {
    return EntityModel.create(
      ownerId: ownerId,
      categoryId: 3, // Social category
      type: EntityType.event,
      name: name,
      notes: notes,
      imagePath: imagePath,
      dates: {
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
      },
      location: location != null ? {'address': location} : null,
      metadata: organizer != null ? {'organizer': organizer} : null,
    );
  }

  // TRIP entity
  factory EntityModel.trip({
    required String ownerId,
    required String name,
    String? notes,
    String? imagePath,
    DateTime? startDate,
    DateTime? endDate,
    String? destination,
    String? accommodation,
  }) {
    return EntityModel.create(
      ownerId: ownerId,
      categoryId: 6, // Travel category
      type: EntityType.trip,
      name: name,
      notes: notes,
      imagePath: imagePath,
      dates: {
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
      },
      location: destination != null ? {'destination': destination} : null,
      metadata: accommodation != null ? {'accommodation': accommodation} : null,
    );
  }

  // Helper methods to access specialized fields

  // Get date from dates JSON field
  DateTime? getDate(String key) {
    if (dates == null || !dates!.containsKey(key)) return null;
    final dateStr = dates![key];
    if (dateStr == null) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  // Get string from metadata JSON field
  String? getMetadata(String key) {
    if (metadata == null || !metadata!.containsKey(key)) return null;
    return metadata![key]?.toString();
  }

  // Get string from contactInfo JSON field
  String? getContactInfo(String key) {
    if (contactInfo == null || !contactInfo!.containsKey(key)) return null;
    return contactInfo![key]?.toString();
  }

  // Get string from location JSON field
  String? getLocation(String key) {
    if (location == null || !location!.containsKey(key)) return null;
    return location![key]?.toString();
  }

  // Type-specific getters

  // Person getters
  DateTime? get dateOfBirth => getDate('dateOfBirth');
  String? get relationship => getMetadata('relationship');
  String? get phone => getContactInfo('phone');
  String? get email => getContactInfo('email');
  String? get address => getLocation('address');

  // Pet getters
  String? get species => getMetadata('species');
  String? get breed => getMetadata('breed');
  String? get vetName => getMetadata('vetName');
  String? get vetPhone => getContactInfo('vetPhone');
  DateTime? get lastCheckup => getDate('lastCheckup');

  // Car getters
  String? get make => getMetadata('make');
  String? get model => getMetadata('model');
  String? get registration => getMetadata('registration');
  DateTime? get dateRegistered => getDate('dateRegistered');
  DateTime? get motDue => getDate('motDue');
  DateTime? get taxDue => getDate('taxDue');
  DateTime? get serviceDue => getDate('serviceDue');
  DateTime? get insuranceDue => getDate('insuranceDue');
  DateTime? get warrantyDue => getDate('warrantyDue');

  // Event getters
  DateTime? get startDate => getDate('startDate');
  DateTime? get endDate => getDate('endDate');
  String? get eventLocation => getLocation('address');
  String? get organizer => getMetadata('organizer');

  // Trip getters
  String? get destination => getLocation('destination');
  String? get accommodation => getMetadata('accommodation');
}

/// Entity member model for sharing entities
@freezed
class EntityMember with _$EntityMember {
  const factory EntityMember({
    required String entityId,
    required String memberId,
    @Default('VIEWER') String role,
    required DateTime addedAt,
  }) = _EntityMember;

  factory EntityMember.fromJson(Map<String, dynamic> json) => _$EntityMemberFromJson(json);
}

/// Entity repository interface
abstract class EntityRepository {
  Future<List<EntityModel>> getEntitiesByCategory(int categoryId);
  Future<EntityModel?> getEntityById(String id);
  Future<EntityModel> createEntity(EntityModel entity);
  Future<EntityModel> updateEntity(EntityModel entity);
  Future<void> deleteEntity(String id);
  Future<List<String>> getEntityMembers(String entityId);
  Future<void> addEntityMember(String entityId, String memberId, {String role = 'VIEWER'});
  Future<void> removeEntityMember(String entityId, String memberId);
  Future<String?> uploadEntityImage(String entityId, List<int> fileBytes, String fileName);
}
