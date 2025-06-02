import 'package:arcinus/core/utils/error/failures.dart';
import 'package:arcinus/features/academy_users_subscriptions/data/models/subscription_model.dart';
import 'package:arcinus/features/academy_users_subscriptions/data/models/subscription_plan_model.dart';
import 'package:fpdart/fpdart.dart';

/// Interfaz abstracta para el repositorio de suscripciones.
/// Define los métodos necesarios para interactuar con los datos
/// de las suscripciones de las academias.
abstract class SubscriptionRepository {
  /// Crea un registro de suscripción inicial para una academia.
  ///
  /// Recibe el [subscription] a crear.
  /// Devuelve [void] en caso de éxito,
  /// o un [Failure] en caso de error.
  Future<Either<Failure, void>> createInitialSubscription(
    SubscriptionModel subscription,
  );

  /// Obtiene la suscripción activa de una academia específica.
  ///
  /// Devuelve el [SubscriptionModel] si se encuentra una suscripción activa,
  /// o `null` si no hay ninguna activa o la academia no existe.
  /// Devuelve un [Failure] en caso de error de comunicación.
  Future<Either<Failure, SubscriptionModel?>> getActiveSubscription(
    String academyId,
  );

  /// Obtiene todos los planes de suscripción de una academia
  Future<Either<Failure, List<SubscriptionPlanModel>>> getSubscriptionPlans(
    String academyId, {
    bool activeOnly = false,
  });
  
  /// Obtiene un plan de suscripción específico por su ID
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
  Future<Either<Failure, void>> deleteSubscriptionPlan(
    String academyId,
    String planId,
  );
  
  /// Asigna un plan de suscripción a un usuario
  Future<Either<Failure, void>> assignPlanToUser(
    String academyId,
    String userId,
    String planId,
    DateTime startDate,
  );
  
  /// Obtiene el plan de suscripción asignado a un usuario
  Future<Either<Failure, SubscriptionPlanModel?>> getUserPlan(
    String academyId,
    String userId,
  );

  // Otros métodos podrían añadirse después (update, cancel, etc.)
}
