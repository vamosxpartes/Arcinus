import 'package:arcinus/core/utils/error/failures.dart';
import 'package:arcinus/features/academies/data/models/academy_model.dart';
import 'package:arcinus/features/academies/presentation/providers/academy_providers.dart'; // Importa el provider del repo
import 'package:arcinus/features/academy_users_subscriptions/data/models/app_subscription_model.dart';
import 'package:arcinus/features/academy_users_subscriptions/data/repositories/app_subscription_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'academy_provider.g.dart';

/// Helper para mapear Failure a Exception (similar al de suscripciones)
/// Considera mover esto a un lugar común en core/error si se repite mucho.
Exception _mapFailureToException(Failure failure) {
  return failure.when(
    serverError:
        (message) =>
            Exception('Error del servidor: $message'),
    networkError: () => Exception('Error de red. Verifica tu conexión.'),
    authError:
        (code, message) =>
            Exception('Error de autenticación: $message'),
    validationError:
        (message) =>
            Exception('Error de validación: $message'),
    notFound:
        (message) =>
            Exception('No encontrado: $message'),
    cacheError:
        (message) => Exception(
          'Error de caché: $message',
        ),
    unexpectedError:
        (error, _) => Exception(
          'Error inesperado: ${error?.toString() ?? 'Desconocido'}',
        ),
  );
}

/// Notifier asíncrono para obtener y
/// gestionar el estado de una academia específica.
///
/// Requiere el [academyId] como argumento.
@riverpod
class Academy extends _$Academy {
  @override
  FutureOr<AcademyModel?> build(String academyId) async {
    if (academyId.isEmpty) {
      return null; // O lanzar error si prefieres
    }

    final academyRepository = ref.watch(academyRepositoryProvider);
    final result = await academyRepository.getAcademyById(academyId);

    return result.fold(
      (failure) => throw _mapFailureToException(failure),
      (academy) async {
        // Si la academia existe, obtenemos la suscripción del propietario
        final appSubscriptionRepository = ref.watch(appSubscriptionRepositoryProvider);
        final subscriptionResult = await appSubscriptionRepository.getOwnerSubscription(academy.ownerId);
        
        // Actualizamos la academia con la información de suscripción
        return subscriptionResult.fold(
          (failure) {
            // Si hay un error, simplemente devolvemos la academia sin modificar
            return academy;
          }, 
          (subscription) {
            if (subscription == null) return academy;
            
            // Actualizar la academia con los datos de suscripción
            return academy.copyWith(
              ownerSubscriptionId: subscription.id,
              inheritedFeatures: subscription.plan?.features ?? [],
            );
          }
        );
      },
    );
  }

  // Métodos para actualizar la academia podrían ir aquí
  // Future<void> updateAcademyDetails(AcademyModel updatedAcademy)
  //async { ... }
}

/// Provider para verificar si una característica está disponible para una academia.
@riverpod
bool isFeatureAvailableForAcademy(
  Ref ref,
  String academyId, 
  AppFeature feature,
) {
  final academyValue = ref.watch(academyProvider(academyId));
  return academyValue.when(
    data: (academy) {
      if (academy == null) return false;
      return academy.inheritedFeatures.contains(feature);
    },
    loading: () => false,
    error: (_, __) => false,
  );
}
