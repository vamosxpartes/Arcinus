// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GroupImpl _$$GroupImplFromJson(Map<String, dynamic> json) => _$GroupImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      academyId: json['academyId'] as String,
      description: json['description'] as String?,
      coachId: json['coachId'] as String?,
      athleteIds: (json['athleteIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      capacity: (json['capacity'] as num?)?.toInt(),
      isPublic: json['isPublic'] as bool? ?? true,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$GroupImplToJson(_$GroupImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'academyId': instance.academyId,
      'description': instance.description,
      'coachId': instance.coachId,
      'athleteIds': instance.athleteIds,
      'capacity': instance.capacity,
      'isPublic': instance.isPublic,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
