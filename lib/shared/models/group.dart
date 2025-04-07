import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'group.freezed.dart';
part 'group.g.dart';

// Funciones de conversión DateTime/String globales
DateTime dateTimeFromString(String dateString) => DateTime.parse(dateString);
String dateTimeToString(DateTime dateTime) => dateTime.toIso8601String();

@freezed
class Group with _$Group {
  const factory Group({
    required String id,
    required String name,
    required String academyId,
    String? description,
    String? coachId,
    @Default([]) List<String> athleteIds,
    int? capacity,
    @Default(true) bool isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Group;

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);
} 