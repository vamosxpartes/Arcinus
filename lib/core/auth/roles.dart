/// Define los roles de usuario disponibles en la aplicación.
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
  desconocido, // Rol por defecto o para estados indefinidos
}

/// Extensión para facilitar la serialización/deserialización del enum AppRole.
extension AppRoleExtension on AppRole {
  /// Convierte el enum a su representación en String (nombre del enum).
  String toJson() => name;
}

/// Convierte un String al enum AppRole correspondiente.
///
/// Devuelve [AppRole.desconocido] si el string no coincide con ningún rol.
AppRole appRoleFromJson(String? roleString) {
  // Usa firstWhereOrNull para simplificar.
  // y evitar excepción si no se encuentra.
  // Aunque el orElse actual ya maneja eso, firstWhereOrNull es más idiomático.
  return AppRole.values.firstWhere(
        (role) => role.name == roleString,
        orElse: () => AppRole.desconocido,
      );
  // Alternativa más concisa con collection y null safety:
  // return AppRole.values.asNameMap()[roleString] ?? AppRole.desconocido;
} 
