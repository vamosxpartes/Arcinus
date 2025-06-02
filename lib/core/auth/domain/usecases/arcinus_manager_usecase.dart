import 'package:arcinus/core/auth/domain/repositories/arcinus_manager_repository.dart';
import 'package:arcinus/core/auth/models/models.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:fpdart/fpdart.dart';

/// Caso de uso principal para operaciones del sistema Arcinus Manager
/// 
/// Encapsula toda la lógica de negocio para:
/// - Supervisión global del sistema
/// - Gestión de academias y propietarios  
/// - Auditoría y análisis
/// - Configuración del sistema
class ArcinusManagerUseCase {
  final ArcinusManagerRepository _repository;
  
  const ArcinusManagerUseCase(this._repository);
  
  // ========================================
  // GESTIÓN DE SUPER ADMINISTRADORES
  // ========================================
  
  /// Obtiene la lista de todos los super administradores
  Future<Either<Failure, List<BaseUser>>> getSuperAdmins() async {
    try {
      AppLogger.logInfo(
        'Obteniendo lista de super administradores',
        className: 'ArcinusManagerUseCase',
        functionName: 'getSuperAdmins',
      );
      
      return await _repository.getSuperAdmins();
    } catch (error) {
      AppLogger.logError(
        message: 'Error al obtener super administradores',
        error: error,
        className: 'ArcinusManagerUseCase',
        functionName: 'getSuperAdmins',
      );
      return Left(SystemFailure(
        message: 'Error al obtener super administradores',
        error: error,
      ));
    }
  }
  
  /// Promueve un usuario a super administrador
  Future<Either<Failure, void>> promoteToSuperAdmin({
    required String userId,
    required String promotedBy,
    String? reason,
  }) async {
    try {
      // Validaciones de negocio
      if (userId.isEmpty) {
        return const Left(SystemFailure(
          message: 'ID de usuario requerido',
          code: 'INVALID_USER_ID',
        ));
      }
      
      if (promotedBy.isEmpty) {
        return const Left(SystemFailure(
          message: 'ID del promotor requerido',
          code: 'INVALID_PROMOTER_ID',
        ));
      }
      
      if (userId == promotedBy) {
        return const Left(SystemFailure(
          message: 'Un usuario no puede promoverse a sí mismo',
          code: 'SELF_PROMOTION_NOT_ALLOWED',
        ));
      }
      
      AppLogger.logInfo(
        'Promoviendo usuario a super administrador',
        className: 'ArcinusManagerUseCase',
        functionName: 'promoteToSuperAdmin',
        params: {
          'userId': userId,
          'promotedBy': promotedBy,
          'reason': reason,
        },
      );
      
      final result = await _repository.promoteToSuperAdmin(
        userId: userId,
        promotedBy: promotedBy,
        reason: reason,
      );
      
      if (result.isRight()) {
        // Registrar evento de auditoría
        await _repository.logAuditEvent(
          userId: promotedBy,
          eventType: AuditEventType.userPromoted,
          description: 'Usuario promovido a super administrador',
          details: {
            'targetUserId': userId,
            'reason': reason ?? 'Sin razón especificada',
            'timestamp': DateTime.now().toIso8601String(),
          },
          targetUserId: userId,
        );
        
        AppLogger.logInfo(
          'Usuario promovido a super administrador exitosamente',
          className: 'ArcinusManagerUseCase',
          functionName: 'promoteToSuperAdmin',
          params: {'userId': userId},
        );
      }
      
      return result;
    } catch (error) {
      AppLogger.logError(
        message: 'Error al promover usuario a super administrador',
        error: error,
        className: 'ArcinusManagerUseCase',
        functionName: 'promoteToSuperAdmin',
        params: {'userId': userId},
      );
      return Left(SystemFailure(
        message: 'Error al promover usuario a super administrador',
        error: error,
      ));
    }
  }
  
  /// Revoca permisos de super administrador
  Future<Either<Failure, void>> revokeSuperAdmin({
    required String userId,
    required String revokedBy,
    required String reason,
  }) async {
    try {
      // Validaciones de negocio
      if (userId.isEmpty || revokedBy.isEmpty) {
        return const Left(SystemFailure(
          message: 'IDs de usuario y revocador requeridos',
          code: 'INVALID_IDS',
        ));
      }
      
      if (userId == revokedBy) {
        return const Left(SystemFailure(
          message: 'Un super administrador no puede revocarse a sí mismo',
          code: 'SELF_REVOCATION_NOT_ALLOWED',
        ));
      }
      
      if (reason.trim().isEmpty) {
        return const Left(SystemFailure(
          message: 'Razón requerida para revocar permisos de super administrador',
          code: 'REASON_REQUIRED',
        ));
      }
      
      AppLogger.logInfo(
        'Revocando permisos de super administrador',
        className: 'ArcinusManagerUseCase',
        functionName: 'revokeSuperAdmin',
        params: {
          'userId': userId,
          'revokedBy': revokedBy,
          'reason': reason,
        },
      );
      
      final result = await _repository.revokeSuperAdmin(
        userId: userId,
        revokedBy: revokedBy,
        reason: reason,
      );
      
      if (result.isRight()) {
        // Registrar evento de auditoría
        await _repository.logAuditEvent(
          userId: revokedBy,
          eventType: AuditEventType.userSuspended,
          description: 'Permisos de super administrador revocados',
          details: {
            'targetUserId': userId,
            'reason': reason,
            'timestamp': DateTime.now().toIso8601String(),
          },
          targetUserId: userId,
        );
      }
      
      return result;
    } catch (error) {
      AppLogger.logError(
        message: 'Error al revocar permisos de super administrador',
        error: error,
        className: 'ArcinusManagerUseCase',
        functionName: 'revokeSuperAdmin',
      );
      return Left(SystemFailure(
        message: 'Error al revocar permisos de super administrador',
        error: error,
      ));
    }
  }
  
  // ========================================
  // SUPERVISIÓN GLOBAL
  // ========================================
  
  /// Obtiene un resumen completo del sistema
  Future<Either<Failure, SystemOverview>> getSystemOverview() async {
    try {
      AppLogger.logInfo(
        'Obteniendo resumen del sistema',
        className: 'ArcinusManagerUseCase',
        functionName: 'getSystemOverview',
      );
      
      // Obtener estadísticas básicas
      final statsResult = await _repository.getSystemStatistics();
      if (statsResult.isLeft()) return Left(statsResult.fold((l) => l, (r) => throw r));
      
      // Obtener alertas críticas
      final alertsResult = await _repository.getSystemAlerts(
        severityFilter: AlertSeverity.critical,
        onlyUnresolved: true,
      );
      if (alertsResult.isLeft()) return Left(alertsResult.fold((l) => l, (r) => throw r));
      
      // Obtener métricas de rendimiento
      final metricsResult = await _repository.getPerformanceMetrics();
      if (metricsResult.isLeft()) return Left(metricsResult.fold((l) => l, (r) => throw r));
      
      final stats = statsResult.fold((l) => throw l, (r) => r);
      final alerts = alertsResult.fold((l) => throw l, (r) => r);
      final metrics = metricsResult.fold((l) => throw l, (r) => r);
      
      final overview = SystemOverview(
        statistics: stats,
        criticalAlerts: alerts,
        performanceMetrics: metrics,
        generatedAt: DateTime.now(),
      );
      
      AppLogger.logInfo(
        'Resumen del sistema obtenido exitosamente',
        className: 'ArcinusManagerUseCase',
        functionName: 'getSystemOverview',
        params: {
          'totalAcademies': stats.totalAcademies,
          'criticalAlerts': alerts.length,
        },
      );
      
      return Right(overview);
    } catch (error) {
      AppLogger.logError(
        message: 'Error al obtener resumen del sistema',
        error: error,
        className: 'ArcinusManagerUseCase',
        functionName: 'getSystemOverview',
      );
      return Left(SystemFailure(
        message: 'Error al obtener resumen del sistema',
        error: error,
      ));
    }
  }
  
  /// Obtiene academias con filtros y paginación
  Future<Either<Failure, AcademiesPageResult>> getAcademiesPage({
    int limit = 20,
    String? lastDocumentId,
    AcademyStatus? statusFilter,
    String? searchQuery,
  }) async {
    try {
      AppLogger.logInfo(
        'Obteniendo página de academias',
        className: 'ArcinusManagerUseCase',
        functionName: 'getAcademiesPage',
        params: {
          'limit': limit,
          'lastDocumentId': lastDocumentId,
          'statusFilter': statusFilter?.name,
          'searchQuery': searchQuery,
        },
      );
      
      final result = await _repository.getAllAcademies(
        limit: limit,
        lastDocumentId: lastDocumentId,
        statusFilter: statusFilter,
      );
      
      return result.map((academies) {
        // Filtrar por búsqueda si se proporciona
        var filteredAcademies = academies;
        if (searchQuery != null && searchQuery.trim().isNotEmpty) {
          final query = searchQuery.toLowerCase().trim();
          filteredAcademies = academies.where((academy) =>
            academy.name.toLowerCase().contains(query) ||
            academy.ownerName.toLowerCase().contains(query) ||
            academy.ownerEmail.toLowerCase().contains(query)
          ).toList();
        }
        
        return AcademiesPageResult(
          academies: filteredAcademies,
          hasMore: academies.length == limit,
          total: filteredAcademies.length,
        );
      });
    } catch (error) {
      AppLogger.logError(
        message: 'Error al obtener página de academias',
        error: error,
        className: 'ArcinusManagerUseCase',
        functionName: 'getAcademiesPage',
      );
      return Left(SystemFailure(
        message: 'Error al obtener página de academias',
        error: error,
      ));
    }
  }
  
  // ========================================
  // GESTIÓN DE ACADEMIAS
  // ========================================
  
  /// Suspende una academia con validaciones de negocio
  Future<Either<Failure, void>> suspendAcademy({
    required String academyId,
    required String reason,
    required String suspendedBy,
    DateTime? suspendUntil,
  }) async {
    try {
      // Validaciones de negocio
      if (academyId.isEmpty || suspendedBy.isEmpty) {
        return const Left(SystemFailure(
          message: 'ID de academia y suspensor requeridos',
          code: 'INVALID_IDS',
        ));
      }
      
      if (reason.trim().isEmpty) {
        return const Left(SystemFailure(
          message: 'Razón requerida para suspender academia',
          code: 'REASON_REQUIRED',
        ));
      }
      
      // Verificar que la academia existe y obtener detalles
      final academyResult = await _repository.getAcademyDetails(academyId);
      if (academyResult.isLeft()) {
        return Left(SystemFailure(
          message: 'Academia no encontrada',
          code: 'ACADEMY_NOT_FOUND',
        ));
      }
      
      final academy = academyResult.fold((l) => throw l, (r) => r);
      
      // Validar que no esté ya suspendida
      if (academy.overview.status == AcademyStatus.suspended) {
        return const Left(SystemFailure(
          message: 'La academia ya está suspendida',
          code: 'ACADEMY_ALREADY_SUSPENDED',
        ));
      }
      
      AppLogger.logInfo(
        'Suspendiendo academia',
        className: 'ArcinusManagerUseCase',
        functionName: 'suspendAcademy',
        params: {
          'academyId': academyId,
          'academyName': academy.overview.name,
          'suspendedBy': suspendedBy,
          'reason': reason,
          'suspendUntil': suspendUntil?.toIso8601String(),
        },
      );
      
      final result = await _repository.suspendAcademy(
        academyId: academyId,
        reason: reason,
        suspendedBy: suspendedBy,
        suspendUntil: suspendUntil,
      );
      
      if (result.isRight()) {
        // Registrar evento de auditoría
        await _repository.logAuditEvent(
          userId: suspendedBy,
          eventType: AuditEventType.academySuspended,
          description: 'Academia suspendida',
          details: {
            'academyId': academyId,
            'academyName': academy.overview.name,
            'reason': reason,
            'suspendUntil': suspendUntil?.toIso8601String(),
            'timestamp': DateTime.now().toIso8601String(),
          },
          academyId: academyId,
        );
        
        AppLogger.logInfo(
          'Academia suspendida exitosamente',
          className: 'ArcinusManagerUseCase',
          functionName: 'suspendAcademy',
          params: {
            'academyId': academyId,
            'academyName': academy.overview.name,
          },
        );
      }
      
      return result;
    } catch (error) {
      AppLogger.logError(
        message: 'Error al suspender academia',
        error: error,
        className: 'ArcinusManagerUseCase',
        functionName: 'suspendAcademy',
        params: {'academyId': academyId},
      );
      return Left(SystemFailure(
        message: 'Error al suspender academia',
        error: error,
      ));
    }
  }
  
  /// Reactiva una academia suspendida
  Future<Either<Failure, void>> reactivateAcademy({
    required String academyId,
    required String reactivatedBy,
    String? notes,
  }) async {
    try {
      // Validaciones de negocio
      if (academyId.isEmpty || reactivatedBy.isEmpty) {
        return const Left(SystemFailure(
          message: 'ID de academia y reactivador requeridos',
          code: 'INVALID_IDS',
        ));
      }
      
      // Verificar que la academia existe y está suspendida
      final academyResult = await _repository.getAcademyDetails(academyId);
      if (academyResult.isLeft()) {
        return Left(SystemFailure(
          message: 'Academia no encontrada',
          code: 'ACADEMY_NOT_FOUND',
        ));
      }
      
      final academy = academyResult.fold((l) => throw l, (r) => r);
      
      if (academy.overview.status != AcademyStatus.suspended) {
        return const Left(SystemFailure(
          message: 'La academia no está suspendida',
          code: 'ACADEMY_NOT_SUSPENDED',
        ));
      }
      
      AppLogger.logInfo(
        'Reactivando academia',
        className: 'ArcinusManagerUseCase',
        functionName: 'reactivateAcademy',
        params: {
          'academyId': academyId,
          'academyName': academy.overview.name,
          'reactivatedBy': reactivatedBy,
          'notes': notes,
        },
      );
      
      final result = await _repository.reactivateAcademy(
        academyId: academyId,
        reactivatedBy: reactivatedBy,
        notes: notes,
      );
      
      if (result.isRight()) {
        // Registrar evento de auditoría
        await _repository.logAuditEvent(
          userId: reactivatedBy,
          eventType: AuditEventType.academyCreated, // No hay evento específico de reactivación
          description: 'Academia reactivada',
          details: {
            'academyId': academyId,
            'academyName': academy.overview.name,
            'notes': notes ?? 'Sin notas adicionales',
            'timestamp': DateTime.now().toIso8601String(),
          },
          academyId: academyId,
        );
      }
      
      return result;
    } catch (error) {
      AppLogger.logError(
        message: 'Error al reactivar academia',
        error: error,
        className: 'ArcinusManagerUseCase',
        functionName: 'reactivateAcademy',
      );
      return Left(SystemFailure(
        message: 'Error al reactivar academia',
        error: error,
      ));
    }
  }
  
  /// Transfiere la propiedad de una academia
  Future<Either<Failure, void>> transferAcademyOwnership({
    required String academyId,
    required String currentOwnerId,
    required String newOwnerId,
    required String transferredBy,
    required String reason,
  }) async {
    try {
      // Validaciones de negocio
      if (academyId.isEmpty || currentOwnerId.isEmpty || 
          newOwnerId.isEmpty || transferredBy.isEmpty) {
        return const Left(SystemFailure(
          message: 'Todos los IDs son requeridos',
          code: 'INVALID_IDS',
        ));
      }
      
      if (currentOwnerId == newOwnerId) {
        return const Left(SystemFailure(
          message: 'El propietario actual y el nuevo no pueden ser el mismo',
          code: 'SAME_OWNER',
        ));
      }
      
      if (reason.trim().isEmpty) {
        return const Left(SystemFailure(
          message: 'Razón requerida para transferir propiedad',
          code: 'REASON_REQUIRED',
        ));
      }
      
      AppLogger.logInfo(
        'Transfiriendo propiedad de academia',
        className: 'ArcinusManagerUseCase',
        functionName: 'transferAcademyOwnership',
        params: {
          'academyId': academyId,
          'currentOwnerId': currentOwnerId,
          'newOwnerId': newOwnerId,
          'transferredBy': transferredBy,
          'reason': reason,
        },
      );
      
      final result = await _repository.transferAcademyOwnership(
        academyId: academyId,
        currentOwnerId: currentOwnerId,
        newOwnerId: newOwnerId,
        transferredBy: transferredBy,
        reason: reason,
      );
      
      if (result.isRight()) {
        // Registrar evento de auditoría
        await _repository.logAuditEvent(
          userId: transferredBy,
          eventType: AuditEventType.ownershipTransferred,
          description: 'Propiedad de academia transferida',
          details: {
            'academyId': academyId,
            'currentOwnerId': currentOwnerId,
            'newOwnerId': newOwnerId,
            'reason': reason,
            'timestamp': DateTime.now().toIso8601String(),
          },
          academyId: academyId,
          targetUserId: newOwnerId,
        );
      }
      
      return result;
    } catch (error) {
      AppLogger.logError(
        message: 'Error al transferir propiedad de academia',
        error: error,
        className: 'ArcinusManagerUseCase',
        functionName: 'transferAcademyOwnership',
      );
      return Left(SystemFailure(
        message: 'Error al transferir propiedad de academia',
        error: error,
      ));
    }
  }
  
  // ========================================
  // EXPORTACIÓN Y ANÁLISIS
  // ========================================
  
  /// Exporta datos del sistema
  Future<Either<Failure, SystemExport>> exportSystemData({
    required ExportType exportType,
    required String requestedBy,
    DateTime? fromDate,
    DateTime? toDate,
    List<String>? academyIds,
  }) async {
    try {
      AppLogger.logInfo(
        'Exportando datos del sistema',
        className: 'ArcinusManagerUseCase',
        functionName: 'exportSystemData',
        params: {
          'exportType': exportType.name,
          'requestedBy': requestedBy,
          'fromDate': fromDate?.toIso8601String(),
          'toDate': toDate?.toIso8601String(),
          'academyIds': academyIds,
        },
      );
      
      final result = await _repository.exportSystemData(
        exportType: exportType,
        fromDate: fromDate,
        toDate: toDate,
        academyIds: academyIds,
      );
      
      if (result.isRight()) {
        // Registrar evento de auditoría
        await _repository.logAuditEvent(
          userId: requestedBy,
          eventType: AuditEventType.dataExported,
          description: 'Datos del sistema exportados',
          details: {
            'exportType': exportType.name,
            'fromDate': fromDate?.toIso8601String(),
            'toDate': toDate?.toIso8601String(),
            'academyIds': academyIds,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
      }
      
      return result;
    } catch (error) {
      AppLogger.logError(
        message: 'Error al exportar datos del sistema',
        error: error,
        className: 'ArcinusManagerUseCase',
        functionName: 'exportSystemData',
      );
      return Left(SystemFailure(
        message: 'Error al exportar datos del sistema',
        error: error,
      ));
    }
  }
}

// ========================================
// MODELOS AUXILIARES
// ========================================

/// Resumen completo del sistema para dashboard
class SystemOverview {
  final SystemStatistics statistics;
  final List<SystemAlert> criticalAlerts;
  final PerformanceMetrics performanceMetrics;
  final DateTime generatedAt;
  
  const SystemOverview({
    required this.statistics,
    required this.criticalAlerts,
    required this.performanceMetrics,
    required this.generatedAt,
  });
}

/// Resultado paginado de academias
class AcademiesPageResult {
  final List<AcademyOverview> academies;
  final bool hasMore;
  final int total;
  
  const AcademiesPageResult({
    required this.academies,
    required this.hasMore,
    required this.total,
  });
} 