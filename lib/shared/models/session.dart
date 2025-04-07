import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'session.freezed.dart';
part 'session.g.dart';

@freezed
class Session with _$Session {
  const factory Session({
    required String id,
    required String name,
    required String trainingId,
    required String academyId,
    required List<String> groupIds,
    required List<String> coachIds,
    required DateTime scheduledDate,
    DateTime? startTime,
    DateTime? endTime,
    @Default(false) bool isCompleted,
    @Default({}) Map<String, bool> attendance, // ID del atleta -> asistencia
    @Default({}) Map<String, dynamic> performanceData, // ID del atleta -> datos de rendimiento
    String? notes,
    required DateTime createdAt,
    required String createdBy,
    DateTime? updatedAt,
    String? updatedBy,
    @Default({}) Map<String, dynamic> content, // Contenido específico de la sesión (puede variar del entrenamiento original)
  }) = _Session;

  factory Session.fromJson(Map<String, dynamic> json) => _$SessionFromJson(json);
} 