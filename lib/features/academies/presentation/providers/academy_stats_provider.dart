import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/core/utils/app_logger.dart';

/// Modelo para datos mensuales utilizado en gráficos y análisis de tendencias
class MonthlyData {
  /// Mes representado (1-12)
  final int month;
  
  /// Año
  final int year;
  
  /// Valor de la métrica (ingresos, miembros, etc.)
  final double value;
  
  /// Etiqueta para mostrar (formato "MMM YYYY")
  final String label;

  /// Constructor para MonthlyData
  MonthlyData({
    required this.month,
    required this.year,
    required this.value,
    required this.label,
  });
}

/// Modelo para almacenar estadísticas de una academia
class AcademyStats {
  /// Número total de miembros activos en la academia
  final int totalMembers;
  
  /// Ingresos mensuales estimados
  final double? monthlyRevenue;
  
  /// Tasa de asistencia promedio (porcentaje)
  final double? attendanceRate;
  
  /// Número de equipos/grupos en la academia
  final int? totalTeams;
  
  /// Número de entrenadores/staff
  final int? totalStaff;
  
  /// Tasa de retención de miembros (porcentaje)
  final double? retentionRate;
  
  /// Tasa de crecimiento mensual (porcentaje)
  final double? growthRate;
  
  /// Ingresos proyectados anuales
  final double? projectedAnnualRevenue;
  
  /// Datos históricos de miembros
  final List<MonthlyData> memberHistory;
  
  /// Datos históricos de ingresos
  final List<MonthlyData> revenueHistory;
  
  /// Datos históricos de asistencia
  final List<MonthlyData> attendanceHistory;

  /// Constructor para AcademyStats
  AcademyStats({
    required this.totalMembers,
    this.monthlyRevenue,
    this.attendanceRate,
    this.totalTeams,
    this.totalStaff,
    this.retentionRate,
    this.growthRate,
    this.projectedAnnualRevenue,
    this.memberHistory = const [],
    this.revenueHistory = const [],
    this.attendanceHistory = const [],
  });
}

/// Provider que obtiene estadísticas para una academia específica
final academyStatsProvider = FutureProvider.family<AcademyStats?, String>((ref, academyId) async {
  try {
    // TODO: Implementar la lógica real para obtener estadísticas de la base de datos
    // Por ahora, devolvemos datos de ejemplo para propósitos de demostración
    
    // Simular retraso de red
    await Future.delayed(const Duration(milliseconds: 800));
    
    AppLogger.logInfo(
      'Cargando estadísticas para academia',
      className: 'academyStatsProvider',
      params: {'academyId': academyId},
    );
    
    // Generar datos históricos de ejemplo para los últimos 6 meses
    final now = DateTime.now();
    final memberHistory = <MonthlyData>[];
    final revenueHistory = <MonthlyData>[];
    final attendanceHistory = <MonthlyData>[];
    
    // Nombres de meses abreviados en español
    final monthNames = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    
    // Generar datos para los últimos 6 meses
    for (var i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthLabel = '${monthNames[date.month - 1]} ${date.year}';
      
      // Base + variación aleatoria para simular cambios
      final baseMembers = 35 + i;
      final baseRevenue = 3000.0 + (i * 100);
      final baseAttendance = 70.0 + (i * 1.5);
      
      memberHistory.add(MonthlyData(
        month: date.month,
        year: date.year,
        value: baseMembers.toDouble(),
        label: monthLabel,
      ));
      
      revenueHistory.add(MonthlyData(
        month: date.month,
        year: date.year,
        value: baseRevenue,
        label: monthLabel,
      ));
      
      attendanceHistory.add(MonthlyData(
        month: date.month,
        year: date.year,
        value: baseAttendance,
        label: monthLabel,
      ));
    }
    
    // Calcular tasas de crecimiento y retención basadas en datos históricos
    final currentMembers = memberHistory.last.value;
    final previousMembers = memberHistory[memberHistory.length - 2].value;
    final growthRate = ((currentMembers - previousMembers) / previousMembers) * 100;
    
    // Datos de ejemplo
    return AcademyStats(
      totalMembers: 42,
      monthlyRevenue: 3500.0,
      attendanceRate: 78.5,
      totalTeams: 5,
      totalStaff: 3,
      retentionRate: 85.0,
      growthRate: growthRate,
      projectedAnnualRevenue: 3500.0 * 12,
      memberHistory: memberHistory,
      revenueHistory: revenueHistory,
      attendanceHistory: attendanceHistory,
    );
  } catch (e, s) {
    AppLogger.logError(
      message: 'Error al cargar estadísticas de academia',
      error: e,
      stackTrace: s,
      className: 'academyStatsProvider',
      params: {'academyId': academyId},
    );
    return null;
  }
});

/// Provider para filtrar las estadísticas por período de tiempo
enum StatsPeriod { day, week, month, quarter, year }

/// Provider para el período de tiempo seleccionado
final statsPeriodProvider = StateProvider<StatsPeriod>((ref) => StatsPeriod.month);

/// Provider que proporciona estadísticas filtradas por el período seleccionado
final filteredStatsProvider = Provider.family<AcademyStats?, String>((ref, academyId) {
  final statsAsync = ref.watch(academyStatsProvider(academyId));
  
  // Si no hay datos, retornar null
  if (statsAsync.value == null) return null;
  
  final stats = statsAsync.value!;
  
  // En una implementación real, filtrarías los datos según el período
  // Por ahora, usamos los mismos datos para todos los períodos
  return stats;
}); 