import 'package:freezed_annotation/freezed_annotation.dart';

part 'athlete_profile.freezed.dart';
part 'athlete_profile.g.dart';

// Funciones de conversión DateTime/String globales
DateTime dateTimeFromString(String dateString) => DateTime.parse(dateString);
String dateTimeToString(DateTime dateTime) => dateTime.toIso8601String();

@freezed
class AthleteProfile with _$AthleteProfile {
  const AthleteProfile._(); // Constructor privado necesario para los getters
  
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
    Map<String, dynamic>? sportStats,
    List<String>? specializations,
    String? position,
    @JsonKey(
      fromJson: dateTimeFromString,
      toJson: dateTimeToString,
    )
    required DateTime createdAt,
  }) = _AthleteProfile;

  // Getter para stats como alias de sportStats
  Map<String, dynamic> get stats => sportStats ?? {};
  
  factory AthleteProfile.fromJson(Map<String, dynamic> json) => _$AthleteProfileFromJson(json);
} 