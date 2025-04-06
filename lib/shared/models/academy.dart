import 'package:freezed_annotation/freezed_annotation.dart';

part 'academy.freezed.dart';
part 'academy.g.dart';

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
    Map<String, dynamic>? sportCharacteristics,
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