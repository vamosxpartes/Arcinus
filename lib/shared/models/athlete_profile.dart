import 'package:freezed_annotation/freezed_annotation.dart';

part 'athlete_profile.freezed.dart';
part 'athlete_profile.g.dart';

// Funciones de conversión DateTime/String globales
DateTime dateTimeFromString(String dateString) => DateTime.parse(dateString);
String dateTimeToString(DateTime dateTime) => dateTime.toIso8601String();

@freezed
class AthleteProfile with _$AthleteProfile {
  const factory AthleteProfile({
    required String userId,
    required String academyId,
    DateTime? birthDate,
    double? height,
    double? weight,
    List<String>? groupIds,
    List<String>? parentIds,
    Map<String, dynamic>? medicalInfo,
    Map<String, dynamic>? emergencyContacts,
    Map<String, dynamic>? additionalInfo,
    @JsonKey(
      fromJson: dateTimeFromString,
      toJson: dateTimeToString,
    )
    required DateTime createdAt,
  }) = _AthleteProfile;

  factory AthleteProfile.fromJson(Map<String, dynamic> json) => _$AthleteProfileFromJson(json);
} 