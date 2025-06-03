/// Rutas específicas del Collaborator Shell.
///
/// Contiene todas las rutas relacionadas con la funcionalidad del Colaborador.
class CollaboratorRoutes {
  // --- Ruta base del shell ---
  static const String root = '/collaborator';
  
  // --- Rutas principales ---
  static const String dashboard = 'collaborator_dashboard'; // Relativa a /collaborator
  
  // --- Grupos ---
  static const String groups = 'groups';
  static const String groupDetails = 'groups/:groupId';
  static const String groupMembers = 'groups/:groupId/members';
  static const String groupTrainings = 'groups/:groupId/trainings';
  
  // --- Asistencia ---
  static const String attendance = 'attendance';
  static const String attendanceHistory = 'attendance/history';
  static const String attendanceReport = 'attendance/report';
  
  // --- Entrenamientos ---
  static const String trainings = 'trainings';
  static const String trainingCreate = 'trainings/create';
  static const String trainingEdit = 'trainings/:trainingId/edit';
  
  // --- Perfil ---
  static const String profile = 'profile';
  static const String settings = 'settings';
} 