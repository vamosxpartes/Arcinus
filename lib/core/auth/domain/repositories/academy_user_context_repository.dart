import 'package:arcinus/core/auth/models/models.dart';
import 'package:arcinus/core/utils/error/failures.dart';
import 'package:fpdart/fpdart.dart';

/// Repositorio para la gestión de contextos de usuarios en academias específicas.
/// Maneja la información específica del rol y actividades de un usuario en cada academia.
abstract class AcademyUserContextRepository {
  // === CRUD de contextos ===
  
  /// Obtiene el contexto de un usuario en una academia específica
  Future<Either<Failure, AcademyUserContext?>> getUserContext(
    String userId, 
    String academyId
  );
  
  /// Obtiene todos los usuarios de una academia con filtro opcional por rol
  Future<Either<Failure, List<AcademyUserContext>>> getAcademyUsers(
    String academyId, {
    AppRole? roleFilter,
    bool? activeOnly,
    int? limit,
  });
  
  /// Obtiene todas las academias en las que un usuario participa
  Future<Either<Failure, List<AcademyUserContext>>> getUserAcademies(
    String userId, {
    bool? activeOnly,
  });
  
  /// Crea un nuevo contexto de usuario en una academia
  Future<Either<Failure, void>> createUserContext(AcademyUserContext context);
  
  /// Actualiza el contexto de un usuario en una academia
  Future<Either<Failure, void>> updateUserContext(AcademyUserContext context);
  
  /// Elimina un usuario de una academia (soft delete)
  Future<Either<Failure, void>> removeUserFromAcademy(
    String userId, 
    String academyId
  );
  
  // === Gestión de administradores ===
  
  /// Actualiza los permisos de un administrador
  Future<Either<Failure, void>> updateAdminPermissions(
    String userId, 
    String academyId, 
    List<ManagerPermission> permissions
  );
  
  /// Obtiene todos los administradores de una academia
  Future<Either<Failure, List<AcademyUserContext>>> getAcademyAdmins(
    String academyId, {
    AdminType? typeFilter,
    ManagerStatus? statusFilter,
  });
  
  /// Promueve un usuario a administrador
  Future<Either<Failure, void>> promoteToAdmin(
    String userId,
    String academyId,
    AdminType type,
    List<ManagerPermission> permissions,
    String promotedBy,
  );
  
  /// Actualiza el estado de un administrador
  Future<Either<Failure, void>> updateAdminStatus(
    String userId,
    String academyId,
    ManagerStatus status,
  );
  
  // === Gestión de miembros ===
  
  /// Obtiene todos los miembros de una academia
  Future<Either<Failure, List<AcademyUserContext>>> getAcademyMembers(
    String academyId, {
    MemberType? typeFilter,
    PaymentStatus? paymentStatusFilter,
  });
  
  /// Vincula un padre con un atleta
  Future<Either<Failure, void>> linkParentToAthlete(
    String parentId, 
    String athleteId, 
    String academyId
  );
  
  /// Desvincula un padre de un atleta
  Future<Either<Failure, void>> unlinkParentFromAthlete(
    String parentId, 
    String athleteId, 
    String academyId
  );
  
  /// Obtiene los atletas asociados a un padre
  Future<Either<Failure, List<AcademyUserContext>>> getParentAthletes(
    String parentId, 
    String academyId
  );
  
  /// Obtiene los padres asociados a un atleta
  Future<Either<Failure, List<AcademyUserContext>>> getAthleteParents(
    String athleteId, 
    String academyId
  );
  
  // === Gestión de pagos ===
  
  /// Actualiza el estado de pago de un miembro
  Future<Either<Failure, void>> updateMemberPaymentStatus(
    String userId,
    String academyId,
    PaymentStatus status, {
    DateTime? lastPaymentDate,
    double? lastPaymentAmount,
    DateTime? nextPaymentDue,
  });
  
  /// Obtiene miembros con problemas de pago
  Future<Either<Failure, List<AcademyUserContext>>> getMembersWithPaymentIssues(
    String academyId
  );
  
  /// Obtiene miembros con pagos vencidos
  Future<Either<Failure, List<AcademyUserContext>>> getOverdueMembers(
    String academyId
  );
  
  // === Búsqueda y filtrado ===
  
  /// Busca usuarios en una academia por término de búsqueda
  Future<Either<Failure, List<AcademyUserContext>>> searchAcademyUsers(
    String academyId,
    String searchTerm, {
    AppRole? roleFilter,
    bool? activeOnly,
    int? limit,
  });
  
  /// Obtiene usuarios paginados de una academia
  Future<Either<Failure, List<AcademyUserContext>>> getAcademyUsersPaginated(
    String academyId, {
    int page = 1,
    int pageSize = 20,
    AppRole? roleFilter,
    String? searchTerm,
    bool? activeOnly,
  });
  
  // === Estadísticas y métricas ===
  
  /// Obtiene el número de usuarios por rol en una academia
  Future<Either<Failure, Map<AppRole, int>>> getAcademyUserCountByRole(
    String academyId
  );
  
  /// Obtiene estadísticas generales de una academia
  Future<Either<Failure, Map<String, dynamic>>> getAcademyStatistics(
    String academyId
  );
  
  /// Obtiene métricas de actividad de usuarios
  Future<Either<Failure, Map<String, dynamic>>> getUserActivityMetrics(
    String academyId, {
    int? daysBack,
  });
  
  // === Validaciones ===
  
  /// Verifica si un usuario ya existe en una academia
  Future<Either<Failure, bool>> userExistsInAcademy(
    String userId, 
    String academyId
  );
  
  /// Verifica si un usuario tiene permisos específicos
  Future<Either<Failure, bool>> userHasPermission(
    String userId,
    String academyId,
    ManagerPermission permission,
  );
  
  /// Verifica si un usuario puede realizar una acción
  Future<Either<Failure, bool>> canUserPerformAction(
    String userId,
    String academyId,
    String action,
  );
  
  // === Auditoría ===
  
  /// Registra una acción de auditoría en el contexto de academia
  Future<Either<Failure, void>> logContextAudit({
    required String userId,
    required String academyId,
    required String action,
    required String details,
    Map<String, dynamic>? metadata,
  });
  
  /// Obtiene el historial de auditoría de un contexto
  Future<Either<Failure, List<Map<String, dynamic>>>> getContextAuditHistory(
    String userId,
    String academyId, {
    int? limit,
    DateTime? since,
  });
}

/// Implementación base del repositorio de contextos
/// que proporciona funcionalidades comunes
abstract class AcademyUserContextRepositoryImpl implements AcademyUserContextRepository {
  
  /// Valida un contexto antes de guardarlo
  Either<Failure, void> validateContext(AcademyUserContext context) {
    if (context.userId.isEmpty) {
      return left(const Failure.validationError(message: 'ID de usuario es requerido'));
    }
    
    if (context.academyId.isEmpty) {
      return left(const Failure.validationError(message: 'ID de academia es requerido'));
    }
    
    // Validar que tenga datos apropiados según el rol
    if (context.isAdmin && context.adminData == null) {
      return left(const Failure.validationError(
        message: 'Datos de administrador requeridos para roles administrativos'
      ));
    }
    
    if (context.isMember && context.memberData == null) {
      return left(const Failure.validationError(
        message: 'Datos de miembro requeridos para roles de miembro'
      ));
    }
    
    return right(null);
  }
  
  /// Genera el ID del documento para el contexto
  String generateContextId(String userId, String academyId) {
    return '${userId}_$academyId';
  }
  
  /// Crea metadatos de auditoría para contextos
  Map<String, dynamic> createContextAuditMetadata({
    required String action,
    required String academyId,
    String? performedBy,
    Map<String, dynamic>? additionalData,
  }) {
    return {
      'action': action,
      'academyId': academyId,
      'timestamp': DateTime.now().toIso8601String(),
      'performedBy': performedBy,
      'additionalData': additionalData,
    };
  }
} 