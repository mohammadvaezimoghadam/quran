import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/extensions/int_extension.dart';
import '../../../../common/utils/arabic_text_helper.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../application/controllers/quran_display_settings_controller.dart';
import '../../application/controllers/word_by_word_provider.dart';

class WordByWordBottomSheet extends ConsumerWidget {
  final int surahId;
  final String surahName;
  final int ayahNumber;

  const WordByWordBottomSheet({
    super.key,
    required this.surahId,
    required this.surahName,
    required this.ayahNumber,
  });

  static Future<void> show(BuildContext context, {required int surahId, required String surahName, required int ayahNumber}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WordByWordBottomSheet(
        surahId: surahId,
        surahName: surahName,
        ayahNumber: ayahNumber,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordsAsync = ref.watch(ayahWordsProvider((surahId: surahId, ayahNumber: ayahNumber)));
    final colorScheme = Theme.of(context).colorScheme;
    
    final fontScript = ref.watch(quranDisplaySettingsControllerProvider.select((s) => s.fontScript));
    final harakatColorHex = ref.watch(quranDisplaySettingsControllerProvider.select((s) => s.harakatColor));
    final fontFamily = AppTypography.getFontFamilyByScript(fontScript);
    final harakatColor = ArabicTextHelper.parseHexColor(harakatColorHex);
    
    final baseArabicStyle = AppTypography.displayQuranReader.copyWith(
      fontFamily: fontFamily,
      fontSize: 24,
      color: colorScheme.onSurface,
      height: 1.5,
    );
    
    final bool useCustomColor = harakatColor != null && harakatColor != colorScheme.onSurface;

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimens.radiusXl)),
          ),
          child: Column(
            children: [
              // Drag Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: AppDimens.stackMd),
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                ),
              ),
              
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.stackLg),
                child: RichText(
                  textDirection: TextDirection.rtl,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Vazirmatn',
                      color: colorScheme.onSurface,
                    ),
                    children: [
                      TextSpan(text: 'لغت‌نامه آیه ${ayahNumber.toPersianDigit()} سوره '),
                      TextSpan(
                        text: surahName,
                        style: TextStyle(
                          fontFamily: fontFamily,
                          fontSize: 22, // Slightly larger to match Arabic fonts
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.stackMd),
              
              // Divider
              Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
              
              // Content
              Expanded(
                child: wordsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimens.stackLg),
                      child: Text(
                        'لغات این آیه هنوز در دیتابیس موجود نیست.\n$error',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colorScheme.error,
                          fontFamily: 'Vazirmatn',
                        ),
                      ),
                    ),
                  ),
                  data: (words) {
                    if (words.isEmpty) {
                      return Center(
                        child: Text(
                          'لغتی یافت نشد.',
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(AppDimens.stackMd),
                      itemCount: words.length,
                      itemBuilder: (context, index) {
                        final word = words[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: AppDimens.stackSm),
                          elevation: 0,
                          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(AppDimens.stackMd),
                            child: Row(
                              textDirection: TextDirection.rtl,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Arabic Word (Right side)
                                Expanded(
                                  child: RichText(
                                    textAlign: TextAlign.right,
                                    textDirection: TextDirection.rtl,
                                    text: TextSpan(
                                      style: baseArabicStyle,
                                      children: useCustomColor
                                        ? ArabicTextHelper.buildColoredSpans(
                                            text: word.arabicText,
                                            baseStyle: baseArabicStyle,
                                            baseColor: colorScheme.onSurface,
                                            harakatColor: harakatColor,
                                          )
                                        : [TextSpan(text: word.arabicText)],
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(width: AppDimens.stackMd),
                                
                                // Translation (Left side)
                                Expanded(
                                  child: Text(
                                    word.translation,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Vazirmatn',
                                      color: colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.left,
                                    textDirection: TextDirection.rtl,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
