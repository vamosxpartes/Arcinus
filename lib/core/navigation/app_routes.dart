/// Rutas estáticas de la aplicación.
///
/// Esta clase contiene las constantes de todas las rutas de la aplicación.
/// Usar estas constantes en lugar de strings directamente para evitar errores.
class AppRoutes {
  /// Rutas de inicialización y autenticación
  static const splash = '/splash';

  /// Ruta de bienvenida/introducción
  static const welcome = '/welcome';

  /// Rutas de autenticación (prefijo general, no usar directamente para ir)
  static const auth = '/auth';

  /// Rutas de login
  static const login = '/auth/login';

  /// Rutas de registro
  static const register = '/auth/register';

  /// Rutas de acceso para miembros/invitados
  static const memberAccess = '/auth/member-access';

  /// Rutas de recuperar contraseña
  static const forgotPassword = '/auth/forgot-password';

  // --- Rutas Raíz de Shell por Rol ---
  static const ownerRoot = '/owner';
  static const athleteRoot = '/athlete';
  static const collaboratorRoot = '/collaborator';
  static const superAdminRoot = '/superadmin';
  static const parentRoot = '/parent';
  
  // --- Ruta para shell compartido de Manager (owner y colaborador) ---
  static const managerRoot = '/manager';

  /// Rutas principales (Obsoleto/Reemplazado por rutas dentro de shells)
  // static const home = '/home';

  /// Rutas de academias (Serán relativas dentro del shell de owner)
  // static const academies = '/academies';
  // static const academyDetails = '/academies/:academyId'; // Usar nombres relativos ahora

  /// Rutas de perfil (Será relativa dentro de cada shell)
  // static const profile = '/profile';

  /// Rutas de ajustes (Será relativa dentro de cada shell)
  // static const settings = '/settings';

  /// Rutas de desarrollo
  static const underDevelopment = '/under-development';

  /// Route name for creating a new academy.
  static const String createAcademy = '/create-academy';

  // --- Rutas unificadas para Manager (Propietario y Colaborador) ---
  static const String managerDashboard = '/manager/dashboard';
  static const String managerCreateAcademy = '/manager/create-academy';
  static const String managerAcademy = '/manager/academy/:academyId';
  static const String managerAcademyMembers = '/manager/academy/:academyId/members';
  static const String managerAcademyPayments = '/manager/academy/:academyId/payments';
  static const String managerProfile = '/manager/profile';
  static const String managerSettings = '/manager/settings';
  
  // Rutas de academia específicas dentro de manager
  static const String managerAcademyPath = '/manager/academy/:academyId';
  static const String managerAcademySubscriptionPlans = 'subscription-plans';
  
  // --- Rutas Relativas dentro del Shell del Propietario (`ownerRoot`) ---
  static const String ownerDashboard = 'owner_dashboard'; // Relativa a /owner
  static const String ownerAcademy = 'academy/:academyId'; // Relativa a /owner
  static const String ownerEditAcademy = 'academy/:academyId/edit';
  static const String ownerAcademyMembers = 'academy/:academyId/members';
  static const String ownerInviteMember = 'academy/:academyId/members/invite';
  static const String ownerEditMemberPermissions = 'academy/:academyId/members/:membershipId/permissions';
  static const String ownerPayments = 'academy/:academyId/payments';
  static const String ownerRegisterPayment = 'academy/:academyId/payments/register';
  static const String ownerPaymentDetails = 'academy/:academyId/payments/:paymentId';
  static const String ownerEditPayment = 'academy/:academyId/payments/:paymentId/edit';
  
  // Rutas para la navegación principal del propietario (bottom navigation/drawer)
  static const String ownerMembers = 'members';
  static const String ownerSchedule = 'schedule';
  static const String ownerStats = 'stats';
  static const String ownerMore = 'more';
  static const String ownerGroups = 'groups';
  static const String ownerTrainings = 'trainings';
  static const String ownerAcademyDetails = 'academy_details';
  static const String ownerSettings = 'settings';
  static const String ownerProfileRoute = '/owner/profile'; // Nueva constante para la ruta completa
  static const String payments = 'payments'; // Ruta para la seccion de pagos del owner
  
  // Añadir aquí otras rutas específicas del Propietario (perfil, ajustes, etc.)
  // static const String ownerProfile = 'profile';
  // static const String ownerSettings = 'settings';


  // --- Rutas Relativas dentro del Shell del Atleta (`athleteRoot`) ---
  static const String athleteDashboard = 'athlete_dashboard'; // Relativa a /athlete
  // Añadir aquí otras rutas específicas del Atleta (entrenamientos, perfil, etc.)
  // static const String athleteTrainings = 'trainings';
  // static const String athleteProfile = 'profile';


  // --- Rutas Relativas dentro del Shell del Colaborador (`collaboratorRoot`) ---
  static const String collaboratorDashboard = 'collaborator_dashboard'; // Relativa a /collaborator
  // Añadir aquí otras rutas específicas del Colaborador (gestión de grupos, asistencia, etc.)
  // static const String collaboratorGroups = 'groups';
  // static const String collaboratorProfile = 'profile';

  // --- Rutas Relativas dentro del Shell del SuperAdmin (`superAdminRoot`) ---
  static const String superAdminDashboard = 'superadmin_dashboard'; // Relativa a /superadmin
  // Añadir aquí otras rutas específicas del SuperAdmin
  
  // --- Rutas Relativas dentro del Shell del Padre/Responsable (`parentRoot`) ---
  static const String parentDashboard = 'parent_dashboard'; // Relativa a /parent
  static const String parentAthletes = 'athletes'; // Listado de atletas a cargo
  static const String parentAthleteDetails = 'athletes/:athleteId'; // Detalles de un atleta específico
  static const String parentPayments = 'payments'; // Historial de pagos
  static const String parentSchedule = 'schedule'; // Calendario/horarios
  static const String parentProfile = 'profile'; // Perfil del padre
}
