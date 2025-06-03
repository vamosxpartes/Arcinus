import 'package:arcinus/core/utils/providers/firebase_providers.dart';
import 'package:arcinus/features/academies/data/repositories/academy_repository_impl.dart';
import 'package:arcinus/features/academies/domain/repositories/academy_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:arcinus/features/academies/data/models/academy_model.dart';
import 'package:arcinus/core/utils/app_logger.dart';

part 'academy_providers.g.dart';

/// Provider que expone la implementación del [AcademyRepository].
///
/// Utiliza el provider de Firestore para obtener la instancia necesaria.
@riverpod
AcademyRepository academyRepository(Ref ref) {
  final firestore = ref.watch(firestoreProvider);
  AppLogger.logInfo(
    'Creando instancia de AcademyRepository',
    className: 'academy_providers',
    functionName: 'academyRepository',
  );
  return AcademyRepositoryImpl(firestore);
}

// Proveedor para obtener los detalles de una academia específica
final academyDetailsProvider = FutureProvider.family<AcademyModel, String>((ref, academyId) async {
  AppLogger.logInfo(
    'Obteniendo detalles de academia',
    className: 'academy_providers',
    functionName: 'academyDetailsProvider',
    params: {'academyId': academyId},
  );
  
  final academyRepo = ref.watch(academyRepositoryProvider);
  final result = await academyRepo.getAcademyById(academyId);
  return result.fold(
    (failure) {
      AppLogger.logError(
        message: 'Error al cargar detalles de academia',
        className: 'academy_providers',
        functionName: 'academyDetailsProvider',
        params: {'academyId': academyId, 'error': failure.message},
      );
      throw Exception('Failed to load academy details: ${failure.message}');
    },
    (academy) {
      AppLogger.logInfo(
        'Detalles de academia cargados correctamente',
        className: 'academy_providers',
        functionName: 'academyDetailsProvider',
        params: {'academyId': academyId, 'academyName': academy.name},
      );
      return academy;
    },
  );
});

// Aquí se podrían añadir otros providers relacionados con academias,
// como un provider para obtener la lista de academias del usuario, etc. 