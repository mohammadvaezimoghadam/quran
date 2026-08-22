import 'package:flutter/material.dart';

import '../extensions/size_extension.dart';
import '../../core/theme/app_dimens.dart';

/// Persian Mosque Tilework & Turquoise Traditional Header Widget.
/// Draws visual inspiration from Persian Mosque Architecture (Isfahan Tilework, Turquoise & Cobalt Lazuli).
class AppHeaderCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? arabicTitle;
  final int? surahNumber;
  final String? revelationType; // 'Meccan' or 'Medinan' or 'مکی' or 'مدنی'
  final int? ayahCount;
  final int? juzNumber;
  final bool showBismillah;
  final List<Widget>? actions;

  const AppHeaderCard({
    super.key,
    required this.title,
    this.subtitle,
    this.arabicTitle,
    this.surahNumber,
    this.revelationType,
    this.ayahCount,
    this.juzNumber,
    this.showBismillah = false,
    this.actions,
  });

  /// Factory constructor specifically for Quran Surah Reader Header
  factory AppHeaderCard.surah({
    required int surahNumber,
    required String surahName,
    required String englishNameTranslation,
    required int ayahCount,
    required String revelationType,
    int? juzNumber,
  }) {
    return AppHeaderCard(
      title: surahName,
      subtitle: englishNameTranslation,
      surahNumber: surahNumber,
      revelationType: revelationType,
      ayahCount: ayahCount,
      juzNumber: juzNumber,
      showBismillah: surahNumber != 1 && surahNumber != 9,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Persian Mosque Palette (Cobalt Lapis Lazuli & Turquoise Gold)
    final bgGradient = isDark
        ? const LinearGradient(
            colors: [
              Color(0xFF0D1B2A), // Deep Lapis Lazuli
              Color(0xFF1B263B), // Royal Cobalt
              Color(0xFF0F3443), // Turquoise Shadow
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [
              Color(0xFF0F2027), // Persian Dark Azure
              Color(0xFF203A43), // Lapis Tile
              Color(0xFF1B4965), // Turquoise Deep
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    const turquoiseAccent = Color(0xFF2EC4B6); // فیروزه‌ای اصیل
    const brightTurquoise = Color(0xFF62B6CB); // فیروزه‌ای روشن
    const softGold = Color(0xFFF4D06F); // طلایی کاشی‌کاری
    const borderGold = Color(0xFFE0A96D);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimens.marginPage,
        vertical: AppDimens.stackSm,
      ),
      decoration: BoxDecoration(
        gradient: bgGradient,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(
          color: turquoiseAccent.withValues(alpha: 0.6),
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: turquoiseAccent.withValues(alpha: 0.12),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Inner Mosaic Tile Border Line Effect (حاشیه کاشی‌کاری معرق)
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimens.radiusLg - 4),
                border: Border.all(
                  color: borderGold.withValues(alpha: 0.35),
                  width: 1.0,
                ),
              ),
            ),
          ),

          // Mosque Mihrab / Dome Background Ornament (شامسه فیروزه‌ای)
          Positioned(
            top: -20,
            right: -20,
            child: Icon(
              Icons.mosque_rounded,
              color: turquoiseAccent.withValues(alpha: 0.08),
              size: 140,
            ),
          ),
          Positioned(
            bottom: -30,
            left: -20,
            child: Icon(
              Icons.auto_awesome_mosaic_rounded,
              color: borderGold.withValues(alpha: 0.06),
              size: 130,
            ),
          ),

          // Main Header Content
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.stackMd,
              vertical: AppDimens.stackLg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Header Row (Centered Title Header Badge)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title Header Badge ("قرآن کریم")
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: turquoiseAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: turquoiseAccent.withValues(alpha: 0.3),
                          width: 0.8,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 12,
                            color: softGold,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'قرآن کریم',
                            style: TextStyle(
                              color: brightTurquoise,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                AppDimens.stackSm.vSpace,

                // Main Title (Arabic Surah Calligraphy)
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: softGold,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Amiri',
                    height: 1.4,
                    shadows: [
                      Shadow(
                        color: Colors.black45,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),

                // Subtitle / English Title
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  AppDimens.stackXs.vSpace,
                  Text(
                    subtitle!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: brightTurquoise,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],

                // Metadata Badges (Makkah/Madinah, Ayah Count, Juz)
                if (revelationType != null || ayahCount != null || juzNumber != null) ...[
                  AppDimens.stackSmMd.vSpace,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (revelationType != null) ...[
                        _buildBadge(
                          icon: Icons.mosque_outlined,
                          label: _translateType(revelationType!),
                          accentColor: turquoiseAccent,
                        ),
                        AppDimens.stackSm.hSpace,
                      ],
                      if (ayahCount != null) ...[
                        _buildBadge(
                          icon: Icons.format_list_numbered_rtl_rounded,
                          label: '$ayahCount آیه',
                          accentColor: softGold,
                        ),
                        AppDimens.stackSm.hSpace,
                      ],
                      if (juzNumber != null) ...[
                        _buildBadge(
                          icon: Icons.auto_stories_rounded,
                          label: 'جزء $juzNumber',
                          accentColor: brightTurquoise,
                        ),
                      ],
                    ],
                  ),
                ],

                // Traditional Ornamental Tile Divider & Bismillah Calligraphy
                if (showBismillah) ...[
                  AppDimens.stackMd.vSpace,
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: turquoiseAccent.withValues(alpha: 0.4),
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Icon(
                          Icons.all_inclusive_rounded,
                          color: softGold.withValues(alpha: 0.8),
                          size: 16,
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: turquoiseAccent.withValues(alpha: 0.4),
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  AppDimens.stackMd.vSpace,

                  // Calligraphic Bismillah with Glow
                  const Text(
                    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: softGold,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Amiri',
                      height: 1.5,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0B192C).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.4),
          width: 0.9,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: accentColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _translateType(String type) {
    if (type.toLowerCase().contains('meccan') || type.contains('مکی')) {
      return 'مکی';
    }
    if (type.toLowerCase().contains('medinan') || type.contains('مدنی')) {
      return 'مدنی';
    }
    return type;
  }
}
