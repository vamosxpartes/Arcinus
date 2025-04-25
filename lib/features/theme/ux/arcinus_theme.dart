import 'package:arcinus/features/theme/ux/arcinus_colors.dart';
import 'package:arcinus/features/theme/ux/arcinus_text_styles.dart';
import 'package:flutter/material.dart';

/// Centralized theme configuration for the Arcinus app.
abstract class ArcinusTheme {
  /// Defines the dark theme for the application.
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: ArcinusColors.primaryBlue,
      brightness: Brightness.dark,
      // Override specific colors if needed
      surface: ArcinusColors.darkSurface,
      error: ArcinusColors.error,
      // Ensure primary, secondary, etc., are generated well from the seed
      // primary: ArcinusColors.primaryBlue, // Usually generated correctly
      // secondary: ArcinusColors.accentGold, // Can override if needed
    );

    final textTheme = ArcinusTextStyles.createTextTheme(
      ArcinusColors.textOnDark,);
    final primaryTextTheme = ArcinusTextStyles.createTextTheme(
      colorScheme.onPrimary,);

    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      textTheme: textTheme,
      primaryTextTheme: primaryTextTheme, 
      // For text on primary colored surfaces
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
         // Or surfaceVariant, surfaceContainerHighest
        elevation: 0,
        titleTextStyle: ArcinusTextStyles.titleLarge.copyWith(
          color: colorScheme.onSurface,),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      // --- Component Themes ---
      cardTheme: CardTheme(
        color: colorScheme.surface,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: ArcinusTextStyles.labelLarge.copyWith(
            color: colorScheme.onPrimary,),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary),
          textStyle: ArcinusTextStyles.labelLarge.copyWith(
            color: colorScheme.primary,),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: ArcinusTextStyles.labelLarge.copyWith(
            color: colorScheme.primary,),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface, // Or a slightly different shade
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none, // Use focusedBorder/enabledBorder
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.onSurface.withAlpha(90)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        labelStyle: ArcinusTextStyles.bodyMedium.copyWith(
          color: ArcinusColors.textOnDarkSecondary,),
        hintStyle: ArcinusTextStyles.bodyMedium.copyWith(
          color: ArcinusColors.textOnDarkSecondary,),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: ArcinusTextStyles.titleLarge.copyWith(
          color: colorScheme.onSurface,),
        contentTextStyle: ArcinusTextStyles.bodyMedium.copyWith(
          color: colorScheme.onSurface,),
      ),
      // Add more component themes as needed 
      //(FloatingActionButton, BottomNavigationBar, etc.)

      // Use Material 3 features
      useMaterial3: true,
    );
  }

  // TODO(user): Define lightTheme in the future
  // static ThemeData get lightTheme { ... }
}

/// Extensions on BuildContext for easy access to theme properties.
extension ArcinusThemeExtension on BuildContext {
  /// Access the current ColorScheme.
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Access the current TextTheme.
  TextTheme get textTheme => Theme.of(this).textTheme;

  // Add shortcuts for specific colors or styles if frequently used
  // e.g., Color get primaryColor => colorScheme.primary;
  // e.g., TextStyle get bodyStyle => textTheme.bodyMedium!;
} 
