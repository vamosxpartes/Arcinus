import 'package:freezed_annotation/freezed_annotation.dart';

part 'athlete_model.freezed.dart';
part 'athlete_model.g.dart';

@freezed
class AthleteModel with _$AthleteModel {
  @JsonSerializable(explicitToJson: true)
  const factory AthleteModel({
    String? id,
    required String userId,
    required String academyId,
    required String firstName,
    required String lastName,
    required DateTime birthDate,
    String? phoneNumber,
    
    // Información física
    double? heightCm,
    double? weightKg,
    
    // Información de salud
    String? allergies,
    String? medicalConditions,
    String? emergencyContactName,
    String? emergencyContactPhone,
    
    // Información deportiva
    String? position,
    
    // Imagen de perfil
    String? profileImageUrl,
    
    // Meta información
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _AthleteModel;

  factory AthleteModel.fromJson(Map<String, dynamic> json) =>
      _$AthleteModelFromJson(json);
} 