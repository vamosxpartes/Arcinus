import 'package:flutter/material.dart';

/// Widget placeholder para simular un gráfico mientras no se implementan gráficos reales
class PlaceholderChart extends StatelessWidget {
  /// Tipo de gráfico a simular
  final ChartType chartType;
  
  /// Texto descriptivo opcional
  final String? label;
  
  /// Constructor que requiere el tipo de gráfico
  const PlaceholderChart({
    super.key,
    required this.chartType,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final IconData iconData = _getIconForType();
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconData, size: 48, color: Colors.grey.shade600),
            const SizedBox(height: 8),
            Text(label ?? _getLabelForType()),
          ],
        ),
      ),
    );
  }
  
  /// Obtiene el icono adecuado según el tipo de gráfico
  IconData _getIconForType() {
    switch (chartType) {
      case ChartType.bar:
        return Icons.bar_chart;
      case ChartType.line:
        return Icons.show_chart;
      case ChartType.pie:
        return Icons.pie_chart;
      case ChartType.radar:
        return Icons.radar;
      case ChartType.scatter:
        return Icons.bubble_chart;
    }
  }
  
  /// Obtiene una etiqueta descriptiva según el tipo de gráfico
  String _getLabelForType() {
    switch (chartType) {
      case ChartType.bar:
        return 'Gráfico de barras';
      case ChartType.line:
        return 'Gráfico de líneas';
      case ChartType.pie:
        return 'Gráfico circular';
      case ChartType.radar:
        return 'Gráfico de radar';
      case ChartType.scatter:
        return 'Gráfico de dispersión';
    }
  }
}

/// Enum para los diferentes tipos de gráficos que se pueden mostrar
enum ChartType {
  /// Gráfico de barras
  bar,
  
  /// Gráfico de líneas
  line,
  
  /// Gráfico circular
  pie,
  
  /// Gráfico de radar
  radar,
  
  /// Gráfico de dispersión
  scatter,
} 