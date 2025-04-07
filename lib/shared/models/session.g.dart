// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SessionImpl _$$SessionImplFromJson(Map<String, dynamic> json) =>
    _$SessionImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      trainingId: json['trainingId'] as String,
      academyId: json['academyId'] as String,
      groupIds:
          (json['groupIds'] as List<dynamic>).map((e) => e as String).toList(),
      coachIds:
          (json['coachIds'] as List<dynamic>).map((e) => e as String).toList(),
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      startTime: json['startTime'] == null
          ? null
          : DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
      attendance: (json['attendance'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as bool),
          ) ??
          const {},
      performanceData:
          json['performanceData'] as Map<String, dynamic>? ?? const {},
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String,
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      updatedBy: json['updatedBy'] as String?,
      content: json['content'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$SessionImplToJson(_$SessionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'trainingId': instance.trainingId,
      'academyId': instance.academyId,
      'groupIds': instance.groupIds,
      'coachIds': instance.coachIds,
      'scheduledDate': instance.scheduledDate.toIso8601String(),
      'startTime': instance.startTime?.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'isCompleted': instance.isCompleted,
      'attendance': instance.attendance,
      'performanceData': instance.performanceData,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'createdBy': instance.createdBy,
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'updatedBy': instance.updatedBy,
      'content': instance.content,
    };
