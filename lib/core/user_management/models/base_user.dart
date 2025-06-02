import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/core/utils/timestamp_converter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'base_user.freezed.dart';
part 'base_user.g.dart';

/// Modelo base unificado para todos los usuarios del sistema Arcinus
/// Este modelo representa la información básica de autenticación y perfil
/// que es común para todos los tipos de usuarios.
@freezed
class BaseUser with _$BaseUser {
  @JsonSerializable(explicitToJson: true, converters: [TimestampConverter()])
  const factory BaseUser({
    /// ID único del usuario (Firebase Auth UID)
    required String id,
    
    /// Dirección de correo electrónico del usuario
    required String email,
    
    /// Nombre para mostrar del usuario
    String? displayName,
    
    /// URL de la foto de perfil del usuario
    String? photoUrl,
    
    /// Rol global del usuario en el sistema
    /// Este rol determina el acceso general al sistema
    @Default(AppRole.desconocido) AppRole globalRole,
    
    /// Indica si el usuario ha completado la configuración inicial de su perfil
    @Default(false) bool profileCompleted,
    
    /// Fecha de creación del usuario en el sistema
    @TimestampConverter() DateTime? createdAt,
    
    /// Fecha de última actualización del perfil
    @TimestampConverter() DateTime? updatedAt,
    
    /// Indica si el usuario está activo en el sistema
    @Default(true) bool isActive,
    
    /// Información adicional del usuario que puede variar según implementación
    @Default({}) Map<String, dynamic> metadata,
  }) = _BaseUser;

  factory BaseUser.fromJson(Map<String, dynamic> json) =>
      _$BaseUserFromJson(json);
}

/// Extensión con métodos de utilidad para BaseUser
extension BaseUserExtension on BaseUser {
  /// Verifica si el usuario es un super administrador del sistema
  bool get isSuperAdmin => globalRole == AppRole.superAdmin;
  
  /// Verifica si el usuario es propietario de al menos una academia
  bool get isOwner => globalRole == AppRole.propietario;
  
  /// Verifica si el usuario es colaborador en al menos una academia
  bool get isCollaborator => globalRole == AppRole.colaborador;
  
  /// Verifica si el usuario es miembro (atleta o padre) de al menos una academia
  bool get isMember => globalRole == AppRole.atleta || globalRole == AppRole.padre;
  
  /// Verifica si el usuario es un administrador (propietario o colaborador)
  bool get isAdmin => isOwner || isCollaborator;
  
  /// Obtiene las iniciales del usuario para mostrar en avatares
  String get initials {
    if (displayName == null || displayName!.isEmpty) {
      return email.substring(0, 1).toUpperCase();
    }
    
    final parts = displayName!.trim().split(' ');
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
  
  /// Obtiene el nombre para mostrar, usando el email si no hay displayName
  String get displayNameOrEmail => displayName?.isNotEmpty == true ? displayName! : email;
} 