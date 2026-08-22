import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/extensions/int_extension.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../common/utils/arabic_text_helper.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../application/controllers/quran_display_settings_controller.dart';
import '../../application/controllers/translation_controller.dart';

/// Renders the Persian translation text of an Ayah with isolated state subscriptions.
class AyahTranslationText extends ConsumerWidget {
  final int surahId;
  final int ayahNumber;
  final String fallbackText;
  final bool isActive;

  const AyahTranslationText({
    super.key,
    required this.surahId,
    required this.ayahNumber,
    required this.fallbackText,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Isolated check: If showTranslation is false, self-collapse
    final showTranslation = ref.watch(
      quranDisplaySettingsControllerProvider.select((s) => s.showTranslation),
    );

    if (!showTranslation) {
      return const SizedBox.shrink();
    }

    // Isolated subscription to ONLY the translation map for this surah
    final translationsAsync = ref.watch(surahTranslationsProvider(surahId));
    final rawTranslation =
        translationsAsync.value?[ayahNumber] ?? fallbackText;
    final translationText = ArabicTextHelper.sanitizeText(rawTranslation);

    if (translationText.isEmpty) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;

    // Isolated subscription to ONLY translationFontSize
    final translationFontSize = ref.watch(
      quranDisplaySettingsControllerProvider
          .select((s) => s.translationFontSize),
    );

    final textColor = isActive
        ? colorScheme.onSurface
        : colorScheme.onSurfaceVariant;

    final style = AppTypography.translationText.copyWith(
      fontSize: translationFontSize,
      color: textColor,
    );

    return Column(
      children: [
        AppDimens.stackMd.vSpace,
        Text(
          '$translationText (${ayahNumber.toPersianDigit()})',
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: style,
        ),
      ],
    );
  }
}
