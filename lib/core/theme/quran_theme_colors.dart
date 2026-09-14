import 'package:flutter/material.dart';

/// Semantic colors extension for Quran app, supporting dynamic light and dark modes.
/// Provides access to specialized theme tokens like gold accents, card surfaces,
/// medallion colors, tashkeel highlights, and chip styles.
class QuranThemeColors extends ThemeExtension<QuranThemeColors> {
  final Color goldAccent;
  final Color goldMetallic;
  final Color goldDarkBorder;
  final Color softGoldText;
  final Color cardBackground;
  final Color cardBorder;
  final Color cardBackgroundSubtle;
  final Color medallionBackground;
  final Color medallionBorder;
  final Color medallionText;
  final Color tashkeelDefault;
  final Color accentIconColor;
  final Color dialogSurface;
  final Color chipBackground;
  final Color chipText;
  final Color quickActionButtonText;

  const QuranThemeColors({
    required this.goldAccent,
    required this.goldMetallic,
    required this.goldDarkBorder,
    required this.softGoldText,
    required this.cardBackground,
    required this.cardBorder,
    required this.cardBackgroundSubtle,
    required this.medallionBackground,
    required this.medallionBorder,
    required this.medallionText,
    required this.tashkeelDefault,
    required this.accentIconColor,
    required this.dialogSurface,
    required this.chipBackground,
    required this.chipText,
    required this.quickActionButtonText,
  });

  /// Standard Light Theme values
  static const QuranThemeColors light = QuranThemeColors(
    goldAccent: Color(0xFFC5A059),
    goldMetallic: Color(0xFFD4AF37),
    goldDarkBorder: Color(0xFFB38F29),
    softGoldText: Color(0xFF8C6D1F),
    cardBackground: Color(0xFFFFFFFF),
    cardBorder: Color(0xFFEDE9E3),
    cardBackgroundSubtle: Color(0xFFF9F7F4),
    medallionBackground: Color(0xFFF4F1ED),
    medallionBorder: Color(0xFFE2DDD5),
    medallionText: Color(0xFF1C1B1B),
    tashkeelDefault: Color(0xFF005C55),
    accentIconColor: Color(0xFF005C55),
    dialogSurface: Color(0xFFFFFFFF),
    chipBackground: Color(0xFFF4F1ED),
    chipText: Color(0xFF1C1B1B),
    quickActionButtonText: Color(0xFF000000),
  );

  /// Standard Dark Theme values (Apple iOS 18 Neutral Dark System)
  static const QuranThemeColors dark = QuranThemeColors(
    goldAccent: Color(0xFFE2B855),
    goldMetallic: Color(0xFFF1CF7A),
    goldDarkBorder: Color(0xFF5C4718),
    softGoldText: Color(0xFFF3DCA2),
    cardBackground: Color(0xFF1C1C1E),
    cardBorder: Color(0xFF2C2C2E),
    cardBackgroundSubtle: Color(0xFF2C2C2E),
    medallionBackground: Color(0xFF2C2C2E),
    medallionBorder: Colors.transparent,
    medallionText: Color(0xFFFFFFFF),
    tashkeelDefault: Color(0xFF52C498),
    accentIconColor: Color(0xFF52C498),
    dialogSurface: Color(0xFF1C1C1E),
    chipBackground: Color(0xFF2C2C2E),
    chipText: Color(0xFFFFFFFF),
    quickActionButtonText: Color(0xFFFFFFFF),
  );

  @override
  QuranThemeColors copyWith({
    Color? goldAccent,
    Color? goldMetallic,
    Color? goldDarkBorder,
    Color? softGoldText,
    Color? cardBackground,
    Color? cardBorder,
    Color? cardBackgroundSubtle,
    Color? medallionBackground,
    Color? medallionBorder,
    Color? medallionText,
    Color? tashkeelDefault,
    Color? accentIconColor,
    Color? dialogSurface,
    Color? chipBackground,
    Color? chipText,
    Color? quickActionButtonText,
  }) {
    return QuranThemeColors(
      goldAccent: goldAccent ?? this.goldAccent,
      goldMetallic: goldMetallic ?? this.goldMetallic,
      goldDarkBorder: goldDarkBorder ?? this.goldDarkBorder,
      softGoldText: softGoldText ?? this.softGoldText,
      cardBackground: cardBackground ?? this.cardBackground,
      cardBorder: cardBorder ?? this.cardBorder,
      cardBackgroundSubtle: cardBackgroundSubtle ?? this.cardBackgroundSubtle,
      medallionBackground: medallionBackground ?? this.medallionBackground,
      medallionBorder: medallionBorder ?? this.medallionBorder,
      medallionText: medallionText ?? this.medallionText,
      tashkeelDefault: tashkeelDefault ?? this.tashkeelDefault,
      accentIconColor: accentIconColor ?? this.accentIconColor,
      dialogSurface: dialogSurface ?? this.dialogSurface,
      chipBackground: chipBackground ?? this.chipBackground,
      chipText: chipText ?? this.chipText,
      quickActionButtonText: quickActionButtonText ?? this.quickActionButtonText,
    );
  }

  @override
  QuranThemeColors lerp(ThemeExtension<QuranThemeColors>? other, double t) {
    if (other is! QuranThemeColors) return this;
    return QuranThemeColors(
      goldAccent: Color.lerp(goldAccent, other.goldAccent, t) ?? goldAccent,
      goldMetallic: Color.lerp(goldMetallic, other.goldMetallic, t) ?? goldMetallic,
      goldDarkBorder: Color.lerp(goldDarkBorder, other.goldDarkBorder, t) ?? goldDarkBorder,
      softGoldText: Color.lerp(softGoldText, other.softGoldText, t) ?? softGoldText,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t) ?? cardBackground,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t) ?? cardBorder,
      cardBackgroundSubtle: Color.lerp(cardBackgroundSubtle, other.cardBackgroundSubtle, t) ?? cardBackgroundSubtle,
      medallionBackground: Color.lerp(medallionBackground, other.medallionBackground, t) ?? medallionBackground,
      medallionBorder: Color.lerp(medallionBorder, other.medallionBorder, t) ?? medallionBorder,
      medallionText: Color.lerp(medallionText, other.medallionText, t) ?? medallionText,
      tashkeelDefault: Color.lerp(tashkeelDefault, other.tashkeelDefault, t) ?? tashkeelDefault,
      accentIconColor: Color.lerp(accentIconColor, other.accentIconColor, t) ?? accentIconColor,
      dialogSurface: Color.lerp(dialogSurface, other.dialogSurface, t) ?? dialogSurface,
      chipBackground: Color.lerp(chipBackground, other.chipBackground, t) ?? chipBackground,
      chipText: Color.lerp(chipText, other.chipText, t) ?? chipText,
      quickActionButtonText: Color.lerp(quickActionButtonText, other.quickActionButtonText, t) ?? quickActionButtonText,
    );
  }
}
