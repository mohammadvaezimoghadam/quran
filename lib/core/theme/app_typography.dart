import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Sacred Serenity Typography System
class AppTypography {
  static const String fontFamily = 'Vazirmatn';
  static const String vazirmatnFont = 'Vazirmatn';
  static const String uthmanicFont = 'Uthmanic';
  static const String neyriziFont = 'Neyrizi';
  static const String thuluthFont = 'Thuluth';
  static const String amiriQuranFont = 'AmiriQuran';
  static const String scheherazadeNewFont = 'ScheherazadeNew';

  /// Returns the corresponding Flutter font family name based on user script selection.
  static String getFontFamilyByScript(String fontScript) {
    switch (fontScript) {
      case 'امیری':
      case 'Amiri':
        return amiriQuranFont;
      case 'شهرزاد':
      case 'Scheherazade':
        return scheherazadeNewFont;
      case 'عثمان طه':
        return uthmanicFont;
      case 'نیریزی':
        return neyriziFont;
      case 'ترتیل':
      default:
        return vazirmatnFont;
    }
  }

  /// Main App Bar Title Style (Thuluth Calligraphy in Gold Accent)
  static const TextStyle appBarTitle = TextStyle(
    fontFamily: thuluthFont,
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: AppColors.goldAccent,
  );

  /// Splash Screen Main Title Style (Thuluth Calligraphy in Gold Accent)
  static const TextStyle splashAppTitle = TextStyle(
    fontFamily: thuluthFont,
    fontSize: 54,
    fontWeight: FontWeight.bold,
    color: AppColors.goldAccent,
    height: 1.4,
    shadows: [
      Shadow(
        color: Color(0x59C5A059), // AppColors.goldAccent ~35% opacity
        blurRadius: 20,
        offset: Offset(0, 4),
      ),
    ],
  );

  /// Quranic Arabic Text Style (Full Display)
  static const TextStyle displayQuran = TextStyle(
    fontFamily: fontFamily,
    fontSize: 26,
    fontWeight: FontWeight.normal,
    height: 1.8,
    color: AppColors.onSurface,
  );

  /// Quranic Arabic Text Style for Quran Reader Screen
  static const TextStyle displayQuranReader = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.normal,
    height: 2.0,
    color: AppColors.onSurface,
  );

  /// Quranic Arabic Text Style (Compact Card Version)
  static const TextStyle displayQuranCompact = TextStyle(
    fontFamily: neyriziFont,
    fontSize: 20,
    fontWeight: FontWeight.normal,
    height: 1.6,
    color: Color(0xE6FED65B), // secondaryContainer at ~90% opacity
  );

  /// Surah Titles and Main Page Headers
  static const TextStyle surahTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    height: 1.4,
    color: AppColors.onSurface,
  );

  /// Katibah Header Title Style
  static const TextStyle katibahTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 21,
    fontWeight: FontWeight.bold,
    height: 1.3,
    color: Color(0xFFF4E0A5),
  );

  /// Section Header Title
  static const TextStyle sectionHeader = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.onSurface,
  );

  /// Card Section Header Title (Compact)
  static const TextStyle cardHeader = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Color(0xCCFFFFFF), // white at ~80% opacity
  );

  /// Persian Translation Body Text
  static const TextStyle translationText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.6,
    color: AppColors.onSurfaceVariant,
  );

  /// Persian Translation Compact (Card Version)
  static const TextStyle translationTextSm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
    color: AppColors.surface,
  );

  /// Ayah Number & Small Metadata Labels
  static const TextStyle badgeLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.secondary,
  );

  /// Ayah Number & Small Metadata Labels (Compact)
  static const TextStyle badgeLabelSm = TextStyle(
    fontFamily: neyriziFont,
    fontSize: 13.5,
    fontWeight: FontWeight.normal,
    color: AppColors.secondaryContainer,
  );

  /// Subtitle & Caption Text
  static const TextStyle captionText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: AppColors.outline,
  );

  /// Subtitle & Caption Text (Compact)
  static const TextStyle captionTextSm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.normal,
    color: AppColors.surface,
  );

  /// Action & Toggle Button Label
  static const TextStyle actionButtonLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.bold,
    color: AppColors.secondaryContainer,
  );

  /// Standard Button Label
  static const TextStyle buttonLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  /// Quick Access Grid Card Title
  static const TextStyle quickAccessItemTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppColors.onSurface,
  );

  /// Loading & Status Message Text
  static const TextStyle statusMessage = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: AppColors.surface,
  );

  /// Search Input Text Style
  static const TextStyle searchInput = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  /// Search Hint Text Style
  static const TextStyle searchHint = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: Color(0x99FFFFFF), // white 60% opacity
  );
}
