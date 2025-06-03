import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:arcinus/core/utils/app_logger.dart';

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
  SuperAdminDashboardNotifier() : super(const SuperAdminDashboardState());

  /// Carga los datos del dashboard
  Future<void> loadDashboardData() async {
    try {
      AppLogger.logInfo(
        'Cargando datos del dashboard del SuperAdmin',
        className: 'SuperAdminDashboardNotifier',
        functionName: 'loadDashboardData',
      );

      state = state.copyWith(isLoading: true, hasError: false);

      // Simular carga de datos - en producción sería desde repositorios reales
      await Future.delayed(const Duration(seconds: 2));

      // Datos simulados
      final newState = state.copyWith(
        isLoading: false,
        totalOwners: 1247,
        pendingOwners: 23,
        activeOwners: 1224,
        totalAcademies: 89,
        activeAcademies: 83,
        inactiveAcademies: 6,
        totalUsers: 15432,
        activeUsers: 12890,
        newUsersThisMonth: 234,
        monthlyRevenue: 45680.0,
        revenueGrowth: 12.5,
        totalRevenue: 523456.78,
        activeSessions: 456,
        averageSessionTime: 24.5,
        topFeatures: [
          'Gestión de Miembros',
          'Programación de Clases',
          'Sistema de Pagos',
          'Reportes',
          'Comunicación'
        ],
        systemUptime: 99.8,
        criticalErrors: 0,
        systemAlerts: _generateSampleAlerts(),
        lastUpdate: DateTime.now(),
      );

      state = newState;

      AppLogger.logInfo(
        'Datos del dashboard cargados exitosamente',
        className: 'SuperAdminDashboardNotifier',
        functionName: 'loadDashboardData',
        params: {
          'totalOwners': newState.totalOwners,
          'totalAcademies': newState.totalAcademies,
          'totalUsers': newState.totalUsers,
        },
      );

    } catch (error, stackTrace) {
      AppLogger.logError(
        message: 'Error al cargar datos del dashboard',
        error: error,
        stackTrace: stackTrace,
        className: 'SuperAdminDashboardNotifier',
        functionName: 'loadDashboardData',
      );

      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Error al cargar los datos del dashboard',
      );
    }
  }

  /// Refresca los datos del dashboard
  Future<void> refreshDashboard() async {
    AppLogger.logInfo(
      'Refrescando dashboard del SuperAdmin',
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

  /// Genera alertas de ejemplo
  List<SystemAlert> _generateSampleAlerts() {
    return [
      SystemAlert(
        id: '1',
        title: 'Suscripciones Vencidas',
        message: '5 academias tienen suscripciones vencidas que requieren atención',
        type: SystemAlertType.warning,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        actionUrl: '/super-admin/subscriptions/expired',
      ),
      SystemAlert(
        id: '2',
        title: 'Nuevos Propietarios Pendientes',
        message: '8 propietarios esperan aprobación de cuenta',
        type: SystemAlertType.info,
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        actionUrl: '/super-admin/owners/pending',
      ),
      SystemAlert(
        id: '3',
        title: 'Backup Completado',
        message: 'Respaldo del sistema completado exitosamente',
        type: SystemAlertType.success,
        timestamp: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ];
  }
}

/// Provider del Dashboard del SuperAdmin
final superAdminDashboardProvider = StateNotifierProvider<SuperAdminDashboardNotifier, SuperAdminDashboardState>((ref) {
  return SuperAdminDashboardNotifier();
}); 