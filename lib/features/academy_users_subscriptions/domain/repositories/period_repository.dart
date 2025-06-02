import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/academy_users_subscriptions/data/models/subscription_assignment_model.dart';
import 'package:fpdart/fpdart.dart';

/// Repositorio para gestionar períodos de suscripción
abstract class PeriodRepository {
  /// Crea un nuevo período de suscripción
  Future<Either<Failure, SubscriptionAssignmentModel>> createPeriod(
    SubscriptionAssignmentModel period,
  );
  
  /// Crea múltiples períodos de suscripción (para pagos múltiples)
  Future<Either<Failure, List<SubscriptionAssignmentModel>>> createMultiplePeriods(
    List<SubscriptionAssignmentModel> periods,
  );
  
  /// Obtiene todos los períodos de un atleta
  Future<Either<Failure, List<SubscriptionAssignmentModel>>> getAthletesPeriods(
    String academyId,
    String athleteId, {
    SubscriptionAssignmentStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
  });
  
  /// Obtiene el período actual activo de un atleta
  Future<Either<Failure, SubscriptionAssignmentModel?>> getCurrentPeriod(
    String academyId,
    String athleteId,
  );
  
  /// Obtiene todos los períodos activos de un atleta
  Future<Either<Failure, List<SubscriptionAssignmentModel>>> getActivePeriods(
    String academyId,
    String athleteId,
  );
  
  /// Obtiene los próximos períodos que se activarán
  Future<Either<Failure, List<SubscriptionAssignmentModel>>> getUpcomingPeriods(
    String academyId,
    String athleteId,
  );
  
  /// Actualiza el estado de un período
  Future<Either<Failure, SubscriptionAssignmentModel>> updatePeriodStatus(
    String academyId,
    String periodId,
    SubscriptionAssignmentStatus newStatus,
  );
  
  /// Actualiza un período completo
  Future<Either<Failure, SubscriptionAssignmentModel>> updatePeriod(
    String academyId,
    String periodId,
    SubscriptionAssignmentModel updatedPeriod,
  );
  
  /// Elimina un período (soft delete)
  Future<Either<Failure, bool>> deletePeriod(
    String academyId,
    String periodId,
  );
  
  /// Obtiene todos los períodos que vencen en un rango de fechas
  Future<Either<Failure, List<SubscriptionAssignmentModel>>> getPeriodsExpiringInRange(
    String academyId,
    DateTime startDate,
    DateTime endDate,
  );
  
  /// Obtiene todos los períodos de una academia (para reportes)
  Future<Either<Failure, List<SubscriptionAssignmentModel>>> getAcademyPeriods(
    String academyId, {
    SubscriptionAssignmentStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit,
  });
} 