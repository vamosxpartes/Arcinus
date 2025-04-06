// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GroupImpl _$$GroupImplFromJson(Map<String, dynamic> json) => _$GroupImpl(
      id: json['id'] as String,
      academyId: json['academyId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      coachId: json['coachId'] as String?,
      athleteIds: (json['athleteIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      settings: json['settings'] as Map<String, dynamic>?,
      createdAt: dateTimeFromString(json['createdAt'] as String),
    );

Map<String, dynamic> _$$GroupImplToJson(_$GroupImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'academyId': instance.academyId,
      'name': instance.name,
      'description': instance.description,
      'coachId': instance.coachId,
      'athleteIds': instance.athleteIds,
      'settings': instance.settings,
      'createdAt': dateTimeToString(instance.createdAt),
    };
