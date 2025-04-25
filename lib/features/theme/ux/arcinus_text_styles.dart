import 'package:flutter/material.dart';
/// Defines the text styles for the Arcinus application using the 'Roboto' font.
///
/// Centralizes all typography to ensure consistency.
abstract class ArcinusTextStyles {
  static const String _fontFamily = 'Roboto';

  /// Base text style with the default font family.
  static const TextStyle _base = TextStyle(
    fontFamily: _fontFamily,
    color: Colors.white, // Default for dark theme, override in ThemeData
  );

  // --- Display & Headline --- (Adjust sizes as needed)
  /// Display Large text style.
  static final TextStyle displayLarge = _base.copyWith(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
  );
  /// Display Medium text style.
  static final TextStyle displayMedium = _base.copyWith(
    fontSize: 45,
    fontWeight: FontWeight.w400,
  );
  /// Display Small text style.
  static final TextStyle displaySmall = _base.copyWith(
    fontSize: 36,
    fontWeight: FontWeight.w400,
  );

  /// Headline Large text style.
  static final TextStyle headlineLarge = _base.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w400,
  );
  /// Headline Medium text style.
  static final TextStyle headlineMedium = _base.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w400,
  );
  /// Headline Small text style.
  static final TextStyle headlineSmall = _base.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w500, // Medium weight for emphasis
  );

  // --- Title --- (Often used for AppBar titles, dialog titles)
  /// Title Large text style.
  static final TextStyle titleLarge = _base.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  );
  /// Title Medium text style.
  static final TextStyle titleMedium = _base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  );
  /// Title Small text style.
  static final TextStyle titleSmall = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  // --- Body --- (Standard text for content)
  /// Body Large text style.
  static final TextStyle bodyLarge = _base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );
  /// Body Medium text style.
  static final TextStyle bodyMedium = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );
  /// Body Small text style.
  static final TextStyle bodySmall = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  );

  // --- Label --- (Typically for buttons, captions, overlines)
  /// Label Large text style.
  static final TextStyle labelLarge = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500, // Medium weight
    letterSpacing: 0.1,
  );
  /// Label Medium text style.
  static final TextStyle labelMedium = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );
  /// Label Small text style.
  static final TextStyle labelSmall = _base.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  /// Creates a [TextTheme] object using the defined styles 
  /// with the provided [textColor].
  static TextTheme createTextTheme(Color textColor) {
    // Create styles with the specified text color
    final displayLargeC = displayLarge.copyWith(color: textColor);
    final displayMediumC = displayMedium.copyWith(color: textColor);
    final displaySmallC = displaySmall.copyWith(color: textColor);
    final headlineLargeC = headlineLarge.copyWith(color: textColor);
    final headlineMediumC = headlineMedium.copyWith(color: textColor);
    final headlineSmallC = headlineSmall.copyWith(color: textColor);
    final titleLargeC = titleLarge.copyWith(color: textColor);
    final titleMediumC = titleMedium.copyWith(color: textColor);
    final titleSmallC = titleSmall.copyWith(color: textColor);
    final bodyLargeC = bodyLarge.copyWith(color: textColor);
    final bodyMediumC = bodyMedium.copyWith(color: textColor);
    final bodySmallC = bodySmall.copyWith(color: textColor);
    final labelLargeC = labelLarge.copyWith(color: textColor);
    final labelMediumC = labelMedium.copyWith(color: textColor);
    final labelSmallC = labelSmall.copyWith(color: textColor);

    return TextTheme(
      displayLarge: displayLargeC,
      displayMedium: displayMediumC,
      displaySmall: displaySmallC,
      headlineLarge: headlineLargeC,
      headlineMedium: headlineMediumC,
      headlineSmall: headlineSmallC,
      titleLarge: titleLargeC,
      titleMedium: titleMediumC,
      titleSmall: titleSmallC,
      bodyLarge: bodyLargeC,
      bodyMedium: bodyMediumC,
      bodySmall: bodySmallC,
      labelLarge: labelLargeC,
      labelMedium: labelMediumC,
      labelSmall: labelSmallC,
    );
  }
} 
