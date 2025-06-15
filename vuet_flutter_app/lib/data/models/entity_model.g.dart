// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EntityModelImpl _$$EntityModelImplFromJson(Map<String, dynamic> json) =>
    _$EntityModelImpl(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      categoryId: (json['categoryId'] as num).toInt(),
      type: $enumDecode(_$EntityTypeEnumMap, json['type']),
      subtype: json['subtype'] as String?,
      name: json['name'] as String,
      notes: json['notes'] as String? ?? '',
      imagePath: json['imagePath'] as String?,
      hidden: json['hidden'] as bool? ?? false,
      parentId: json['parentId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      dates: json['dates'] as Map<String, dynamic>?,
      contactInfo: json['contactInfo'] as Map<String, dynamic>?,
      location: json['location'] as Map<String, dynamic>?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      memberIds: (json['memberIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$EntityModelImplToJson(_$EntityModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ownerId': instance.ownerId,
      'categoryId': instance.categoryId,
      'type': _$EntityTypeEnumMap[instance.type]!,
      'subtype': instance.subtype,
      'name': instance.name,
      'notes': instance.notes,
      'imagePath': instance.imagePath,
      'hidden': instance.hidden,
      'parentId': instance.parentId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'dates': instance.dates,
      'contactInfo': instance.contactInfo,
      'location': instance.location,
      'metadata': instance.metadata,
      'memberIds': instance.memberIds,
    };

const _$EntityTypeEnumMap = {
  EntityType.person: 'PERSON',
  EntityType.pet: 'PET',
  EntityType.event: 'EVENT',
  EntityType.club: 'CLUB',
  EntityType.hobby: 'HOBBY',
  EntityType.school: 'SCHOOL',
  EntityType.course: 'COURSE',
  EntityType.assignment: 'ASSIGNMENT',
  EntityType.job: 'JOB',
  EntityType.project: 'PROJECT',
  EntityType.professionalEntity: 'PROFESSIONAL_ENTITY',
  EntityType.trip: 'TRIP',
  EntityType.flight: 'FLIGHT',
  EntityType.accommodation: 'ACCOMMODATION',
  EntityType.medication: 'MEDICATION',
  EntityType.appointment: 'APPOINTMENT',
  EntityType.exercise: 'EXERCISE',
  EntityType.home: 'HOME',
  EntityType.room: 'ROOM',
  EntityType.appliance: 'APPLIANCE',
  EntityType.plant: 'PLANT',
  EntityType.gardenArea: 'GARDEN_AREA',
  EntityType.recipe: 'RECIPE',
  EntityType.mealPlan: 'MEAL_PLAN',
  EntityType.car: 'CAR',
  EntityType.bicycle: 'BICYCLE',
  EntityType.publicTransport: 'PUBLIC_TRANSPORT',
  EntityType.account: 'ACCOUNT',
  EntityType.subscription: 'SUBSCRIPTION',
};

_$EntityMemberImpl _$$EntityMemberImplFromJson(Map<String, dynamic> json) =>
    _$EntityMemberImpl(
      entityId: json['entityId'] as String,
      memberId: json['memberId'] as String,
      role: json['role'] as String? ?? 'VIEWER',
      addedAt: DateTime.parse(json['addedAt'] as String),
    );

Map<String, dynamic> _$$EntityMemberImplToJson(_$EntityMemberImpl instance) =>
    <String, dynamic>{
      'entityId': instance.entityId,
      'memberId': instance.memberId,
      'role': instance.role,
      'addedAt': instance.addedAt.toIso8601String(),
    };
