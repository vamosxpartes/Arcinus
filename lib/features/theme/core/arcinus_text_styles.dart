import 'package:flutter/material.dart';
import 'arcinus_colors.dart';

/// Clase que contiene todos los estilos de texto utilizados en la aplicación Arcinus
/// Implementa la jerarquía tipográfica definida en el brandbook
class ArcinusTextStyles {
  ArcinusTextStyles._(); // Constructor privado para evitar instanciación

  static const String _fontFamily = 'Roboto';

  // Pesos de fuente
  static const FontWeight thin = FontWeight.w100;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight black = FontWeight.w900;

  // Títulos
  static TextStyle h1({Color? color, FontWeight? weight, double? height}) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: 32,
      fontWeight: weight ?? black,
      color: color ?? ArcinusColors.textPrimary,
      height: height ?? 1.2,
      letterSpacing: -0.5,
    );
  }

  static TextStyle h2({Color? color, FontWeight? weight, double? height}) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: 24,
      fontWeight: weight ?? bold,
      color: color ?? ArcinusColors.textPrimary,
      height: height ?? 1.2,
      letterSpacing: -0.3,
    );
  }

  static TextStyle h3({Color? color, FontWeight? weight, double? height}) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: 20,
      fontWeight: weight ?? bold,
      color: color ?? ArcinusColors.textPrimary,
      height: height ?? 1.2,
      letterSpacing: -0.2,
    );
  }

  // Subtítulos
  static TextStyle subtitle({Color? color, FontWeight? weight, double? height}) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: 18,
      fontWeight: weight ?? medium,
      color: color ?? ArcinusColors.textPrimary,
      height: height ?? 1.3,
      letterSpacing: -0.1,
    );
  }

  // Cuerpo de texto
  static TextStyle body({Color? color, FontWeight? weight, double? height}) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: 16,
      fontWeight: weight ?? regular,
      color: color ?? ArcinusColors.textPrimary,
      height: height ?? 1.5,
    );
  }

  // Texto secundario
  static TextStyle secondary({Color? color, FontWeight? weight, double? height}) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: 14,
      fontWeight: weight ?? light,
      color: color ?? ArcinusColors.textSecondary,
      height: height ?? 1.4,
    );
  }

  // Notas pequeñas
  static TextStyle caption({Color? color, FontWeight? weight, double? height}) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: 12,
      fontWeight: weight ?? light,
      color: color ?? ArcinusColors.textSecondary,
      height: height ?? 1.3,
    );
  }

  // Estadísticas destacadas
  static TextStyle stats({Color? color, FontWeight? weight, double? height}) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: 48,
      fontWeight: weight ?? black,
      color: color ?? ArcinusColors.textPrimary,
      height: height ?? 1.1,
      letterSpacing: -1.0,
    );
  }

  // Botones
  static TextStyle button({Color? color, FontWeight? weight, double? height}) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: 16,
      fontWeight: weight ?? medium,
      color: color ?? ArcinusColors.textPrimary,
      height: height ?? 1.0,
      letterSpacing: 0.2,
    );
  }

  // Etiquetas
  static TextStyle label({Color? color, FontWeight? weight, double? height}) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: 14,
      fontWeight: weight ?? medium,
      color: color ?? ArcinusColors.textPrimary,
      height: height ?? 1.0,
      letterSpacing: 0.3,
    );
  }

  // Links
  static TextStyle link({Color? color, FontWeight? weight, double? height}) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: 16,
      fontWeight: weight ?? medium,
      color: color ?? ArcinusColors.textLink,
      height: height ?? 1.5,
      decoration: TextDecoration.underline,
    );
  }

  // Tablas
  static TextStyle tableHeader({Color? color, FontWeight? weight, double? height}) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: 14,
      fontWeight: weight ?? bold,
      color: color ?? ArcinusColors.textPrimary,
      height: height ?? 1.2,
    );
  }

  static TextStyle tableCell({Color? color, FontWeight? weight, double? height}) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: 14,
      fontWeight: weight ?? regular,
      color: color ?? ArcinusColors.textPrimary,
      height: height ?? 1.2,
    );
  }
} 