import 'package:arcinus/core/auth/models/models.dart';
import 'package:fpdart/fpdart.dart';

/// Error específico para operaciones de Arcinus Manager
abstract class Failure {
  const Failure();
}

class SystemFailure extends Failure {
  final String message;
  final String? code;
  final dynamic error;
  
  const SystemFailure({
    required this.message,
    this.code,
    this.error,
  });
}

/// Repositorio para operaciones del sistema Arcinus Manager
/// 
/// Gestiona todas las funcionalidades de super administración:
/// - Supervisión global del sistema
/// - Gestión de academias
/// - Gestión de propietarios
/// - Auditoría y análisis
abstract class ArcinusManagerRepository {
  // ========================================
  // GESTIÓN DE SUPER ADMINISTRADORES
  // ========================================
  
  /// Obtiene la lista de todos los super administradores
  Future<Either<Failure, List<BaseUser>>> getSuperAdmins();
  
  /// Promueve un usuario a super administrador
  /// Solo super administradores existentes pueden hacer esta operación
  Future<Either<Failure, void>> promoteToSuperAdmin({
    required String userId,
    required String promotedBy,
    String? reason,
  });
  
  /// Revoca permisos de super administrador
  Future<Either<Failure, void>> revokeSuperAdmin({
    required String userId,
    required String revokedBy,
    required String reason,
  });
  
  // ========================================
  // SUPERVISIÓN GLOBAL
  // ========================================
  
  /// Obtiene estadísticas generales del sistema
  Future<Either<Failure, SystemStatistics>> getSystemStatistics();
  
  /// Obtiene la lista de todas las academias en el sistema
  Future<Either<Failure, List<AcademyOverview>>> getAllAcademies({
    int? limit,
    String? lastDocumentId,
    AcademyStatus? statusFilter,
  });
  
  /// Obtiene métricas de rendimiento del sistema
  Future<Either<Failure, PerformanceMetrics>> getPerformanceMetrics({
    DateTime? fromDate,
    DateTime? toDate,
  });
  
  /// Obtiene alertas del sistema que requieren atención
  Future<Either<Failure, List<SystemAlert>>> getSystemAlerts({
    AlertSeverity? severityFilter,
    bool onlyUnresolved = true,
  });
  
  // ========================================
  // GESTIÓN DE ACADEMIAS
  // ========================================
  
  /// Obtiene detalles completos de una academia específica
  Future<Either<Failure, AcademyDetailView>> getAcademyDetails(String academyId);
  
  /// Suspende una academia temporalmente
  Future<Either<Failure, void>> suspendAcademy({
    required String academyId,
    required String reason,
    required String suspendedBy,
    DateTime? suspendUntil,
  });
  
  /// Reactiva una academia suspendida
  Future<Either<Failure, void>> reactivateAcademy({
    required String academyId,
    required String reactivatedBy,
    String? notes,
  });
  
  /// Elimina permanentemente una academia (soft delete)
  Future<Either<Failure, void>> deleteAcademy({
    required String academyId,
    required String reason,
    required String deletedBy,
  });
  
  // ========================================
  // GESTIÓN DE PROPIETARIOS
  // ========================================
  
  /// Obtiene lista de todos los propietarios de academias
  Future<Either<Failure, List<OwnerOverview>>> getAllOwners({
    int? limit,
    String? lastDocumentId,
  });
  
  /// Transfiere la propiedad de una academia
  Future<Either<Failure, void>> transferAcademyOwnership({
    required String academyId,
    required String currentOwnerId,
    required String newOwnerId,
    required String transferredBy,
    required String reason,
  });
  
  /// Obtiene el historial de un propietario específico
  Future<Either<Failure, OwnerHistory>> getOwnerHistory(String ownerId);
  
  // ========================================
  // AUDITORÍA Y LOGS
  // ========================================
  
  /// Obtiene logs de auditoría del sistema
  Future<Either<Failure, List<AuditLog>>> getAuditLogs({
    DateTime? fromDate,
    DateTime? toDate,
    String? userId,
    String? academyId,
    AuditEventType? eventType,
    int? limit,
    String? lastDocumentId,
  });
  
  /// Registra un evento de auditoría
  Future<Either<Failure, void>> logAuditEvent({
    required String userId,
    required AuditEventType eventType,
    required String description,
    required Map<String, dynamic> details,
    String? academyId,
    String? targetUserId,
  });
  
  /// Exporta datos del sistema para análisis
  Future<Either<Failure, SystemExport>> exportSystemData({
    required ExportType exportType,
    DateTime? fromDate,
    DateTime? toDate,
    List<String>? academyIds,
  });
  
  // ========================================
  // CONFIGURACIÓN DEL SISTEMA
  // ========================================
  
  /// Obtiene configuraciones globales del sistema
  Future<Either<Failure, SystemConfiguration>> getSystemConfiguration();
  
  /// Actualiza configuraciones del sistema
  Future<Either<Failure, void>> updateSystemConfiguration({
    required String updatedBy,
    required Map<String, dynamic> configurations,
    String? reason,
  });
  
  /// Obtiene límites y cuotas del sistema
  Future<Either<Failure, SystemLimits>> getSystemLimits();
  
  /// Actualiza límites del sistema
  Future<Either<Failure, void>> updateSystemLimits({
    required String updatedBy,
    required SystemLimits newLimits,
    required String reason,
  });
}

// ========================================
// MODELOS DE DATOS
// ========================================

/// Estadísticas generales del sistema
class SystemStatistics {
  final int totalAcademies;
  final int activeAcademies;
  final int suspendedAcademies;
  final int totalUsers;
  final int totalOwners;
  final int totalAthletes;
  final int totalParents;
  final double totalRevenue;
  final DateTime lastUpdated;
  
  const SystemStatistics({
    required this.totalAcademies,
    required this.activeAcademies,
    required this.suspendedAcademies,
    required this.totalUsers,
    required this.totalOwners,
    required this.totalAthletes,
    required this.totalParents,
    required this.totalRevenue,
    required this.lastUpdated,
  });
}

/// Vista general de academia para super administradores
class AcademyOverview {
  final String id;
  final String name;
  final String ownerName;
  final String ownerEmail;
  final AcademyStatus status;
  final int totalMembers;
  final double monthlyRevenue;
  final DateTime createdAt;
  final DateTime? lastActivity;
  
  const AcademyOverview({
    required this.id,
    required this.name,
    required this.ownerName,
    required this.ownerEmail,
    required this.status,
    required this.totalMembers,
    required this.monthlyRevenue,
    required this.createdAt,
    this.lastActivity,
  });
}

/// Estados posibles de una academia
enum AcademyStatus {
  active,
  suspended,
  inactive,
  deleted,
}

/// Vista detallada de academia
class AcademyDetailView {
  final AcademyOverview overview;
  final List<String> adminIds;
  final Map<String, dynamic> metrics;
  final List<String> recentAlerts;
  final Map<String, int> membersByRole;
  
  const AcademyDetailView({
    required this.overview,
    required this.adminIds,
    required this.metrics,
    required this.recentAlerts,
    required this.membersByRole,
  });
}

/// Métricas de rendimiento del sistema
class PerformanceMetrics {
  final double averageResponseTime;
  final int totalRequests;
  final int errorRate;
  final double uptime;
  final Map<String, dynamic> resourceUsage;
  final DateTime measuredAt;
  
  const PerformanceMetrics({
    required this.averageResponseTime,
    required this.totalRequests,
    required this.errorRate,
    required this.uptime,
    required this.resourceUsage,
    required this.measuredAt,
  });
}

/// Alerta del sistema
class SystemAlert {
  final String id;
  final AlertSeverity severity;
  final String title;
  final String message;
  final String? academyId;
  final bool isResolved;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? resolvedBy;
  
  const SystemAlert({
    required this.id,
    required this.severity,
    required this.title,
    required this.message,
    this.academyId,
    required this.isResolved,
    required this.createdAt,
    this.resolvedAt,
    this.resolvedBy,
  });
}

/// Niveles de severidad de alertas
enum AlertSeverity {
  low,
  medium,
  high,
  critical,
}

/// Vista general de propietario
class OwnerOverview {
  final String id;
  final String name;
  final String email;
  final int academiesCount;
  final int totalMembers;
  final double totalRevenue;
  final DateTime registeredAt;
  final DateTime? lastLogin;
  
  const OwnerOverview({
    required this.id,
    required this.name,
    required this.email,
    required this.academiesCount,
    required this.totalMembers,
    required this.totalRevenue,
    required this.registeredAt,
    this.lastLogin,
  });
}

/// Historial de un propietario
class OwnerHistory {
  final OwnerOverview owner;
  final List<AcademyOverview> academies;
  final List<AuditLog> recentActions;
  final Map<String, dynamic> analytics;
  
  const OwnerHistory({
    required this.owner,
    required this.academies,
    required this.recentActions,
    required this.analytics,
  });
}

/// Log de auditoría
class AuditLog {
  final String id;
  final String userId;
  final String userName;
  final AuditEventType eventType;
  final String description;
  final Map<String, dynamic> details;
  final String? academyId;
  final String? targetUserId;
  final DateTime timestamp;
  
  const AuditLog({
    required this.id,
    required this.userId,
    required this.userName,
    required this.eventType,
    required this.description,
    required this.details,
    this.academyId,
    this.targetUserId,
    required this.timestamp,
  });
}

/// Tipos de eventos de auditoría
enum AuditEventType {
  userCreated,
  userDeleted,
  userPromoted,
  userSuspended,
  academyCreated,
  academyDeleted,
  academySuspended,
  ownershipTransferred,
  systemConfigChanged,
  dataExported,
  loginAttempt,
  failedLogin,
}

/// Exportación de datos del sistema
class SystemExport {
  final String id;
  final ExportType type;
  final String downloadUrl;
  final int recordCount;
  final DateTime createdAt;
  final DateTime? expiresAt;
  
  const SystemExport({
    required this.id,
    required this.type,
    required this.downloadUrl,
    required this.recordCount,
    required this.createdAt,
    this.expiresAt,
  });
}

/// Tipos de exportación
enum ExportType {
  users,
  academies,
  auditLogs,
  analytics,
  full,
}

/// Configuración del sistema
class SystemConfiguration {
  final Map<String, dynamic> globalSettings;
  final Map<String, dynamic> featureFlags;
  final Map<String, dynamic> integrations;
  final DateTime lastUpdated;
  final String lastUpdatedBy;
  
  const SystemConfiguration({
    required this.globalSettings,
    required this.featureFlags,
    required this.integrations,
    required this.lastUpdated,
    required this.lastUpdatedBy,
  });
}

/// Límites del sistema
class SystemLimits {
  final int maxAcademiesPerOwner;
  final int maxMembersPerAcademy;
  final int maxAdminsPerAcademy;
  final double maxStoragePerAcademy;
  final Map<String, dynamic> customLimits;
  
  const SystemLimits({
    required this.maxAcademiesPerOwner,
    required this.maxMembersPerAcademy,
    required this.maxAdminsPerAcademy,
    required this.maxStoragePerAcademy,
    required this.customLimits,
  });
} 