import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'training_plan.freezed.dart';
part 'training_plan.g.dart';

@freezed
class TrainingPlan with _$TrainingPlan {
  const factory TrainingPlan({
    required String id,
    required String name,
    required String description,
    required String academyId,
    required List<String> groupIds,
    required List<String> coachIds,
    required int durationInWeeks,
    required String sport,
    String? difficulty,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    @Default([]) List<TrainingPlanPhase> phases,
    @Default({}) Map<String, dynamic> metadata,
    @Default(false) bool isActive,
    required DateTime createdAt,
    required String createdBy,
    DateTime? updatedAt,
    String? updatedBy,
  }) = _TrainingPlan;

  factory TrainingPlan.fromJson(Map<String, dynamic> json) => _$TrainingPlanFromJson(json);
}

@freezed
class TrainingPlanPhase with _$TrainingPlanPhase {
  const factory TrainingPlanPhase({
    required String id,
    required String name,
    required String description,
    required int order,
    required int durationInDays,
    @Default([]) List<TrainingPlanSession> plannedSessions,
    @Default({}) Map<String, dynamic> objectives,
    DateTime? startDate,
    DateTime? endDate,
  }) = _TrainingPlanPhase;

  factory TrainingPlanPhase.fromJson(Map<String, dynamic> json) => _$TrainingPlanPhaseFromJson(json);
}

@freezed
class TrainingPlanSession with _$TrainingPlanSession {
  const factory TrainingPlanSession({
    required String id,
    required String name,
    required int dayOffset, // Días desde el inicio de la fase
    String? trainingTemplateId, // Template que se usará como base
    String? description,
    @Default({}) Map<String, dynamic> content, // Contenido específico si no hay template
    @Default(0) int duration, // Duración en minutos
    @Default('normal') String intensity, // baja, normal, alta
    String? generatedSessionId, // Sesión real generada a partir de este plan
  }) = _TrainingPlanSession;

  factory TrainingPlanSession.fromJson(Map<String, dynamic> json) => _$TrainingPlanSessionFromJson(json);
} 