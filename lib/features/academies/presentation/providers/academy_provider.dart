import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/academies/data/models/academy_model.dart';
import 'package:arcinus/features/academies/presentation/providers/academy_providers.dart'; // Importa el provider del repo
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
      (academy) => academy, // Puede ser null si no se encontró
    );
  }

  // Métodos para actualizar la academia podrían ir aquí
  // Future<void> updateAcademyDetails(AcademyModel updatedAcademy)
  //async { ... }
}
