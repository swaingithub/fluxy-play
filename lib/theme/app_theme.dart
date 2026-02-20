import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette - Modern, vibrant gradients
  static const _primaryGradient = [Color(0xFF6366F1), Color(0xFF8B5CF6)];
  static const _accentGradient = [Color(0xFFEC4899), Color(0xFFF43F5E)];
  
  // Dark Theme Colors
  static const _darkBg = Color(0xFF0F0F1A);
  static const _darkSurface = Color(0xFF1A1A2E);
  static const _darkCard = Color(0xFF252541);
  
  // Light Theme Colors
  static const _lightBg = Color(0xFFF8FAFC);
  static const _lightSurface = Color(0xFFFFFFFF);
  static const _lightCard = Color(0xFFF1F5F9);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _darkBg,
      colorScheme: ColorScheme.dark(
        primary: _primaryGradient[0],
        secondary: _accentGradient[0],
        surface: _darkSurface,
        error: _accentGradient[1],
      ),
      cardTheme: CardThemeData(
        color: _darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      textTheme: _buildTextTheme(true),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryGradient[0],
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: _lightBg,
      colorScheme: ColorScheme.light(
        primary: _primaryGradient[0],
        secondary: _accentGradient[0],
        surface: _lightSurface,
        error: _accentGradient[1],
      ),
      cardTheme: CardThemeData(
        color: _lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      textTheme: _buildTextTheme(false),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryGradient[0],
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme(bool isDark) {
    final baseColor = isDark ? Colors.white : Colors.black87;
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.bold,
        color: baseColor,
        letterSpacing: -0.25,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.bold,
        color: baseColor,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: baseColor,
      ),
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: baseColor.withValues(alpha: 0.87),
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: baseColor.withValues(alpha: 0.87),
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: baseColor.withValues(alpha: 0.6),
      ),
    );
  }

  // Gradient helpers
  static LinearGradient get primaryGradient => const LinearGradient(
        colors: _primaryGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get accentGradient => const LinearGradient(
        colors: _accentGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // Crisp Surface effect (Replaces blurry glass)
  static BoxDecoration glassEffect({bool isDark = true}) {
    return BoxDecoration(
      color: isDark
          ? const Color(0xFF1E1E2E).withValues(alpha: 0.9)
          : Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.05),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
