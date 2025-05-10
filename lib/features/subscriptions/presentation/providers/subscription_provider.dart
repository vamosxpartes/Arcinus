import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/subscriptions/data/models/subscription_model.dart';
import 'package:arcinus/features/subscriptions/presentation/providers/subscription_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'subscription_provider.g.dart';

/// Notifier asíncrono para obtener y gestionar el estado de la suscripción de una academia.
///
/// Requiere el [academyId] como argumento para saber qué suscripción buscar.
@riverpod
class AcademySubscription extends _$AcademySubscription {
  /// Método build inicial que se llama para obtener el estado.
  @override
  FutureOr<SubscriptionModel?> build(String academyId) async {
    // Si el academyId está vacío, no intentes buscar.
    if (academyId.isEmpty) {
      // Puedes devolver null o lanzar un error controlado si prefieres
      return null;
    }

    final subscriptionRepository = ref.watch(subscriptionRepositoryProvider);
    final result = await subscriptionRepository.getActiveSubscription(
      academyId,
    );

    // Maneja el resultado Either
    return result.fold(
      (failure) {
        // En caso de error, lanza la falla para que Riverpod la maneje como AsyncError
        // Considera loggear el error aquí también.
        // logger.e('Error fetching subscription for $academyId: $failure');
        throw _mapFailureToException(failure);
      },
      (subscription) {
        // Devuelve la suscripción (puede ser null si no se encontró)
        return subscription;
      },
    );
  }

  // Podrías añadir métodos aquí para actualizar o refrescar la suscripción si es necesario
  // Future<void> refreshSubscription() async {
  //   final academyId = arg; // Obtiene el academyId con el que se construyó
  //   state = const AsyncLoading();
  //   state = await AsyncValue.guard(() => build(academyId));
  // }
}

/// Helper para mapear Failure a una Exception que AsyncValue puede manejar mejor.
/// Esto es útil porque AsyncError prefiere Exceptions.
Exception _mapFailureToException(Failure failure) {
  // Usar la definición correcta de los constructores de Failure
  return failure.when<Exception>(
    serverError: (message) =>
        Exception('Error del servidor${message.isNotEmpty ? ": $message" : ""}'),
    networkError: () => Exception('Error de red. Verifica tu conexión.'),
    // Usar los parámetros correctos: code y message
    authError: (code, message) => 
        Exception('Error de autenticación${message.isNotEmpty ? ": $message" : " ($code)"}'),
    validationError: (message) =>
        Exception('Error de validación${message.isNotEmpty ? ": $message" : ""}'),
    notFound: (message) =>
        Exception('No encontrado${message.isNotEmpty ? ": $message" : ""}'),
    cacheError: (message) => 
        Exception('Error de caché${message.isNotEmpty ? ": $message" : ""}'),
    unexpectedError: (error, stackTrace) => Exception(
      'Error inesperado: ${error?.toString() ?? 'Ocurrió un problema'}',
    ),
  );
}

/// Provider que determina si la suscripción de una academia específica está activa.
///
/// Devuelve `true` si la suscripción existe, tiene estado `active` o `trial` y la fecha de fin
/// es posterior a la fecha actual. Devuelve `false` en cualquier otro caso
/// (incluyendo estados de carga, error, suscripción nula, inactiva o expirada).
///
/// Requiere el [academyId] como argumento.
@riverpod
bool isAcademySubscriptionActive(
  Ref ref,
  String academyId,
) {
  // Observa el estado del AsyncNotifier para la academia dada.
  final subscriptionAsyncValue = ref.watch(
    academySubscriptionProvider(academyId),
  );

  // Extrae el valor solo si está disponible y no es nulo.
  final subscription = subscriptionAsyncValue.valueOrNull;

  // Si no hay suscripción (aún cargando, error, o no encontrada), no está activa.
  if (subscription == null) {
    return false;
  }

  // Verifica el estado y la fecha de expiración.
  // Usar el nombre del enum para comparar el estado.
  final bool isActive = subscription.status == SubscriptionStatus.active.name || 
                      subscription.status == SubscriptionStatus.trial.name;
  // Convertir Timestamp a DateTime antes de comparar.
  final bool isNotExpired = subscription.endDate.toDate().isAfter(DateTime.now());

  return isActive && isNotExpired;
}
