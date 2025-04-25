import 'package:arcinus/core/auth/roles.dart'; // Asegúrate que la ruta sea correcta
import 'package:freezed_annotation/freezed_annotation.dart';

part 'membership_model.freezed.dart';
part 'membership_model.g.dart';

/// Representa la membresía de un usuario dentro de una academia,
/// incluyendo su rol y permisos específicos.
@freezed
class MembershipModel with _$MembershipModel {
  /// Crea una instancia de [MembershipModel].
  factory MembershipModel({
    /// ID único del documento de membresía 
    /// (puede ser el mismo que userId si es 1:1)
    required String id, 
    /// ID del usuario al que pertenece esta membresía.
    required String userId,
    /// ID de la academia a la que pertenece esta membresía.
    required String academyId,
    /// Rol principal del usuario dentro de esta academia.
    @JsonKey(fromJson: appRoleFromJson)
    required AppRole role,
    /// Lista de permisos específicos (strings) asignados,
    /// relevante para Colaboradores.
    @Default([]) List<String> permissions,
    /// Lista de IDs de atletas vinculados, relevante para Padres/Responsables.
    @Default([]) List<String> linkedAthleteIds,
    /// Fecha de creación de la membresía (opcional, pero útil).
    DateTime? createdAt,
  }) = _MembershipModel;

  /// Constructor privado para posibles métodos futuros.
  const MembershipModel._();

  /// Crea una instancia de MembershipModel desde un mapa JSON.
  factory MembershipModel.fromJson(Map<String, dynamic> json) =>
      _$MembershipModelFromJson(json);
} 
