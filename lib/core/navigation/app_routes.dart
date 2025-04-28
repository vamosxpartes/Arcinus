/// Rutas estáticas de la aplicación.
///
/// Esta clase contiene las constantes de todas las rutas de la aplicación.
/// Usar estas constantes en lugar de strings directamente para evitar errores.
class AppRoutes {
  /// Rutas de inicialización y autenticación
  static const splash = '/splash';

  /// Ruta de bienvenida/introducción
  static const welcome = '/welcome';

  /// Rutas de autenticación
  static const auth = '/auth';

  /// Rutas de login
  static const login = '/auth/login';

  /// Rutas de registro
  static const register = '/auth/register';

  /// Rutas de acceso para miembros/invitados
  static const memberAccess = '/auth/member-access';

  /// Rutas de completar perfil
  static const completeProfile = '/auth/complete-profile';

  /// Rutas de recuperar contraseña
  static const forgotPassword = '/auth/forgot-password';

  /// Rutas principales
  static const home = '/home';

  /// Rutas de academias
  static const academies = '/academies';

  /// Rutas de detalles de academia
  static const academyDetails = '/academies/:academyId';

  /// Rutas de perfil
  static const profile = '/profile';

  /// Rutas de ajustes
  static const settings = '/settings';

  /// Rutas de desarrollo
  static const underDevelopment = '/under-development';

  /// Route name for creating a new academy.
  static const String createAcademy = '/create-academy';

  // --- Rutas de Gestión de Academia (Propietario) ---
  static const String academyDashboard = '/academy/:academyId';
  static const String editAcademy = '/academy/:academyId/edit';
  static const String academyMembers = '/academy/:academyId/members';
  static const String inviteMember = '/academy/:academyId/members/invite';

  // --- Rutas de Gestión de Miembros ---
  // static const String memberProfile = '/member/:memberId';

  /// Editar permisos de un miembro (/:academyId/members/:membershipId/permissions)
  static const String editMemberPermissions = ':membershipId/permissions';

  // --- Rutas de Gestión de Pagos ---
  /// Lista de pagos de la academia
  static const String payments = '/academy/:academyId/payments';
  
  /// Registrar un nuevo pago
  static const String registerPayment = '/academy/:academyId/payments/register';
  
  /// Ver detalles de un pago
  static const String paymentDetails = '/academy/:academyId/payments/:paymentId';
  
  /// Editar un pago existente
  static const String editPayment = '/academy/:academyId/payments/:paymentId/edit';
}
