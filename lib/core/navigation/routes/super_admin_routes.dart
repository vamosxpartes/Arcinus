/// Rutas específicas del SuperAdmin Shell.
///
/// Contiene todas las rutas relacionadas con la funcionalidad del SuperAdmin.
class SuperAdminRoutes {
  // --- Ruta base del shell ---
  static const String root = '/superadmin';
  
  // --- Rutas principales ---
  static const String dashboard = 'superadmin_dashboard'; // Relativa a /superadmin
  
  // --- Gestión de Usuarios ---
  static const String owners = '/superadmin/owners';
  static const String ownersApproval = '/superadmin/owners/pending-approval';
  static const String ownerDetails = '/superadmin/owners/:ownerId';
  
  // --- Gestión de Academias ---
  static const String academies = '/superadmin/academies';
  static const String academyDetails = '/superadmin/academies/:academyId';
  static const String academyEdit = '/superadmin/academies/:academyId/edit';
  static const String academyStatus = '/superadmin/academies/:academyId/status';
  
  // --- Gestión de Suscripciones ---
  static const String subscriptions = '/superadmin/subscriptions';
  static const String subscriptionPlans = '/superadmin/subscriptions/plans';
  static const String subscriptionPlanCreate = '/superadmin/subscriptions/plans/create';
  static const String subscriptionPlanEdit = '/superadmin/subscriptions/plans/:planId/edit';
  static const String subscriptionBilling = '/superadmin/subscriptions/billing';
  
  // --- Deportes Globales ---
  static const String sports = '/superadmin/sports';
  static const String sportCreate = '/superadmin/sports/create';
  static const String sportEdit = '/superadmin/sports/:sportId/edit';
  static const String sportCategories = '/superadmin/sports/:sportId/categories';
  
  // --- Sistema ---
  static const String systemBackups = '/superadmin/system/backups';
  static const String systemBackupCreate = '/superadmin/system/backups/create';
  static const String systemBackupRestore = '/superadmin/system/backups/:backupId/restore';
  static const String systemMaintenance = '/superadmin/system/maintenance';
  
  // --- Seguridad ---
  static const String security = '/superadmin/security';
  static const String securityAuditLogs = '/superadmin/security/audit-logs';
  static const String securityUserSessions = '/superadmin/security/user-sessions';
  static const String securityPermissions = '/superadmin/security/permissions';
  
  // --- Analytics ---
  static const String analytics = '/superadmin/analytics';
  static const String analyticsUsage = '/superadmin/analytics/usage';
  static const String analyticsPerformance = '/superadmin/analytics/performance';
  static const String analyticsRevenue = '/superadmin/analytics/revenue';
  
  // --- Configuración ---
  static const String settings = '/superadmin/settings';
  static const String settingsGeneral = '/superadmin/settings/general';
  static const String settingsNotifications = '/superadmin/settings/notifications';
  static const String settingsIntegrations = '/superadmin/settings/integrations';
  
  // --- Reportes ---
  static const String reports = '/superadmin/reports';
  static const String reportsGenerate = '/superadmin/reports/generate';
  static const String reportsHistory = '/superadmin/reports/history';
  
  // --- Usuarios Globales ---
  static const String users = '/superadmin/users';
  static const String userDetails = '/superadmin/users/:userId';
  static const String userSessions = '/superadmin/users/:userId/sessions';
  static const String userActivity = '/superadmin/users/:userId/activity';
} 