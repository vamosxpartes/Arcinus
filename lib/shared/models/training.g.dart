// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrainingImpl _$$TrainingImplFromJson(Map<String, dynamic> json) =>
    _$TrainingImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      academyId: json['academyId'] as String,
      groupIds:
          (json['groupIds'] as List<dynamic>).map((e) => e as String).toList(),
      coachIds:
          (json['coachIds'] as List<dynamic>).map((e) => e as String).toList(),
      isTemplate: json['isTemplate'] as bool,
      isRecurring: json['isRecurring'] as bool? ?? false,
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      recurrencePattern: json['recurrencePattern'] as String?,
      recurrenceDays: (json['recurrenceDays'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      recurrenceInterval: (json['recurrenceInterval'] as num?)?.toInt(),
      sessionIds: (json['sessionIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String,
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      updatedBy: json['updatedBy'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      content: json['content'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$TrainingImplToJson(_$TrainingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'academyId': instance.academyId,
      'groupIds': instance.groupIds,
      'coachIds': instance.coachIds,
      'isTemplate': instance.isTemplate,
      'isRecurring': instance.isRecurring,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'recurrencePattern': instance.recurrencePattern,
      'recurrenceDays': instance.recurrenceDays,
      'recurrenceInterval': instance.recurrenceInterval,
      'sessionIds': instance.sessionIds,
      'createdAt': instance.createdAt.toIso8601String(),
      'createdBy': instance.createdBy,
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'updatedBy': instance.updatedBy,
      'metadata': instance.metadata,
      'content': instance.content,
    };
