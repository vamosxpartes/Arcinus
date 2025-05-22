import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/users/data/models/client_user_model.dart';
import 'package:fpdart/fpdart.dart';

/// Interfaz para el repositorio de usuarios cliente
abstract class ClientUserRepository {
  /// Obtiene un usuario cliente por su ID
  Future<Either<Failure, ClientUserModel>> getClientUser(
    String academyId,
    String userId,
  );
  
  /// Obtiene todos los usuarios cliente de una academia, con filtros opcionales
  Future<Either<Failure, List<ClientUserModel>>> getClientUsers(
    String academyId, {
    AppRole? clientType,
    PaymentStatus? paymentStatus,
  });
  
  /// Actualiza los datos de un usuario cliente
  Future<Either<Failure, ClientUserModel>> updateClientUser(
    String academyId,
    String userId,
    Map<String, dynamic> clientData,
  );
  
  /// Asigna un plan de suscripción a un usuario
  Future<Either<Failure, ClientUserModel>> assignSubscriptionPlan(
    String academyId,
    String userId,
    String planId,
    DateTime? startDate,
  );
  
  /// Actualiza específicamente el estado de pago de un usuario
  Future<Either<Failure, bool>> updateClientUserPaymentStatus(
    String academyId,
    String userId,
    PaymentStatus newStatus,
  );

  /// Obtiene todos los planes de suscripción disponibles
  Future<Either<Failure, List<SubscriptionPlanModel>>> getSubscriptionPlans(
    String academyId, {
    bool activeOnly = true,
  });

  /// Obtiene un plan de suscripción específico
  Future<Either<Failure, SubscriptionPlanModel>> getSubscriptionPlan(
    String academyId,
    String planId,
  );

  /// Crea un nuevo plan de suscripción
  Future<Either<Failure, SubscriptionPlanModel>> createSubscriptionPlan(
    String academyId,
    SubscriptionPlanModel plan,
  );

  /// Actualiza un plan de suscripción existente
  Future<Either<Failure, SubscriptionPlanModel>> updateSubscriptionPlan(
    String academyId,
    String planId,
    SubscriptionPlanModel plan,
  );

  /// Elimina un plan de suscripción
  Future<Either<Failure, Unit>> deleteSubscriptionPlan(
    String academyId,
    String planId,
  );
}
