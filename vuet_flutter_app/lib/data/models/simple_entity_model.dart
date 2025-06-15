// lib/data/models/simple_entity_model.dart
// Simplified entity model without freezed dependencies for basic operations

import 'package:flutter/material.dart';
import 'package:vuet_flutter/core/constants/app_constants.dart';

/// Entity type enum for type safety
enum EntityType {
  // Family & Personal
  person,
  pet,
  
  // Social
  event,
  club,
  hobby,
  
  // Education
  school,
  course,
  assignment,
  
  // Career
  job,
  project,
  professionalEntity,
  
  // Travel
  trip,
  flight,
  accommodation,
  
  // Health
  medication,
  appointment,
  exercise,
  
  // Home
  home,
  room,
  appliance,
  
  // Garden
  plant,
  gardenArea,
  
  // Food
  recipe,
  mealPlan,
  
  // Transport
  car,
  bicycle,
  publicTransport,
  
  // Finance
  account,
  subscription,
  
  // Lists
  list,
  
  // Other
  other;
  
  /// Convert from string (from Supabase)
  static EntityType fromString(String value) {
    try {
      return EntityType.values.firstWhere(
        (e) => e.toString().split('.').last.toUpperCase() == value.toUpperCase(),
        orElse: () => EntityType.other,
      );
    } catch (_) {
      return EntityType.other;
    }
  }
  
  /// Convert to string (for Supabase)
  String toDbString() {
    return toString().split('.').last.toUpperCase();
  }
  
  /// Get icon for this entity type
  IconData get icon {
    switch (this) {
      case EntityType.person:
        return Icons.person;
      case EntityType.pet:
        return Icons.pets;
      case EntityType.event:
        return Icons.event;
      case EntityType.club:
        return Icons.group;
      case EntityType.hobby:
        return Icons.sports_esports;
      case EntityType.school:
        return Icons.school;
      case EntityType.course:
        return Icons.book;
      case EntityType.assignment:
        return Icons.assignment;
      case EntityType.job:
        return Icons.work;
      case EntityType.project:
        return Icons.folder;
      case EntityType.professionalEntity:
        return Icons.business_center;
      case EntityType.trip:
        return Icons.card_travel;
      case EntityType.flight:
        return Icons.flight;
      case EntityType.accommodation:
        return Icons.hotel;
      case EntityType.medication:
        return Icons.medication;
      case EntityType.appointment:
        return Icons.calendar_today;
      case EntityType.exercise:
        return Icons.fitness_center;
      case EntityType.home:
        return Icons.home;
      case EntityType.room:
        return Icons.meeting_room;
      case EntityType.appliance:
        return Icons.kitchen;
      case EntityType.plant:
        return Icons.local_florist;
      case EntityType.gardenArea:
        return Icons.grass;
      case EntityType.recipe:
        return Icons.restaurant_menu;
      case EntityType.mealPlan:
        return Icons.restaurant;
      case EntityType.car:
        return Icons.directions_car;
      case EntityType.bicycle:
        return Icons.pedal_bike;
      case EntityType.publicTransport:
        return Icons.directions_bus;
      case EntityType.account:
        return Icons.account_balance;
      case EntityType.subscription:
        return Icons.subscriptions;
      case EntityType.list:
        return Icons.list_alt;
      case EntityType.other:
        return Icons.category;
    }
  }
  
  /// Get color for this entity type
  Color get color {
    switch (this) {
      case EntityType.person:
      case EntityType.pet:
        return const Color(0xFF4CAF50); // Green
      case EntityType.event:
      case EntityType.club:
      case EntityType.hobby:
        return const Color(0xFF2196F3); // Blue
      case EntityType.school:
      case EntityType.course:
      case EntityType.assignment:
        return const Color(0xFF9C27B0); // Purple
      case EntityType.job:
      case EntityType.project:
      case EntityType.professionalEntity:
        return const Color(0xFF607D8B); // Blue Grey
      case EntityType.trip:
      case EntityType.flight:
      case EntityType.accommodation:
        return const Color(0xFF00BCD4); // Cyan
      case EntityType.medication:
      case EntityType.appointment:
      case EntityType.exercise:
        return const Color(0xFFE91E63); // Pink
      case EntityType.home:
      case EntityType.room:
      case EntityType.appliance:
        return const Color(0xFF795548); // Brown
      case EntityType.plant:
      case EntityType.gardenArea:
        return const Color(0xFF8BC34A); // Light Green
      case EntityType.recipe:
      case EntityType.mealPlan:
        return const Color(0xFFFFC107); // Amber
      case EntityType.car:
      case EntityType.bicycle:
      case EntityType.publicTransport:
        return const Color(0xFFF44336); // Red
      case EntityType.account:
      case EntityType.subscription:
        return const Color(0xFF009688); // Teal
      case EntityType.list:
        return const Color(0xFF3F51B5); // Indigo
      case EntityType.other:
        return const Color(0xFF9E9E9E); // Grey
    }
  }
}

/// Entity member model
class EntityMember {
  final String userId;
  final String role; // OWNER, EDITOR, VIEWER
  final DateTime createdAt;

  EntityMember({
    required this.userId,
    required this.role,
    required this.createdAt,
  });

  factory EntityMember.fromJson(Map<String, dynamic> json) {
    return EntityMember(
      userId: json['user_id'] as String,
      role: json['role'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'role': role,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Simplified entity model
class SimpleEntityModel {
  final String id;
  final String ownerId;
  final int categoryId;
  final EntityType type;
  final String? subtype;
  final String name;
  final String? notes;
  final String? imagePath;
  final bool hidden;
  final String? parentId;
  final List<EntityMember> members;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Generic fields for type-specific data
  final Map<String, dynamic>? dates;
  final Map<String, dynamic>? contactInfo;
  final Map<String, dynamic>? location;
  final Map<String, dynamic>? metadata;

  SimpleEntityModel({
    required this.id,
    required this.ownerId,
    required this.categoryId,
    required this.type,
    this.subtype,
    required this.name,
    this.notes,
    this.imagePath,
    this.hidden = false,
    this.parentId,
    this.members = const [],
    required this.createdAt,
    required this.updatedAt,
    this.dates,
    this.contactInfo,
    this.location,
    this.metadata,
  });

  /// Create from Supabase JSON
  factory SimpleEntityModel.fromJson(Map<String, dynamic> json) {
    // Parse members if present
    List<EntityMember> membersList = [];
    if (json['members'] != null) {
      membersList = (json['members'] as List)
          .map((member) => EntityMember.fromJson(member))
          .toList();
    }

    return SimpleEntityModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      categoryId: json['category_id'] as int,
      type: EntityType.fromString(json['type'] as String),
      subtype: json['subtype'] as String?,
      name: json['name'] as String,
      notes: json['notes'] as String?,
      imagePath: json['image_path'] as String?,
      hidden: json['hidden'] as bool? ?? false,
      parentId: json['parent_id'] as String?,
      members: membersList,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      dates: json['dates'] as Map<String, dynamic>?,
      contactInfo: json['contact_info'] as Map<String, dynamic>?,
      location: json['location'] as Map<String, dynamic>?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'category_id': categoryId,
      'type': type.toDbString(),
      'subtype': subtype,
      'name': name,
      'notes': notes,
      'image_path': imagePath,
      'hidden': hidden,
      'parent_id': parentId,
      'members': members.map((member) => member.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'dates': dates,
      'contact_info': contactInfo,
      'location': location,
      'metadata': metadata,
    };
  }

  /// Create a copy with updated fields
  SimpleEntityModel copyWith({
    String? id,
    String? ownerId,
    int? categoryId,
    EntityType? type,
    String? subtype,
    String? name,
    String? notes,
    String? imagePath,
    bool? hidden,
    String? parentId,
    List<EntityMember>? members,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? dates,
    Map<String, dynamic>? contactInfo,
    Map<String, dynamic>? location,
    Map<String, dynamic>? metadata,
  }) {
    return SimpleEntityModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      subtype: subtype ?? this.subtype,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
      hidden: hidden ?? this.hidden,
      parentId: parentId ?? this.parentId,
      members: members ?? this.members,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dates: dates ?? this.dates,
      contactInfo: contactInfo ?? this.contactInfo,
      location: location ?? this.location,
      metadata: metadata ?? this.metadata,
    );
  }
  
  /// Helper to get a typed value from dates
  T? getDate<T>(String key) {
    if (dates == null) return null;
    return dates![key] as T?;
  }
  
  /// Helper to get a typed value from metadata
  T? getMetadata<T>(String key) {
    if (metadata == null) return null;
    return metadata![key] as T?;
  }
  
  /// Helper to get a typed value from contact info
  T? getContactInfo<T>(String key) {
    if (contactInfo == null) return null;
    return contactInfo![key] as T?;
  }
  
  /// Helper to get a typed value from location
  T? getLocation<T>(String key) {
    if (location == null) return null;
    return location![key] as T?;
  }
  
  /// Check if this entity has a specific member
  bool hasMember(String userId) {
    return members.any((member) => member.userId == userId);
  }
  
  /// Check if a user has a specific role on this entity
  bool hasRole(String userId, String role) {
    return members.any((member) => member.userId == userId && member.role == role);
  }
  
  /// Check if a user can edit this entity
  bool canEdit(String userId) {
    if (ownerId == userId) return true;
    return members.any((member) => 
        member.userId == userId && 
        (member.role == 'OWNER' || member.role == 'EDITOR'));
  }
  
  /// Check if a user can view this entity
  bool canView(String userId) {
    if (ownerId == userId) return true;
    return members.any((member) => member.userId == userId);
  }
  
  /// Get display name (formatted based on type)
  String get displayName {
    switch (type) {
      case EntityType.car:
        return '${getMetadata<String>('make') ?? ''} ${getMetadata<String>('model') ?? ''} ${name}'.trim();
      case EntityType.person:
        return name;
      case EntityType.event:
        final location = getLocation<String>('name');
        return location != null ? '$name @ $location' : name;
      default:
        return name;
    }
  }
}
