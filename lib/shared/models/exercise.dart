import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise.freezed.dart';
part 'exercise.g.dart';

@freezed
class Exercise with _$Exercise {
  const factory Exercise({
    required String id,
    required String name,
    required String description,
    required String academyId,
    required String sport, // Deporte al que pertenece
    required String category, // Categoría: cardio, fuerza, flexibilidad, etc.
    required String difficulty, // Dificultad: principiante, intermedio, avanzado
    @Default([]) List<String> muscleGroups, // Grupos musculares trabajados
    @Default([]) List<String> equipment, // Equipamiento necesario
    @Default({}) Map<String, dynamic> instructions, // Instrucciones detalladas (pasos)
    String? videoUrl, // URL de video demostrativo
    @Default([]) List<String> imageUrls, // URLs de imágenes demostrativas
    @Default({}) Map<String, dynamic> metrics, // Métricas que se pueden registrar (tiempo, repeticiones, peso, etc.)
    @Default({}) Map<String, dynamic> variations, // Variaciones del ejercicio
    required DateTime createdAt,
    required String createdBy,
    DateTime? updatedAt,
    String? updatedBy,
    @Default({}) Map<String, dynamic> metadata,
  }) = _Exercise;

  factory Exercise.fromJson(Map<String, dynamic> json) => _$ExerciseFromJson(json);
} 