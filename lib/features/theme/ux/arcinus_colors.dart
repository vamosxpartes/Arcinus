import 'package:flutter/material.dart';

/// Defines the color palette for the Arcinus application.
///
/// Centralizes all colors used throughout the app for consistency.
abstract class ArcinusColors {
  // --- Primary Colors ---
  /// Primary blue color, often used for branding and main actions.
  static const Color primaryBlue = Color(0xFF0D47A1); // Example: Deep Blue

  // --- Accent Colors ---
  /// Accent color, used for highlighting elements or secondary actions.
  static const Color accentGold = Color(0xFFFFD700); // Example: Gold

  // --- Neutral Colors ---
  /// Base background color for dark theme.
  static const Color darkBackground = Color(0xFF121212);

  /// Color for surfaces like cards, dialogs in dark theme.
  static const Color darkSurface = Color(0xFF1E1E1E);

  /// Primary text color on dark backgrounds.
  static const Color textOnDark = Color(0xFFFFFFFF);

  /// Secondary text color (less emphasis) on dark backgrounds.
  static const Color textOnDarkSecondary = Color(0xB3FFFFFF); // White 70%

  // --- Status Colors ---
  /// Color indicating success or confirmation.
  static const Color success = Color(0xFF4CAF50);

  /// Color indicating errors or danger.
  static const Color error = Color(0xFFF44336);

  /// Color indicating warnings or potential issues.
  static const Color warning = Color(0xFFFFC107);

  /// Color indicating informational messages.
  static const Color info = Color(0xFF2196F3);

  // --- Gradients ---
  /// Example gradient, can be used for backgrounds or decorative elements.
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, Color(0xFF1976D2)], // Lighter blue
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Add more specific colors as needed (e.g., button colors, icon colors)
}
