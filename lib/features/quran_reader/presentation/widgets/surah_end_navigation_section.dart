import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/extensions/int_extension.dart';
import '../../../../common/extensions/surah_name_extension.dart';
import '../../../../core/theme/app_typography.dart';
import '../../application/controllers/quran_display_settings_controller.dart';
import '../../domain/entities/ayah_theme_entity.dart';
import 'quran_ornamental_divider.dart';

/// A minimalist, elegant end-of-surah section with clean typography,
/// delicate circular chevron indicators, and intuitive Next/Previous Surah navigation.
/// Colors strictly follow the active Surah skin (activeTheme):
/// - Light skins (Ivory, White, Sepia, Emerald) -> Crisp black/dark typography and icons.
/// - Dark skins (Midnight Slate, OLED Black) -> Crisp white/light typography and icons.
class SurahEndNavigationSection extends ConsumerWidget {
  final int surahId;
  final String surahName;
  final int totalAyahs;
  final VoidCallback? onNextSurah;
  final VoidCallback? onPreviousSurah;

  const SurahEndNavigationSection({
    super.key,
    required this.surahId,
    required this.surahName,
    required this.totalAyahs,
    this.onNextSurah,
    this.onPreviousSurah,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Read the active Surah skin (e.g. classic_ivory, pure_white, midnight_slate, oled_black)
    final ayahThemeId = ref.watch(
      quranDisplaySettingsControllerProvider.select((s) => s.ayahThemeId),
    );
    final activeTheme = AyahThemePresets.getById(ayahThemeId);

    // Dark state strictly depends on the Surah skin background:
    // When the skin is light, text MUST be black/dark regardless of system dark mode.
    // When the skin is dark (شب / دودی), text MUST be white/light.
    final isDark = activeTheme.isDark;

    final cleanSurahName = surahName.replaceAll('سوره ', '').trim();
    final hasNext = surahId < 114;
    final hasPrevious = surahId > 1;

    final nextSurahName = hasNext ? (surahId + 1).surahNameFa : 'آخرین سوره';
    final prevSurahName = hasPrevious ? (surahId - 1).surahNameFa : 'اولین سوره';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── 1. Top Decorative Divider (Harmonized with skin) ──
          QuranOrnamentalDivider(
            color: activeTheme.dividerColor,
            height: 18.0,
          ),
          const SizedBox(height: 20),

          // ── 2. Clean Typography Title ──
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'پایان سوره مبارکه $cleanSurahName',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.95)
                      : const Color(0xFF1E1E22),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${totalAyahs.toPersianDigit()} آیه • سوره ${surahId.toPersianDigit()} قرآن کریم',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.65)
                      : const Color(0xFF666666),
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── 3. Navigation Buttons Row (Always shows both, symmetrically centered) ──
          Row(
            textDirection: TextDirection.rtl,
            children: [
              // Right side: Previous Surah (with icon on the RIGHT)
              Expanded(
                child: Center(
                  child: _buildPreviousButton(
                    context: context,
                    surahNameSubtitle: prevSurahName,
                    isEnabled: hasPrevious,
                    isDark: isDark,
                    onPressed: hasPrevious
                        ? () {
                            HapticFeedback.lightImpact();
                            onPreviousSurah?.call();
                          }
                        : null,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Left side: Next Surah (with icon on the LEFT)
              Expanded(
                child: Center(
                  child: _buildNextButton(
                    context: context,
                    surahNameSubtitle: nextSurahName,
                    isEnabled: hasNext,
                    isDark: isDark,
                    onPressed: hasNext
                        ? () {
                            HapticFeedback.lightImpact();
                            onNextSurah?.call();
                          }
                        : null,
                  ),
                ),
              ),
            ],
          ),

          if (surahId == 114) ...[
            const SizedBox(height: 16),
            _buildQuranCompletionText(context, activeTheme, isDark),
          ],

          // ── 4. Bottom Spacing ──
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Next Surah Button: Direction arrow is on the LEFT (سمت چپ)
  Widget _buildNextButton({
    required BuildContext context,
    required String surahNameSubtitle,
    required bool isDark,
    required bool isEnabled,
    required VoidCallback? onPressed,
  }) {
    final titleColor = isEnabled
        ? (isDark
            ? Colors.white.withValues(alpha: 0.65)
            : const Color(0xFF666666))
        : (isDark
            ? Colors.white24
            : const Color(0xFFB0B0B0));

    final nameColor = isEnabled
        ? (isDark
            ? Colors.white
            : const Color(0xFF1E1E22))
        : (isDark
            ? Colors.white30
            : const Color(0xFF999999));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onPressed : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            textDirection: TextDirection.rtl,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Text section: center-aligned
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'سوره بعد',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 11,
                      color: titleColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    isEnabled ? 'سوره $surahNameSubtitle' : surahNameSubtitle,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: nameColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 8),

              // Direction icon on the LEFT inside a delicate neutral circle
              _buildDelicateCircleIcon(
                icon: CupertinoIcons.chevron_left,
                isEnabled: isEnabled,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Previous Surah Button: Direction arrow is on the RIGHT (سمت راست)
  Widget _buildPreviousButton({
    required BuildContext context,
    required String surahNameSubtitle,
    required bool isDark,
    required bool isEnabled,
    required VoidCallback? onPressed,
  }) {
    final titleColor = isEnabled
        ? (isDark
            ? Colors.white.withValues(alpha: 0.65)
            : const Color(0xFF666666))
        : (isDark
            ? Colors.white24
            : const Color(0xFFB0B0B0));

    final nameColor = isEnabled
        ? (isDark
            ? Colors.white
            : const Color(0xFF1E1E22))
        : (isDark
            ? Colors.white30
            : const Color(0xFF999999));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onPressed : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            textDirection: TextDirection.rtl,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Direction icon on the RIGHT inside a delicate neutral circle
              _buildDelicateCircleIcon(
                icon: CupertinoIcons.chevron_right,
                isEnabled: isEnabled,
                isDark: isDark,
              ),

              const SizedBox(width: 8),

              // Text section: center-aligned
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'سوره قبل',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 11,
                      color: titleColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    isEnabled ? 'سوره $surahNameSubtitle' : surahNameSubtitle,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: nameColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Subtle, delicate circular outline around the direction icon (دایره ظریف بی‌رنگ)
  Widget _buildDelicateCircleIcon({
    required IconData icon,
    required bool isDark,
    bool isEnabled = true,
  }) {
    final borderColor = isEnabled
        ? (isDark
            ? Colors.white.withValues(alpha: 0.22)
            : Colors.black.withValues(alpha: 0.16))
        : (isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.06));

    final iconColor = isEnabled
        ? (isDark
            ? Colors.white.withValues(alpha: 0.95)
            : const Color(0xFF1E1E22))
        : (isDark
            ? Colors.white.withValues(alpha: 0.25)
            : const Color(0xFFAAAAAA));

    final circleBg = isEnabled
        ? (isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.03))
        : Colors.transparent;

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 1.0),
        color: circleBg,
      ),
      child: Center(
        child: Icon(
          icon,
          size: 15,
          color: iconColor,
        ),
      ),
    );
  }

  Widget _buildQuranCompletionText(
    BuildContext context,
    AyahThemeEntity activeTheme,
    bool isDark,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'صَدَقَ اللَّهُ الْعَلِیُّ الْعَظِیمُ',
          style: TextStyle(
            fontFamily: AppTypography.amiriQuranFont,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: activeTheme.headerTextColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'ختم کلام‌الله مجید مبارک باد • التماس دعا',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 12,
            color: isDark
                ? Colors.white.withValues(alpha: 0.75)
                : const Color(0xFF555555),
          ),
        ),
      ],
    );
  }
}
