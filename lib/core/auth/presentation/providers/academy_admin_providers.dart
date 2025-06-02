import 'package:arcinus/core/auth/models/models.dart';
import 'package:arcinus/core/auth/domain/usecases/manage_academy_admins_usecase.dart';
import 'package:arcinus/core/auth/domain/repositories/base_user_repository.dart';
import 'package:arcinus/core/auth/domain/repositories/academy_user_context_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'academy_admin_providers.g.dart';
part 'academy_admin_providers.freezed.dart';

// === Providers de repositorios ===
// Nota: Estos deberán ser implementados con las versiones reales
final baseUserRepositoryProvider = Provider<BaseUserRepository>((ref) {
  throw UnimplementedError('BaseUserRepository implementation needed');
});

final academyUserContextRepositoryProvider = Provider<AcademyUserContextRepository>((ref) {
  throw UnimplementedError('AcademyUserContextRepository implementation needed');
});

// === Provider del caso de uso ===
@riverpod
ManageAcademyAdminsUseCase manageAcademyAdminsUseCase(Ref ref) {
  return ManageAcademyAdminsUseCase(
    ref.watch(baseUserRepositoryProvider),
    ref.watch(academyUserContextRepositoryProvider),
  );
}

// === Providers de estado ===

/// Estado para la gestión de administradores
@freezed
class AcademyAdminsState with _$AcademyAdminsState {
  const factory AcademyAdminsState({
    @Default([]) List<AcademyUserContext> admins,
    @Default(false) bool isLoading,
    @Default(false) bool isPromoting,
    @Default(false) bool isUpdatingPermissions,
    String? error,
  }) = _AcademyAdminsState;
}

/// Provider para gestionar el estado de administradores de una academia
@riverpod
class AcademyAdminsNotifier extends _$AcademyAdminsNotifier {
  @override
  AcademyAdminsState build(String academyId) {
    // Cargar administradores inicialmente
    _loadAdmins();
    return const AcademyAdminsState();
  }

  // === Métodos públicos ===

  /// Carga la lista de administradores
  Future<void> loadAdmins({
    AdminType? typeFilter,
    ManagerStatus? statusFilter,
  }) async {
    await _loadAdmins(typeFilter: typeFilter, statusFilter: statusFilter);
  }

  /// Promueve un usuario a propietario
  Future<bool> promoteToOwner({
    required String userId,
    List<ManagerPermission>? customPermissions,
    String? promotedBy,
  }) async {
    state = state.copyWith(isPromoting: true, error: null);

    try {
      final useCase = ref.read(manageAcademyAdminsUseCaseProvider);
      final result = await useCase.promoteToOwner(
        userId: userId,
        academyId: academyId,
        customPermissions: customPermissions,
        promotedBy: promotedBy,
      );

      return result.fold(
        (failure) {
          state = state.copyWith(
            isPromoting: false,
            error: failure.message,
          );
          return false;
        },
        (_) {
          state = state.copyWith(isPromoting: false);
          // Recargar lista
          _loadAdmins();
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isPromoting: false,
        error: 'Error inesperado: $e',
      );
      return false;
    }
  }

  /// Promueve un usuario a colaborador
  Future<bool> promoteToPartner({
    required String userId,
    required List<ManagerPermission> permissions,
    required String promotedBy,
  }) async {
    state = state.copyWith(isPromoting: true, error: null);

    try {
      final useCase = ref.read(manageAcademyAdminsUseCaseProvider);
      final result = await useCase.promoteToPartner(
        userId: userId,
        academyId: academyId,
        permissions: permissions,
        promotedBy: promotedBy,
      );

      return result.fold(
        (failure) {
          state = state.copyWith(
            isPromoting: false,
            error: failure.message,
          );
          return false;
        },
        (_) {
          state = state.copyWith(isPromoting: false);
          // Recargar lista
          _loadAdmins();
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isPromoting: false,
        error: 'Error inesperado: $e',
      );
      return false;
    }
  }

  /// Actualiza permisos de un colaborador
  Future<bool> updatePartnerPermissions({
    required String partnerId,
    required List<ManagerPermission> newPermissions,
    required String updatedBy,
  }) async {
    state = state.copyWith(isUpdatingPermissions: true, error: null);

    try {
      final useCase = ref.read(manageAcademyAdminsUseCaseProvider);
      final result = await useCase.updatePartnerPermissions(
        partnerId: partnerId,
        academyId: academyId,
        newPermissions: newPermissions,
        updatedBy: updatedBy,
      );

      return result.fold(
        (failure) {
          state = state.copyWith(
            isUpdatingPermissions: false,
            error: failure.message,
          );
          return false;
        },
        (_) {
          state = state.copyWith(isUpdatingPermissions: false);
          // Actualizar admin específico en la lista
          _updateAdminInList(partnerId, newPermissions);
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isUpdatingPermissions: false,
        error: 'Error inesperado: $e',
      );
      return false;
    }
  }

  /// Suspende un administrador
  Future<bool> suspendAdmin({
    required String adminId,
    required String suspendedBy,
    String? reason,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final useCase = ref.read(manageAcademyAdminsUseCaseProvider);
      final result = await useCase.suspendAdmin(
        adminId: adminId,
        academyId: academyId,
        suspendedBy: suspendedBy,
        reason: reason,
      );

      return result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
          );
          return false;
        },
        (_) {
          state = state.copyWith(isLoading: false);
          // Actualizar estado del admin en la lista
          _updateAdminStatusInList(adminId, ManagerStatus.suspended);
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error inesperado: $e',
      );
      return false;
    }
  }

  /// Reactiva un administrador
  Future<bool> reactivateAdmin({
    required String adminId,
    required String reactivatedBy,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final useCase = ref.read(manageAcademyAdminsUseCaseProvider);
      final result = await useCase.reactivateAdmin(
        adminId: adminId,
        academyId: academyId,
        reactivatedBy: reactivatedBy,
      );

      return result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
          );
          return false;
        },
        (_) {
          state = state.copyWith(isLoading: false);
          // Actualizar estado del admin en la lista
          _updateAdminStatusInList(adminId, ManagerStatus.active);
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error inesperado: $e',
      );
      return false;
    }
  }

  /// Remueve un colaborador
  Future<bool> removePartner({
    required String partnerId,
    required String removedBy,
    String? reason,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final useCase = ref.read(manageAcademyAdminsUseCaseProvider);
      final result = await useCase.removePartner(
        partnerId: partnerId,
        academyId: academyId,
        removedBy: removedBy,
        reason: reason,
      );

      return result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
          );
          return false;
        },
        (_) {
          state = state.copyWith(isLoading: false);
          // Remover de la lista
          _removeAdminFromList(partnerId);
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error inesperado: $e',
      );
      return false;
    }
  }

  /// Limpia el error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // === Métodos privados ===

  Future<void> _loadAdmins({
    AdminType? typeFilter,
    ManagerStatus? statusFilter,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final useCase = ref.read(manageAcademyAdminsUseCaseProvider);
      final result = await useCase.getAcademyAdmins(
        academyId: academyId,
        typeFilter: typeFilter,
        statusFilter: statusFilter,
      );

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
          );
        },
        (admins) {
          state = state.copyWith(
            isLoading: false,
            admins: admins,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error inesperado: $e',
      );
    }
  }

  void _updateAdminInList(String adminId, List<ManagerPermission> newPermissions) {
    final updatedAdmins = state.admins.map((admin) {
      if (admin.userId == adminId) {
        return admin.withUpdatedPermissions(newPermissions);
      }
      return admin;
    }).toList();

    state = state.copyWith(admins: updatedAdmins);
  }

  void _updateAdminStatusInList(String adminId, ManagerStatus newStatus) {
    final updatedAdmins = state.admins.map((admin) {
      if (admin.userId == adminId && admin.adminData != null) {
        return admin.copyWith(
          adminData: admin.adminData!.copyWith(status: newStatus),
          updatedAt: DateTime.now(),
        );
      }
      return admin;
    }).toList();

    state = state.copyWith(admins: updatedAdmins);
  }

  void _removeAdminFromList(String adminId) {
    final updatedAdmins = state.admins.where((admin) => admin.userId != adminId).toList();
    state = state.copyWith(admins: updatedAdmins);
  }
}

// === Providers utilitarios ===

/// Provider para verificar permisos de un usuario
@riverpod
Future<bool> userHasPermission(
  Ref ref,
  String userId,
  String academyId,
  ManagerPermission permission,
) async {
  final useCase = ref.watch(manageAcademyAdminsUseCaseProvider);
  final result = await useCase.canUserPerformAction(
    userId: userId,
    academyId: academyId,
    permission: permission,
  );

  return result.fold((failure) => false, (hasPermission) => hasPermission);
}

/// Provider para obtener administradores filtrados
@riverpod
Future<List<AcademyUserContext>> filteredAcademyAdmins(
  Ref ref,
  String academyId, {
  AdminType? typeFilter,
  ManagerStatus? statusFilter,
}) async {
  final useCase = ref.watch(manageAcademyAdminsUseCaseProvider);
  final result = await useCase.getAcademyAdmins(
    academyId: academyId,
    typeFilter: typeFilter,
    statusFilter: statusFilter,
  );

  return result.fold((failure) => [], (admins) => admins);
}

/// Provider que expone solo los propietarios
@riverpod
Future<List<AcademyUserContext>> academyOwners(
  Ref ref,
  String academyId,
) async {
  return ref.watch(filteredAcademyAdminsProvider(
    academyId,
    typeFilter: AdminType.owner,
  ).future);
}

/// Provider wque expone solo los colaboradores activos
@riverpod
Future<List<AcademyUserContext>> activePartners(
  Ref ref,
  String academyId,
) async {
  return ref.watch(filteredAcademyAdminsProvider(
    academyId,
    typeFilter: AdminType.partner,
    statusFilter: ManagerStatus.active,
  ).future);
}

// === Extensiones útiles ===

extension AcademyAdminsStateX on AcademyAdminsState {
  /// Obtiene solo los propietarios
  List<AcademyUserContext> get owners => 
      admins.where((admin) => admin.isOwner).toList();

  /// Obtiene solo los colaboradores
  List<AcademyUserContext> get partners => 
      admins.where((admin) => admin.isPartner).toList();

  /// Obtiene solo los administradores activos
  List<AcademyUserContext> get activeAdmins => 
      admins.where((admin) => admin.adminData?.canOperate == true).toList();

  /// Obtiene solo los administradores suspendidos
  List<AcademyUserContext> get suspendedAdmins => 
      admins.where((admin) => admin.adminData?.status == ManagerStatus.suspended).toList();

  /// Verifica si hay alguna operación en curso
  bool get hasOperationInProgress => isLoading || isPromoting || isUpdatingPermissions;

  /// Verifica si hay errores
  bool get hasError => error != null;
} 