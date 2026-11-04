import 'package:flutter/material.dart';
import 'package:relay_mobile/config/app_config.dart';

/// App theme definitions supporting System Theme, Dynamic Environment Seeds,
/// Light Mode, and Dark Mode.
abstract final class AppTheme {
  static ThemeData light(AppEnvironment env) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: env.primaryColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      colorScheme: colorScheme,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      useMaterial3: true,
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: env.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: env.primaryColor.withValues(alpha: 0.18),
        elevation: 1,
      ),
    );
  }

  static ThemeData dark(AppEnvironment env) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: env.primaryColor,
      brightness: Brightness.dark,
      surface: const Color(0xFF131B2E),
    );

    return ThemeData(
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0B0F19),
      useMaterial3: true,
      cardTheme: CardThemeData(
        color: const Color(0xFF131B2E),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF23304F)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0B0F19),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF0F1626),
        indicatorColor: env.primaryColor.withValues(alpha: 0.25),
        elevation: 0,
      ),
    );
  }
}
