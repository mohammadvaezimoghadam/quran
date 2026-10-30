import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../common/extensions/int_extension.dart';
import '../../../../common/extensions/surah_name_extension.dart';
import '../../../../core/theme/app_typography.dart';
import 'quran_ornamental_divider.dart';

/// A minimalist, elegant end-of-surah section with clean typography,
/// delicate circular chevron indicators, and intuitive Next/Previous Surah navigation.
/// Always displays both Next and Previous buttons, with appropriate disabled styling
/// at the boundaries (Surah 1 and Surah 114).
class SurahEndNavigationSection extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

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
          // ── 1. Top Decorative Divider ──
          QuranOrnamentalDivider(
            color: colorScheme.primary.withValues(alpha: isDark ? 0.45 : 0.6),
            height: 18.0,
          ),
          const SizedBox(height: 20),

          // ── 2. Clean Typography Title (No box, no checkmark) ──
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'پایان سوره مبارکه $cleanSurahName',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: AppTypography.fontFamily,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white.withValues(alpha: 0.9) : colorScheme.onSurface,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${totalAyahs.toPersianDigit()} آیه • سوره ${surahId.toPersianDigit()} قرآن کریم',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: AppTypography.fontFamily,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.65),
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
                    colorScheme: colorScheme,
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
                    colorScheme: colorScheme,
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
            _buildQuranCompletionText(context, colorScheme, isDark),
          ],

          // ── 4. Bottom Spacing (Replaced divider with SizedBox) ──
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
    required ColorScheme colorScheme,
    required bool isEnabled,
    required VoidCallback? onPressed,
  }) {
    final titleColor = isEnabled
        ? colorScheme.onSurfaceVariant.withValues(alpha: 0.7)
        : (isDark ? Colors.white24 : colorScheme.onSurfaceVariant.withValues(alpha: 0.35));

    final nameColor = isEnabled
        ? (isDark ? Colors.white : colorScheme.onSurface)
        : (isDark ? Colors.white30 : colorScheme.onSurface.withValues(alpha: 0.35));

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
                colorScheme: colorScheme,
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
    required ColorScheme colorScheme,
    required bool isEnabled,
    required VoidCallback? onPressed,
  }) {
    final titleColor = isEnabled
        ? colorScheme.onSurfaceVariant.withValues(alpha: 0.7)
        : (isDark ? Colors.white24 : colorScheme.onSurfaceVariant.withValues(alpha: 0.35));

    final nameColor = isEnabled
        ? (isDark ? Colors.white : colorScheme.onSurface)
        : (isDark ? Colors.white30 : colorScheme.onSurface.withValues(alpha: 0.35));

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
                colorScheme: colorScheme,
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
    required ColorScheme colorScheme,
    bool isEnabled = true,
  }) {
    final borderColor = isEnabled
        ? (isDark
            ? Colors.white.withValues(alpha: 0.16)
            : Colors.black.withValues(alpha: 0.14))
        : (isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.05));

    final iconColor = isEnabled
        ? (isDark
            ? Colors.white.withValues(alpha: 0.85)
            : colorScheme.onSurface.withValues(alpha: 0.85))
        : (isDark
            ? Colors.white.withValues(alpha: 0.22)
            : colorScheme.onSurface.withValues(alpha: 0.22));

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 1.0),
        color: isEnabled
            ? (isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.black.withValues(alpha: 0.02))
            : Colors.transparent,
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
    ColorScheme colorScheme,
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
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'ختم کلام‌الله مجید مبارک باد • التماس دعا',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 12,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
