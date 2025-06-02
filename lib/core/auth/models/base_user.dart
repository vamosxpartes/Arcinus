import 'package:arcinus/core/auth/roles.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:arcinus/core/utils/timestamp_converter.dart';

part 'base_user.freezed.dart';
part 'base_user.g.dart';

/// Modelo base unificado para todos los usuarios del sistema Arcinus.
/// Este modelo contiene la información global del usuario que se mantiene
/// consistente independientemente del contexto de academia específico.
@freezed
class BaseUser with _$BaseUser {
  @JsonSerializable(
    explicitToJson: true,
    converters: [NullableTimestampConverter()]
  )
  const factory BaseUser({
    /// ID único del usuario (Firebase Auth UID)
    required String id,
    
    /// Email del usuario (Firebase Auth email)
    required String email,
    
    /// Nombre para mostrar del usuario
    String? displayName,
    
    /// URL de la foto de perfil
    String? photoUrl,
    
    /// Rol global del usuario en el sistema Arcinus
    /// Este es el rol principal que determina el acceso general al sistema
    @Default(AppRole.desconocido) AppRole globalRole,
    
    /// Indica si el usuario ha completado su perfil inicial
    @Default(false) bool profileCompleted,
    
    /// Fecha de creación del usuario en el sistema
    DateTime? createdAt,
    
    /// Fecha de última actualización del perfil
    DateTime? updatedAt,
    
    /// Número de teléfono principal del usuario
    String? phoneNumber,
    
    /// Configuraciones adicionales del usuario
    @Default({}) Map<String, dynamic> userSettings,
    
    /// Metadatos adicionales para uso futuro
    @Default({}) Map<String, dynamic> metadata,
  }) = _BaseUser;

  factory BaseUser.fromJson(Map<String, dynamic> json) => 
      _$BaseUserFromJson(json);
}

/// Extensiones útiles para BaseUser
extension BaseUserExtensions on BaseUser {
  /// Verifica si el usuario es un super administrador del sistema
  bool get isSuperAdmin => globalRole == AppRole.superAdmin;
  
  /// Verifica si el usuario tiene un perfil completo
  bool get hasCompleteProfile => profileCompleted && displayName != null;
  
  /// Obtiene el nombre a mostrar o un fallback al email
  String get displayNameOrEmail => displayName ?? email;
  
  /// Verifica si el usuario puede gestionar academias globalmente
  bool get canManageSystemGlobally => isSuperAdmin;
  
  /// Crea una copia con campos de auditoría actualizados
  BaseUser withUpdatedTimestamp() => copyWith(
    updatedAt: DateTime.now(),
  );
} 