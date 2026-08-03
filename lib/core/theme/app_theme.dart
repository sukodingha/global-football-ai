import 'package:flutter/material.dart';

/// Centralized application theme using Material 3.
class AppTheme {
  AppTheme._();

  static const Color _primary = Color(0xFF1B5E20);
  static const Color _primaryDark = Color(0xFF6FCF97);
  static const Color _secondary = Color(0xFF4CAF50);
  static const Color _background = Color(0xFFF6F8F7);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _backgroundDark = Color(0xFF121212);
  static const Color _surfaceDark = Color(0xFF1E1E1E);

  /// Light theme.
  static ThemeData get lightTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: _primary,
      primary: _primary,
      secondary: _secondary,
      surface: _surface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: _background,
      appBarTheme: const AppBarTheme(
        backgroundColor: _surface,
        foregroundColor: _primary,
        elevation: 0,
        centerTitle: true,
      ),
      inputDecorationTheme: _inputDecoration(surface: _surface),
      elevatedButtonTheme: _elevatedButtonTheme(primary: _primary),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: _primary),
      ),
      cardTheme: CardThemeData(
        color: _surface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      textTheme: _textTheme(dark: false),
    );
  }

  /// Dark theme.
  static ThemeData get darkTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: _primaryDark,
      brightness: Brightness.dark,
      primary: _primaryDark,
      secondary: _secondary,
      surface: _surfaceDark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: _backgroundDark,
      appBarTheme: AppBarTheme(
        backgroundColor: _surfaceDark,
        foregroundColor: _primaryDark,
        elevation: 0,
        centerTitle: true,
      ),
      inputDecorationTheme: _inputDecoration(surface: _surfaceDark),
      elevatedButtonTheme: _elevatedButtonTheme(primary: _primaryDark),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: _primaryDark),
      ),
      cardTheme: CardThemeData(
        color: _surfaceDark,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      textTheme: _textTheme(dark: true),
    );
  }

  static InputDecorationTheme _inputDecoration({required Color surface}) {
    return InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme({required Color primary}) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  static TextTheme _textTheme({required bool dark}) {
    final color = dark ? Colors.white : const Color(0xFF1A1A1A);
    final sub = dark ? const Color(0xFFB0B0B0) : const Color(0xFF555555);
    return TextTheme(
      headlineSmall: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      bodyMedium: TextStyle(fontSize: 14, color: sub),
    );
  }
}
