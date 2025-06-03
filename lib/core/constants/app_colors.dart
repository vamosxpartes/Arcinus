import 'package:flutter/material.dart';
import 'package:arcinus/core/theme/ux/arcinus_colors.dart';

/// Constantes de colores para la aplicación
abstract class AppColors {
  /// Color primario de la aplicación
  static const Color primary = ArcinusColors.primaryBlue;
  
  /// Color de acento
  static const Color accent = ArcinusColors.accentGold;
  
  /// Color de fondo
  static const Color background = ArcinusColors.lightBackground;
  
  /// Color de superficie
  static const Color surface = ArcinusColors.lightSurface;
  
  /// Color de texto primario
  static const Color textPrimary = ArcinusColors.textOnLight;
  
  /// Color de texto secundario
  static const Color textSecondary = ArcinusColors.textOnLightSecondary;
  
  /// Color de éxito
  static const Color success = ArcinusColors.success;
  
  /// Color de error
  static const Color error = ArcinusColors.error;
  
  /// Color de advertencia
  static const Color warning = ArcinusColors.warning;
  
  /// Color de información
  static const Color info = ArcinusColors.info;
  
  /// Gradiente primario
  static const LinearGradient primaryGradient = ArcinusColors.primaryGradient;
} 