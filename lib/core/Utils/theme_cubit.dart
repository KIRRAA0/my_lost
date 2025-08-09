import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_colors.dart';

enum AppThemeMode { light, dark }

class ThemeState {
  final AppThemeMode themeMode;

  ThemeState(this.themeMode);
}

class ThemeCubit extends Cubit<ThemeState> {
  static const String themeKey = 'theme_mode';

  ThemeCubit() : super(ThemeState(AppThemeMode.dark));

  Future<void> loadSavedTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(themeKey);
      if (savedTheme != null) {
        final themeMode = savedTheme == 'dark' ? AppThemeMode.dark : AppThemeMode.light;
        emit(ThemeState(themeMode));
      }
    } catch (e) {
      // If there's an error, default to dark theme
      emit(ThemeState(AppThemeMode.dark));
    }
  }

  Future<void> toggleTheme() async {
    final newTheme = state.themeMode == AppThemeMode.light ? AppThemeMode.dark : AppThemeMode.light;
    emit(ThemeState(newTheme));
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(themeKey, newTheme == AppThemeMode.dark ? 'dark' : 'light');
    } catch (e) {
      // Handle error if needed
    }
  }

  Future<void> setTheme(AppThemeMode theme) async {
    emit(ThemeState(theme));
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(themeKey, theme == AppThemeMode.dark ? 'dark' : 'light');
    } catch (e) {
      // Handle error if needed
    }
  }

  static ThemeData lightTheme(double screenHeight) {
    final dynamicFontSize = screenHeight * 0.025;
    final dynamicBorderRadius = screenHeight * 0.03;

    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      primaryColor: AppColors.lightPrimaryColor,
      scaffoldBackgroundColor: AppColors.lightBackgroundColor,
      cardColor: AppColors.lightCardColor,
      dividerColor: AppColors.lightDividerColor,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      colorScheme: const ColorScheme.light(
        primary: AppColors.lightPrimaryColor,
        secondary: AppColors.lightSecondaryColor,
        surface: AppColors.lightSurfaceColor,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.lightTextPrimary,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        toolbarHeight: screenHeight / 7,
        backgroundColor: AppColors.lightPrimaryColor,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: dynamicFontSize,
          fontWeight: FontWeight.bold,
        ),
        shape: OutlineInputBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(dynamicBorderRadius),
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        elevation: 0,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(color: AppColors.lightTextPrimary),
        displayMedium: TextStyle(color: AppColors.lightTextPrimary),
        displaySmall: TextStyle(color: AppColors.lightTextPrimary),
        headlineLarge: TextStyle(color: AppColors.lightTextPrimary),
        headlineMedium: TextStyle(color: AppColors.lightTextPrimary),
        headlineSmall: TextStyle(color: AppColors.lightTextPrimary),
        titleLarge: TextStyle(color: AppColors.lightTextPrimary),
        titleMedium: TextStyle(color: AppColors.lightTextPrimary),
        titleSmall: TextStyle(color: AppColors.lightTextPrimary),
        bodyLarge: TextStyle(color: AppColors.lightTextPrimary),
        bodyMedium: TextStyle(color: AppColors.lightTextPrimary),
        bodySmall: TextStyle(color: AppColors.lightTextSecondary),
        labelLarge: TextStyle(color: AppColors.lightTextPrimary),
        labelMedium: TextStyle(color: AppColors.lightTextSecondary),
        labelSmall: TextStyle(color: AppColors.lightTextSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightPrimaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dynamicBorderRadius * 0.5),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  static ThemeData darkTheme(double screenHeight) {
    final dynamicFontSize = screenHeight * 0.025;
    final dynamicBorderRadius = screenHeight * 0.03;

    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      primaryColor: AppColors.darkPrimaryColor,
      scaffoldBackgroundColor: AppColors.darkBackgroundColor,
      cardColor: AppColors.darkCardColor,
      dividerColor: AppColors.darkDividerColor,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkPrimaryColor,
        secondary: AppColors.darkSecondaryColor,
        surface: AppColors.darkSurfaceColor,
        error: Colors.redAccent,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.darkTextPrimary,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        toolbarHeight: screenHeight / 7,
        backgroundColor: AppColors.darkPrimaryColor,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: dynamicFontSize,
          fontWeight: FontWeight.bold,
        ),
        shape: OutlineInputBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(dynamicBorderRadius),
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        elevation: 0,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(color: AppColors.darkTextPrimary),
        displayMedium: TextStyle(color: AppColors.darkTextPrimary),
        displaySmall: TextStyle(color: AppColors.darkTextPrimary),
        headlineLarge: TextStyle(color: AppColors.darkTextPrimary),
        headlineMedium: TextStyle(color: AppColors.darkTextPrimary),
        headlineSmall: TextStyle(color: AppColors.darkTextPrimary),
        titleLarge: TextStyle(color: AppColors.darkTextPrimary),
        titleMedium: TextStyle(color: AppColors.darkTextPrimary),
        titleSmall: TextStyle(color: AppColors.darkTextPrimary),
        bodyLarge: TextStyle(color: AppColors.darkTextPrimary),
        bodyMedium: TextStyle(color: AppColors.darkTextPrimary),
        bodySmall: TextStyle(color: AppColors.darkTextSecondary),
        labelLarge: TextStyle(color: AppColors.darkTextPrimary),
        labelMedium: TextStyle(color: AppColors.darkTextSecondary),
        labelSmall: TextStyle(color: AppColors.darkTextSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dynamicBorderRadius * 0.5),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
} 