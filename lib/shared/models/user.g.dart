// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      permissions: Map<String, bool>.from(json['permissions'] as Map),
      academyIds: (json['academyIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      customRoleIds: (json['customRoleIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      profileImageUrl: json['profileImageUrl'] as String?,
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'role': _$UserRoleEnumMap[instance.role]!,
      'permissions': instance.permissions,
      'academyIds': instance.academyIds,
      'customRoleIds': instance.customRoleIds,
      'createdAt': instance.createdAt.toIso8601String(),
      'profileImageUrl': instance.profileImageUrl,
    };

const _$UserRoleEnumMap = {
  UserRole.superAdmin: 'superAdmin',
  UserRole.owner: 'owner',
  UserRole.manager: 'manager',
  UserRole.coach: 'coach',
  UserRole.athlete: 'athlete',
  UserRole.parent: 'parent',
  UserRole.guest: 'guest',
};
