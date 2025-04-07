import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'training.freezed.dart';
part 'training.g.dart';

@freezed
class Training with _$Training {
  const factory Training({
    required String id,
    required String name,
    required String description,
    required String academyId,
    required List<String> groupIds,
    required List<String> coachIds,
    required bool isTemplate,
    @Default(false) bool isRecurring,
    DateTime? startDate,
    DateTime? endDate,
    String? recurrencePattern, // Patrón de recurrencia: "daily", "weekly", "monthly"
    List<String>? recurrenceDays, // Días de la semana para recurrencia semanal
    int? recurrenceInterval, // Intervalo de recurrencia
    List<String>? sessionIds,
    required DateTime createdAt,
    required String createdBy,
    DateTime? updatedAt,
    String? updatedBy,
    Map<String, dynamic>? metadata,
    @Default({}) Map<String, dynamic> content, // Contenido estructurado del entrenamiento
  }) = _Training;

  factory Training.fromJson(Map<String, dynamic> json) => _$TrainingFromJson(json);
} 