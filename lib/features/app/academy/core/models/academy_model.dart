import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../sports/core/models/sport_characteristics.dart';

part 'academy_model.freezed.dart';
part 'academy_model.g.dart';

// Funciones de conversión DateTime/String globales
DateTime dateTimeFromString(String dateString) => DateTime.parse(dateString);
String dateTimeToString(DateTime dateTime) => dateTime.toIso8601String();

@freezed
class Academy with _$Academy {
  const factory Academy({
    required String id,
    required String name,
    required String ownerId,
    String? logo,
    required String sport,
    String? location,
    String? taxId,
    String? description,
    SportCharacteristics? sportConfig,
    List<String>? groupIds,
    List<String>? coachIds,
    List<String>? athleteIds,
    Map<String, dynamic>? settings,
    required String subscription,
    @JsonKey(
      fromJson: dateTimeFromString,
      toJson: dateTimeToString,
    )
    required DateTime createdAt,
  }) = _Academy;

  factory Academy.fromJson(Map<String, dynamic> json) => _$AcademyFromJson(json);
} 