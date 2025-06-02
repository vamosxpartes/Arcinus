/// Tipos de permisos que puede tener un manager
enum ManagerPermission {
  /// Permiso para gestionar usuarios (añadir, modificar, eliminar)
  manageUsers,
  
  /// Permiso para gestionar pagos (registrar, modificar, eliminar)
  managePayments,
  
  /// Permiso para gestionar suscripciones y planes
  manageSubscriptions,
  
  /// Permiso para ver estadísticas y reportes
  viewStats,
  
  /// Permiso para modificar configuración de academia
  editAcademy,
  
  /// Permiso para gestionar horarios y eventos
  manageSchedule,
  
  /// Permiso para acceder a todas las funcionalidades (solo propietarios)
  fullAccess
}