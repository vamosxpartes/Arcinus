import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/features/super_admin/data/providers/owners_repository_provider.dart';
import 'package:arcinus/features/super_admin/data/adapters/owner_data_adapter.dart';
import 'package:arcinus/features/super_admin/data/repositories/owners_management_repository.dart';
import 'package:arcinus/features/super_admin/data/models/owner_data_model.dart';

part 'owners_management_provider.freezed.dart';

/// Estado de la gestión de propietarios
@freezed
class OwnersManagementState with _$OwnersManagementState {
  const factory OwnersManagementState({
    @Default(false) bool isLoading,
    @Default(false) bool hasError,
    @Default('') String errorMessage,
    
    // Lista de propietarios
    @Default([]) List<OwnerData> owners,
    @Default([]) List<OwnerData> filteredOwners,
    
    // Filtros
    @Default(OwnerStatusFilter.all) OwnerStatusFilter statusFilter,
    @Default('') String searchQuery,
    
    // Paginación
    @Default(1) int currentPage,
    @Default(20) int itemsPerPage,
    @Default(0) int totalItems,
    
    // Timestamp de última actualización
    DateTime? lastUpdate,
  }) = _OwnersManagementState;
}

/// Modelo de datos del propietario
@freezed
class OwnerData with _$OwnerData {
  const factory OwnerData({
    required String id,
    required String firstName,
    required String lastName,
    required String email,
    String? phoneNumber,
    String? profileImageUrl,
    required OwnerStatus status,
    required DateTime createdAt,
    DateTime? lastLoginAt,
    
    // Información de la academia
    AcademyBasicInfo? academy,
    
    // Métricas básicas
    @Default(0) int totalUsers,
    @Default(0) int activeUsers,
    @Default(0.0) double monthlyRevenue,
    DateTime? lastActivityAt,
  }) = _OwnerData;
}

/// Información básica de la academia asociada
@freezed
class AcademyBasicInfo with _$AcademyBasicInfo {
  const factory AcademyBasicInfo({
    required String id,
    required String name,
    String? logoUrl,
    required String sport,
    required String country,
    required String city,
    required AcademyStatus status,
  }) = _AcademyBasicInfo;
}

/// Estados del propietario
enum OwnerStatus {
  active,      // Activo
  inactive,    // Inactivo
  suspended,   // Suspendido
  pending,     // Pendiente (funcionalidad futura)
}

/// Estados de la academia
enum AcademyStatus {
  active,
  inactive,
  suspended,
}

/// Filtros para el estado del propietario
enum OwnerStatusFilter {
  all,
  active,
  inactive,
  suspended,
  pending,
}

/// Notifier para la gestión de propietarios
class OwnersManagementNotifier extends StateNotifier<OwnersManagementState> {
  OwnersManagementNotifier(this._repository) : super(const OwnersManagementState());

  final OwnersManagementRepository _repository;

  /// Carga la lista de propietarios desde Firestore
  Future<void> loadOwners() async {
    try {
      AppLogger.logInfo(
        'Cargando lista de propietarios desde Firestore',
        className: 'OwnersManagementNotifier',
        functionName: 'loadOwners',
      );

      state = state.copyWith(isLoading: true, hasError: false);

      // Obtener propietarios del repositorio
      final ownersResult = await _repository.getAllOwners();
      
      await ownersResult.fold(
        (failure) async {
          AppLogger.logError(
            message: 'Error al cargar propietarios desde el repositorio',
            error: failure,
            className: 'OwnersManagementNotifier',
            functionName: 'loadOwners',
          );

          state = state.copyWith(
            isLoading: false,
            hasError: true,
            errorMessage: 'Error al cargar la lista de propietarios: ${failure.message}',
          );
        },
        (ownerModels) async {
          // Obtener academias y métricas para cada propietario
          final ownersAcademies = <String, List<AcademyBasicInfoModel>>{};
          final ownersMetrics = <String, OwnerMetricsModel>{};

          for (final ownerModel in ownerModels) {
            // Obtener academias del propietario
            final academiesResult = await _repository.getOwnerAcademies(ownerModel.id);
            academiesResult.fold(
              (failure) {
                AppLogger.logWarning(
                  'Error obteniendo academias para propietario ${ownerModel.id}',
                  className: 'OwnersManagementNotifier',
                  functionName: 'loadOwners',
                  error: failure,
                );
                ownersAcademies[ownerModel.id] = <AcademyBasicInfoModel>[];
              },
              (academies) {
                ownersAcademies[ownerModel.id] = academies;
              },
            );

            // Obtener métricas del propietario
            final metricsResult = await _repository.getOwnerMetrics(ownerModel.id);
            metricsResult.fold(
              (failure) {
                AppLogger.logWarning(
                  'Error obteniendo métricas para propietario ${ownerModel.id}',
                  className: 'OwnersManagementNotifier',
                  functionName: 'loadOwners',
                  error: failure,
                );
                ownersMetrics[ownerModel.id] = const OwnerMetricsModel();
              },
              (metrics) {
                ownersMetrics[ownerModel.id] = metrics;
              },
            );
          }

          // Convertir modelos a datos de UI
          final owners = await OwnerDataAdapter.toOwnerDataList(
            ownerModels,
            ownersAcademies,
            ownersMetrics,
          );

          state = state.copyWith(
            isLoading: false,
            owners: owners,
            filteredOwners: owners,
            totalItems: owners.length,
            lastUpdate: DateTime.now(),
          );

          AppLogger.logInfo(
            'Propietarios cargados exitosamente desde Firestore',
            className: 'OwnersManagementNotifier',
            functionName: 'loadOwners',
            params: {
              'totalOwners': owners.length,
            },
          );
        },
      );
    } catch (error, stackTrace) {
      AppLogger.logError(
        message: 'Error inesperado al cargar propietarios',
        error: error,
        stackTrace: stackTrace,
        className: 'OwnersManagementNotifier',
        functionName: 'loadOwners',
      );

      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Error inesperado al cargar la lista de propietarios',
      );
    }
  }

  /// Actualiza el filtro por estado
  void updateStatusFilter(OwnerStatusFilter filter) {
    AppLogger.logInfo(
      'Actualizando filtro de estado',
      className: 'OwnersManagementNotifier',
      functionName: 'updateStatusFilter',
      params: {'filter': filter.toString()},
    );

    state = state.copyWith(statusFilter: filter);
    _applyFilters();
  }

  /// Actualiza la consulta de búsqueda
  void updateSearchQuery(String query) {
    AppLogger.logInfo(
      'Actualizando búsqueda',
      className: 'OwnersManagementNotifier',
      functionName: 'updateSearchQuery',
      params: {'query': query},
    );

    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  /// Aplica los filtros actuales
  void _applyFilters() {
    var filtered = List<OwnerData>.from(state.owners);

    // Filtrar por estado
    if (state.statusFilter != OwnerStatusFilter.all) {
      final targetStatus = _mapFilterToStatus(state.statusFilter);
      if (targetStatus != null) {
        filtered = filtered.where((owner) => owner.status == targetStatus).toList();
      }
    }

    // Filtrar por búsqueda
    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filtered = filtered.where((owner) {
        return owner.firstName.toLowerCase().contains(query) ||
               owner.lastName.toLowerCase().contains(query) ||
               owner.email.toLowerCase().contains(query) ||
               (owner.academy?.name.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    state = state.copyWith(
      filteredOwners: filtered,
      currentPage: 1, // Reset a la primera página
    );

    AppLogger.logInfo(
      'Filtros aplicados',
      className: 'OwnersManagementNotifier',
      functionName: '_applyFilters',
      params: {
        'totalFiltered': filtered.length,
        'originalTotal': state.owners.length,
      },
    );
  }

  /// Cambia el estado de un propietario en Firestore
  Future<void> changeOwnerStatus(String ownerId, OwnerStatus newStatus) async {
    try {
      AppLogger.logInfo(
        'Cambiando estado del propietario en Firestore',
        className: 'OwnersManagementNotifier',
        functionName: 'changeOwnerStatus',
        params: {
          'ownerId': ownerId,
          'newStatus': newStatus.toString(),
        },
      );

      // Actualizar en Firestore
      final isActive = newStatus == OwnerStatus.active;
      final updateResult = await _repository.updateOwnerStatus(ownerId, isActive);

      await updateResult.fold(
        (failure) async {
          AppLogger.logError(
            message: 'Error al actualizar estado del propietario en Firestore',
            error: failure,
            className: 'OwnersManagementNotifier',
            functionName: 'changeOwnerStatus',
          );
        },
        (_) async {
          // Actualizar el estado local
          final updatedOwners = state.owners.map((owner) {
            if (owner.id == ownerId) {
              return owner.copyWith(status: newStatus);
            }
            return owner;
          }).toList();

          state = state.copyWith(owners: updatedOwners);
          _applyFilters(); // Reaplica filtros con los datos actualizados

          AppLogger.logInfo(
            'Estado del propietario actualizado exitosamente en Firestore',
            className: 'OwnersManagementNotifier',
            functionName: 'changeOwnerStatus',
          );
        },
      );
    } catch (error, stackTrace) {
      AppLogger.logError(
        message: 'Error inesperado al cambiar estado del propietario',
        error: error,
        stackTrace: stackTrace,
        className: 'OwnersManagementNotifier',
        functionName: 'changeOwnerStatus',
      );
    }
  }

  /// Refresca la lista de propietarios
  Future<void> refreshOwners() async {
    AppLogger.logInfo(
      'Refrescando lista de propietarios desde Firestore',
      className: 'OwnersManagementNotifier',
      functionName: 'refreshOwners',
    );

    await loadOwners();
  }

  /// Mapea filtro a estado
  OwnerStatus? _mapFilterToStatus(OwnerStatusFilter filter) {
    switch (filter) {
      case OwnerStatusFilter.active:
        return OwnerStatus.active;
      case OwnerStatusFilter.inactive:
        return OwnerStatus.inactive;
      case OwnerStatusFilter.suspended:
        return OwnerStatus.suspended;
      case OwnerStatusFilter.pending:
        return OwnerStatus.pending;
      case OwnerStatusFilter.all:
        return null;
    }
  }
}

/// Provider para la gestión de propietarios con datos reales
final ownersManagementProvider = StateNotifierProvider<OwnersManagementNotifier, OwnersManagementState>((ref) {
  final repository = ref.watch(ownersManagementRepositoryProvider);
  return OwnersManagementNotifier(repository);
}); 