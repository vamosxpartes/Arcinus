import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/subscriptions/data/models/app_subscription_model.dart';
import 'package:fpdart/fpdart.dart';

/// Interfaz abstracta para el repositorio de suscripciones de la aplicación.
/// Define los métodos necesarios para interactuar con los datos
/// de las suscripciones a nivel de aplicación (planes de software para propietarios).
abstract class AppSubscriptionRepository {
  /// Obtiene todos los planes de suscripción disponibles.
  /// 
  /// Si [activeOnly] es true, solo devuelve planes activos.
  /// Devuelve la lista de [AppSubscriptionPlanModel] en caso de éxito,
  /// o un [Failure] en caso de error.
  Future<Either<Failure, List<AppSubscriptionPlanModel>>> getAvailablePlans({
    bool activeOnly = true,
  });
  
  /// Obtiene un plan de suscripción específico.
  /// 
  /// Recibe el [planId] del plan a buscar.
  /// Devuelve el [AppSubscriptionPlanModel] en caso de éxito,
  /// o un [Failure] en caso de error.
  Future<Either<Failure, AppSubscriptionPlanModel>> getPlan(String planId);
  
  /// Obtiene la suscripción activa de un propietario.
  /// 
  /// Recibe el [ownerId] del propietario.
  /// Devuelve el [AppSubscriptionModel] en caso de éxito (o null si no tiene),
  /// o un [Failure] en caso de error.
  Future<Either<Failure, AppSubscriptionModel?>> getOwnerSubscription(String ownerId);
  
  /// Crea una nueva suscripción para un propietario.
  /// 
  /// Recibe los datos necesarios para crear la suscripción.
  /// Devuelve el [AppSubscriptionModel] creado en caso de éxito,
  /// o un [Failure] en caso de error.
  Future<Either<Failure, AppSubscriptionModel>> createSubscription(
    String ownerId, 
    String planId,
    DateTime startDate,
  );
  
  /// Actualiza una suscripción existente.
  /// 
  /// Recibe el [subscriptionId] y los [data] a actualizar.
  /// Devuelve el [AppSubscriptionModel] actualizado en caso de éxito,
  /// o un [Failure] en caso de error.
  Future<Either<Failure, AppSubscriptionModel>> updateSubscription(
    String subscriptionId, 
    Map<String, dynamic> data,
  );
  
  /// Cambia el plan de una suscripción existente.
  /// 
  /// Recibe el [subscriptionId] y el [newPlanId].
  /// Devuelve el [AppSubscriptionModel] actualizado en caso de éxito,
  /// o un [Failure] en caso de error.
  Future<Either<Failure, AppSubscriptionModel>> changePlan(
    String subscriptionId, 
    String newPlanId,
  );
  
  /// Verifica si un propietario puede crear más academias.
  /// 
  /// Recibe el [ownerId] del propietario.
  /// Devuelve [true] si puede crear más academias, [false] si no.
  /// En caso de error, devuelve un [Failure].
  Future<Either<Failure, bool>> canCreateMoreAcademies(String ownerId);
  
  /// Vincula una academia a una suscripción.
  /// 
  /// Recibe el [subscriptionId] y el [academyId].
  /// Devuelve [void] en caso de éxito, o un [Failure] en caso de error.
  Future<Either<Failure, void>> linkAcademyToSubscription(
    String subscriptionId, 
    String academyId,
  );
  
  /// Desvincula una academia de una suscripción.
  /// 
  /// Recibe el [subscriptionId] y el [academyId].
  /// Devuelve [void] en caso de éxito, o un [Failure] en caso de error.
  Future<Either<Failure, void>> unlinkAcademyFromSubscription(
    String subscriptionId, 
    String academyId,
  );
  
  /// Verifica si se pueden añadir más usuarios a una academia.
  /// 
  /// Recibe el [academyId] y la [count] cantidad de usuarios a añadir.
  /// Devuelve [true] si se pueden añadir, [false] si no.
  /// En caso de error, devuelve un [Failure].
  Future<Either<Failure, bool>> canAddMoreUsers(
    String academyId, 
    int count,
  );
  
  /// Verifica si una característica está disponible para una academia.
  /// 
  /// Recibe el [academyId] y la [feature] a verificar.
  /// Devuelve [true] si la característica está disponible, [false] si no.
  /// En caso de error, devuelve un [Failure].
  Future<Either<Failure, bool>> isFeatureAvailable(
    String academyId, 
    AppFeature feature,
  );
  
  /// Crea un nuevo plan de suscripción (admin).
  /// 
  /// Recibe el [plan] a crear.
  /// Devuelve el [AppSubscriptionPlanModel] creado en caso de éxito,
  /// o un [Failure] en caso de error.
  Future<Either<Failure, AppSubscriptionPlanModel>> createPlan(
    AppSubscriptionPlanModel plan,
  );
  
  /// Actualiza un plan de suscripción existente (admin).
  /// 
  /// Recibe el [planId] y los datos actualizados [plan].
  /// Devuelve el [AppSubscriptionPlanModel] actualizado en caso de éxito,
  /// o un [Failure] en caso de error.
  Future<Either<Failure, AppSubscriptionPlanModel>> updatePlan(
    String planId,
    AppSubscriptionPlanModel plan,
  );
} 