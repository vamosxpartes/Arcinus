import 'package:flutter/material.dart';
import '../theme/arcinus_colors.dart';
import 'arcinus_text.dart';

/// Botón personalizado de Arcinus con estilos definidos en el brandbook
class ArcinusButton extends StatelessWidget {
  /// Texto a mostrar en el botón
  final String text;

  /// Función a ejecutar al presionar el botón
  final VoidCallback? onPressed;

  /// Icono opcional para mostrar junto al texto
  final IconData? icon;

  /// Si el icono debe mostrarse antes del texto
  final bool iconLeading;

  /// Ancho del botón (si es null, se ajusta al contenido)
  final double? width;

  /// Altura del botón
  final double height;

  /// Radio de borde del botón
  final double borderRadius;

  /// Padding interno del botón
  final EdgeInsetsGeometry padding;

  /// Espacio entre icono y texto
  final double iconSpacing;

  /// Si debe mostrar efecto de carga
  final bool isLoading;

  /// Color de fondo del botón
  final Color? backgroundColor;

  /// Color del texto e icono
  final Color? foregroundColor;

  /// Color del borde
  final Color? borderColor;

  /// Ancho del borde
  final double borderWidth;

  /// Elevación del botón
  final double elevation;

  /// Si el botón debe ocupar todo el ancho disponible
  final bool fullWidth;

  /// Constructor para botón primario
  const ArcinusButton.primary({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.iconLeading = true,
    this.width,
    this.height = 48.0,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    this.iconSpacing = 8.0,
    this.isLoading = false,
    this.fullWidth = false,
    Color? backgroundColor,
    Color? foregroundColor,
    this.borderColor,
    this.borderWidth = 0,
    this.elevation = 2.0,
  })  : backgroundColor = backgroundColor ?? ArcinusColors.primaryBlue,
        foregroundColor = foregroundColor ?? ArcinusColors.white;

  /// Constructor para botón secundario (outline)
  const ArcinusButton.secondary({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.iconLeading = true,
    this.width,
    this.height = 48.0,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    this.iconSpacing = 8.0,
    this.isLoading = false,
    this.fullWidth = false,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? borderColor,
    this.borderWidth = 2.0,
    this.elevation = 0.0,
  })  : backgroundColor = backgroundColor ?? Colors.transparent,
        foregroundColor = foregroundColor ?? ArcinusColors.primaryBlue,
        borderColor = borderColor ?? ArcinusColors.primaryBlue;

  /// Constructor para botón de texto (sin fondo)
  const ArcinusButton.text({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.iconLeading = true,
    this.width,
    this.height = 40.0,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.iconSpacing = 8.0,
    this.isLoading = false,
    this.fullWidth = false,
    Color? foregroundColor,
    this.borderColor,
    this.borderWidth = 0,
    this.elevation = 0.0,
  })  : backgroundColor = Colors.transparent,
        foregroundColor = foregroundColor ?? ArcinusColors.primaryBlue;

  /// Constructor para botón de acción circular con icono
  const ArcinusButton.action({
    super.key,
    required this.onPressed,
    required IconData this.icon,
    this.height = 56.0,
    this.isLoading = false,
    Color? backgroundColor,
    Color? foregroundColor,
    this.borderColor,
    this.borderWidth = 0,
    this.elevation = 4.0,
  })  : text = '',
        backgroundColor = backgroundColor ?? ArcinusColors.primaryBlue,
        foregroundColor = foregroundColor ?? ArcinusColors.white,
        borderRadius = height / 2,
        padding = const EdgeInsets.all(0),
        iconSpacing = 0,
        iconLeading = true,
        width = height,
        fullWidth = false;

  /// Constructor para botón con gradiente
  const ArcinusButton.gradient({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.iconLeading = true,
    this.width,
    this.height = 48.0,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    this.iconSpacing = 8.0,
    this.isLoading = false,
    this.fullWidth = false,
    Color? foregroundColor,
    this.borderColor,
    this.borderWidth = 0,
    this.elevation = 2.0,
  })  : backgroundColor = null,
        foregroundColor = foregroundColor ?? ArcinusColors.white;

  @override
  Widget build(BuildContext context) {
    // Construir el contenido del botón
    Widget buttonContent = _buildButtonContent();

    // Aplicar material para tener efectos de elevación y ripple
    return Material(
      color: Colors.transparent,
      elevation: onPressed != null ? elevation : 0,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Ink(
        decoration: _buildButtonDecoration(),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            width: fullWidth ? double.infinity : width,
            height: height,
            padding: padding,
            child: buttonContent,
          ),
        ),
      ),
    );
  }

  /// Construye la decoración del botón según el tipo
  BoxDecoration _buildButtonDecoration() {
    // Botón con gradiente
    if (backgroundColor == null) {
      return BoxDecoration(
        gradient: const LinearGradient(
          colors: ArcinusColors.blueGradient,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderWidth > 0 && borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
      );
    }

    // Botón con color sólido y posible borde
    return BoxDecoration(
      color: onPressed != null ? backgroundColor : ArcinusColors.mediumGrey,
      borderRadius: BorderRadius.circular(borderRadius),
      border: borderWidth > 0 && borderColor != null
          ? Border.all(color: borderColor!, width: borderWidth)
          : null,
    );
  }

  /// Construye el contenido interno del botón (texto, icono, spinner)
  Widget _buildButtonContent() {
    // Si está cargando, mostrar spinner
    if (isLoading) {
      return Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              foregroundColor ?? ArcinusColors.white,
            ),
          ),
        ),
      );
    }

    // Botón de acción (solo icono)
    if (text.isEmpty && icon != null) {
      return Center(
        child: Icon(
          icon,
          color: onPressed != null
              ? foregroundColor
              : ArcinusColors.textDisabled,
          size: 24,
        ),
      );
    }

    // Color del texto e icono
    final Color textIconColor = onPressed != null
        ? foregroundColor ?? ArcinusColors.white
        : ArcinusColors.textDisabled;

    // Construir botón con texto y posiblemente un icono
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: iconLeading
            ? [
                Icon(icon, size: 20, color: textIconColor),
                SizedBox(width: iconSpacing),
                Flexible(
                  child: ArcinusText.button(
                    text,
                    color: textIconColor,
                    textAlign: TextAlign.center,
                  ),
                ),
              ]
            : [
                Flexible(
                  child: ArcinusText.button(
                    text,
                    color: textIconColor,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(width: iconSpacing),
                Icon(icon, size: 20, color: textIconColor),
              ],
      );
    }

    // Botón solo con texto
    return Center(
      child: ArcinusText.button(
        text,
        color: textIconColor,
        textAlign: TextAlign.center,
      ),
    );
  }
} 