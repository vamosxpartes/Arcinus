/// Rutas específicas del Owner Shell.
///
/// Contiene todas las rutas relacionadas con la funcionalidad del Propietario.
class OwnerRoutes {
  // --- Ruta base del shell ---
  static const String root = '/owner';
  
  // --- Rutas principales ---
  static const String dashboard = 'owner_dashboard'; // Relativa a /owner
  
  // --- Academia ---
  static const String academy = 'academy/:academyId'; // Relativa a /owner
  static const String editAcademy = 'academy/:academyId/edit';
  static const String academyDetails = 'academy_details';
  
  // --- Miembros ---
  static const String members = 'members';
  static const String academyMembers = 'academy/:academyId/members';
  static const String inviteMember = 'academy/:academyId/members/invite';
  static const String editMemberPermissions = 'academy/:academyId/members/:membershipId/permissions';
  
  // --- Pagos ---
  static const String payments = 'payments'; // Relativa a /owner
  static const String academyPayments = 'academy/:academyId/payments';
  static const String registerPayment = 'academy/:academyId/payments/register';
  static const String paymentDetails = 'academy/:academyId/payments/:paymentId';
  static const String editPayment = 'academy/:academyId/payments/:paymentId/edit';
  
  // --- Navegación principal ---
  static const String schedule = 'schedule';
  static const String stats = 'stats';
  static const String more = 'more';
  static const String groups = 'groups';
  static const String trainings = 'trainings';
  static const String settings = 'settings';
  
  // --- Perfil ---
  static const String profile = '/owner/profile'; // Ruta completa
} 