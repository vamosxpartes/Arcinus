// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExerciseImpl _$$ExerciseImplFromJson(Map<String, dynamic> json) =>
    _$ExerciseImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      academyId: json['academyId'] as String,
      sport: json['sport'] as String,
      category: json['category'] as String,
      difficulty: json['difficulty'] as String,
      muscleGroups: (json['muscleGroups'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      equipment: (json['equipment'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      instructions: json['instructions'] as Map<String, dynamic>? ?? const {},
      videoUrl: json['videoUrl'] as String?,
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      metrics: json['metrics'] as Map<String, dynamic>? ?? const {},
      variations: json['variations'] as Map<String, dynamic>? ?? const {},
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String,
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      updatedBy: json['updatedBy'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$ExerciseImplToJson(_$ExerciseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'academyId': instance.academyId,
      'sport': instance.sport,
      'category': instance.category,
      'difficulty': instance.difficulty,
      'muscleGroups': instance.muscleGroups,
      'equipment': instance.equipment,
      'instructions': instance.instructions,
      'videoUrl': instance.videoUrl,
      'imageUrls': instance.imageUrls,
      'metrics': instance.metrics,
      'variations': instance.variations,
      'createdAt': instance.createdAt.toIso8601String(),
      'createdBy': instance.createdBy,
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'updatedBy': instance.updatedBy,
      'metadata': instance.metadata,
    };
