import 'package:flutter/material.dart';

class PanicTheme {
  static ThemeData build() {
    const background = Color(0xFF0B0C10);
    const surface = Color(0xFF161922);
    const accent = Color(0xFF8ED1D4);
    const onBackground = Color(0xFFF5F5F0);

    final colorScheme = const ColorScheme.dark(
      primary: accent,
      secondary: Color(0xFFB6E2B8),
      surface: surface,
      onSurface: onBackground,
      onPrimary: Color(0xFF0B0C10),
      onSecondary: Color(0xFF0B0C10),
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Geneva',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: onBackground,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: onBackground,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: onBackground,
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          height: 1.4,
          color: onBackground,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          height: 1.4,
          color: onBackground,
        ),
      ),
    );
  }
}
