import 'package:flutter/material.dart';

/// AppTheme
///
/// Implementación del tema de Arcinus basada en el estilo de la NBA.
/// Este archivo contiene todos los estilos y colores definidos
/// para mantener una apariencia consistente similar a la app de la NBA.

class AppTheme {
  // Colores Primarios
  /// Color negro primario para fondos
  static const Color blackSwarm = Color(0xFF000000);

  /// Color rojo primario para elementos destacados (rojo NBA)
  static const Color bonfireRed = Color(0xFFE03A3E);

  /// Color rojo oscuro para elementos secundarios
  static const Color embers = Color(0xFFC8102E);

  /// Color blanco para textos y elementos sobre fondos oscuros
  static const Color magnoliaWhite = Color(0xFFFFFFFF);

  // Colores Secundarios
  /// Color azul NBA para elementos destacados
  static const Color nbaBluePrimary = Color(0xFF17408B);

  /// Color amarillo para elementos de premio o destacados
  static const Color goldTrophy = Color(0xFFFFBF3C);

  /// Color verde para indicadores de éxito o progreso
  static const Color courtGreen = Color(0xFF007A33);

  // Grises UI
  /// Color gris oscuro para elementos de fondo secundarios
  static const Color darkGray = Color(0xFF121212);

  /// Color gris medio para tarjetas y elementos de interfaz
  static const Color mediumGray = Color(0xFF1D1D1D);

  /// Color gris claro para textos secundarios y bordes
  static const Color lightGray = Color(0xFF9E9E9E);

  /// Color gris para elementos deshabilitados
  static const Color disabledGray = Color(0xFF5F5F5F);

  // Tamaños de fuente
  /// Tamaño para titulares principales
  static const double h1Size = 28;

  /// Tamaño para titulares secundarios
  static const double h2Size = 22;

  /// Tamaño para subtítulos
  static const double h3Size = 18;

  /// Tamaño para textos destacados
  static const double subtitleSize = 16;

  /// Tamaño para texto de cuerpo principal
  static const double bodySize = 14;

  /// Tamaño para textos secundarios
  static const double secondarySize = 13;

  /// Tamaño para textos de pie de página y notas
  static const double captionSize = 11;

  /// Tamaño para texto en botones
  static const double buttonSize = 15;

  /// Tamaño para números de estadísticas
  static const double statsSize = 42;

  // Radios de esquina
  /// Radio de esquina para botones
  static const double buttonRadius = 20;

  /// Radio de esquina para tarjetas
  static const double cardRadius = 16;

  /// Radio de esquina para campos de entrada
  static const double inputRadius = 12;

  // Espaciado (basado en la grid de 8px)
  /// Valor base para la cuadrícula de espaciado
  static const double grid = 8;

  /// Alias de grid para uso como espaciado estándar
  static const double spacing = grid;

  /// Espaciado extra pequeño (4px)
  static const double spacingXs = grid / 2;

  /// Espaciado pequeño (8px)
  static const double spacingSm = grid;

  /// Espaciado medio (16px)
  static const double spacingMd = grid * 2;

  /// Espaciado grande (24px)
  static const double spacingLg = grid * 3;

  /// Espaciado extra grande (32px)
  static const double spacingXl = grid * 4;

  // Elevación
  /// Elevación baja para elementos sutiles
  static const double elevationLow = 1;

  /// Elevación media para elementos destacados
  static const double elevationMedium = 3;

  /// Elevación alta para elementos muy destacados
  static const double elevationHigh = 6;

  // Tamaños de botones
  /// Altura estándar para botones
  static const double buttonHeight = 44;

  /// Tamaño para botones de acción flotantes
  static const double actionButtonSize = 52;


  /// Obtiene el tema claro (no utilizado actualmente,
  /// pero disponible para futuras implementaciones)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      // No se recomienda el tema claro según el brand book,
      // pero se incluye por completitud
    );
  }

  /// Obtiene el tema oscuro (tema principal según el estilo NBA)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Colores base
      scaffoldBackgroundColor: blackSwarm,
      colorScheme: const ColorScheme.dark(
        primary: bonfireRed,
        onPrimary: magnoliaWhite,
        secondary: nbaBluePrimary,
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
          letterSpacing: -0.5,
          height: 1.1,
        ),
        displayMedium: TextStyle(
          fontSize: h2Size,
          fontWeight: FontWeight.w700,
          color: magnoliaWhite,
          letterSpacing: -0.25,
          height: 1.1,
        ),
        displaySmall: TextStyle(
          fontSize: h3Size,
          fontWeight: FontWeight.w700,
          color: magnoliaWhite,
          letterSpacing: 0,
          height: 1.1,
        ),

        // Subtítulos y cuerpo
        titleLarge: TextStyle(
          fontSize: subtitleSize,
          fontWeight: FontWeight.w600,
          color: magnoliaWhite,
          letterSpacing: 0.15,
          height: 1.2,
        ),
        bodyLarge: TextStyle(
          fontSize: bodySize,
          fontWeight: FontWeight.w400,
          color: magnoliaWhite,
          letterSpacing: 0.15,
          height: 1.4,
        ),
        bodyMedium: TextStyle(
          fontSize: secondarySize,
          fontWeight: FontWeight.w400,
          color: lightGray,
          letterSpacing: 0.25,
          height: 1.3,
        ),
        bodySmall: TextStyle(
          fontSize: captionSize,
          fontWeight: FontWeight.w400,
          color: lightGray,
          letterSpacing: 0.4,
          height: 1.2,
        ),

        // Botones
        labelLarge: TextStyle(
          fontSize: buttonSize,
          fontWeight: FontWeight.w600,
          color: magnoliaWhite,
          letterSpacing: 0.5,
          height: 1,
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
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: bonfireRed,
          minimumSize: const Size.fromHeight(buttonHeight),
          side: const BorderSide(color: bonfireRed, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: const TextStyle(
            fontSize: buttonSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: bonfireRed,
          minimumSize: const Size.fromHeight(40),
          textStyle: const TextStyle(
            fontSize: buttonSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Cards
      cardTheme: CardTheme(
        color: mediumGray,
        elevation: elevationLow,
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
          borderSide: const BorderSide(color: bonfireRed, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: bonfireRed, width: 1.5),
        ),
        errorStyle: const TextStyle(color: bonfireRed, fontSize: captionSize),
      ),

      // Appbar
      appBarTheme: const AppBarTheme(
        backgroundColor: blackSwarm,
        foregroundColor: magnoliaWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: h3Size,
          fontWeight: FontWeight.w700,
          color: magnoliaWhite,
        ),
      ),

      // Tabs
      tabBarTheme: const TabBarTheme(
        labelColor: magnoliaWhite,
        unselectedLabelColor: lightGray,
        indicatorColor: bonfireRed,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: bodySize,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: bodySize,
          letterSpacing: 0.5,
        ),
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: blackSwarm,
        selectedItemColor: bonfireRed,
        unselectedItemColor: lightGray,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),

      // Iconos
      iconTheme: const IconThemeData(color: magnoliaWhite, size: 22),

      // Otros
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: bonfireRed,
        circularTrackColor: mediumGray,
        linearTrackColor: mediumGray,
      ),
      dividerTheme: const DividerThemeData(
        color: darkGray,
        thickness: 0.5,
        space: spacingMd,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return bonfireRed;
          }
          return mediumGray;
        }),
        checkColor: WidgetStateProperty.all(magnoliaWhite),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // FAB (Action Button)
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: bonfireRed,
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
      letterSpacing: -0.5,
      height: 1.1,
    );
  }

  /// Método para crear decoración de tarjetas con gradiente
  /// (para casos especiales)
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
  
  /// Método para crear decoración para elementos tipo badge de LIVE
  static BoxDecoration liveBadgeDecoration() {
    return BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: bonfireRed, width: 1),
    );
  }
  
  /// Método para crear decoración para logos de equipos con borde rojo
  static BoxDecoration teamLogoDecoration() {
    return BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: bonfireRed, width: 2),
    );
  }
}
