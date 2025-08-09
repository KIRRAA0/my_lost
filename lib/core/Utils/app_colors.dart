import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Colors - Matching the logo's gradient theme
  static const Color lightPrimaryColor = Color(0xFFE91E63); // Pink/Magenta from logo
  static const Color lightBackgroundColor = Color(0xFFFFFFFF);
  static const Color lightSurfaceColor = Color(0xFFFAF5F7); // Soft pink tint
  static const Color lightSecondaryColor = Color(0xFFFF9800); // Orange from logo
  static const Color lightAccentColor = Color(0xFFFF6B35); // Orange-red accent
  static const Color lightTextPrimary = Color(0xFF000000);
  static const Color lightTextSecondary = Color(0xFF666666);
  static const Color lightCardColor = Color(0xFFFFFFFF);
  static const Color lightDividerColor = Color(0xFFE0E0E0);

  // Dark Theme Colors - Matching the logo's gradient theme
  static const Color darkPrimaryColor = Color(0xFFE91E63); // Pink/Magenta from logo
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkSurfaceColor = Color(0xFF1E1E1E);
  static const Color darkSecondaryColor = Color(0xFFFF9800); // Orange from logo
  static const Color darkAccentColor = Color(0xFFFF6B35); // Orange-red accent
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkCardColor = Color(0xFF2D2D2D);
  static const Color darkDividerColor = Color(0xFF404040);

  // Additional gradient colors for enhanced theming
  static const Color gradientStart = Color(0xFFE91E63); // Pink/Magenta
  static const Color gradientMiddle = Color(0xFFFF5722); // Red-orange
  static const Color gradientEnd = Color(0xFFFF9800); // Orange

  // Legacy colors for backward compatibility
  static const Color primaryColor = lightPrimaryColor;
  static const Color backgroundColor = darkBackgroundColor;
  static const Color secondaryColor = lightSecondaryColor;
  static const Color accentColor = lightAccentColor;
}