// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'athlete_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AthleteProfileImpl _$$AthleteProfileImplFromJson(Map<String, dynamic> json) =>
    _$AthleteProfileImpl(
      userId: json['userId'] as String,
      academyId: json['academyId'] as String,
      birthDate: json['birthDate'] == null
          ? null
          : DateTime.parse(json['birthDate'] as String),
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      groupIds: (json['groupIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      parentIds: (json['parentIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      medicalInfo: json['medicalInfo'] as Map<String, dynamic>?,
      emergencyContacts: json['emergencyContacts'] as Map<String, dynamic>?,
      additionalInfo: json['additionalInfo'] as Map<String, dynamic>?,
      createdAt: dateTimeFromString(json['createdAt'] as String),
    );

Map<String, dynamic> _$$AthleteProfileImplToJson(
        _$AthleteProfileImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'academyId': instance.academyId,
      'birthDate': instance.birthDate?.toIso8601String(),
      'height': instance.height,
      'weight': instance.weight,
      'groupIds': instance.groupIds,
      'parentIds': instance.parentIds,
      'medicalInfo': instance.medicalInfo,
      'emergencyContacts': instance.emergencyContacts,
      'additionalInfo': instance.additionalInfo,
      'createdAt': dateTimeToString(instance.createdAt),
    };
