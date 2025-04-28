import 'package:freezed_annotation/freezed_annotation.dart';

part 'roles.g.dart'; // Necesario para json_serializable

/// Define los roles de usuario disponibles en la aplicación.
@JsonEnum(alwaysCreate: true)
enum AppRole {
  /// Rol con acceso total al sistema (administración general).
  superAdmin,

  /// Rol del dueño de una o más academias.
  propietario,

  /// Rol para personal administrativo o entrenadores con permisos específicos.
  colaborador,

  /// Rol para los deportistas/estudiantes de la academia.
  atleta,

  /// Rol para padres o responsables legales de atletas menores.
  padre,

  /// Rol por defecto o para estados indefinidos/error.
  desconocido; // Rol por defecto o para estados indefinidos

  /// Helper para obtener el rol desde un String (útil para Claims).
  /// Devuelve [AppRole.desconocido] si el string es nulo o no coincide.
  static AppRole fromString(String? roleString) {
    if (roleString == null) return AppRole.desconocido;
    // Alternativa más concisa con collection y null safety:
    return AppRole.values.asNameMap()[roleString] ?? AppRole.desconocido;
  }
}

/// Extensión para facilitar la serialización/deserialización del enum AppRole.
extension AppRoleExtension on AppRole {
  /// Convierte el enum a su representación en String (nombre del enum).
  String toJson() => name;

  /// Función de deserialización estática para json_serializable
  static AppRole fromJson(String json) => AppRole.fromString(json);
}
