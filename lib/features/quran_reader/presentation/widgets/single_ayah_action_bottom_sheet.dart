import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../common/extensions/ayah_extension.dart';
import '../../../../common/extensions/int_extension.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../common/widgets/app_snackbar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../bookmarks/application/controllers/bookmarks_controller.dart';
import '../../application/controllers/quran_display_settings_controller.dart';
import '../../application/controllers/selected_ayah_action_provider.dart';
import '../../domain/entities/ayah_entity.dart';
import 'word_by_word_bottom_sheet.dart';

/// Luxury bottom sheet displayed when a user long-presses an Ayah.
/// Houses single-ayah quick actions: Copy, Share, Word-by-word Dictionary,
/// and Bookmark Ayah.
class SingleAyahActionBottomSheet extends ConsumerWidget {
  final AyahEntity ayah;
  final String surahName;
  final int totalAyahsInSurah;

  const SingleAyahActionBottomSheet({
    super.key,
    required this.ayah,
    required this.surahName,
    required this.totalAyahsInSurah,
  });

  static Future<void> show(
    BuildContext context, {
    required AyahEntity ayah,
    required String surahName,
    required int totalAyahsInSurah,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SingleAyahActionBottomSheet(
        ayah: ayah,
        surahName: surahName,
        totalAyahsInSurah: totalAyahsInSurah,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final fontScript = ref.watch(
      quranDisplaySettingsControllerProvider.select((s) => s.fontScript),
    );
    final arabicFontFamily = AppTypography.getFontFamilyByScript(fontScript);

    // Check if this specific Ayah is currently bookmarked
    final isBookmarked = ref.watch(
      bookmarksControllerProvider.select(
        (list) => list.any(
          (b) => b.surahId == ayah.surahId && b.ayahNumber == ayah.ayahNumber,
        ),
      ),
    );

    final sheetBg = isDark ? const Color(0xFF161E1B) : const Color(0xFFFAF9F6);
    final cardBg = isDark ? const Color(0xFF1E2825) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFEBE7DF);
    final goldColor = isDark ? const Color(0xFFF4E0A5) : const Color(0xFFB5872A);

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Pull Bar Indicator
              Center(
                child: Container(
                  width: 42,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              14.vSpace,

              // 2. Ayah Info & Context Pill
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.goldAccent.withValues(alpha: 0.12)
                          : const Color(0xFFF4EFE6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? AppColors.goldAccent.withValues(alpha: 0.25)
                            : const Color(0xFFE5DDD0),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'سوره $surahName',
                          style: TextStyle(
                            fontFamily: arabicFontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.goldAccent
                                : AppColors.primary,
                          ),
                        ),
                        6.hSpace,
                        Text(
                          '• آیه ${ayah.ayahNumber.toPersianDigit()}',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.goldAccent
                                : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      CupertinoIcons.xmark_circle_fill,
                      color: isDark ? Colors.white38 : Colors.black26,
                      size: 24,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              14.vSpace,

              // 3. Grid of 4 Standard Ayah Actions
              Row(
                children: [
                  // Action 1: Bookmark Ayah (نشانه‌گذاری آیه)
                  Expanded(
                    child: _buildActionButton(
                      context: context,
                      isDark: isDark,
                      cardBg: cardBg,
                      borderColor: borderColor,
                      icon: isBookmarked
                          ? CupertinoIcons.bookmark_fill
                          : CupertinoIcons.bookmark,
                      iconColor: isBookmarked ? goldColor : (isDark ? Colors.white70 : Colors.black87),
                      label: isBookmarked ? 'نشان‌شده' : 'نشانه‌گذاری',
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        final isAdded = await ref
                            .read(bookmarksControllerProvider.notifier)
                            .toggleBookmark(
                              surahId: ayah.surahId,
                              surahName: surahName,
                              ayahNumber: ayah.ayahNumber,
                              totalAyahs: totalAyahsInSurah,
                              arabicText: ayah.arabicText,
                              isAyahBookmark: true,
                            );

                        if (context.mounted) {
                          Navigator.of(context).pop();
                          if (isAdded) {
                            AppSnackBar.showSuccess(
                              context,
                              'آیه ${ayah.ayahNumber.toPersianDigit()} سوره $surahName نشانه‌گذاری شد.',
                            );
                          } else {
                            AppSnackBar.showInfo(
                              context,
                              'نشانه آیه ${ayah.ayahNumber.toPersianDigit()} حذف شد.',
                            );
                          }
                        }
                      },
                    ),
                  ),
                  10.hSpace,

                  // Action 2: Dictionary / Word by Word (لغت‌نامه)
                  Expanded(
                    child: _buildActionButton(
                      context: context,
                      isDark: isDark,
                      cardBg: cardBg,
                      borderColor: borderColor,
                      icon: CupertinoIcons.book,
                      iconColor: isDark ? Colors.white70 : Colors.black87,
                      label: 'لغت‌نامه',
                      onTap: () {
                        Navigator.of(context).pop();
                        ref.read(selectedAyahActionProvider.notifier).clearSelection();
                        WordByWordBottomSheet.show(
                          context,
                          surahId: ayah.surahId,
                          surahName: surahName,
                          ayahNumber: ayah.ayahNumber,
                        );
                      },
                    ),
                  ),
                  10.hSpace,

                  // Action 3: Copy (کپی)
                  Expanded(
                    child: _buildActionButton(
                      context: context,
                      isDark: isDark,
                      cardBg: cardBg,
                      borderColor: borderColor,
                      icon: CupertinoIcons.doc_on_doc,
                      iconColor: isDark ? Colors.white70 : Colors.black87,
                      label: 'کپی آیه',
                      onTap: () async {
                        Navigator.of(context).pop();
                        ref.read(selectedAyahActionProvider.notifier).clearSelection();

                        final removeBrackets = ref
                            .read(quranDisplaySettingsControllerProvider)
                            .removeTranslationBrackets;

                        final formatted = ayah.toShareableText(
                          surahName: surahName,
                          removeBrackets: removeBrackets,
                        );

                        await Clipboard.setData(ClipboardData(text: formatted));
                        if (context.mounted) {
                          AppSnackBar.showSuccess(
                            context,
                            'آیه ${ayah.ayahNumber.toPersianDigit()} سوره $surahName کپی شد.',
                          );
                        }
                      },
                    ),
                  ),
                  10.hSpace,

                  // Action 4: Share (اشتراک‌گذاری)
                  Expanded(
                    child: _buildActionButton(
                      context: context,
                      isDark: isDark,
                      cardBg: cardBg,
                      borderColor: borderColor,
                      icon: CupertinoIcons.share,
                      iconColor: isDark ? Colors.white70 : Colors.black87,
                      label: 'اشتراک',
                      onTap: () async {
                        Navigator.of(context).pop();
                        ref.read(selectedAyahActionProvider.notifier).clearSelection();

                        final removeBrackets = ref
                            .read(quranDisplaySettingsControllerProvider)
                            .removeTranslationBrackets;

                        final formatted = ayah.toShareableText(
                          surahName: surahName,
                          removeBrackets: removeBrackets,
                        );

                        await Share.share(
                          formatted,
                          subject: 'آیه ${ayah.ayahNumber} سوره $surahName',
                        );
                      },
                    ),
                  ),
                ],
              ),
              8.vSpace,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required bool isDark,
    required Color cardBg,
    required Color borderColor,
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: iconColor),
              6.vSpace,
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : const Color(0xFF4A463F),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
