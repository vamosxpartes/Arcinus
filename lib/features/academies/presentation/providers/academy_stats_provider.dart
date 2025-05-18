import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/features/academies/data/repositories/academy_stats_repository.dart';

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

/// Provider para el repositorio de estadísticas 
final academyStatsRepositoryProvider = Provider<AcademyStatsRepository>((ref) {
  return AcademyStatsRepository();
});

/// Provider que obtiene estadísticas para una academia específica
final academyStatsProvider = FutureProvider.family<AcademyStats?, String>((ref, academyId) async {
  try {
    final repository = ref.watch(academyStatsRepositoryProvider);
    
    // Primero, asegurarse que existen datos de series temporales para los últimos 6 meses
    final generateResult = await repository.generateTimeSeriesData(academyId);
    
    // Si hubo error al generar los datos y no es un "not found", propagamos el error
    if (generateResult.isLeft()) {
      generateResult.fold(
        (failure) => AppLogger.logError(
          message: 'Error al generar datos de series temporales',
          error: failure,
          className: 'academyStatsProvider',
          params: {'academyId': academyId},
        ),
        (_) => null,
      );
    }
    
    // Obtener estadísticas actuales
    final statsResult = await repository.getAcademyStats(academyId);
    
    if (statsResult.isLeft()) {
      // Si no hay estadísticas, registramos el error pero continuamos para intentar obtener datos históricos
      AppLogger.logInfo(
        'No se encontraron estadísticas actuales para la academia, usando datos históricos',
        className: 'academyStatsProvider',
        params: {'academyId': academyId},
      );
    }
    
    // Calcular fechas para los últimos 6 meses
    final now = DateTime.now();
    final sixMonthsAgo = DateTime(now.year, now.month - 5, 1);
    
    // Obtener datos históricos de los últimos 6 meses
    final timeSeriesResult = await repository.getTimeSeriesData(
      academyId,
      startDate: sixMonthsAgo,
      endDate: now,
    );
    
    if (timeSeriesResult.isLeft()) {
      // Si no hay datos históricos y tampoco estadísticas actuales, retornamos null
      if (statsResult.isLeft()) {
        AppLogger.logError(
          message: 'No se encontraron datos de estadísticas ni históricos para la academia',
          className: 'academyStatsProvider',
          params: {'academyId': academyId},
        );
        return null;
      }
      
      // Si hay estadísticas actuales pero no datos históricos, creamos un objeto con solo estadísticas actuales
      return statsResult.fold(
        (_) => null, // No debería llegar aquí por la comprobación anterior
        (stats) => AcademyStats(
          totalMembers: stats.totalMembers,
          monthlyRevenue: stats.monthlyRevenue,
          attendanceRate: stats.attendanceRate,
          totalTeams: stats.totalTeams,
          totalStaff: stats.totalStaff,
          retentionRate: stats.retentionRate,
          growthRate: stats.growthRate,
          projectedAnnualRevenue: stats.projectedAnnualRevenue,
        ),
      );
    }
    
    // Si tenemos datos históricos, construir las listas de MonthlyData
    final List<MonthlyData> memberHistory = [];
    final List<MonthlyData> revenueHistory = [];
    final List<MonthlyData> attendanceHistory = [];
    
    timeSeriesResult.fold(
      (_) => null, // No debería llegar aquí por la comprobación anterior
      (timeSeriesList) {
        memberHistory.addAll(repository.convertToMonthlyData(timeSeriesList, 'members'));
        revenueHistory.addAll(repository.convertToMonthlyData(timeSeriesList, 'revenue'));
        attendanceHistory.addAll(repository.convertToMonthlyData(timeSeriesList, 'attendance'));
      },
    );
    
    // Calcular tasas de crecimiento y retención basadas en datos históricos
    double? growthRate;
    if (memberHistory.length >= 2) {
      final currentMembers = memberHistory.last.value;
      final previousMembers = memberHistory[memberHistory.length - 2].value;
      growthRate = ((currentMembers - previousMembers) / previousMembers) * 100;
    }
    
    // Si hay estadísticas actuales, usarlas; si no, usar los datos más recientes del histórico
    return statsResult.fold(
      (_) {
        // No hay estadísticas actuales, usamos el último dato histórico
        if (memberHistory.isEmpty) return null;
        
        final latestMemberCount = memberHistory.last.value.toInt();
        final latestRevenue = revenueHistory.isNotEmpty ? revenueHistory.last.value : null;
        final latestAttendance = attendanceHistory.isNotEmpty ? attendanceHistory.last.value : null;
        
        return AcademyStats(
          totalMembers: latestMemberCount,
          monthlyRevenue: latestRevenue,
          attendanceRate: latestAttendance,
          growthRate: growthRate,
          projectedAnnualRevenue: latestRevenue != null ? latestRevenue * 12 : null,
          memberHistory: memberHistory,
          revenueHistory: revenueHistory,
          attendanceHistory: attendanceHistory,
        );
      },
      (stats) {
        // Hay estadísticas actuales, las combinamos con los datos históricos
        return AcademyStats(
          totalMembers: stats.totalMembers,
          monthlyRevenue: stats.monthlyRevenue,
          attendanceRate: stats.attendanceRate,
          totalTeams: stats.totalTeams,
          totalStaff: stats.totalStaff,
          retentionRate: stats.retentionRate,
          growthRate: growthRate ?? stats.growthRate,
          projectedAnnualRevenue: stats.projectedAnnualRevenue,
          memberHistory: memberHistory,
          revenueHistory: revenueHistory,
          attendanceHistory: attendanceHistory,
        );
      },
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
  
  // Aquí podrías filtrar las historias según el período seleccionado
  // Por ejemplo, si es year, mostrar datos mensuales del último año
  // Si es quarter, mostrar datos de los últimos 3 meses, etc.
  
  // Por ahora, simplemente retornamos los datos tal cual
  return stats;
}); 