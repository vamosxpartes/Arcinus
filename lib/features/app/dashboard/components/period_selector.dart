import 'package:flutter/material.dart';

/// Enum para los diferentes períodos de tiempo que se pueden seleccionar
enum MetricsPeriod {
  /// Período semanal
  week,
  
  /// Período mensual
  month,
  
  /// Período anual
  year,
}

/// Widget que permite seleccionar un período de tiempo para las métricas
class PeriodSelector extends StatelessWidget {
  /// Período actualmente seleccionado
  final MetricsPeriod selectedPeriod;
  
  /// Callback que se ejecuta cuando cambia el período seleccionado
  final ValueChanged<MetricsPeriod> onPeriodChanged;
  
  /// Constructor que requiere el período actual y la callback
  const PeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPeriodButton(context, MetricsPeriod.week, 'S'),
          _buildPeriodButton(context, MetricsPeriod.month, 'M'),
          _buildPeriodButton(context, MetricsPeriod.year, 'A'),
        ],
      ),
    );
  }
  
  /// Construye el botón para un período específico
  Widget _buildPeriodButton(BuildContext context, MetricsPeriod period, String label) {
    final isSelected = selectedPeriod == period;
    return InkWell(
      onTap: () => onPeriodChanged(period),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected 
                ? Theme.of(context).colorScheme.onPrimary 
                : Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
  
  /// Obtiene el texto descriptivo del período seleccionado
  static String getPeriodText(MetricsPeriod period) {
    switch (period) {
      case MetricsPeriod.week:
        return 'Semanal';
      case MetricsPeriod.month:
        return 'Mensual';
      case MetricsPeriod.year:
        return 'Anual';
    }
  }
  
  /// Obtiene el título para la cabecera según el período
  static String getPeriodTitle(MetricsPeriod period) {
    switch (period) {
      case MetricsPeriod.week:
        return 'Actividad Semanal';
      case MetricsPeriod.month:
        return 'Actividad Mensual';
      case MetricsPeriod.year:
        return 'Actividad Anual';
    }
  }
  
  /// Obtiene el subtítulo descriptivo del período
  static String getPeriodData(MetricsPeriod period) {
    switch (period) {
      case MetricsPeriod.week:
        return 'Últimos 7 días';
      case MetricsPeriod.month:
        return 'Últimos 30 días';
      case MetricsPeriod.year:
        return 'Últimos 12 meses';
    }
  }
} 