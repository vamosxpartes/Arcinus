import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/features/super_admin/data/providers/dashboard_repository_provider.dart';
import 'package:arcinus/features/super_admin/data/repositories/super_admin_dashboard_repository.dart';

part 'super_admin_dashboard_provider.freezed.dart';

/// Estado del Dashboard del SuperAdmin
@freezed
class SuperAdminDashboardState with _$SuperAdminDashboardState {
  const factory SuperAdminDashboardState({
    @Default(false) bool isLoading,
    @Default(false) bool hasError,
    @Default('') String errorMessage,
    
    // Métricas de propietarios
    @Default(0) int totalOwners,
    @Default(0) int pendingOwners,
    @Default(0) int activeOwners,
    
    // Métricas de academias
    @Default(0) int totalAcademies,
    @Default(0) int activeAcademies,
    @Default(0) int inactiveAcademies,
    
    // Métricas de usuarios
    @Default(0) int totalUsers,
    @Default(0) int activeUsers,
    @Default(0) int newUsersThisMonth,
    
    // Métricas financieras
    @Default(0.0) double monthlyRevenue,
    @Default(0.0) double revenueGrowth,
    @Default(0.0) double totalRevenue,
    
    // Métricas de uso
    @Default(0) int activeSessions,
    @Default(0.0) double averageSessionTime,
    @Default([]) List<String> topFeatures,
    
    // Estado del sistema
    @Default(0.0) double systemUptime,
    @Default(0) int criticalErrors,
    @Default([]) List<SystemAlert> systemAlerts,
    
    // Timestamp de última actualización
    DateTime? lastUpdate,
  }) = _SuperAdminDashboardState;
}

/// Modelo para alertas del sistema
@freezed
class SystemAlert with _$SystemAlert {
  const factory SystemAlert({
    required String id,
    required String title,
    required String message,
    required SystemAlertType type,
    required DateTime timestamp,
    @Default(false) bool isRead,
    String? actionUrl,
  }) = _SystemAlert;
}

/// Tipos de alertas del sistema
enum SystemAlertType {
  critical,
  warning,
  info,
  success,
}

/// Notifier del Dashboard del SuperAdmin
class SuperAdminDashboardNotifier extends StateNotifier<SuperAdminDashboardState> {
  SuperAdminDashboardNotifier(this._repository) : super(const SuperAdminDashboardState());

  final SuperAdminDashboardRepository _repository;

  /// Carga los datos del dashboard desde Firestore
  Future<void> loadDashboardData() async {
    try {
      AppLogger.logInfo(
        'Cargando datos del dashboard del SuperAdmin desde Firestore',
        className: 'SuperAdminDashboardNotifier',
        functionName: 'loadDashboardData',
      );

      state = state.copyWith(isLoading: true, hasError: false);

      // Obtener métricas del dashboard
      final metricsResult = await _repository.getDashboardMetrics();
      
      await metricsResult.fold(
        (failure) async {
          AppLogger.logError(
            message: 'Error al cargar métricas del dashboard',
            error: failure,
            className: 'SuperAdminDashboardNotifier',
            functionName: 'loadDashboardData',
          );

          state = state.copyWith(
            isLoading: false,
            hasError: true,
            errorMessage: 'Error al cargar los datos del dashboard: ${failure.message}',
          );
        },
        (metrics) async {
          // Obtener alertas del sistema
          final alertsResult = await _repository.getSystemAlerts();
          
          final alerts = alertsResult.fold(
            (failure) {
              AppLogger.logWarning(
                'Error al cargar alertas del sistema',
                className: 'SuperAdminDashboardNotifier',
                functionName: 'loadDashboardData',
                error: failure,
              );
              return <SystemAlert>[];
            },
            (alertsList) => alertsList,
          );

          // Actualizar estado con métricas reales
          state = state.copyWith(
            isLoading: false,
            totalOwners: metrics.totalOwners,
            pendingOwners: metrics.pendingOwners,
            activeOwners: metrics.activeOwners,
            totalAcademies: metrics.totalAcademies,
            activeAcademies: metrics.activeAcademies,
            inactiveAcademies: metrics.inactiveAcademies,
            totalUsers: metrics.totalUsers,
            activeUsers: metrics.activeUsers,
            newUsersThisMonth: metrics.newUsersThisMonth,
            monthlyRevenue: metrics.monthlyRevenue,
            revenueGrowth: metrics.revenueGrowth,
            totalRevenue: metrics.totalRevenue,
            activeSessions: metrics.activeSessions,
            averageSessionTime: metrics.averageSessionTime,
            topFeatures: metrics.topFeatures,
            systemUptime: metrics.systemUptime,
            criticalErrors: metrics.criticalErrors,
            systemAlerts: alerts,
            lastUpdate: DateTime.now(),
          );

          AppLogger.logInfo(
            'Datos del dashboard cargados exitosamente desde Firestore',
            className: 'SuperAdminDashboardNotifier',
            functionName: 'loadDashboardData',
            params: {
              'totalOwners': metrics.totalOwners,
              'totalAcademies': metrics.totalAcademies,
              'totalUsers': metrics.totalUsers,
              'monthlyRevenue': metrics.monthlyRevenue,
            },
          );
        },
      );
    } catch (error, stackTrace) {
      AppLogger.logError(
        message: 'Error inesperado al cargar datos del dashboard',
        error: error,
        stackTrace: stackTrace,
        className: 'SuperAdminDashboardNotifier',
        functionName: 'loadDashboardData',
      );

      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Error inesperado al cargar los datos del dashboard',
      );
    }
  }

  /// Refresca los datos del dashboard
  Future<void> refreshDashboard() async {
    AppLogger.logInfo(
      'Refrescando dashboard del SuperAdmin desde Firestore',
      className: 'SuperAdminDashboardNotifier',
      functionName: 'refreshDashboard',
    );

    await loadDashboardData();
  }

  /// Marca una alerta como leída
  void markAlertAsRead(String alertId) {
    final updatedAlerts = state.systemAlerts.map((alert) {
      if (alert.id == alertId) {
        return alert.copyWith(isRead: true);
      }
      return alert;
    }).toList();

    state = state.copyWith(systemAlerts: updatedAlerts);

    AppLogger.logInfo(
      'Alerta marcada como leída',
      className: 'SuperAdminDashboardNotifier',
      functionName: 'markAlertAsRead',
      params: {'alertId': alertId},
    );
  }
}

/// Provider del Dashboard del SuperAdmin con datos reales
final superAdminDashboardProvider = StateNotifierProvider<SuperAdminDashboardNotifier, SuperAdminDashboardState>((ref) {
  final repository = ref.watch(superAdminDashboardRepositoryProvider);
  return SuperAdminDashboardNotifier(repository);
}); 