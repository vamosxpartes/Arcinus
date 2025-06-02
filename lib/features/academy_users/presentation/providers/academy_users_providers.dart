import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/features/academy_users/data/repositories/academy_users_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:arcinus/features/academy_users/data/models/academy_user_model.dart';

part 'academy_users_providers.g.dart';

// Provider para todos los usuarios de una academia
@riverpod
Stream<List<AcademyUserModel>> academyUsers(Ref ref, String academyId) {
  AppLogger.logProcessStart(
    'Creando academyUsers stream provider',
    className: 'AcademyUsersProviders',
    functionName: 'academyUsers',
    params: {
      'academyId': academyId,
      'timestamp': DateTime.now().toString(),
      'provider_hashCode': ref.hashCode,
    },
  );

  // Añadir listener para detectar cuando se destruye
  ref.onDispose(() {
    AppLogger.logInfo(
      'Destruyendo academyUsers stream provider',
      className: 'AcademyUsersProviders',
      functionName: 'academyUsers',
      params: {
        'academyId': academyId,
        'timestamp': DateTime.now().toString(),
      },
    );
  });

  final repository = ref.watch(academyUsersRepositoryProvider);
  
  AppLogger.logInfo(
    'Obteniendo stream de usuarios de la academia',
    className: 'AcademyUsersProviders',
    functionName: 'academyUsers',
    params: {
      'academyId': academyId,
      'repository_hashCode': repository.hashCode,
    },
  );

  // Crear el stream y añadir logging y manejo de errores a cada evento
  final stream = repository.getAcademyUsers(academyId);
  
  return stream.map((users) {
    AppLogger.logInfo(
      'Nuevo evento en stream de academyUsers',
      className: 'AcademyUsersProviders',
      functionName: 'academyUsers',
      params: {
        'academyId': academyId,
        'userCount': users.length,
        'userIds': users.map((u) => u.id ?? 'null_id').take(3).toList(), // Manejar IDs nulos
        'timestamp': DateTime.now().toString(),
        'stream_event_hashCode': users.hashCode,
      },
    );
    return users;
  }).handleError((error, StackTrace stackTrace) {
    AppLogger.logError(
      message: 'Error en stream de academyUsers',
      error: error,
      stackTrace: stackTrace,
      className: 'AcademyUsersProviders',
      functionName: 'academyUsers',
      params: {
        'academyId': academyId,
        'error_type': error.runtimeType.toString(),
      },
    );
    
    // En lugar de propagar el error, emitir lista vacía
    // Esto previene que la UI se rompa por errores de conversión
    return <AcademyUserModel>[];
  });
}

// Provider para usuarios filtrados por rol
@riverpod
Stream<List<AcademyUserModel>> academyUsersByRole(
  Ref ref, 
  String academyId, 
  AppRole role,
) {
  final repository = ref.watch(academyUsersRepositoryProvider);
  
  // Asegurarnos de que estamos pasando el nombre del rol en minúsculas para coincidir con Firebase
  final roleName = role.name.toLowerCase();
  
  // Log para depuración con AppLogger
  AppLogger.logInfo(
    'Filtrando usuarios por rol',
    className: 'AcademyUsersProviders',
    functionName: 'academyUsersByRole',
    params: {
      'academyId': academyId,
      'roleName': roleName,
      'roleEnum': role.toString(),
    },
  );
  
  return repository.getUsersByRole(academyId, roleName);
}

// Provider para buscar un usuario específico
@riverpod
Future<AcademyUserModel?> academyUserDetails(
  Ref ref,
  String academyId,
  String userId,
) async {
  final repository = ref.watch(academyUsersRepositoryProvider);
  AppLogger.logInfo(
    'Obteniendo detalles del usuario',
    className: 'AcademyUsersProviders',
    functionName: 'academyUserDetails',
    params: {'academyId': academyId, 'userId': userId},
  );
  return repository.getUserById(academyId, userId);
}

// Provider de estado para el término de búsqueda
@riverpod
class SearchTermNotifier extends _$SearchTermNotifier {
  @override
  String build() {
    return '';
  }
  
  void updateSearchTerm(String term) {
    AppLogger.logInfo(
      'Actualizando término de búsqueda',
      className: 'SearchTermNotifier',
      functionName: 'updateSearchTerm',
      params: {'searchTerm': term},
    );
    state = term;
  }
  
  void clearSearchTerm() {
    AppLogger.logInfo(
      'Limpiando término de búsqueda',
      className: 'SearchTermNotifier',
      functionName: 'clearSearchTerm',
    );
    state = '';
  }
}

// Provider para resultados de búsqueda
@riverpod
Stream<List<AcademyUserModel>> academyUsersSearch(
  Ref ref,
  String academyId,
) {
  final searchTerm = ref.watch(searchTermNotifierProvider);
  
  // Si el término de búsqueda está vacío, devolver stream vacío
  if (searchTerm.isEmpty) {
    return Stream.value([]);
  }
  
  AppLogger.logInfo(
    'Buscando usuarios por nombre',
    className: 'AcademyUsersProviders',
    functionName: 'academyUsersSearch',
    params: {'academyId': academyId, 'searchTerm': searchTerm},
  );
  
  final repository = ref.watch(academyUsersRepositoryProvider);
  return repository.searchUsersByName(academyId, searchTerm);
} 