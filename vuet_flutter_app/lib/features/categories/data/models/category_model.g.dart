// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CategoryModelImpl _$$CategoryModelImplFromJson(Map<String, dynamic> json) =>
    _$CategoryModelImpl(
      id: (json['id'] as num).toInt(),
      name: $enumDecode(_$CategoryNameEnumMap, json['name']),
      readableName: json['readableName'] as String,
      isPremium: json['isPremium'] as bool? ?? false,
      isEnabled: json['isEnabled'] as bool? ?? true,
    );

Map<String, dynamic> _$$CategoryModelImplToJson(_$CategoryModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': _$CategoryNameEnumMap[instance.name]!,
      'readableName': instance.readableName,
      'isPremium': instance.isPremium,
      'isEnabled': instance.isEnabled,
    };

const _$CategoryNameEnumMap = {
  CategoryName.family: 'FAMILY',
  CategoryName.pets: 'PETS',
  CategoryName.socialInterests: 'SOCIAL_INTERESTS',
  CategoryName.education: 'EDUCATION',
  CategoryName.career: 'CAREER',
  CategoryName.travel: 'TRAVEL',
  CategoryName.healthBeauty: 'HEALTH_BEAUTY',
  CategoryName.home: 'HOME',
  CategoryName.garden: 'GARDEN',
  CategoryName.food: 'FOOD',
  CategoryName.laundry: 'LAUNDRY',
  CategoryName.finance: 'FINANCE',
  CategoryName.transport: 'TRANSPORT',
};

_$ProfessionalCategoryModelImpl _$$ProfessionalCategoryModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ProfessionalCategoryModelImpl(
      id: (json['id'] as num).toInt(),
      userId: json['user_id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$ProfessionalCategoryModelImplToJson(
        _$ProfessionalCategoryModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      'created_at': instance.createdAt.toIso8601String(),
    };
