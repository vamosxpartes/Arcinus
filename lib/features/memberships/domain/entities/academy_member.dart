import 'package:arcinus/core/auth/roles.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:arcinus/core/utils/timestamp_converter.dart';

part 'academy_member.freezed.dart';
part 'academy_member.g.dart';

/// Representa un miembro de una academia deportiva (atleta, padre o gestor)
@freezed
class AcademyMember with _$AcademyMember {
  @JsonSerializable(explicitToJson: true)
  const factory AcademyMember({
    @JsonKey(includeFromJson: false, includeToJson: false) String? id,
    required String userId,
    required String academyId,
    required AppRole role,
    required String name,
    @Default('') String email,
    @Default('') String phone,
    @Default('') String photoUrl,
    @Default(false) bool isActive,
    
    // Datos deportivos (principalmente para atletas)
    @Default({}) Map<String, dynamic> sportData,
    
    // Métricas físicas y deportivas
    @Default({}) Map<String, dynamic> metrics,
    
    // Información médica (para atletas)
    @Default({}) Map<String, dynamic> medicalInfo,
    
    // Información de contacto de emergencia
    @Default({}) Map<String, dynamic> contactInfo,
    
    // Relaciones con otros miembros (ej: padre-atleta)
    @Default([]) List<String> relatedMemberIds,
    
    // Datos de equipos (ej: equipos a los que pertenece)
    @Default([]) List<String> teamIds,
    
    // Fechas importantes
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
    @TimestampConverter() DateTime? lastActive,
    
    // Metadatos adicionales específicos según la implementación
    @Default({}) Map<String, dynamic> metadata,
  }) = _AcademyMember;

  factory AcademyMember.fromJson(Map<String, dynamic> json) =>
      _$AcademyMemberFromJson(json);
}

/// Extensión con métodos de ayuda para AcademyMember
extension AcademyMemberExtension on AcademyMember {
  // Verifica si el miembro es un atleta
  bool get isAthlete => role == AppRole.atleta;
  
  // Verifica si el miembro es un padre/responsable
  bool get isParent => role == AppRole.padre;
  
  // Verifica si el miembro es un gestor (propietario o colaborador)
  bool get isManager => role == AppRole.propietario || role == AppRole.colaborador;
  
  // Obtiene la posición de juego (para atletas)
  String? get position => sportData['position'] as String?;
  
  // Obtiene la experiencia (para atletas)
  String? get experience => sportData['experience'] as String?;
  
  // Obtiene la especialización (para atletas)
  String? get specialization => sportData['specialization'] as String?;
  
  // Obtiene la altura en cm (para atletas)
  int? get heightCm => metrics['height'] as int?;
  
  // Obtiene el peso en kg (para atletas)
  int? get weightKg => metrics['weight'] as int?;
} 