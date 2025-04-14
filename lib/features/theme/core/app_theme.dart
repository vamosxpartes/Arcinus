import 'package:flutter/material.dart';

/// AppTheme
/// 
/// Implementación del tema de Arcinus basada en el brand book.
/// Este archivo contiene todos los estilos y colores definidos
/// en el brand book para mantener una apariencia consistente.

class AppTheme {
  // Colores Primarios
  static const Color blackSwarm = Color(0xFF000000);
  static const Color bonfireRed = Color(0xFFDA1A32);
  static const Color embers = Color(0xFFA00C30);
  static const Color magnoliaWhite = Color(0xFFFFFFFF);

  // Colores Secundarios
  static const Color goldTrophy = Color(0xFFFFC400);
  static const Color courtGreen = Color(0xFF00C853);

  // Grises UI
  static const Color darkGray = Color(0xFF1E1E1E);
  static const Color mediumGray = Color(0xFF323232);
  static const Color lightGray = Color(0xFF8A8A8A);
  static const Color disabledGray = Color(0xFF5F5F5F);

  // Tamaños de fuente
  static const double h1Size = 32.0;
  static const double h2Size = 24.0;
  static const double h3Size = 20.0;
  static const double subtitleSize = 18.0;
  static const double bodySize = 16.0;
  static const double secondarySize = 14.0;
  static const double captionSize = 12.0;
  static const double buttonSize = 16.0;
  static const double statsSize = 48.0;

  // Radios de esquina
  static const double buttonRadius = 8.0;
  static const double cardRadius = 12.0;
  static const double inputRadius = 8.0;

  // Espaciado (basado en la grid de 8px)
  static const double grid = 8.0;
  static const double spacing = grid;
  static const double spacingXs = grid / 2; // 4
  static const double spacingSm = grid; // 8
  static const double spacingMd = grid * 2; // 16
  static const double spacingLg = grid * 3; // 24
  static const double spacingXl = grid * 4; // 32

  // Elevación
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;

  // Tamaños de botones
  static const double buttonHeight = 48.0;
  static const double actionButtonSize = 56.0;

  /// Obtiene el tema claro (no utilizado actualmente, pero disponible para futuras implementaciones)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      // No se recomienda el tema claro según el brand book,
      // pero se incluye por completitud
    );
  }

  /// Obtiene el tema oscuro (tema principal según el brand book)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Colores base
      scaffoldBackgroundColor: blackSwarm,
      colorScheme: const ColorScheme.dark(
        primary: bonfireRed,
        onPrimary: magnoliaWhite,
        secondary: embers,
        onSecondary: magnoliaWhite,
        surface: darkGray,
        error: bonfireRed,
        onError: magnoliaWhite,
      ),
      
      // Tipografía
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        // Headers
        displayLarge: TextStyle(
          fontSize: h1Size, 
          fontWeight: FontWeight.w900,
          color: magnoliaWhite,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          fontSize: h2Size, 
          fontWeight: FontWeight.w700,
          color: magnoliaWhite,
          height: 1.2,
        ),
        displaySmall: TextStyle(
          fontSize: h3Size, 
          fontWeight: FontWeight.w700,
          color: magnoliaWhite,
          height: 1.2,
        ),
        
        // Subtítulos y cuerpo
        titleLarge: TextStyle(
          fontSize: subtitleSize, 
          fontWeight: FontWeight.w500,
          color: magnoliaWhite,
          height: 1.3,
        ),
        bodyLarge: TextStyle(
          fontSize: bodySize, 
          fontWeight: FontWeight.w400,
          color: magnoliaWhite,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: secondarySize, 
          fontWeight: FontWeight.w300,
          color: lightGray,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          fontSize: captionSize, 
          fontWeight: FontWeight.w300,
          color: lightGray,
          height: 1.3,
        ),
        
        // Botones
        labelLarge: TextStyle(
          fontSize: buttonSize, 
          fontWeight: FontWeight.w500,
          color: magnoliaWhite,
          height: 1.0,
        ),
      ),
      
      // Botones
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: bonfireRed,
          foregroundColor: magnoliaWhite,
          minimumSize: const Size.fromHeight(buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: const TextStyle(
            fontSize: buttonSize,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: bonfireRed,
          minimumSize: const Size.fromHeight(buttonHeight),
          side: const BorderSide(color: bonfireRed, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: const TextStyle(
            fontSize: buttonSize,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: embers,
          minimumSize: const Size.fromHeight(40),
          textStyle: const TextStyle(
            fontSize: buttonSize,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      // Cards
      cardTheme: CardTheme(
        color: mediumGray,
        elevation: elevationMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
        margin: const EdgeInsets.all(spacingSm),
      ),
      
      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: mediumGray,
        contentPadding: const EdgeInsets.all(spacingMd),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: embers, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: bonfireRed, width: 2),
        ),
        errorStyle: const TextStyle(
          color: bonfireRed,
          fontSize: captionSize,
        ),
      ),
      
      // Appbar
      appBarTheme: const AppBarTheme(
        backgroundColor: blackSwarm,
        foregroundColor: magnoliaWhite,
        elevation: 0,
      ),
      
      // Tabs
      tabBarTheme: const TabBarTheme(
        labelColor: magnoliaWhite,
        unselectedLabelColor: lightGray,
        indicatorColor: embers,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: bodySize,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: bodySize,
        ),
      ),
      
      // Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: blackSwarm,
        selectedItemColor: embers,
        unselectedItemColor: lightGray,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      
      // Iconos
      iconTheme: const IconThemeData(
        color: magnoliaWhite,
        size: 24.0,
      ),
      
      // Otros
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: embers,
        circularTrackColor: mediumGray,
        linearTrackColor: mediumGray,
      ),
      dividerTheme: const DividerThemeData(
        color: darkGray,
        thickness: 1,
        space: spacingMd,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return embers;
          }
          return mediumGray;
        }),
        checkColor: WidgetStateProperty.all(magnoliaWhite),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      
      // FAB (Action Button)
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: embers,
        foregroundColor: magnoliaWhite,
        elevation: elevationMedium,
        focusElevation: elevationHigh,
        hoverElevation: elevationHigh,
        shape: CircleBorder(),
      ),
    );
  }

  /// Método estático para definir textos de estilo de estadísticas
  static TextStyle statsTextStyle() {
    return const TextStyle(
      fontSize: statsSize,
      fontWeight: FontWeight.w900,
      color: magnoliaWhite,
      height: 1.1,
    );
  }

  /// Método para crear decoración de tarjetas con gradiente (para casos especiales)
  static BoxDecoration cardGradientDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(cardRadius),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [embers, bonfireRed],
      ),
    );
  }
} 