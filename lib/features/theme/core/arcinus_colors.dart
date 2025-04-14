import 'package:flutter/material.dart';

/// Clase que contiene todos los colores utilizados en la aplicación Arcinus
/// Inspirada en la paleta de la app NBA con un enfoque en colores vibrantes sobre fondo oscuro
class ArcinusColors {
  ArcinusColors._(); // Constructor privado para evitar instanciación

  // Colores Primarios
  static const Color backgroundDark = Color(0xFF121212);
  static const Color primaryBlue = Color(0xFF0063FF);
  static const Color white = Color(0xFFFFFFFF);

  // Colores de Acento
  static const Color energyRed = Color(0xFFF82C2C);
  static const Color gold = Color(0xFFFFC400);
  static const Color successGreen = Color(0xFF00C853);
  static const Color turquoise = Color(0xFF00E5FF);
  static const Color purple = Color(0xFF9C27B0);

  // Escala de Grises
  static const Color darkGrey = Color(0xFF1E1E1E);
  static const Color mediumGrey = Color(0xFF323232);
  static const Color lightGrey = Color(0xFF8A8A8A);
  static const Color ultraLightGrey = Color(0xFFE0E0E0);

  // Gradientes
  static const List<Color> blueGradient = [
    Color(0xFF0063FF),
    Color(0xFF33B6FF),
  ];

  static const List<Color> redGradient = [
    Color(0xFFF82C2C),
    Color(0xFFFF6B6B),
  ];

  static const List<Color> goldGradient = [
    Color(0xFFFFC400),
    Color(0xFFFFE066),
  ];

  static const List<Color> purpleGradient = [
    Color(0xFF9C27B0),
    Color(0xFFD559EA),
  ];

  static const List<Color> turquoiseGradient = [
    Color(0xFF00E5FF),
    Color(0xFF6EFFFF),
  ];

  // Colores de Estado
  static const Color error = Color(0xFFFF3B30);
  static const Color warning = Color(0xFFFFCC00);
  static const Color success = Color(0xFF34C759);
  static const Color info = Color(0xFF5AC8FA);

  // Colores de Texto
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8A8A8A);
  static const Color textDisabled = Color(0xFF5F5F5F);
  static const Color textLink = Color(0xFF33B6FF);

  // Colores para Gráficos
  static const List<Color> chartColors = [
    primaryBlue,
    energyRed, 
    gold,
    turquoise,
    purple,
    successGreen,
  ];

  // Crea un LinearGradient a partir de los colores proporcionados
  static LinearGradient createGradient(List<Color> colors, {bool horizontal = true}) {
    return LinearGradient(
      colors: colors,
      begin: horizontal ? Alignment.centerLeft : Alignment.topCenter,
      end: horizontal ? Alignment.centerRight : Alignment.bottomCenter,
    );
  }

  // Overlay y Sombras
  static Color get shadow => Colors.black.withAlpha(60);
  static Color get overlay => Colors.black.withAlpha(125);
  static Color get shimmerBase => const Color(0xFF262626);
  static Color get shimmerHighlight => const Color(0xFF3A3A3A);
} 