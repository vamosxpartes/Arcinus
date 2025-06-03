import 'package:flutter/material.dart';
import 'package:arcinus/core/constants/app_colors.dart';

/// Widget de botón elevado personalizado para la aplicación
class CustomElevatedButton extends StatelessWidget {
  /// Texto del botón
  final String text;
  
  /// Función a ejecutar cuando se presiona el botón
  final VoidCallback? onPressed;
  
  /// Color de fondo del botón
  final Color? backgroundColor;
  
  /// Color del texto
  final Color? foregroundColor;
  
  /// Icono opcional
  final Widget? icon;
  
  /// Tamaño del botón
  final Size? minimumSize;
  
  /// Padding interno
  final EdgeInsetsGeometry? padding;
  
  /// Estilo del texto
  final TextStyle? textStyle;
  
  /// Si el botón está cargando
  final bool isLoading;
  
  /// Ancho completo
  final bool fullWidth;

  const CustomElevatedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.icon,
    this.minimumSize,
    this.padding,
    this.textStyle,
    this.isLoading = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final Widget buttonChild = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: textStyle,
              ),
            ],
          );

    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.primary,
        foregroundColor: foregroundColor ?? Colors.white,
        minimumSize: minimumSize ?? const Size(120, 48),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
      ),
      child: buttonChild,
    );

    return fullWidth
        ? SizedBox(
            width: double.infinity,
            child: button,
          )
        : button;
  }
} 