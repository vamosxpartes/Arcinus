import 'package:flutter/material.dart';

/// Widget reutilizable para mostrar una métrica simple con un icono y un valor
class MetricCard extends StatelessWidget {
  /// Título de la métrica
  final String title;
  
  /// Valor de la métrica que se mostrará
  final String value;
  
  /// Icono que representa esta métrica
  final IconData icon;
  
  /// Color principal para el icono y valor (opcional)
  final Color? color;
  
  /// Tamaño mínimo de ancho de la tarjeta (opcional)
  final double? minWidth;
  
  /// Si se debe mostrar el icono con un fondo circular
  final bool circularBackground;

  /// Constructor que requiere los campos principales
  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.minWidth,
    this.circularBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    
    Widget iconWidget = Icon(icon, color: effectiveColor, size: 28);
    
    // Si se requiere fondo circular, envolvemos el icono en un contenedor
    if (circularBackground) {
      iconWidget = Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: effectiveColor.withAlpha(30),
          shape: BoxShape.circle,
        ),
        child: iconWidget,
      );
    }
    
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: minWidth ?? 80),
      child: Column(
        children: [
          iconWidget,
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: effectiveColor,
            ),
          ),
        ],
      ),
    );
  }
} 