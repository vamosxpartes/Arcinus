import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'arcinus_colors.dart';
import 'arcinus_text_styles.dart';

/// Configuración del tema de la aplicación Arcinus
/// Inspirado en la app de la NBA con un enfoque oscuro y vibrante
class ArcinusThemeData {
  ArcinusThemeData._(); // Constructor privado para evitar instanciación

  // Valores de diseño
  static const double _defaultElevation = 2.0;
  static const double _cardRadius = 12.0;
  static const double _buttonRadius = 8.0;
  static const double _inputRadius = 8.0;
  static const Duration _animationDuration = Duration(milliseconds: 300);

  /// Tema oscuro principal (default)
  static ThemeData get darkTheme {
    final ThemeData base = ThemeData.dark();
    return base.copyWith(
      // Colores base
      scaffoldBackgroundColor: ArcinusColors.backgroundDark,
      primaryColor: ArcinusColors.primaryBlue,
      canvasColor: ArcinusColors.backgroundDark,
      shadowColor: ArcinusColors.shadow,
      splashColor: ArcinusColors.primaryBlue.withAlpha(30),
      highlightColor: ArcinusColors.primaryBlue.withAlpha(15),
      disabledColor: ArcinusColors.textDisabled,
      
      // Brillo y contraste
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: ArcinusColors.primaryBlue,
        secondary: ArcinusColors.turquoise,
        error: ArcinusColors.error,
        surface: ArcinusColors.darkGrey,
        onPrimary: ArcinusColors.white,
        onSecondary: ArcinusColors.white,
        onError: ArcinusColors.white,
      ),
      
      // Tipografía
      textTheme: _buildTextTheme(base.textTheme),
      primaryTextTheme: _buildTextTheme(base.primaryTextTheme),

      // Appbar (aunque no lo estemos usando, configuramos por compatibilidad)
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: ArcinusColors.backgroundDark,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: ArcinusTextStyles.h3(),
        toolbarHeight: 56,
        centerTitle: true,
      ),
      
      // Botones
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ArcinusColors.primaryBlue,
          foregroundColor: ArcinusColors.white,
          textStyle: ArcinusTextStyles.button(),
          elevation: _defaultElevation,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_buttonRadius),
          ),
          minimumSize: const Size(88, 48),
          animationDuration: _animationDuration,
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ArcinusColors.primaryBlue,
          side: const BorderSide(color: ArcinusColors.primaryBlue, width: 2),
          textStyle: ArcinusTextStyles.button(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_buttonRadius),
          ),
          minimumSize: const Size(88, 48),
          backgroundColor: Colors.transparent,
          animationDuration: _animationDuration,
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ArcinusColors.primaryBlue,
          textStyle: ArcinusTextStyles.button(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_buttonRadius),
          ),
          minimumSize: const Size(64, 36),
          animationDuration: _animationDuration,
        ),
      ),
      
      // Tarjetas
      cardTheme: CardTheme(
        elevation: _defaultElevation,
        color: ArcinusColors.darkGrey,
        shadowColor: ArcinusColors.shadow,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardRadius),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      
      // Campos de texto
      inputDecorationTheme: InputDecorationTheme(
        fillColor: ArcinusColors.darkGrey,
        filled: true,
        hintStyle: ArcinusTextStyles.body(color: ArcinusColors.textSecondary),
        labelStyle: ArcinusTextStyles.label(color: ArcinusColors.textSecondary),
        errorStyle: ArcinusTextStyles.caption(color: ArcinusColors.error),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: const BorderSide(
            color: ArcinusColors.primaryBlue,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: const BorderSide(
            color: ArcinusColors.error,
            width: 2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: const BorderSide(
            color: ArcinusColors.error,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      
      // Switches
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return ArcinusColors.textDisabled;
          }
          if (states.contains(WidgetState.selected)) {
            return ArcinusColors.primaryBlue;
          }
          return ArcinusColors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return ArcinusColors.mediumGrey;
          }
          if (states.contains(WidgetState.selected)) {
            return ArcinusColors.primaryBlue.withAlpha(100);
          }
          return ArcinusColors.lightGrey;
        }),
      ),
      
      // Checkboxes
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return ArcinusColors.textDisabled;
          }
          if (states.contains(WidgetState.selected)) {
            return ArcinusColors.primaryBlue;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(ArcinusColors.white),
        side: const BorderSide(color: ArcinusColors.lightGrey, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      
      // Radio buttons
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return ArcinusColors.textDisabled;
          }
          if (states.contains(WidgetState.selected)) {
            return ArcinusColors.primaryBlue;
          }
          return ArcinusColors.lightGrey;
        }),
      ),
      
      // Sliders
      sliderTheme: SliderThemeData(
        activeTrackColor: ArcinusColors.primaryBlue,
        inactiveTrackColor: ArcinusColors.lightGrey.withAlpha(100),
        thumbColor: ArcinusColors.primaryBlue,
        overlayColor: ArcinusColors.primaryBlue.withAlpha(50),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
        overlayShape: const RoundSliderOverlayShape(),
      ),
      
      // BottomNavigationBar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: ArcinusColors.backgroundDark,
        selectedItemColor: ArcinusColors.primaryBlue,
        unselectedItemColor: ArcinusColors.lightGrey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // TabBar
      tabBarTheme: TabBarTheme(
        labelColor: ArcinusColors.primaryBlue,
        unselectedLabelColor: ArcinusColors.lightGrey,
        labelStyle: ArcinusTextStyles.label(),
        unselectedLabelStyle: ArcinusTextStyles.label(weight: ArcinusTextStyles.regular),
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: ArcinusColors.primaryBlue, width: 3),
        ),
      ),
      
      // Diálogos
      dialogTheme: DialogTheme(
        backgroundColor: ArcinusColors.darkGrey,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: ArcinusTextStyles.h3(),
        contentTextStyle: ArcinusTextStyles.body(),
      ),
      
      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ArcinusColors.darkGrey,
        contentTextStyle: ArcinusTextStyles.body(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
        actionTextColor: ArcinusColors.primaryBlue,
      ),
      
      // Divider
      dividerTheme: const DividerThemeData(
        color: ArcinusColors.mediumGrey,
        thickness: 1,
        space: 16,
      ),
      
      // Tooltip
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: ArcinusColors.darkGrey,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: ArcinusTextStyles.caption(color: ArcinusColors.white),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: ArcinusColors.primaryBlue,
        linearTrackColor: ArcinusColors.mediumGrey,
        circularTrackColor: ArcinusColors.mediumGrey,
      ),
      
      // PopupMenu
      popupMenuTheme: PopupMenuThemeData(
        color: ArcinusColors.darkGrey,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: ArcinusTextStyles.body(),
      ),
      
      // Animaciones
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  // Construye el tema de texto basado en la tipografía de Arcinus
  static TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: ArcinusTextStyles.stats(),
      displayMedium: ArcinusTextStyles.h1(),
      displaySmall: ArcinusTextStyles.h2(),
      headlineLarge: ArcinusTextStyles.h2(),
      headlineMedium: ArcinusTextStyles.h3(),
      headlineSmall: ArcinusTextStyles.subtitle(),
      titleLarge: ArcinusTextStyles.subtitle(),
      titleMedium: ArcinusTextStyles.body(weight: ArcinusTextStyles.medium),
      titleSmall: ArcinusTextStyles.label(),
      bodyLarge: ArcinusTextStyles.body(),
      bodyMedium: ArcinusTextStyles.secondary(weight: ArcinusTextStyles.regular),
      bodySmall: ArcinusTextStyles.caption(),
      labelLarge: ArcinusTextStyles.button(),
      labelMedium: ArcinusTextStyles.label(),
      labelSmall: ArcinusTextStyles.caption(weight: ArcinusTextStyles.medium),
    );
  }

  /// Configuración del SystemUiOverlayStyle para el estilo oscuro
  static SystemUiOverlayStyle get systemUiDarkStyle {
    return const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: ArcinusColors.backgroundDark,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
    );
  }
} 