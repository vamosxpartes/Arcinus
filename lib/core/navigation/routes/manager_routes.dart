/// Rutas específicas del Manager Shell.
///
/// Contiene todas las rutas compartidas entre Owner y Collaborator.
class ManagerRoutes {
  // --- Ruta base del shell ---
  static const String root = '/manager';
  
  // --- Rutas principales ---
  static const String dashboard = '/manager/dashboard';
  static const String createAcademy = '/manager/create-academy';
  
  // --- Academia específica ---
  static const String academy = '/manager/academy/:academyId';
  static const String academyMembers = '/manager/academy/:academyId/members';
  static const String academyPayments = '/manager/academy/:academyId/payments';
  static const String academySubscriptionPlans = 'subscription-plans'; // Relativa
  
  // --- Perfil y configuración ---
  static const String profile = '/manager/profile';
  static const String settings = '/manager/settings';
  
  // --- Herramientas de desarrollo ---
  static const String useCaseTest = '/manager/dev-tools/use-case-test';
  
  // --- Rutas de academia (base) ---
  static const String academyPath = '/manager/academy/:academyId';
} 