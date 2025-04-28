import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/subscriptions/data/models/subscription_model.dart';
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

  // Otros métodos podrían añadirse después (update, cancel, etc.)
}
