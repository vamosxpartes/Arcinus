import 'package:freezed_annotation/freezed_annotation.dart';

part 'enums.g.dart';

/// Tipo de administrador en una academia
@JsonEnum(alwaysCreate: true)
enum AdminType {
  /// Propietario de la academia - tiene todos los permisos
  owner,
  
  /// Socio/Colaborador - tiene permisos específicos asignados por el propietario
  partner,
}

/// Tipo de miembro en una academia
@JsonEnum(alwaysCreate: true)
enum MemberType {
  /// Atleta - persona que practica el deporte
  athlete,
  
  /// Padre/Responsable - tutor legal de un atleta
  parent,
}

/// Estado de un administrador en la academia
@JsonEnum(alwaysCreate: true)
enum ManagerStatus {
  /// Manager activo con permisos completos según su configuración
  active,
  
  /// Manager con acceso restringido temporalmente
  restricted,
  
  /// Manager inactivo, sin acceso a la academia
  inactive,
  
  /// Manager suspendido por el propietario
  suspended,
}

/// Permisos específicos que pueden tener los administradores
@JsonEnum(alwaysCreate: true)
enum ManagerPermission {
  // Gestión de usuarios
  /// Gestionar usuarios (crear, editar, activar/desactivar)
  manageUsers,
  
  /// Invitar nuevos usuarios a la academia
  inviteUsers,
  
  /// Remover usuarios de la academia
  removeUsers,
  
  // Gestión financiera
  /// Gestionar pagos (registrar, editar, eliminar)
  managePayments,
  
  /// Ver información de pagos y estados financieros
  viewPayments,
  
  /// Gestionar planes de suscripción de la academia
  manageSubscriptions,
  
  // Gestión de academia
  /// Editar información básica de la academia
  editAcademyInfo,
  
  /// Gestionar horarios y cronogramas
  manageSchedule,
  
  /// Gestionar equipos y grupos
  manageTeams,
  
  // Análisis y reportes
  /// Ver estadísticas y métricas de la academia
  viewStatistics,
  
  /// Exportar datos de la academia
  exportData,
  
  /// Generar reportes personalizados
  generateReports,
  
  // Configuración avanzada
  /// Gestionar permisos de otros administradores (solo para propietarios)
  managePermissions,
  
  /// Acceso completo a todas las funcionalidades (solo para propietarios)
  fullAccess,
}

/// Extensiones para facilitar el trabajo con las enumeraciones
extension AdminTypeExtension on AdminType {
  /// Convierte el enum a string para serialización
  String toJson() => name;
  
  /// Crea el enum desde string
  static AdminType fromJson(String json) => AdminType.values.byName(json);
  
  /// Verifica si es propietario
  bool get isOwner => this == AdminType.owner;
  
  /// Verifica si es socio/colaborador
  bool get isPartner => this == AdminType.partner;
}

extension MemberTypeExtension on MemberType {
  /// Convierte el enum a string para serialización
  String toJson() => name;
  
  /// Crea el enum desde string
  static MemberType fromJson(String json) => MemberType.values.byName(json);
  
  /// Verifica si es atleta
  bool get isAthlete => this == MemberType.athlete;
  
  /// Verifica si es padre
  bool get isParent => this == MemberType.parent;
}

extension ManagerStatusExtension on ManagerStatus {
  /// Convierte el enum a string para serialización
  String toJson() => name;
  
  /// Crea el enum desde string
  static ManagerStatus fromJson(String json) => ManagerStatus.values.byName(json);
  
  /// Verifica si el manager puede acceder al sistema
  bool get canAccess => this == ManagerStatus.active || this == ManagerStatus.restricted;
  
  /// Verifica si el manager tiene acceso completo
  bool get hasFullAccess => this == ManagerStatus.active;
}

extension ManagerPermissionExtension on ManagerPermission {
  /// Convierte el enum a string para serialización
  String toJson() => name;
  
  /// Crea el enum desde string
  static ManagerPermission fromJson(String json) => ManagerPermission.values.byName(json);
  
  /// Verifica si es un permiso relacionado con usuarios
  bool get isUserPermission => [
    ManagerPermission.manageUsers,
    ManagerPermission.inviteUsers,
    ManagerPermission.removeUsers,
  ].contains(this);
  
  /// Verifica si es un permiso relacionado con finanzas
  bool get isFinancialPermission => [
    ManagerPermission.managePayments,
    ManagerPermission.viewPayments,
    ManagerPermission.manageSubscriptions,
  ].contains(this);
  
  /// Verifica si es un permiso relacionado con configuración de academia
  bool get isAcademyConfigPermission => [
    ManagerPermission.editAcademyInfo,
    ManagerPermission.manageSchedule,
    ManagerPermission.manageTeams,
  ].contains(this);
  
  /// Verifica si es un permiso relacionado con análisis
  bool get isAnalyticsPermission => [
    ManagerPermission.viewStatistics,
    ManagerPermission.exportData,
    ManagerPermission.generateReports,
  ].contains(this);
  
  /// Verifica si es un permiso administrativo avanzado
  bool get isAdvancedPermission => [
    ManagerPermission.managePermissions,
    ManagerPermission.fullAccess,
  ].contains(this);
}

/// Utilidades para trabajar con listas de permisos
extension ManagerPermissionListExtension on List<ManagerPermission> {
  /// Verifica si la lista contiene acceso completo
  bool get hasFullAccess => contains(ManagerPermission.fullAccess);
  
  /// Verifica si tiene un permiso específico o acceso completo
  bool hasPermission(ManagerPermission permission) {
    return hasFullAccess || contains(permission);
  }
  
  /// Verifica si puede gestionar usuarios
  bool get canManageUsers => hasPermission(ManagerPermission.manageUsers);
  
  /// Verifica si puede gestionar pagos
  bool get canManagePayments => hasPermission(ManagerPermission.managePayments);
  
  /// Verifica si puede ver estadísticas
  bool get canViewStatistics => hasPermission(ManagerPermission.viewStatistics);
  
  /// Verifica si puede gestionar permisos (solo propietarios)
  bool get canManagePermissions => hasPermission(ManagerPermission.managePermissions);
  
  /// Agrupa permisos por categoría
  Map<String, List<ManagerPermission>> groupByCategory() {
    return {
      'Usuarios': where((p) => p.isUserPermission).toList(),
      'Finanzas': where((p) => p.isFinancialPermission).toList(),
      'Academia': where((p) => p.isAcademyConfigPermission).toList(),
      'Análisis': where((p) => p.isAnalyticsPermission).toList(),
      'Administración': where((p) => p.isAdvancedPermission).toList(),
    };
  }
} 