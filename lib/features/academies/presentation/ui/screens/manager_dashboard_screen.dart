import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:arcinus/features/academies/presentation/providers/academy_stats_provider.dart';
import 'package:arcinus/features/academies/presentation/providers/current_academy_provider.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/features/navigation_shells/manager_shell/manager_shell.dart';

/// Pantalla de Dashboard para el Manager con métricas detalladas
class ManagerDashboardScreen extends ConsumerStatefulWidget {
  /// Constructor para ManagerDashboardScreen
  const ManagerDashboardScreen({super.key});

  @override
  ConsumerState<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends ConsumerState<ManagerDashboardScreen> {
  bool _titleInitialized = false;

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_titleInitialized) {
        // Establecer el título de la pantalla usando TitleManager
        ref.read(titleManagerProvider.notifier).updateCurrentTitle('Panel de control');
        _titleInitialized = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentAcademy = ref.watch(currentAcademyProvider);
    
    // Usar ref.listen para escuchar cambios en la academia actual
    ref.listen(currentAcademyProvider, (previous, current) {
      if (mounted && current != null && current != previous) {
        final title = 'Panel de ${current.name}';
        ref.read(titleManagerProvider.notifier).updateCurrentTitle(title);
      }
    });
    
    // Si no hay academia seleccionada, mostrar mensaje
    if (currentAcademy == null) {
      return const Center(
        child: Text('Selecciona una academia para ver su dashboard'),
      );
    }
    
    // Obtener estadísticas de la academia
    final academyStatsAsync = ref.watch(academyStatsProvider(currentAcademy.id!));
    final selectedPeriod = ref.watch(statsPeriodProvider);
    
    return Scaffold(
      backgroundColor: AppTheme.blackSwarm,
      body: academyStatsAsync.when(
        data: (stats) {
          if (stats == null) {
            return const Center(
              child: Text(
                'No se encontraron estadísticas disponibles',
                style: TextStyle(color: AppTheme.magnoliaWhite),
              ),
            );
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selector de período
                _buildPeriodSelector(selectedPeriod),
                
                const SizedBox(height: 24),
                
                // KPIs principales
                _buildKPISection(stats),
                
                const SizedBox(height: 24),
                
                // Gráfico de miembros
                _buildChartCard(
                  title: 'Miembros',
                  value: '${stats.totalMembers}',
                  trend: stats.growthRate,
                  chartData: stats.memberHistory,
                  color: Colors.blue,
                ),
                
                const SizedBox(height: 16),
                
                // Gráfico de ingresos
                _buildChartCard(
                  title: 'Ingresos',
                  value: '\$${stats.monthlyRevenue?.toStringAsFixed(0) ?? '0'}',
                  trend: stats.revenueHistory.isNotEmpty ? 
                    ((stats.revenueHistory.last.value - 
                      stats.revenueHistory[stats.revenueHistory.length - 2].value) / 
                      stats.revenueHistory[stats.revenueHistory.length - 2].value) * 100 : 
                    0.0,
                  chartData: stats.revenueHistory,
                  color: Colors.green,
                  valueFormat: (value) => '\$${value.toInt()}',
                ),
                
                const SizedBox(height: 16),
                
                // Gráfico de asistencia
                _buildChartCard(
                  title: 'Asistencia',
                  value: '${stats.attendanceRate?.toStringAsFixed(1) ?? '0'}%',
                  trend: stats.attendanceHistory.isNotEmpty ? 
                    ((stats.attendanceHistory.last.value - 
                      stats.attendanceHistory[stats.attendanceHistory.length - 2].value) / 
                      stats.attendanceHistory[stats.attendanceHistory.length - 2].value) * 100 : 
                    0.0,
                  chartData: stats.attendanceHistory,
                  color: Colors.orange,
                  valueFormat: (value) => '${value.toInt()}%',
                ),
                
                const SizedBox(height: 24),
                
                // Sección de métricas adicionales
                _buildAdditionalMetricsSection(stats),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppTheme.embers,
          ),
        ),
        error: (error, stack) {
          AppLogger.logError(
            message: 'Error al cargar estadísticas para dashboard',
            error: error,
            stackTrace: stack,
          );
          return Center(
            child: Text(
              'Error al cargar estadísticas: $error',
              style: const TextStyle(color: AppTheme.magnoliaWhite),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildPeriodSelector(StatsPeriod selectedPeriod) {
    return Card(
      color: AppTheme.mediumGray,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Período:',
              style: TextStyle(
                color: AppTheme.magnoliaWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
            DropdownButton<StatsPeriod>(
              value: selectedPeriod,
              dropdownColor: AppTheme.mediumGray,
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, color: AppTheme.magnoliaWhite),
              items: StatsPeriod.values.map((period) {
                String label;
                switch (period) {
                  case StatsPeriod.day:
                    label = 'Hoy';
                    break;
                  case StatsPeriod.week:
                    label = 'Semana';
                    break;
                  case StatsPeriod.month:
                    label = 'Mes';
                    break;
                  case StatsPeriod.quarter:
                    label = 'Trimestre';
                    break;
                  case StatsPeriod.year:
                    label = 'Año';
                    break;
                }
                return DropdownMenuItem<StatsPeriod>(
                  value: period,
                  child: Text(
                    label,
                    style: const TextStyle(color: AppTheme.magnoliaWhite),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  ref.read(statsPeriodProvider.notifier).state = newValue;
                }
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildKPISection(AcademyStats stats) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildKPICard(
          title: 'Miembros activos',
          value: '${stats.totalMembers}',
          icon: Icons.people,
          color: Colors.blue,
        ),
        _buildKPICard(
          title: 'Ingreso mensual',
          value: '\$${stats.monthlyRevenue?.toStringAsFixed(0) ?? '0'}',
          icon: Icons.attach_money,
          color: Colors.green,
        ),
        _buildKPICard(
          title: 'Retención',
          value: '${stats.retentionRate?.toStringAsFixed(1) ?? '0'}%',
          icon: Icons.verified_user,
          color: Colors.purple,
        ),
        _buildKPICard(
          title: 'Asistencia',
          value: '${stats.attendanceRate?.toStringAsFixed(1) ?? '0'}%',
          icon: Icons.calendar_today,
          color: Colors.orange,
        ),
      ],
    );
  }
  
  Widget _buildKPICard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      color: AppTheme.mediumGray,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.magnoliaWhite,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildChartCard({
    required String title,
    required String value,
    required double? trend,
    required List<MonthlyData> chartData,
    required Color color,
    String Function(double)? valueFormat,
  }) {
    // Formateador de valores predeterminado
    valueFormat ??= (value) => value.toStringAsFixed(0);
    
    // Verificar si hay datos suficientes
    if (chartData.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Card(
      color: AppTheme.mediumGray,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.magnoliaWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        color: color,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (trend != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Row(
                          children: [
                            Icon(
                              trend >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                              color: trend >= 0 ? Colors.green : Colors.red,
                              size: 14,
                            ),
                            Text(
                              ' ${trend.abs().toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: trend >= 0 ? Colors.green : Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 20,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppTheme.lightGray.withAlpha(60),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          // Mostrar etiquetas solo en posiciones específicas
                          if (value % 2 != 0 && value != chartData.length - 1) {
                            return const SizedBox();
                          }
                          
                          // Prevenir índices fuera de rango
                          final index = value.toInt();
                          if (index < 0 || index >= chartData.length) {
                            return const SizedBox();
                          }
                          
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              chartData[index].label,
                              style: const TextStyle(
                                color: AppTheme.magnoliaWhite,
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 20,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            valueFormat!(value),
                            style: const TextStyle(
                              color: AppTheme.lightGray,
                              fontSize: 10,
                            ),
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(chartData.length, (index) {
                        return FlSpot(index.toDouble(), chartData[index].value);
                      }),
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [color.withAlpha(125), color],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: false,
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            color.withAlpha(60),
                            color.withAlpha(0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((spot) {
                          final index = spot.x.toInt();
                          if (index < 0 || index >= chartData.length) {
                            return null;
                          }
                          
                          return LineTooltipItem(
                            '${chartData[index].label}: ${valueFormat!(spot.y)}',
                            const TextStyle(color: AppTheme.magnoliaWhite),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAdditionalMetricsSection(AcademyStats stats) {
    return Card(
      color: AppTheme.mediumGray,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Métricas Adicionales',
              style: TextStyle(
                color: AppTheme.magnoliaWhite,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildMetricRow(
              title: 'Ingreso anual proyectado',
              value: '\$${stats.projectedAnnualRevenue?.toStringAsFixed(0) ?? "0"}',
              icon: Icons.calendar_today,
            ),
            const Divider(color: AppTheme.lightGray, height: 24),
            _buildMetricRow(
              title: 'Equipos activos',
              value: '${stats.totalTeams ?? 0}',
              icon: Icons.groups,
            ),
            const Divider(color: AppTheme.lightGray, height: 24),
            _buildMetricRow(
              title: 'Personal/Entrenadores',
              value: '${stats.totalStaff ?? 0}',
              icon: Icons.sports,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMetricRow({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppTheme.magnoliaWhite.withAlpha(178),
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: AppTheme.magnoliaWhite.withAlpha(178),
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.magnoliaWhite,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
} 