import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/payments/data/models/client_user_model.dart';
import 'package:fpdart/fpdart.dart';

/// Interfaz para el repositorio de usuarios cliente (atletas y padres)
abstract class ClientUserRepository {
  /// Obtiene un usuario cliente específico
  Future<Either<Failure, ClientUserModel>> getClientUser(String academyId, String userId);
  
  /// Obtiene la lista de usuarios cliente filtrados opcionalmente por tipo o estado de pago
  Future<Either<Failure, List<ClientUserModel>>> getClientUsers(
    String academyId, {
    AppRole? clientType,
    PaymentStatus? paymentStatus,
  });
  
  /// Actualiza los datos de cliente de un usuario
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