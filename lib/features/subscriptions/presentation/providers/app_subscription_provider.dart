import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/subscriptions/data/models/app_subscription_model.dart';
import 'package:arcinus/features/subscriptions/data/repositories/app_subscription_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_subscription_provider.g.dart';

/// Provider asíncrono para obtener y gestionar el estado de la suscripción de un propietario.
///
/// Requiere el [ownerId] como argumento para saber qué suscripción buscar.
@riverpod
class AppSubscription extends _$AppSubscription {
  /// Método build inicial que se llama para obtener el estado.
  @override
  FutureOr<AppSubscriptionModel?> build(String ownerId) async {
    // Si el ownerId está vacío, no intentes buscar.
    if (ownerId.isEmpty) {
      return null;
    }

    final appSubscriptionRepository = ref.watch(appSubscriptionRepositoryProvider);
    final result = await appSubscriptionRepository.getOwnerSubscription(ownerId);

    // Maneja el resultado Either
    return result.fold(
      (failure) {
        // En caso de error, lanza la falla para que Riverpod la maneje como AsyncError
        throw _mapFailureToException(failure);
      },
      (subscription) {
        // Devuelve la suscripción (puede ser null si no se encontró)
        return subscription;
      },
    );
  }

  /// Refresca la suscripción desde el repositorio.
  Future<void> refreshSubscription() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return await build(ownerId);
    });
  }
}

/// Provider asíncrono para obtener todos los planes de suscripción disponibles.
@riverpod
Future<List<AppSubscriptionPlanModel>> availablePlans(
  Ref ref, {
  bool activeOnly = true,
}) async {
  final appSubscriptionRepository = ref.watch(appSubscriptionRepositoryProvider);
  final result = await appSubscriptionRepository.getAvailablePlans(
    activeOnly: activeOnly,
  );

  return result.fold(
    (failure) {
      throw _mapFailureToException(failure);
    },
    (plans) {
      return plans;
    },
  );
}

/// Provider para verificar si un propietario puede crear más academias.
@riverpod
Future<bool> canCreateMoreAcademies(
  Ref ref,
  String ownerId,
) async {
  final appSubscriptionRepository = ref.watch(appSubscriptionRepositoryProvider);
  final result = await appSubscriptionRepository.canCreateMoreAcademies(ownerId);

  return result.fold(
    (failure) {
      throw _mapFailureToException(failure);
    },
    (canCreate) {
      return canCreate;
    },
  );
}

/// Provider para verificar si una característica está disponible para una academia.
@riverpod
Future<bool> isFeatureAvailable(
  Ref ref,
  String academyId,
  AppFeature feature,
) async {
  final appSubscriptionRepository = ref.watch(appSubscriptionRepositoryProvider);
  final result = await appSubscriptionRepository.isFeatureAvailable(
    academyId,
    feature,
  );

  return result.fold(
    (failure) {
      throw _mapFailureToException(failure);
    },
    (isAvailable) {
      return isAvailable;
    },
  );
}

/// Helper para mapear Failure a una Exception que AsyncValue puede manejar mejor.
Exception _mapFailureToException(Failure failure) {
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