/// Rutas específicas del Parent Shell.
///
/// Contiene todas las rutas relacionadas con la funcionalidad del Padre/Responsable.
class ParentRoutes {
  // --- Ruta base del shell ---
  static const String root = '/parent';
  
  // --- Rutas principales ---
  static const String dashboard = 'parent_dashboard'; // Relativa a /parent
  
  // --- Atletas a cargo ---
  static const String athletes = 'athletes'; // Listado de atletas a cargo
  static const String athleteDetails = 'athletes/:athleteId'; // Detalles de un atleta específico
  static const String athleteProgress = 'athletes/:athleteId/progress';
  static const String athleteSchedule = 'athletes/:athleteId/schedule';
  
  // --- Pagos ---
  static const String payments = 'payments'; // Historial de pagos
  static const String paymentDetails = 'payments/:paymentId';
  static const String paymentHistory = 'payments/history';
  
  // --- Horarios ---
  static const String schedule = 'schedule'; // Calendario/horarios
  static const String scheduleWeekly = 'schedule/weekly';
  static const String scheduleMonthly = 'schedule/monthly';
  
  // --- Comunicación ---
  static const String messages = 'messages';
  static const String messageDetails = 'messages/:messageId';
  static const String notifications = 'notifications';
  
  // --- Perfil ---
  static const String profile = 'profile'; // Perfil del padre
  static const String settings = 'settings';
} 