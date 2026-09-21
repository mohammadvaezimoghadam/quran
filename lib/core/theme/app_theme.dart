import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_typography.dart';
import 'quran_theme_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFFFFFF),
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Color(0xFFFFFFFF),
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
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
      fontFamily: AppTypography.fontFamily,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontFamily: AppTypography.fontFamily, color: AppColors.onSurface, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(fontFamily: AppTypography.fontFamily, color: AppColors.onSurface, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(fontFamily: AppTypography.fontFamily, color: AppColors.onSurface, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontFamily: AppTypography.fontFamily, color: AppColors.onSurface, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontFamily: AppTypography.fontFamily, color: AppColors.onSurface, fontSize: 18, height: 1.6),
        bodyMedium: TextStyle(fontFamily: AppTypography.fontFamily, color: AppColors.onSurface, fontSize: 16, height: 1.5),
        bodySmall: TextStyle(fontFamily: AppTypography.fontFamily, color: AppColors.onSurfaceVariant, fontSize: 14),
        labelLarge: TextStyle(fontFamily: AppTypography.fontFamily, color: AppColors.onSurface, fontSize: 14, fontWeight: FontWeight.w600),
        labelMedium: TextStyle(fontFamily: AppTypography.fontFamily, color: AppColors.onSurfaceVariant, fontSize: 12),
        labelSmall: TextStyle(fontFamily: AppTypography.fontFamily, color: AppColors.onSurfaceVariant, fontSize: 11),
      ),
      extensions: const [
        QuranThemeColors.light,
      ],
      snackBarTheme: const SnackBarThemeData(
        contentTextStyle: TextStyle(
          color: Colors.white,
          fontFamily: AppTypography.fontFamily,
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData get darkTheme {
    const darkSurface = Color(0xFF1C1C1E);
    const darkOnSurface = Color(0xFFFFFFFF);
    const darkOnSurfaceVariant = Color(0xFF8E8E93);

    return ThemeData(
      brightness: Brightness.dark,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: darkSurface,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
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
        tertiary: Color(0xFF64D2FF),
        onTertiary: Color(0xFF003544),
        tertiaryContainer: Color(0xFF004D63),
        onTertiaryContainer: Color(0xFFBEE9FF),
        error: Color(0xFFFF453A),
        onError: Color(0xFF690005),
        errorContainer: Color(0xFF93000A),
        onErrorContainer: Color(0xFFFFDAD6),
        surface: darkSurface,
        onSurface: darkOnSurface,
        onSurfaceVariant: darkOnSurfaceVariant,
        outline: Color(0xFF48484A),
        outlineVariant: Color(0xFF2C2C2E),
      ),
      scaffoldBackgroundColor: const Color(0xFF000000),
      useMaterial3: true,
      fontFamily: AppTypography.fontFamily,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontFamily: AppTypography.fontFamily, color: darkOnSurface, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(fontFamily: AppTypography.fontFamily, color: darkOnSurface, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(fontFamily: AppTypography.fontFamily, color: darkOnSurface, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontFamily: AppTypography.fontFamily, color: darkOnSurface, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontFamily: AppTypography.fontFamily, color: darkOnSurface, fontSize: 18, height: 1.6),
        bodyMedium: TextStyle(fontFamily: AppTypography.fontFamily, color: darkOnSurface, fontSize: 16, height: 1.5),
        bodySmall: TextStyle(fontFamily: AppTypography.fontFamily, color: darkOnSurfaceVariant, fontSize: 14),
        labelLarge: TextStyle(fontFamily: AppTypography.fontFamily, color: darkOnSurface, fontSize: 14, fontWeight: FontWeight.w600),
        labelMedium: TextStyle(fontFamily: AppTypography.fontFamily, color: darkOnSurfaceVariant, fontSize: 12),
        labelSmall: TextStyle(fontFamily: AppTypography.fontFamily, color: darkOnSurfaceVariant, fontSize: 11),
      ),
      extensions: const [
        QuranThemeColors.dark,
      ],
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: darkOnSurfaceVariant, fontFamily: AppTypography.fontFamily),
        labelStyle: TextStyle(color: darkOnSurface, fontFamily: AppTypography.fontFamily),
        prefixIconColor: darkOnSurfaceVariant,
        suffixIconColor: darkOnSurfaceVariant,
      ),
      snackBarTheme: const SnackBarThemeData(
        contentTextStyle: TextStyle(
          color: Colors.white,
          fontFamily: AppTypography.fontFamily,
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
