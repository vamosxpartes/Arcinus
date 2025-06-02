/// Estados posibles para un usuario manager
enum ManagerStatus {
  /// Manager activo (con permisos completos según su rol)
  active,
  
  /// Manager con acceso restringido temporalmente
  restricted,
  
  /// Manager inactivo (sin acceso)
  inactive
}