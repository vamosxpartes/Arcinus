import 'package:flutter/material.dart';
import '../theme/arcinus_colors.dart';
import '../theme/arcinus_theme.dart';

/// Tarjeta personalizada de Arcinus con estilos definidos en el brandbook
class ArcinusCard extends StatelessWidget {
  /// Contenido de la tarjeta
  final Widget child;

  /// Padding interno de la tarjeta
  final EdgeInsetsGeometry padding;

  /// Margen externo de la tarjeta
  final EdgeInsetsGeometry margin;

  /// Radio de borde de la tarjeta
  final double borderRadius;

  /// Color de fondo de la tarjeta (si es null y useGradient es false, se usa el color de tarjeta predeterminado)
  final Color? backgroundColor;

  /// Si debe usar un degradado como fondo
  final bool useGradient;

  /// Colores para el degradado (solo si useGradient es true)
  final List<Color>? gradientColors;

  /// Si el degradado debe ser horizontal o vertical
  final bool horizontalGradient;

  /// Elevación de la tarjeta
  final double elevation;

  /// Función para ejecutar al tocar la tarjeta
  final VoidCallback? onTap;

  /// Función para ejecutar al mantener presionada la tarjeta
  final VoidCallback? onLongPress;

  /// Si debe mostrar un efecto de borde al ser seleccionada
  final bool selected;

  /// Color del borde de selección
  final Color? selectedBorderColor;

  /// Ancho del borde de selección
  final double selectedBorderWidth;

  /// Constructor para tarjeta estándar con color sólido
  const ArcinusCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.all(8),
    this.borderRadius = 12.0,
    this.backgroundColor,
    this.elevation = 2.0,
    this.onTap,
    this.onLongPress,
    this.selected = false,
    this.selectedBorderColor,
    this.selectedBorderWidth = 2.0,
  })  : useGradient = false,
        gradientColors = null,
        horizontalGradient = true;

  /// Constructor para tarjeta con gradiente
  const ArcinusCard.gradient({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.all(8),
    this.borderRadius = 12.0,
    this.gradientColors,
    this.horizontalGradient = true,
    this.elevation = 2.0,
    this.onTap,
    this.onLongPress,
    this.selected = false,
    this.selectedBorderColor,
    this.selectedBorderWidth = 2.0,
  })  : useGradient = true,
        backgroundColor = null;

  @override
  Widget build(BuildContext context) {
    final color = backgroundColor ?? ArcinusColors.darkGrey;
    final borderColor = selectedBorderColor ?? ArcinusColors.primaryBlue;
    
    // Decoración de la tarjeta
    final BoxDecoration decoration = useGradient
        ? ArcinusTheme.cardGradientDecoration(
            colors: gradientColors ?? ArcinusColors.blueGradient,
            radius: borderRadius,
            horizontal: horizontalGradient,
          )
        : ArcinusTheme.cardSolidDecoration(
            color: color,
            radius: borderRadius,
          );
    
    // Agregar borde si está seleccionada
    final BoxDecoration finalDecoration = selected
        ? decoration.copyWith(
            border: Border.all(
              color: borderColor,
              width: selectedBorderWidth,
            ),
          )
        : decoration;

    // Contenido con padding
    final Widget paddedChild = Padding(
      padding: padding,
      child: child,
    );

    // Si la tarjeta es interactiva
    if (onTap != null || onLongPress != null) {
      return GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: margin,
          decoration: finalDecoration,
          child: Material(
            color: Colors.transparent,
            child: paddedChild,
          ),
        ),
      );
    }

    // Tarjeta no interactiva
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: margin,
      decoration: finalDecoration,
      child: paddedChild,
    );
  }
}

/// Tarjeta para mostrar estadísticas con un título y un valor destacado
class ArcinusStatCard extends StatelessWidget {
  /// Título de la estadística
  final String title;

  /// Valor de la estadística
  final String value;

  /// Subtítulo opcional
  final String? subtitle;

  /// Icono opcional
  final IconData? icon;

  /// Color del icono
  final Color? iconColor;

  /// Si debe usar un gradiente como fondo
  final bool useGradient;

  /// Colores para el gradiente
  final List<Color>? gradientColors;

  /// Color de fondo (si no usa gradiente)
  final Color? backgroundColor;

  /// Margen externo
  final EdgeInsetsGeometry margin;

  /// Acción al presionar la tarjeta
  final VoidCallback? onTap;

  const ArcinusStatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.useGradient = false,
    this.gradientColors,
    this.backgroundColor,
    this.margin = const EdgeInsets.all(8),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título y posible icono
        Row(
          children: [
            if (icon != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(
                  icon,
                  size: 20,
                  color: iconColor ?? ArcinusColors.textSecondary,
                ),
              ),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ArcinusColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Valor destacado
        Text(
          value,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: ArcinusColors.textPrimary,
            letterSpacing: -1,
          ),
        ),
        
        // Subtítulo opcional
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: ArcinusColors.textSecondary,
            ),
          ),
        ],
      ],
    );

    // Usar la tarjeta adecuada según el estilo deseado
    if (useGradient) {
      return ArcinusCard.gradient(
        margin: margin,
        gradientColors: gradientColors,
        onTap: onTap,
        child: content,
      );
    } else {
      return ArcinusCard(
        margin: margin,
        backgroundColor: backgroundColor,
        onTap: onTap,
        child: content,
      );
    }
  }
} 