/// Rutas específicas del Athlete Shell.
///
/// Contiene todas las rutas relacionadas con la funcionalidad del Atleta.
class AthleteRoutes {
  // --- Ruta base del shell ---
  static const String root = '/athlete';
  
  // --- Rutas principales ---
  static const String dashboard = 'athlete_dashboard'; // Relativa a /athlete
  
  // --- Entrenamientos ---
  static const String trainings = 'trainings';
  static const String trainingDetails = 'trainings/:trainingId';
  static const String trainingHistory = 'trainings/history';
  
  // --- Progreso ---
  static const String progress = 'progress';
  static const String progressStats = 'progress/stats';
  static const String progressGoals = 'progress/goals';
  
  // --- Horarios ---
  static const String schedule = 'schedule';
  static const String scheduleWeekly = 'schedule/weekly';
  static const String scheduleMonthly = 'schedule/monthly';
  
  // --- Perfil ---
  static const String profile = 'profile';
  static const String settings = 'settings';
} 