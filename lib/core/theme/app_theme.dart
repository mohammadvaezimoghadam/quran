import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onSecondary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
      ),
      scaffoldBackgroundColor: AppColors.background,
      useMaterial3: true,
      fontFamily: 'Vazirmatn',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: AppColors.onSurface, fontSize: 18, height: 1.6),
        bodyMedium: TextStyle(color: AppColors.onSurface, fontSize: 16, height: 1.5),
        bodySmall: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
        labelMedium: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
      ),
    );
  }

  static ThemeData get darkTheme {
    const darkSurface = Color(0xFF1E2124);
    const darkOnSurface = Color(0xFFE6E1E5);
    const darkOnSurfaceVariant = Color(0xFFC4C7C5);

    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: Color(0xFF52C498),
        onPrimary: Color(0xFF003825),
        primaryContainer: Color(0xFF1A3B30),
        onPrimaryContainer: Color(0xFF85F5C6),
        secondary: Color(0xFF8CD8BD),
        onSecondary: Color(0xFF003829),
        secondaryContainer: Color(0xFF00513D),
        onSecondaryContainer: Color(0xFFA8F5D8),
        tertiary: Color(0xFFA6CCDF),
        onTertiary: Color(0xFF083544),
        tertiaryContainer: Color(0xFF254B5B),
        onTertiaryContainer: Color(0xFFC2E8FD),
        error: Color(0xFFFFB4AB),
        onError: Color(0xFF690005),
        errorContainer: Color(0xFF93000A),
        onErrorContainer: Color(0xFFFFDAD6),
        surface: darkSurface,
        onSurface: darkOnSurface,
        onSurfaceVariant: darkOnSurfaceVariant,
        outline: Color(0xFF8C938E),
        outlineVariant: Color(0xFF323835),
      ),
      scaffoldBackgroundColor: const Color(0xFF121416),
      useMaterial3: true,
      fontFamily: 'Vazirmatn',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: darkOnSurface, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: darkOnSurface, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: darkOnSurface, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: darkOnSurface, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: darkOnSurface, fontSize: 18, height: 1.6),
        bodyMedium: TextStyle(color: darkOnSurface, fontSize: 16, height: 1.5),
        bodySmall: TextStyle(color: darkOnSurfaceVariant, fontSize: 14),
        labelMedium: TextStyle(color: darkOnSurfaceVariant, fontSize: 12),
      ),
    );
  }
}
