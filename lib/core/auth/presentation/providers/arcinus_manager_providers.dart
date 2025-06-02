import 'package:arcinus/core/auth/domain/repositories/arcinus_manager_repository.dart';
import 'package:arcinus/core/auth/domain/usecases/arcinus_manager_usecase.dart';
import 'package:arcinus/core/auth/models/models.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'arcinus_manager_providers.g.dart';
part 'arcinus_manager_providers.freezed.dart';

// ========================================
// PROVIDERS DE REPOSITORIO Y CASO DE USO
// ========================================

/// Provider del repositorio Arcinus Manager
/// Necesita implementación con Firestore
final arcinusManagerRepositoryProvider = Provider<ArcinusManagerRepository>((ref) {
  throw UnimplementedError('ArcinusManagerRepository implementation needed');
});

/// Provider del caso de uso Arcinus Manager
final arcinusManagerUseCaseProvider = Provider<ArcinusManagerUseCase>((ref) {
  return ArcinusManagerUseCase(ref.read(arcinusManagerRepositoryProvider));
});

// ========================================
// ESTADOS DE LA APLICACIÓN
// ========================================

/// Estado del dashboard principal de Arcinus Manager
@freezed
class ArcinusManagerDashboardState with _$ArcinusManagerDashboardState {
  const factory ArcinusManagerDashboardState({
    @Default(false) bool isLoading,
    @Default(false) bool isRefreshing,
    SystemOverview? systemOverview,
    String? error,
    DateTime? lastUpdated,
  }) = _ArcinusManagerDashboardState;
}

/// Estado para la gestión de academias
@freezed
class AcademiesManagementState with _$AcademiesManagementState {
  const factory AcademiesManagementState({
    @Default([]) List<AcademyOverview> academies,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default(false) bool hasMore,
    @Default('') String searchQuery,
    AcademyStatus? statusFilter,
    String? lastDocumentId,
    String? error,
    
    // Estados de operaciones
    @Default(false) bool isSuspending,
    @Default(false) bool isReactivating,
    @Default(false) bool isTransferring,
    String? operationError,
  }) = _AcademiesManagementState;
}

/// Estado para la gestión de super administradores
@freezed
class SuperAdminsManagementState with _$SuperAdminsManagementState {
  const factory SuperAdminsManagementState({
    @Default([]) List<BaseUser> superAdmins,
    @Default(false) bool isLoading,
    @Default(false) bool isPromoting,
    @Default(false) bool isRevoking,
    String? error,
    String? operationError,
  }) = _SuperAdminsManagementState;
}

/// Estado para auditoría y logs
@freezed
class AuditLogsState with _$AuditLogsState {
  const factory AuditLogsState({
    @Default([]) List<AuditLog> auditLogs,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default(false) bool hasMore,
    String? lastDocumentId,
    
    // Filtros
    DateTime? fromDate,
    DateTime? toDate,
    String? userId,
    String? academyId,
    AuditEventType? eventType,
    
    String? error,
  }) = _AuditLogsState;
}

/// Estado para exportación de datos
@freezed
class DataExportState with _$DataExportState {
  const factory DataExportState({
    @Default(false) bool isExporting,
    @Default([]) List<SystemExport> recentExports,
    String? error,
    SystemExport? currentExport,
  }) = _DataExportState;
}

// ========================================
// NOTIFIERS PRINCIPALES
// ========================================

/// Notifier del dashboard principal
@riverpod
class ArcinusManagerDashboardNotifier extends _$ArcinusManagerDashboardNotifier {
  @override
  ArcinusManagerDashboardState build() {
    // Cargar datos automáticamente al inicializar
    loadDashboardData();
    return const ArcinusManagerDashboardState();
  }
  
  /// Carga los datos del dashboard
  Future<void> loadDashboardData() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final useCase = ref.read(arcinusManagerUseCaseProvider);
      final result = await useCase.getSystemOverview();
      
      result.fold(
        (failure) => state = state.copyWith(
          isLoading: false,
          error: failure is SystemFailure ? failure.message : 'Error desconocido',
        ),
        (overview) => state = state.copyWith(
          isLoading: false,
          systemOverview: overview,
          lastUpdated: DateTime.now(),
          error: null,
        ),
      );
    } catch (error) {
      AppLogger.logError(
        message: 'Error al cargar datos del dashboard',
        error: error,
        className: 'ArcinusManagerDashboardNotifier',
        functionName: 'loadDashboardData',
      );
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar datos del dashboard',
      );
    }
  }
  
  /// Refresca los datos del dashboard
  Future<void> refreshDashboard() async {
    try {
      state = state.copyWith(isRefreshing: true);
      
      final useCase = ref.read(arcinusManagerUseCaseProvider);
      final result = await useCase.getSystemOverview();
      
      result.fold(
        (failure) => state = state.copyWith(
          isRefreshing: false,
          error: failure is SystemFailure ? failure.message : 'Error desconocido',
        ),
        (overview) => state = state.copyWith(
          isRefreshing: false,
          systemOverview: overview,
          lastUpdated: DateTime.now(),
          error: null,
        ),
      );
    } catch (error) {
      state = state.copyWith(
        isRefreshing: false,
        error: 'Error al refrescar dashboard',
      );
    }
  }
}

/// Notifier para gestión de academias
@riverpod
class AcademiesManagementNotifier extends _$AcademiesManagementNotifier {
  @override
  AcademiesManagementState build() {
    // Cargar academias automáticamente
    loadAcademies();
    return const AcademiesManagementState();
  }
  
  /// Carga la lista de academias
  Future<void> loadAcademies() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final useCase = ref.read(arcinusManagerUseCaseProvider);
      final result = await useCase.getAcademiesPage(
        limit: 20,
        statusFilter: state.statusFilter,
        searchQuery: state.searchQuery.isEmpty ? null : state.searchQuery,
      );
      
      result.fold(
        (failure) => state = state.copyWith(
          isLoading: false,
          error: failure is SystemFailure ? failure.message : 'Error desconocido',
        ),
        (pageResult) => state = state.copyWith(
          isLoading: false,
          academies: pageResult.academies,
          hasMore: pageResult.hasMore,
          lastDocumentId: pageResult.academies.isNotEmpty ? pageResult.academies.last.id : null,
          error: null,
        ),
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar academias',
      );
    }
  }
  
  /// Carga más academias (paginación)
  Future<void> loadMoreAcademies() async {
    if (state.isLoadingMore || !state.hasMore) return;
    
    try {
      state = state.copyWith(isLoadingMore: true);
      
      final useCase = ref.read(arcinusManagerUseCaseProvider);
      final result = await useCase.getAcademiesPage(
        limit: 20,
        lastDocumentId: state.lastDocumentId,
        statusFilter: state.statusFilter,
        searchQuery: state.searchQuery.isEmpty ? null : state.searchQuery,
      );
      
      result.fold(
        (failure) => state = state.copyWith(isLoadingMore: false),
        (pageResult) => state = state.copyWith(
          isLoadingMore: false,
          academies: [...state.academies, ...pageResult.academies],
          hasMore: pageResult.hasMore,
          lastDocumentId: pageResult.academies.isNotEmpty ? pageResult.academies.last.id : state.lastDocumentId,
        ),
      );
    } catch (error) {
      state = state.copyWith(isLoadingMore: false);
    }
  }
  
  /// Actualiza el filtro de búsqueda
  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    // Recargar con el nuevo filtro
    loadAcademies();
  }
  
  /// Actualiza el filtro de estado
  void updateStatusFilter(AcademyStatus? status) {
    state = state.copyWith(
      statusFilter: status,
      lastDocumentId: null, // Reset pagination
    );
    loadAcademies();
  }
  
  /// Suspende una academia
  Future<bool> suspendAcademy({
    required String academyId,
    required String reason,
    required String suspendedBy,
    DateTime? suspendUntil,
  }) async {
    try {
      state = state.copyWith(isSuspending: true, operationError: null);
      
      final useCase = ref.read(arcinusManagerUseCaseProvider);
      final result = await useCase.suspendAcademy(
        academyId: academyId,
        reason: reason,
        suspendedBy: suspendedBy,
        suspendUntil: suspendUntil,
      );
      
      return result.fold(
        (failure) {
          state = state.copyWith(
            isSuspending: false,
            operationError: failure is SystemFailure ? failure.message : 'Error desconocido',
          );
          return false;
        },
        (_) {
          state = state.copyWith(isSuspending: false, operationError: null);
          // Recargar lista
          loadAcademies();
          return true;
        },
      );
    } catch (error) {
      state = state.copyWith(
        isSuspending: false,
        operationError: 'Error al suspender academia',
      );
      return false;
    }
  }
  
  /// Reactiva una academia
  Future<bool> reactivateAcademy({
    required String academyId,
    required String reactivatedBy,
    String? notes,
  }) async {
    try {
      state = state.copyWith(isReactivating: true, operationError: null);
      
      final useCase = ref.read(arcinusManagerUseCaseProvider);
      final result = await useCase.reactivateAcademy(
        academyId: academyId,
        reactivatedBy: reactivatedBy,
        notes: notes,
      );
      
      return result.fold(
        (failure) {
          state = state.copyWith(
            isReactivating: false,
            operationError: failure is SystemFailure ? failure.message : 'Error desconocido',
          );
          return false;
        },
        (_) {
          state = state.copyWith(isReactivating: false, operationError: null);
          // Recargar lista
          loadAcademies();
          return true;
        },
      );
    } catch (error) {
      state = state.copyWith(
        isReactivating: false,
        operationError: 'Error al reactivar academia',
      );
      return false;
    }
  }
  
  /// Transfiere propiedad de academia
  Future<bool> transferOwnership({
    required String academyId,
    required String currentOwnerId,
    required String newOwnerId,
    required String transferredBy,
    required String reason,
  }) async {
    try {
      state = state.copyWith(isTransferring: true, operationError: null);
      
      final useCase = ref.read(arcinusManagerUseCaseProvider);
      final result = await useCase.transferAcademyOwnership(
        academyId: academyId,
        currentOwnerId: currentOwnerId,
        newOwnerId: newOwnerId,
        transferredBy: transferredBy,
        reason: reason,
      );
      
      return result.fold(
        (failure) {
          state = state.copyWith(
            isTransferring: false,
            operationError: failure is SystemFailure ? failure.message : 'Error desconocido',
          );
          return false;
        },
        (_) {
          state = state.copyWith(isTransferring: false, operationError: null);
          // Recargar lista
          loadAcademies();
          return true;
        },
      );
    } catch (error) {
      state = state.copyWith(
        isTransferring: false,
        operationError: 'Error al transferir propiedad',
      );
      return false;
    }
  }
}

/// Notifier para gestión de super administradores
@riverpod
class SuperAdminsManagementNotifier extends _$SuperAdminsManagementNotifier {
  @override
  SuperAdminsManagementState build() {
    loadSuperAdmins();
    return const SuperAdminsManagementState();
  }
  
  /// Carga la lista de super administradores
  Future<void> loadSuperAdmins() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final useCase = ref.read(arcinusManagerUseCaseProvider);
      final result = await useCase.getSuperAdmins();
      
      result.fold(
        (failure) => state = state.copyWith(
          isLoading: false,
          error: failure is SystemFailure ? failure.message : 'Error desconocido',
        ),
        (superAdmins) => state = state.copyWith(
          isLoading: false,
          superAdmins: superAdmins,
          error: null,
        ),
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar super administradores',
      );
    }
  }
  
  /// Promueve un usuario a super administrador
  Future<bool> promoteToSuperAdmin({
    required String userId,
    required String promotedBy,
    String? reason,
  }) async {
    try {
      state = state.copyWith(isPromoting: true, operationError: null);
      
      final useCase = ref.read(arcinusManagerUseCaseProvider);
      final result = await useCase.promoteToSuperAdmin(
        userId: userId,
        promotedBy: promotedBy,
        reason: reason,
      );
      
      return result.fold(
        (failure) {
          state = state.copyWith(
            isPromoting: false,
            operationError: failure is SystemFailure ? failure.message : 'Error desconocido',
          );
          return false;
        },
        (_) {
          state = state.copyWith(isPromoting: false, operationError: null);
          // Recargar lista
          loadSuperAdmins();
          return true;
        },
      );
    } catch (error) {
      state = state.copyWith(
        isPromoting: false,
        operationError: 'Error al promover usuario',
      );
      return false;
    }
  }
  
  /// Revoca permisos de super administrador
  Future<bool> revokeSuperAdmin({
    required String userId,
    required String revokedBy,
    required String reason,
  }) async {
    try {
      state = state.copyWith(isRevoking: true, operationError: null);
      
      final useCase = ref.read(arcinusManagerUseCaseProvider);
      final result = await useCase.revokeSuperAdmin(
        userId: userId,
        revokedBy: revokedBy,
        reason: reason,
      );
      
      return result.fold(
        (failure) {
          state = state.copyWith(
            isRevoking: false,
            operationError: failure is SystemFailure ? failure.message : 'Error desconocido',
          );
          return false;
        },
        (_) {
          state = state.copyWith(isRevoking: false, operationError: null);
          // Recargar lista
          loadSuperAdmins();
          return true;
        },
      );
    } catch (error) {
      state = state.copyWith(
        isRevoking: false,
        operationError: 'Error al revocar permisos',
      );
      return false;
    }
  }
}

// ========================================
// PROVIDERS DE CONSULTA
// ========================================

/// Provider que obtiene estadísticas básicas del sistema
@riverpod
Future<SystemStatistics?> systemStatistics(Ref ref) async {
  final dashboardState = ref.watch(arcinusManagerDashboardNotifierProvider);
  return dashboardState.systemOverview?.statistics;
}

/// Provider que obtiene alertas críticas
@riverpod
Future<List<SystemAlert>> criticalAlerts(Ref ref) async {
  final dashboardState = ref.watch(arcinusManagerDashboardNotifierProvider);
  return dashboardState.systemOverview?.criticalAlerts ?? [];
}

/// Provider que filtra academias por estado
@riverpod
Future<List<AcademyOverview>> filteredAcademies(
  Ref ref, {
  AcademyStatus? status,
  String? searchQuery,
}) async {
  final academiesState = ref.watch(academiesManagementNotifierProvider);
  var academies = academiesState.academies;
  
  if (status != null) {
    academies = academies.where((academy) => academy.status == status).toList();
  }
  
  if (searchQuery != null && searchQuery.trim().isNotEmpty) {
    final query = searchQuery.toLowerCase().trim();
    academies = academies.where((academy) =>
      academy.name.toLowerCase().contains(query) ||
      academy.ownerName.toLowerCase().contains(query) ||
      academy.ownerEmail.toLowerCase().contains(query)
    ).toList();
  }
  
  return academies;
}

/// Provider que obtiene métricas de rendimiento
@riverpod
Future<PerformanceMetrics?> performanceMetrics(Ref ref) async {
  final dashboardState = ref.watch(arcinusManagerDashboardNotifierProvider);
  return dashboardState.systemOverview?.performanceMetrics;
}

// ========================================
// EXTENSIONES ÚTILES
// ========================================

/// Extensiones para el estado del dashboard
extension ArcinusManagerDashboardStateX on ArcinusManagerDashboardState {
  bool get hasData => systemOverview != null;
  bool get hasError => error != null;
  bool get isOperating => isLoading || isRefreshing;
  
  int get totalAcademies => systemOverview?.statistics.totalAcademies ?? 0;
  int get criticalAlertsCount => systemOverview?.criticalAlerts.length ?? 0;
  double get systemUptime => systemOverview?.performanceMetrics.uptime ?? 0.0;
}

/// Extensiones para el estado de academias
extension AcademiesManagementStateX on AcademiesManagementState {
  bool get hasData => academies.isNotEmpty;
  bool get hasError => error != null || operationError != null;
  bool get isOperating => isLoading || isLoadingMore || isSuspending || isReactivating || isTransferring;
  
  List<AcademyOverview> get activeAcademies => 
    academies.where((academy) => academy.status == AcademyStatus.active).toList();
  
  List<AcademyOverview> get suspendedAcademies => 
    academies.where((academy) => academy.status == AcademyStatus.suspended).toList();
  
  int get totalMembers => academies.fold(0, (sum, academy) => sum + academy.totalMembers);
  double get totalRevenue => academies.fold(0.0, (sum, academy) => sum + academy.monthlyRevenue);
}

/// Extensiones para el estado de super administradores
extension SuperAdminsManagementStateX on SuperAdminsManagementState {
  bool get hasData => superAdmins.isNotEmpty;
  bool get hasError => error != null || operationError != null;
  bool get isOperating => isLoading || isPromoting || isRevoking;
  
  int get totalSuperAdmins => superAdmins.length;
} 