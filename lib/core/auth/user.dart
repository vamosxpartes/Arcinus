import 'package:arcinus/core/auth/roles.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// Representa un usuario de la aplicación Arcinus.
@freezed
class User with _$User {
  /// Crea una instancia de [User].
  const factory User({
    /// ID único del usuario.
    required String id,

    /// Dirección de correo electrónico del usuario.
    required String email,

    /// Nombre del usuario.
    String? name, // Puede ser null inicialmente
    /// Rol del usuario.
    @Default(AppRole.desconocido) AppRole role, // Obtener de Claims
    /// URL de la foto del usuario.
    String? photoUrl,
    // Otros campos relevantes:
    String? academyId, // ID de la academia a la que pertenece (si aplica)
    List<String>? permissions, // Específico para Colaborador
    List<String>? athleteIds, // Específico para Padre/Responsable
  }) = _User;

  /// Crea una instancia de [User] desde un mapa JSON.
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
