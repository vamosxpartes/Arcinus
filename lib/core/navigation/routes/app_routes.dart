/// Rutas principales de la aplicación.
///
/// Este archivo contiene las rutas comunes y expone las rutas específicas
/// de cada shell a través de imports organizados.
library;

// Exportar rutas específicas de cada shell
export 'auth_routes.dart';
export 'super_admin_routes.dart';
export 'owner_routes.dart';
export 'athlete_routes.dart';
export 'collaborator_routes.dart';
export 'parent_routes.dart';
export 'manager_routes.dart';

/// Rutas principales y comunes de la aplicación.
///
/// Este archivo contiene las rutas comunes y expone las rutas específicas
/// de cada shell a través de imports organizados.
/// Usar estas constantes en lugar de strings directamente para evitar errores.
class AppRoutes {
  // --- Rutas de inicialización ---
  static const String splash = '/splash';
  static const String welcome = '/welcome';
  
  // --- Rutas de desarrollo ---
  static const String underDevelopment = '/under-development';
  
  // --- Rutas raíz de cada shell ---
  static const String ownerRoot = '/owner';
  static const String athleteRoot = '/athlete';
  static const String collaboratorRoot = '/collaborator';
  static const String superAdminRoot = '/superadmin';
  static const String parentRoot = '/parent';
  static const String managerRoot = '/manager';
  
  // --- Rutas de autenticación (prefijo general) ---
  static const String auth = '/auth';
  
  // --- Rutas legacy/compatibilidad ---
  static const String createAcademy = '/create-academy';
}
