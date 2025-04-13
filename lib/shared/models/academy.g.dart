// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'academy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AcademyImpl _$$AcademyImplFromJson(Map<String, dynamic> json) =>
    _$AcademyImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      ownerId: json['ownerId'] as String,
      logo: json['logo'] as String?,
      sport: json['sport'] as String,
      location: json['location'] as String?,
      taxId: json['taxId'] as String?,
      description: json['description'] as String?,
      sportConfig: json['sportConfig'] == null
          ? null
          : SportCharacteristics.fromJson(
              json['sportConfig'] as Map<String, dynamic>),
      groupIds: (json['groupIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      coachIds: (json['coachIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      athleteIds: (json['athleteIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      settings: json['settings'] as Map<String, dynamic>?,
      subscription: json['subscription'] as String,
      createdAt: dateTimeFromString(json['createdAt'] as String),
    );

Map<String, dynamic> _$$AcademyImplToJson(_$AcademyImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'ownerId': instance.ownerId,
      'logo': instance.logo,
      'sport': instance.sport,
      'location': instance.location,
      'taxId': instance.taxId,
      'description': instance.description,
      'sportConfig': instance.sportConfig,
      'groupIds': instance.groupIds,
      'coachIds': instance.coachIds,
      'athleteIds': instance.athleteIds,
      'settings': instance.settings,
      'subscription': instance.subscription,
      'createdAt': dateTimeToString(instance.createdAt),
    };
