import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/features/academies/presentation/providers/current_academy_provider.dart';
import 'package:arcinus/features/users/data/models/client_user_model.dart';
import 'package:arcinus/features/users/data/models/payment_status.dart';
import 'package:arcinus/features/users/domain/repositories/client_user_repository_impl.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider que obtiene información del usuario cliente (atleta o padre) por su ID
final clientUserProvider = FutureProvider.family.autoDispose<ClientUserModel?, String>((ref, userId) async {
  AppLogger.logProcessStart(
    'Creando clientUserProvider',
    className: 'ClientUserProvider',
    params: {
      'userId': userId,
      'timestamp': DateTime.now().toString(),
    }
  );

  // Añadir un listener para saber cuándo se destruye el provider
  ref.onDispose(() {
    AppLogger.logInfo(
      'Destruyendo clientUserProvider',
      className: 'ClientUserProvider',
      params: {
        'userId': userId,
        'timestamp': DateTime.now().toString(),
      }
    );
  });

  // Obtener el repository
  final repository = ref.read(clientUserRepositoryProvider);
  
  // Obtener la academia actual (necesaria para la consulta)
  final currentAcademy = ref.read(currentAcademyProvider);
  
  if (currentAcademy?.id == null) {
    AppLogger.logWarning(
      'No hay academia seleccionada para clientUserProvider',
      className: 'ClientUserProvider',
      params: {'userId': userId}
    );
    return null;
  }

  final academyId = currentAcademy!.id!;
  
  AppLogger.logInfo(
    'Ejecutando consulta de clientUser',
    className: 'ClientUserProvider',
    params: {
      'userId': userId,
      'academyId': academyId,
      'repository_hashCode': repository.hashCode,
    }
  );

  try {
    final result = await repository.getClientUser(academyId, userId);
    
    return result.fold(
      (failure) {
        AppLogger.logError(
          message: 'Error en clientUserProvider',
          error: failure,
          className: 'ClientUserProvider',
          params: {
            'userId': userId,
            'academyId': academyId,
            'failure_type': failure.runtimeType.toString(),
          }
        );
        return null;
      },
      (clientUser) {
        AppLogger.logProcessEnd(
          'clientUserProvider completado exitosamente',
          className: 'ClientUserProvider',
          params: {
            'userId': userId,
            'academyId': academyId,
            'clientUser_found': clientUser ,
            'paymentStatus': clientUser?.paymentStatus.toString(),
          }
        );
        return clientUser;
      },
    );
  } catch (e, stackTrace) {
    AppLogger.logError(
      message: 'Excepción inesperada en clientUserProvider',
      error: e,
      stackTrace: stackTrace,
      className: 'ClientUserProvider',
      params: {
        'userId': userId,
        'academyId': academyId,
      }
    );
    rethrow;
  }
});

/// Provider que obtiene la lista de usuarios cliente (atletas y padres) filtrados por rol
final clientUsersByRoleProvider = FutureProvider.family<List<ClientUserModel>, (String, AppRole)>(
  (ref, params) async {
    final repository = ref.watch(clientUserRepositoryProvider);
    final academyId = params.$1;
    final role = params.$2;
    
    final result = await repository.getClientUsers(
      academyId,
      clientType: role,
    );
    
    return result.fold(
      (failure) => [],
      (clients) => clients,
    );
  }
);

/// Provider que obtiene la lista de usuarios cliente (atletas y padres) filtrados por estado de pago
final clientUsersByPaymentStatusProvider = FutureProvider.family<List<ClientUserModel>, (String, PaymentStatus)>(
  (ref, params) async {
    final repository = ref.watch(clientUserRepositoryProvider);
    final academyId = params.$1;
    final status = params.$2;
    
    final result = await repository.getClientUsers(
      academyId,
      paymentStatus: status,
    );
    
    return result.fold(
      (failure) => [],
      (clients) => clients,
    );
  }
);

// Provider optimizado que mantiene el estado en caché por más tiempo
final clientUserCachedProvider = StateNotifierProvider.family.autoDispose<ClientUserNotifier, AsyncValue<ClientUserModel?>, String>((ref, userId) {
  AppLogger.logInfo(
    'Creando clientUserCachedProvider',
    className: 'ClientUserCachedProvider',
    params: {'userId': userId}
  );
  
  return ClientUserNotifier(ref, userId);
});

class ClientUserNotifier extends StateNotifier<AsyncValue<ClientUserModel?>> {
  final Ref _ref;
  final String _userId;
  
  ClientUserNotifier(this._ref, this._userId) : super(const AsyncValue.loading()) {
    AppLogger.logInfo(
      'Inicializando ClientUserNotifier',
      className: 'ClientUserNotifier',
      params: {'userId': _userId}
    );
    _loadClientUser();
  }

  Future<void> _loadClientUser() async {
    try {
      final repository = _ref.read(clientUserRepositoryProvider);
      final currentAcademy = _ref.read(currentAcademyProvider);
      
      if (currentAcademy?.id == null) {
        // Verificar si está montado antes de actualizar el estado
        if (mounted) {
          state = const AsyncValue.data(null);
        }
        return;
      }

      final academyId = currentAcademy!.id!;
      
      AppLogger.logInfo(
        'Cargando datos para ClientUserNotifier',
        className: 'ClientUserNotifier',
        params: {
          'userId': _userId,
          'academyId': academyId,
          'isMounted': mounted,
        }
      );

      final result = await repository.getClientUser(academyId, _userId);
      
      // Verificar si el notifier sigue montado antes de actualizar el estado
      if (!mounted) {
        AppLogger.logInfo(
          'ClientUserNotifier ya no está montado, cancelando actualización de estado',
          className: 'ClientUserNotifier',
          params: {'userId': _userId}
        );
        return;
      }
      
      result.fold(
        (failure) {
          AppLogger.logError(
            message: 'Error en ClientUserNotifier',
            error: failure,
            className: 'ClientUserNotifier',
            params: {'userId': _userId}
          );
          state = AsyncValue.error(failure, StackTrace.current);
        },
        (clientUser) {
          AppLogger.logInfo(
            'Datos cargados exitosamente en ClientUserNotifier',
            className: 'ClientUserNotifier',
            params: {
              'userId': _userId,
              'clientUser_found': clientUser,
              'paymentStatus': clientUser?.paymentStatus.toString(),
            }
          );
          state = AsyncValue.data(clientUser);
        },
      );
    } catch (e, stackTrace) {
      AppLogger.logError(
        message: 'Excepción en ClientUserNotifier',
        error: e,
        stackTrace: stackTrace,
        className: 'ClientUserNotifier',
        params: {'userId': _userId}
      );
      
      // Verificar si está montado antes de actualizar el estado de error
      if (mounted) {
        state = AsyncValue.error(e, stackTrace);
      }
    }
  }

  void refresh() {
    AppLogger.logInfo(
      'Refrescando ClientUserNotifier manualmente',
      className: 'ClientUserNotifier',
      params: {
        'userId': _userId,
        'isMounted': mounted,
      }
    );
    
    // Solo refrescar si está montado
    if (!mounted) {
      AppLogger.logWarning(
        'Intentando refrescar ClientUserNotifier que ya no está montado',
        className: 'ClientUserNotifier',
        params: {'userId': _userId}
      );
      return;
    }
    
    state = const AsyncValue.loading();
    _loadClientUser();
  }

  /// Método para invalidar y recargar después de un pago
  void invalidateAfterPayment() {
    AppLogger.logInfo(
      'Invalidando ClientUserNotifier después de pago',
      className: 'ClientUserNotifier',
      params: {
        'userId': _userId,
        'isMounted': mounted,
      }
    );
    
    // Solo proceder si está montado
    if (!mounted) {
      AppLogger.logWarning(
        'Intentando invalidar ClientUserNotifier que ya no está montado',
        className: 'ClientUserNotifier',
        params: {'userId': _userId}
      );
      return;
    }
    
    // Invalidar el provider de cliente primero para limpiar caché
    _ref.invalidate(clientUserProvider(_userId));
    
    // Luego refrescar este notifier
    refresh();
  }
} 