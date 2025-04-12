// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrainingPlanImpl _$$TrainingPlanImplFromJson(Map<String, dynamic> json) =>
    _$TrainingPlanImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      academyId: json['academyId'] as String,
      groupIds:
          (json['groupIds'] as List<dynamic>).map((e) => e as String).toList(),
      coachIds:
          (json['coachIds'] as List<dynamic>).map((e) => e as String).toList(),
      durationInWeeks: (json['durationInWeeks'] as num).toInt(),
      sport: json['sport'] as String,
      difficulty: json['difficulty'] as String?,
      category: json['category'] as String?,
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      phases: (json['phases'] as List<dynamic>?)
              ?.map(
                  (e) => TrainingPlanPhase.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      isActive: json['isActive'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String,
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      updatedBy: json['updatedBy'] as String?,
    );

Map<String, dynamic> _$$TrainingPlanImplToJson(_$TrainingPlanImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'academyId': instance.academyId,
      'groupIds': instance.groupIds,
      'coachIds': instance.coachIds,
      'durationInWeeks': instance.durationInWeeks,
      'sport': instance.sport,
      'difficulty': instance.difficulty,
      'category': instance.category,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'phases': instance.phases,
      'metadata': instance.metadata,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'createdBy': instance.createdBy,
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'updatedBy': instance.updatedBy,
    };

_$TrainingPlanPhaseImpl _$$TrainingPlanPhaseImplFromJson(
        Map<String, dynamic> json) =>
    _$TrainingPlanPhaseImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      order: (json['order'] as num).toInt(),
      durationInDays: (json['durationInDays'] as num).toInt(),
      plannedSessions: (json['plannedSessions'] as List<dynamic>?)
              ?.map((e) =>
                  TrainingPlanSession.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      objectives: json['objectives'] as Map<String, dynamic>? ?? const {},
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
    );

Map<String, dynamic> _$$TrainingPlanPhaseImplToJson(
        _$TrainingPlanPhaseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'order': instance.order,
      'durationInDays': instance.durationInDays,
      'plannedSessions': instance.plannedSessions,
      'objectives': instance.objectives,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
    };

_$TrainingPlanSessionImpl _$$TrainingPlanSessionImplFromJson(
        Map<String, dynamic> json) =>
    _$TrainingPlanSessionImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      dayOffset: (json['dayOffset'] as num).toInt(),
      trainingTemplateId: json['trainingTemplateId'] as String?,
      description: json['description'] as String?,
      content: json['content'] as Map<String, dynamic>? ?? const {},
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      intensity: json['intensity'] as String? ?? 'normal',
      generatedSessionId: json['generatedSessionId'] as String?,
    );

Map<String, dynamic> _$$TrainingPlanSessionImplToJson(
        _$TrainingPlanSessionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'dayOffset': instance.dayOffset,
      'trainingTemplateId': instance.trainingTemplateId,
      'description': instance.description,
      'content': instance.content,
      'duration': instance.duration,
      'intensity': instance.intensity,
      'generatedSessionId': instance.generatedSessionId,
    };
