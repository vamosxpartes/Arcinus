// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_role.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CustomRoleImpl _$$CustomRoleImplFromJson(Map<String, dynamic> json) =>
    _$CustomRoleImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      academyId: json['academyId'] as String,
      createdBy: json['createdBy'] as String,
      permissions: Map<String, bool>.from(json['permissions'] as Map),
      description: json['description'] as String?,
      assignedUserIds: (json['assignedUserIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$CustomRoleImplToJson(_$CustomRoleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'academyId': instance.academyId,
      'createdBy': instance.createdBy,
      'permissions': instance.permissions,
      'description': instance.description,
      'assignedUserIds': instance.assignedUserIds,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
