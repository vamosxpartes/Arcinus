import 'package:arcinus/ui/shared/widgets/metrics/metric_card.dart';
import 'package:flutter/material.dart';

/// Widget que muestra un panel de métricas con gráfico y datos resumidos
class MetricsPanel extends StatelessWidget {
  /// Título descriptivo del panel
  final String title;
  
  /// Subtítulo opcional con información adicional
  final String? subtitle;
  
  /// Altura del área del gráfico
  final double chartHeight;
  
  /// Widget personalizado para el gráfico
  final Widget chartWidget;
  
  /// Lista de métricas a mostrar debajo del gráfico
  final List<MetricData> metrics;
  
  /// Función personalizada para construir el encabezado del panel
  final Widget Function(BuildContext)? headerBuilder;

  /// Constructor que requiere los campos principales
  const MetricsPanel({
    super.key,
    required this.title,
    this.subtitle,
    this.chartHeight = 150,
    required this.chartWidget,
    required this.metrics,
    this.headerBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado
        if (headerBuilder != null)
          headerBuilder!(context)
        else
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        const SizedBox(height: 8),
        
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subtítulo opcional
                if (subtitle != null) ...[
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                
                // Área del gráfico
                SizedBox(
                  height: chartHeight,
                  child: chartWidget,
                ),
                const SizedBox(height: 16),
                
                // Métricas resumidas
                Wrap(
                  spacing: 16.0,
                  runSpacing: 16.0,
                  alignment: WrapAlignment.spaceAround,
                  children: metrics.map((metric) => MetricCard(
                    title: metric.title,
                    value: metric.value,
                    icon: metric.icon,
                    color: metric.color,
                  )).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Clase para encapsular los datos de una métrica
class MetricData {
  /// Título de la métrica
  final String title;
  
  /// Valor de la métrica
  final String value;
  
  /// Icono que representa la métrica
  final IconData icon;
  
  /// Color asociado a la métrica
  final Color color;

  /// Constructor que requiere todos los campos
  const MetricData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
} 