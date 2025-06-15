// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EntityMembershipModelImpl _$$EntityMembershipModelImplFromJson(
        Map<String, dynamic> json) =>
    _$EntityMembershipModelImpl(
      id: json['id'] as String,
      entityId: json['entity_id'] as String,
      memberId: json['member_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$EntityMembershipModelImplToJson(
        _$EntityMembershipModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'entity_id': instance.entityId,
      'member_id': instance.memberId,
      'created_at': instance.createdAt.toIso8601String(),
    };

_$ReferenceGroupModelImpl _$$ReferenceGroupModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ReferenceGroupModelImpl(
      id: json['id'] as String,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      name: json['name'] as String,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      entityIds: (json['entityIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      references: (json['references'] as List<dynamic>?)
              ?.map((e) => ReferenceModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$ReferenceGroupModelImplToJson(
        _$ReferenceGroupModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_by': instance.createdBy,
      'created_at': instance.createdAt.toIso8601String(),
      'name': instance.name,
      'tags': instance.tags,
      'entityIds': instance.entityIds,
      'references': instance.references,
    };

_$ReferenceModelImpl _$$ReferenceModelImplFromJson(Map<String, dynamic> json) =>
    _$ReferenceModelImpl(
      id: json['id'] as String,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      name: json['name'] as String,
      value: json['value'] as String,
      type: $enumDecode(_$ReferenceTypeEnumMap, json['type']),
      groupId: json['group_id'] as String?,
    );

Map<String, dynamic> _$$ReferenceModelImplToJson(
        _$ReferenceModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_by': instance.createdBy,
      'created_at': instance.createdAt.toIso8601String(),
      'name': instance.name,
      'value': instance.value,
      'type': _$ReferenceTypeEnumMap[instance.type]!,
      'group_id': instance.groupId,
    };

const _$ReferenceTypeEnumMap = {
  ReferenceType.name: 'NAME',
  ReferenceType.accountNumber: 'ACCOUNT_NUMBER',
  ReferenceType.username: 'USERNAME',
  ReferenceType.password: 'PASSWORD',
  ReferenceType.website: 'WEBSITE',
  ReferenceType.note: 'NOTE',
  ReferenceType.address: 'ADDRESS',
  ReferenceType.phoneNumber: 'PHONE_NUMBER',
  ReferenceType.date: 'DATE',
  ReferenceType.other: 'OTHER',
};
