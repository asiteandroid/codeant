import 'package:flutter/material.dart';

/// Centralised app theme configuration.
///
/// Using a Material 3 seed-color scheme gives us automatic
/// light/dark support and consistent color tokens.
class AppTheme {
  AppTheme._(); // Prevent instantiation.

  static const _seedColor = Colors.indigo;

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: _seedColor),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(),
        ),
      );
}

