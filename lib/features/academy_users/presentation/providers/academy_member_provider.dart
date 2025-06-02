import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/features/academies/presentation/providers/current_academy_provider.dart';
import 'package:arcinus/features/academy_users/data/models/member/academy_member_model.dart';
import 'package:arcinus/features/academy_users_payments/payment_status.dart';
import 'package:arcinus/features/academy_users/domain/repositories/academy_member_repository_impl.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/features/academy_users/data/repositories/academy_users_repository.dart';
import 'package:arcinus/features/academy_users/data/models/academy_user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final membersScreenSearchProvider = FutureProvider.family<List<AcademyUserModel>, ({String academyId, String searchTerm, AppRole? role})>(
  (ref, params) async {
    try {
      AppLogger.logInfo(
        'Ejecutando búsqueda de miembros',
        className: 'MembersScreenSearchProvider',
        functionName: 'membersScreenSearchProvider',
        params: {
          'academyId': params.academyId,
          'searchTerm': params.searchTerm,
          'role': params.role?.name,
        },
      );

      final repository = ref.watch(academyUsersRepositoryProvider);
      
      // Envolver la obtención de usuarios en try-catch para manejar errores de conversión
      List<AcademyUserModel> allUsers;
      try {
        allUsers = await repository.getAcademyUsers(params.academyId).first;
      } catch (e, stackTrace) {
        AppLogger.logError(
          message: 'Error obteniendo usuarios de academia',
          error: e,
          stackTrace: stackTrace,
          className: 'MembersScreenSearchProvider',
          functionName: 'membersScreenSearchProvider',
          params: {
            'academyId': params.academyId,
            'error_type': e.runtimeType.toString(),
          },
        );
        
        // En lugar de propagar el error, devolver lista vacía
        return <AcademyUserModel>[];
      }
      
      List<AcademyUserModel> filteredUsers = allUsers;

      // Filtrar por rol si se especifica
      if (params.role != null) {
        try {
          filteredUsers = filteredUsers.where((user) => user.appRole == params.role).toList();
        } catch (e, stackTrace) {
          AppLogger.logError(
            message: 'Error filtrando usuarios por rol',
            error: e,
            stackTrace: stackTrace,
            className: 'MembersScreenSearchProvider',
            params: {
              'role': params.role?.name,
              'userCount': filteredUsers.length,
            },
          );
          // Continuar sin filtrar por rol
        }
      }

      // Filtrar por término de búsqueda si se especifica
      if (params.searchTerm.isNotEmpty) {
        try {
          filteredUsers = filteredUsers.where((user) {
            final searchTermLower = params.searchTerm.toLowerCase();
            return user.fullName.toLowerCase().contains(searchTermLower);
          }).toList();
        } catch (e, stackTrace) {
          AppLogger.logError(
            message: 'Error filtrando usuarios por búsqueda',
            error: e,
            stackTrace: stackTrace,
            className: 'MembersScreenSearchProvider',
            params: {
              'searchTerm': params.searchTerm,
              'userCount': filteredUsers.length,
            },
          );
          // Continuar sin filtrar por búsqueda
        }
      }

      AppLogger.logInfo(
        'Búsqueda de miembros completada',
        className: 'MembersScreenSearchProvider',
        functionName: 'membersScreenSearchProvider',
        params: {
          'academyId': params.academyId,
          'totalUsers': allUsers.length,
          'filteredUsers': filteredUsers.length,
          'searchTerm': params.searchTerm,
          'role': params.role?.name,
        },
      );

      return filteredUsers;
    } catch (e, stackTrace) {
      AppLogger.logError(
        message: 'Error general en membersScreenSearchProvider',
        error: e,
        stackTrace: stackTrace,
        className: 'MembersScreenSearchProvider',
        functionName: 'membersScreenSearchProvider',
        params: {
          'academyId': params.academyId,
          'searchTerm': params.searchTerm,
          'role': params.role?.name,
        },
      );
      
      // En lugar de propagar el error, devolver lista vacía
      return <AcademyUserModel>[];
    }
  }
); 

/// Provider que obtiene información del miembro de academia (atleta o padre) por su ID
final academyMemberProvider = FutureProvider.family.autoDispose<AcademyMemberUserModel?, String>((ref, userId) async {
  AppLogger.logProcessStart(
    'Creando academyMemberProvider',
    className: 'AcademyMemberProvider',
    params: {
      'userId': userId,
      'timestamp': DateTime.now().toString(),
    }
  );

  // Añadir un listener para saber cuándo se destruye el provider
  ref.onDispose(() {
    AppLogger.logInfo(
      'Destruyendo academyMemberProvider',
      className: 'AcademyMemberProvider',
      params: {
        'userId': userId,
        'timestamp': DateTime.now().toString(),
      }
    );
  });

  // Obtener el repository
  final repository = ref.read(academyMemberRepositoryProvider);
  
  // Obtener la academia actual (necesaria para la consulta)
  final currentAcademy = ref.read(currentAcademyProvider);
  
  if (currentAcademy?.id == null) {
    AppLogger.logWarning(
      'No hay academia seleccionada para academyMemberProvider',
      className: 'AcademyMemberProvider',
      params: {'userId': userId}
    );
    return null;
  }

  final academyId = currentAcademy!.id!;
  
  AppLogger.logInfo(
    'Ejecutando consulta de academyMember',
    className: 'AcademyMemberProvider',
    params: {
      'userId': userId,
      'academyId': academyId,
      'repository_hashCode': repository.hashCode,
    }
  );

  try {
    final result = await repository.getAcademyMember(academyId, userId);
    
    return result.fold(
      (failure) {
        AppLogger.logError(
          message: 'Error en academyMemberProvider',
          error: failure,
          className: 'AcademyMemberProvider',
          params: {
            'userId': userId,
            'academyId': academyId,
            'failure_type': failure.runtimeType.toString(),
          }
        );
        return null;
      },
      (academyMember) {
        AppLogger.logProcessEnd(
          'academyMemberProvider completado exitosamente',
          className: 'AcademyMemberProvider',
          params: {
            'userId': userId,
            'academyId': academyId,
            'academyMember_found': academyMember ,
            'paymentStatus': academyMember?.paymentStatus.toString(),
          }
        );
        return academyMember;
      },
    );
  } catch (e, stackTrace) {
    AppLogger.logError(
      message: 'Excepción inesperada en academyMemberProvider',
      error: e,
      stackTrace: stackTrace,
      className: 'AcademyMemberProvider',
      params: {
        'userId': userId,
        'academyId': academyId,
      }
    );
    rethrow;
  }
});

/// Provider que obtiene la lista de miembros de academia (atletas y padres) filtrados por rol
final academyMembersByRoleProvider = FutureProvider.family<List<AcademyMemberUserModel>, (String, AppRole)>(
  (ref, params) async {
    final repository = ref.watch(academyMemberRepositoryProvider);
    final academyId = params.$1;
    final role = params.$2;
    
    final result = await repository.getAcademyMembers(
      academyId,
      memberType: role,
    );
    
    return result.fold(
      (failure) => [],
      (members) => members,
    );
  }
);

/// Provider que obtiene la lista de miembros de academia (atletas y padres) filtrados por estado de pago
final academyMembersByPaymentStatusProvider = FutureProvider.family<List<AcademyMemberUserModel>, (String, PaymentStatus)>(
  (ref, params) async {
    final repository = ref.watch(academyMemberRepositoryProvider);
    final academyId = params.$1;
    final status = params.$2;
    
    final result = await repository.getAcademyMembers(
      academyId,
      paymentStatus: status,
    );
    
    return result.fold(
      (failure) => [],
      (members) => members,
    );
  }
);

// Provider optimizado que mantiene el estado en caché por más tiempo
final academyMemberCachedProvider = StateNotifierProvider.family.autoDispose<AcademyMemberNotifier, AsyncValue<AcademyMemberUserModel?>, String>((ref, userId) {
  AppLogger.logInfo(
    'Creando academyMemberCachedProvider',
    className: 'AcademyMemberCachedProvider',
    params: {'userId': userId}
  );
  
  return AcademyMemberNotifier(ref, userId);
});

class AcademyMemberNotifier extends StateNotifier<AsyncValue<AcademyMemberUserModel?>> {
  final Ref _ref;
  final String _userId;
  
  AcademyMemberNotifier(this._ref, this._userId) : super(const AsyncValue.loading()) {
    AppLogger.logInfo(
      'Inicializando AcademyMemberNotifier',
      className: 'AcademyMemberNotifier',
      params: {'userId': _userId}
    );
    _loadAcademyMember();
  }

  Future<void> _loadAcademyMember() async {
    try {
      final repository = _ref.read(academyMemberRepositoryProvider);
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
        'Cargando datos para AcademyMemberNotifier',
        className: 'AcademyMemberNotifier',
        params: {
          'userId': _userId,
          'academyId': academyId,
          'isMounted': mounted,
        }
      );

      final result = await repository.getAcademyMember(academyId, _userId);
      
      // Verificar si el notifier sigue montado antes de actualizar el estado
      if (!mounted) {
        AppLogger.logInfo(
          'AcademyMemberNotifier ya no está montado, cancelando actualización de estado',
          className: 'AcademyMemberNotifier',
          params: {'userId': _userId}
        );
        return;
      }

      result.fold(
        (failure) {
          AppLogger.logError(
            message: 'Error cargando datos en AcademyMemberNotifier',
            error: failure,
            className: 'AcademyMemberNotifier',
            params: {'userId': _userId, 'academyId': academyId}
          );
          state = AsyncValue.error(failure, StackTrace.current);
        },
        (academyMember) {
          AppLogger.logInfo(
            'Datos cargados exitosamente en AcademyMemberNotifier',
            className: 'AcademyMemberNotifier',
            params: {
              'userId': _userId,
              'academyId': academyId,
              'academyMember_found': academyMember != null,
              'paymentStatus': academyMember?.paymentStatus.toString(),
            }
          );
          state = AsyncValue.data(academyMember);
        },
      );
    } catch (e, stackTrace) {
      AppLogger.logError(
        message: 'Error inesperado en AcademyMemberNotifier',
        error: e,
        stackTrace: stackTrace,
        className: 'AcademyMemberNotifier',
        params: {'userId': _userId}
      );
      
      // Solo actualizar el estado si el notifier sigue montado
      if (mounted) {
        state = AsyncValue.error(e, stackTrace);
      }
    }
  }

  /// Refresca los datos del miembro de academia
  Future<void> refresh() async {
    if (!mounted) return;
    
    AppLogger.logInfo(
      'Refrescando datos en AcademyMemberNotifier',
      className: 'AcademyMemberNotifier',
      params: {'userId': _userId}
    );
    
    state = const AsyncValue.loading();
    await _loadAcademyMember();
  }

  /// Actualiza el estado de pago localmente (para optimización de UI)
  void updatePaymentStatus(PaymentStatus newStatus) {
    if (!mounted) return;
    
    final currentValue = state.value;
    if (currentValue != null) {
      AppLogger.logInfo(
        'Actualizando estado de pago en AcademyMemberNotifier',
        className: 'AcademyMemberNotifier',
        params: {
          'userId': _userId,
          'oldStatus': currentValue.paymentStatus.toString(),
          'newStatus': newStatus.toString(),
        }
      );
      
      final updatedMember = currentValue.copyWith(paymentStatus: newStatus);
      state = AsyncValue.data(updatedMember);
    }
  }
}

/// Provider para obtener todos los miembros de la academia actual
final currentAcademyMembersProvider = FutureProvider<List<AcademyMemberUserModel>>((ref) async {
  final currentAcademy = ref.read(currentAcademyProvider);
  
  if (currentAcademy?.id == null) {
    return [];
  }
  
  final repository = ref.read(academyMemberRepositoryProvider);
  final result = await repository.getAcademyMembers(currentAcademy!.id!);
  
  return result.fold(
    (failure) => [],
    (members) => members,
  );
});

/// Provider para obtener estadísticas rápidas de miembros
final academyMembersStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final members = await ref.watch(currentAcademyMembersProvider.future);
  
  final stats = {
    'total': members.length,
    'athletes': members.where((m) => m.isAthlete).length,
    'parents': members.where((m) => m.isParent).length,
    'active': members.where((m) => m.isActive).length,
    'overdue': members.where((m) => m.isOverdue).length,
    'inactive': members.where((m) => m.paymentStatus == PaymentStatus.inactive).length,
  };
  
  AppLogger.logInfo(
    'Estadísticas de miembros calculadas',
    className: 'academyMembersStatsProvider',
    params: stats
  );
  
  return stats;
}); 