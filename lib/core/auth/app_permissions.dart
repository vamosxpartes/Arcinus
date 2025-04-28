/// Define los permisos disponibles para colaboradores en las academias.
///
/// Estos permisos controlan las acciones específicas que un colaborador
/// puede realizar dentro de una academia.
class AppPermissions {
  // Permisos para gestión de atletas
  static const String manageAthletes = 'manage_athletes';
  static const String viewAthletes = 'view_athletes';
  
  // Permisos para gestión de grupos/equipos
  static const String manageGroups = 'manage_groups';
  static const String viewGroups = 'view_groups';
  
  // Permisos para asistencia
  static const String recordAttendance = 'record_attendance';
  static const String viewAttendance = 'view_attendance';
  
  // Permisos para gestión de pagos
  static const String managePayments = 'manage_payments';
  static const String viewPayments = 'view_payments';
  
  // Permisos para entrenamientos
  static const String manageTrainings = 'manage_trainings';
  static const String viewTrainings = 'view_trainings';
  
  // Permisos para eventos
  static const String manageEvents = 'manage_events';
  static const String viewEvents = 'view_events';
  
  // Permisos para membresías
  static const String inviteMembers = 'invite_members';
  static const String manageMemberships = 'manage_memberships';
  static const String viewMembers = 'view_members';
  
  /// Lista completa de todos los permisos disponibles.
  static List<String> allPermissions = [
    manageAthletes, viewAthletes,
    manageGroups, viewGroups, 
    recordAttendance, viewAttendance,
    managePayments, viewPayments,
    manageTrainings, viewTrainings,
    manageEvents, viewEvents,
    inviteMembers, manageMemberships, viewMembers,
  ];
  
  /// Obtiene la descripción legible de un permiso.
  static String getDescription(String permission) {
    switch (permission) {
      case manageAthletes: return 'Administrar atletas';
      case viewAthletes: return 'Ver atletas';
      case manageGroups: return 'Administrar grupos/equipos';
      case viewGroups: return 'Ver grupos/equipos';
      case recordAttendance: return 'Registrar asistencia';
      case viewAttendance: return 'Ver registros de asistencia';
      case managePayments: return 'Administrar pagos';
      case viewPayments: return 'Ver registros de pagos';
      case manageTrainings: return 'Administrar entrenamientos';
      case viewTrainings: return 'Ver entrenamientos';
      case manageEvents: return 'Administrar eventos';
      case viewEvents: return 'Ver eventos';
      case inviteMembers: return 'Invitar miembros';
      case manageMemberships: return 'Administrar membresías';
      case viewMembers: return 'Ver miembros';
      default: return permission;
    }
  }
  
  /// Agrupa los permisos por categoría para mostrar en la UI.
  static Map<String, List<String>> getGroupedPermissions() {
    return {
      'Atletas': [viewAthletes, manageAthletes],
      'Grupos/Equipos': [viewGroups, manageGroups],
      'Asistencia': [viewAttendance, recordAttendance],
      'Pagos': [viewPayments, managePayments],
      'Entrenamientos': [viewTrainings, manageTrainings],
      'Eventos': [viewEvents, manageEvents],
      'Membresías': [viewMembers, inviteMembers, manageMemberships],
    };
  }
} 