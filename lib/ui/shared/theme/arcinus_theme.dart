import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'arcinus_colors.dart';
import 'arcinus_text_styles.dart';
import 'arcinus_theme_data.dart';

/// Clase principal para la implementación del tema de Arcinus
/// Proporciona acceso centralizado a todos los componentes del tema
class ArcinusTheme {
  ArcinusTheme._(); // Constructor privado para evitar instanciación

  /// Obtiene el ThemeData oscuro principal (predeterminado)
  static ThemeData get darkTheme => ArcinusThemeData.darkTheme;

  /// Acceso a la paleta de colores de Arcinus
  static ArcinusColors get colors => throw UnsupportedError(
      'ArcinusColors no tiene constructor, utilice directamente ArcinusColors.nombreDelColor');

  /// Acceso a los estilos de texto de Arcinus
  static ArcinusTextStyles get textStyles => throw UnsupportedError(
      'ArcinusTextStyles no tiene constructor, utilice directamente ArcinusTextStyles.nombreDelEstilo()');

  /// Aplica el estilo del sistema UI para modo oscuro
  static void applySystemUIOverlay() {
    SystemChrome.setSystemUIOverlayStyle(ArcinusThemeData.systemUiDarkStyle);
  }

  /// Wrapper para aplicar el tema a la aplicación
  static Widget withTheme({required Widget child}) {
    return Theme(
      data: darkTheme,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: ArcinusThemeData.systemUiDarkStyle,
        child: child,
      ),
    );
  }

  /// Crea un gradiente lineal horizontal con los colores dados
  static LinearGradient horizontalGradient(List<Color> colors) {
    return ArcinusColors.createGradient(colors);
  }

  /// Crea un gradiente lineal vertical con los colores dados
  static LinearGradient verticalGradient(List<Color> colors) {
    return ArcinusColors.createGradient(colors, horizontal: false);
  }

  /// Obtiene una decoración de BoxDecoration para tarjetas con gradiente
  static BoxDecoration cardGradientDecoration({
    required List<Color> colors, 
    double radius = 12.0,
    bool horizontal = true,
  }) {
    return BoxDecoration(
      gradient: ArcinusColors.createGradient(colors, horizontal: horizontal),
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: ArcinusColors.shadow,
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Obtiene una decoración de BoxDecoration para tarjetas con color sólido
  static BoxDecoration cardSolidDecoration({
    Color? color,
    double radius = 12.0,
  }) {
    return BoxDecoration(
      color: color ?? ArcinusColors.darkGrey,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: ArcinusColors.shadow,
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
} 