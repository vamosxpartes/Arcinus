import 'package:arcinus/shared/models/academy.dart';
import 'package:arcinus/ui/features/dashboard/widgets/stats/period_selector.dart';
import 'package:arcinus/ui/shared/widgets/metrics/metrics_panel.dart';
import 'package:arcinus/ui/shared/widgets/metrics/placeholder_chart.dart';
import 'package:flutter/material.dart';

/// Widget que muestra estadísticas relacionadas con una academia
class AcademyStatsSection extends StatefulWidget {
  /// Academia de la cual se mostrarán las estadísticas
  final Academy academy;

  /// Constructor que requiere la academia
  const AcademyStatsSection({
    super.key,
    required this.academy,
  });

  @override
  State<AcademyStatsSection> createState() => _AcademyStatsSectionState();
}

class _AcademyStatsSectionState extends State<AcademyStatsSection> {
  /// Período seleccionado para mostrar las estadísticas
  MetricsPeriod _selectedPeriod = MetricsPeriod.month;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildActivitySection(),
        const SizedBox(height: 24),
        _buildPaymentsSection(),
        const SizedBox(height: 24),
        _buildUsersActivitySection(),
      ],
    );
  }

  /// Construye la sección de actividad con estadísticas generales
  Widget _buildActivitySection() {
    final periodTitle = PeriodSelector.getPeriodTitle(_selectedPeriod);
    final periodData = PeriodSelector.getPeriodData(_selectedPeriod);
    final periodText = PeriodSelector.getPeriodText(_selectedPeriod);
    
    // Encabezado personalizado con selector de período
    Widget header(BuildContext context) {
      return Row(
        children: [
          Expanded(
            child: Text(
              periodTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          PeriodSelector(
            selectedPeriod: _selectedPeriod,
            onPeriodChanged: (period) {
              setState(() {
                _selectedPeriod = period;
              });
            },
          ),
        ],
      );
    }
    
    // Simulación de gráfico
    final chartWidget = PlaceholderChart(
      chartType: ChartType.bar,
      label: 'Gráfico de actividad - $periodText',
    );
    
    // Métricas para mostrar
    final metrics = [
      MetricData(
        title: 'Asistencia',
        value: _getMetricValueForPeriod('asistencia'),
        icon: Icons.check_circle_outline,
        color: Colors.green,
      ),
      MetricData(
        title: 'Ausencias',
        value: _getMetricValueForPeriod('ausencias'),
        icon: Icons.cancel_outlined,
        color: Colors.red,
      ),
      MetricData(
        title: 'Clases',
        value: _getMetricValueForPeriod('clases'),
        icon: Icons.event_note,
        color: Colors.blue,
      ),
    ];
    
    return MetricsPanel(
      title: periodTitle,
      subtitle: periodData,
      chartWidget: chartWidget,
      metrics: metrics,
      headerBuilder: header,
    );
  }

  /// Construye la sección de pagos
  Widget _buildPaymentsSection() {
    final periodText = PeriodSelector.getPeriodText(_selectedPeriod);
    
    // Simulación de gráfico
    final chartWidget = const PlaceholderChart(
      chartType: ChartType.pie,
      label: 'Gráfico de pagos',
    );
    
    // Métricas para mostrar
    final metrics = [
      const MetricData(
        title: 'Pagados',
        value: '78%',
        icon: Icons.check_circle,
        color: Colors.green,
      ),
      const MetricData(
        title: 'Pendientes',
        value: '15%',
        icon: Icons.warning_amber,
        color: Colors.amber,
      ),
      const MetricData(
        title: 'Atrasados',
        value: '7%',
        icon: Icons.error_outline,
        color: Colors.red,
      ),
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MetricsPanel(
          title: 'Estado de Pagos',
          chartWidget: chartWidget,
          metrics: metrics,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Recaudado ($periodText)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '\$1,250,000',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Funcionalidad no implementada')),
                    );
                  },
                  icon: const Icon(Icons.receipt),
                  label: const Text('Ver Detalle'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Construye la sección de actividad de usuarios
  Widget _buildUsersActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actividad de Usuarios',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Métricas de usuarios - Usando Wrap
                Wrap(
                  spacing: 16.0,
                  runSpacing: 16.0,
                  alignment: WrapAlignment.spaceAround,
                  children: [
                    _buildUserActivityMetric(
                      'Nuevos',
                      '+5',
                      Icons.person_add,
                      Colors.green,
                    ),
                    _buildUserActivityMetric(
                      'Retirados',
                      '-2',
                      Icons.person_off,
                      Colors.red,
                    ),
                    _buildUserActivityMetric(
                      'Activos',
                      '28',
                      Icons.people,
                      Colors.blue,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Lista de usuarios recientes
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 3,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.primaries[index % Colors.primaries.length],
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(
                          'Usuario Ejemplo ${index + 1}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          index == 0 ? 'Nuevo registro' : 'Última actividad: hace ${index + 1} días',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Icon(
                          index == 0 ? Icons.new_releases : Icons.accessibility_new,
                          color: index == 0 ? Colors.green : Colors.blue,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Widget para mostrar una métrica de actividad de usuario
  Widget _buildUserActivityMetric(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  /// Método para simular valores según el período
  String _getMetricValueForPeriod(String metric) {
    switch (_selectedPeriod) {
      case MetricsPeriod.week:
        if (metric == 'asistencia') return '82%';
        if (metric == 'ausencias') return '18%';
        if (metric == 'clases') return '12';
        break;
      case MetricsPeriod.month:
        if (metric == 'asistencia') return '86%';
        if (metric == 'ausencias') return '14%';
        if (metric == 'clases') return '48';
        break;
      case MetricsPeriod.year:
        if (metric == 'asistencia') return '89%';
        if (metric == 'ausencias') return '11%';
        if (metric == 'clases') return '576';
        break;
    }
    return '0';
  }
} 