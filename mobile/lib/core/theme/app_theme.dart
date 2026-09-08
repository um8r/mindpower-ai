import 'package:flutter/material.dart';

class AppTheme {
  // Theme Colors
  static const Color primaryTeal = Color(0xFF00897B);
  static const Color primaryDarkTeal = Color(0xFF004D40);
  
  // Dynamic Helpers for Light & Dark mode support across all screens
  static Color getDeepSlate(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? const Color(0xFFE2E8F0) 
        : const Color(0xFF263238);
  }

  static Color getTextMuted(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? const Color(0xFF94A3B8) 
        : const Color(0xFF78909C);
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryTeal,
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      cardColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF263238),
        elevation: 0.5,
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryTeal,
        primary: primaryTeal,
        secondary: primaryDarkTeal,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryTeal,
      scaffoldBackgroundColor: const Color(0xFF0F172A), // Dark Background for all screens
      cardColor: const Color(0xFF1E293B), // Dark Card Color
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0.5,
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryTeal,
        primary: primaryTeal,
        secondary: primaryDarkTeal,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );
  }
}