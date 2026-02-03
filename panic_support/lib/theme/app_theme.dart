import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData day() {
    const primary = Color(0xFF3D6B6D);
    const surface = Color(0xFFFFFBF5);
    const onSurface = Color(0xFF2B2018);

    final colorScheme = const ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,
      secondary: Color(0xFFB5844B),
      onSecondary: Colors.white,
      surface: surface,
      onSurface: onSurface,
    );

    return _baseTheme(colorScheme, onSurface);
  }

  static ThemeData night() {
    const primary = Color(0xFF8EC5C9);
    const surface = Color(0xFF1B2334);
    const onSurface = Color(0xFFF2F4F8);

    final colorScheme = const ColorScheme.dark(
      primary: primary,
      onPrimary: Color(0xFF0B0C10),
      secondary: Color(0xFFB6E2B8),
      onSecondary: Color(0xFF0B0C10),
      surface: surface,
      onSurface: onSurface,
    );

    return _baseTheme(colorScheme, onSurface);
  }

  static ThemeData _baseTheme(ColorScheme colorScheme, Color onSurface) {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Geneva',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
          color: onSurface,
        ),
        headlineMedium: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          height: 1.5,
          color: onSurface,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          height: 1.5,
          color: onSurface,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: onSurface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size.fromHeight(64),
          textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary, width: 1.4),
          minimumSize: const Size.fromHeight(52),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
