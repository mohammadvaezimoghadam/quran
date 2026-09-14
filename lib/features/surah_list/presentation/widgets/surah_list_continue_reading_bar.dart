import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/extensions/context_extension.dart';
import '../../../../common/extensions/int_extension.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../common/extensions/surah_name_extension.dart';
import '../../../../core/routes/route_name.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../quran_home/application/controllers/continue_reading_controller.dart';
import '../../../quran_reader/application/controllers/quran_display_settings_controller.dart';

/// Floating Translucent Frosted-Glass Pill "Continue Reading" bottom banner for Surah List screen.
/// Styled with Apple iOS translucent floating card principles so underlying list items show through.
class SurahListContinueReadingBar extends ConsumerWidget {
  final VoidCallback? onBeforeNavigation;

  const SurahListContinueReadingBar({
    super.key,
    this.onBeforeNavigation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final continueState = ref.watch(continueReadingControllerProvider);
    final isDark = context.isDark;
    final colorScheme = context.colorScheme;

    // Resolve active reading location or default to Al-Fatihah 1
    final surahId = continueState?.surahId ?? 1;
    final rawSurahName = continueState?.surahName ?? 'الفاتحة';
    final surahFaName = surahId.surahNameFa;
    final ayahNumber = continueState?.ayahNumber ?? 1;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0D2522).withValues(alpha: 0.72)
                  : Colors.white.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(AppDimens.radiusFull),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.14)
                    : Colors.white.withValues(alpha: 0.75),
                width: 0.8,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(AppDimens.radiusFull),
              child: InkWell(
                onTap: () => _handleTap(context, ref, surahId, rawSurahName, ayahNumber),
                borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Right Side: Surah Info + Ayah Number
                      Icon(
                        CupertinoIcons.book,
                        size: 17,
                        color: colorScheme.primary,
                      ),
                      10.hSpace,
                      Expanded(
                        child: Text(
                          'سوره $surahFaName • آیه ${ayahNumber.toPersianDigit()}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),

                      10.hSpace,

                      // Left Side: "ادامه مطالعه" Action Chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                        ),
                        child: const Text(
                          'ادامه مطالعه',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap(
    BuildContext context,
    WidgetRef ref,
    int surahId,
    String rawSurahName,
    int ayahNumber,
  ) {
    onBeforeNavigation?.call();
    ref.read(quranDisplaySettingsControllerProvider.notifier).toggleArabicText(true);
    context.pushNamed(
      quranReaderRoute,
      pathParameters: {'id': surahId.toString()},
      queryParameters: {
        'name': rawSurahName,
        'ayah': ayahNumber.toString(),
      },
    );
  }
}
