import 'package:freezed_annotation/freezed_annotation.dart';

part 'academy_user_enums.g.dart';

/// Tipo de administrador en una academia
@JsonEnum(alwaysCreate: true)
enum AdminType {
  /// Propietario de la academia (acceso completo)
  owner,
  
  /// Socio o colaborador con permisos específicos
  partner;

  /// Helper para obtener el tipo desde un String
  static AdminType fromString(String? typeString) {
    if (typeString == null) return AdminType.partner;
    return AdminType.values.asNameMap()[typeString] ?? AdminType.partner;
  }
}

/// Tipo de miembro en una academia
@JsonEnum(alwaysCreate: true)
enum MemberType {
  /// Atleta de la academia
  athlete,
  
  /// Padre o responsable legal
  parent;

  /// Helper para obtener el tipo desde un String
  static MemberType fromString(String? typeString) {
    if (typeString == null) return MemberType.athlete;
    return MemberType.values.asNameMap()[typeString] ?? MemberType.athlete;
  }
}

/// Permisos granulares para gestores de academia
@JsonEnum(alwaysCreate: true)
enum ManagerPermission {
  // === Gestión de usuarios ===
  /// Gestionar usuarios de la academia
  manageUsers,
  
  /// Invitar nuevos usuarios
  inviteUsers,
  
  /// Remover usuarios de la academia
  removeUsers,
  
  /// Ver detalles de usuarios
  viewUsers,
  
  // === Gestión financiera ===
  /// Gestionar pagos y cobros
  managePayments,
  
  /// Ver historial de pagos
  viewPayments,
  
  /// Gestionar suscripciones
  manageSubscriptions,
  
  /// Generar reportes financieros
  generateFinancialReports,
  
  // === Gestión de academia ===
  /// Editar información de la academia
  editAcademyInfo,
  
  /// Gestionar horarios y clases
  manageSchedule,
  
  /// Gestionar equipos deportivos
  manageTeams,
  
  /// Gestionar instalaciones
  manageFacilities,
  
  // === Análisis y reportes ===
  /// Ver estadísticas de la academia
  viewStatistics,
  
  /// Exportar datos
  exportData,
  
  /// Generar reportes generales
  generateReports,
  
  /// Acceso a analytics avanzado
  viewAdvancedAnalytics,
  
  // === Configuración ===
  /// Gestionar permisos de otros usuarios (solo para owners)
  managePermissions,
  
  /// Acceso completo (solo para owners)
  fullAccess,
  
  // === Comunicación ===
  /// Enviar notificaciones
  sendNotifications,
  
  /// Gestionar comunicaciones
  manageCommunications;

  /// Helper para obtener el permiso desde un String
  static ManagerPermission fromString(String? permissionString) {
    if (permissionString == null) return ManagerPermission.viewUsers;
    return ManagerPermission.values.asNameMap()[permissionString] ?? 
           ManagerPermission.viewUsers;
  }
}

/// Estado de un gestor en una academia
@JsonEnum(alwaysCreate: true)
enum ManagerStatus {
  /// Manager activo con todos sus permisos
  active,
  
  /// Acceso restringido temporalmente
  restricted,
  
  /// Manager inactivo (sin acceso)
  inactive,
  
  /// Suspendido por el propietario
  suspended;

  /// Helper para obtener el estado desde un String
  static ManagerStatus fromString(String? statusString) {
    if (statusString == null) return ManagerStatus.active;
    return ManagerStatus.values.asNameMap()[statusString] ?? 
           ManagerStatus.active;
  }
}

/// Estado de pago de un miembro
@JsonEnum(alwaysCreate: true)
enum PaymentStatus {
  /// Pagos al día
  upToDate,
  
  /// Pago pendiente (dentro del período de gracia)
  pending,
  
  /// Pago atrasado
  overdue,
  
  /// Cuenta suspendida por falta de pago
  suspended,
  
  /// Exonerado de pagos
  exempt;

  /// Helper para obtener el estado desde un String
  static PaymentStatus fromString(String? statusString) {
    if (statusString == null) return PaymentStatus.upToDate;
    return PaymentStatus.values.asNameMap()[statusString] ?? 
           PaymentStatus.upToDate;
  }
}

/// Extensiones para AdminType
extension AdminTypeExtension on AdminType {
  String toJson() => name;
  static AdminType fromJson(String json) => AdminType.fromString(json);
  
  /// Verifica si es propietario
  bool get isOwner => this == AdminType.owner;
  
  /// Verifica si es socio
  bool get isPartner => this == AdminType.partner;
}

/// Extensiones para MemberType
extension MemberTypeExtension on MemberType {
  String toJson() => name;
  static MemberType fromJson(String json) => MemberType.fromString(json);
  
  /// Verifica si es atleta
  bool get isAthlete => this == MemberType.athlete;
  
  /// Verifica si es padre
  bool get isParent => this == MemberType.parent;
}

/// Extensiones para ManagerPermission
extension ManagerPermissionExtension on ManagerPermission {
  String toJson() => name;
  static ManagerPermission fromJson(String json) => ManagerPermission.fromString(json);
  
  /// Verifica si es un permiso de administración completa
  bool get isFullAccessPermission => this == ManagerPermission.fullAccess;
  
  /// Verifica si es un permiso relacionado con usuarios
  bool get isUserRelated => [
    ManagerPermission.manageUsers,
    ManagerPermission.inviteUsers,
    ManagerPermission.removeUsers,
    ManagerPermission.viewUsers,
  ].contains(this);
  
  /// Verifica si es un permiso financiero
  bool get isFinancialRelated => [
    ManagerPermission.managePayments,
    ManagerPermission.viewPayments,
    ManagerPermission.manageSubscriptions,
    ManagerPermission.generateFinancialReports,
  ].contains(this);
}

/// Extensiones para ManagerStatus
extension ManagerStatusExtension on ManagerStatus {
  String toJson() => name;
  static ManagerStatus fromJson(String json) => ManagerStatus.fromString(json);
  
  /// Verifica si el manager puede operar
  bool get canOperate => this == ManagerStatus.active;
  
  /// Verifica si está suspendido o inactivo
  bool get isBlocked => [ManagerStatus.suspended, ManagerStatus.inactive].contains(this);
}

/// Extensiones para PaymentStatus
extension PaymentStatusExtension on PaymentStatus {
  String toJson() => name;
  static PaymentStatus fromJson(String json) => PaymentStatus.fromString(json);
  
  /// Verifica si está al día con los pagos
  bool get isUpToDate => this == PaymentStatus.upToDate;
  
  /// Verifica si tiene problemas de pago
  bool get hasPaymentIssues => [
    PaymentStatus.overdue, 
    PaymentStatus.suspended
  ].contains(this);
} 