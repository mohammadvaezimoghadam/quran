import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/extensions/int_extension.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../common/extensions/string_extension.dart';
import '../../../../common/utils/arabic_text_helper.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../quran_reader/application/controllers/quran_display_settings_controller.dart';
import '../../application/controllers/ayah_translation_provider.dart';
import 'translation_skeleton.dart';

/// Renders the translation text of an Ayah.
/// This widget is fully decoupled from the Reader feature's display settings.
class AyahTranslationText extends ConsumerWidget {
  final int surahId;
  final int ayahNumber;
  final String fallbackText;
  final bool isActive;
  final bool isVisible;
  final double fontSize;
  final String? translationId;

  const AyahTranslationText({
    super.key,
    required this.surahId,
    required this.ayahNumber,
    required this.fallbackText,
    required this.isVisible,
    required this.fontSize,
    this.translationId,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isVisible) {
      return const SizedBox.shrink();
    }

    // Fetch the translation using the translation_manager module
    final translationAsync = ref.watch(ayahTranslationProvider(surahId, ayahNumber, translationId));
    
    if (translationAsync.isLoading && !translationAsync.hasValue) {
      return const TranslationSkeleton();
    }

    final removeBrackets = ref.watch(
      quranDisplaySettingsControllerProvider.select((s) => s.removeTranslationBrackets),
    );

    final rawTranslation = translationAsync.value ?? fallbackText;
    final textToClean = removeBrackets ? rawTranslation.removeTranslatorExplanations() : rawTranslation;
    final translationText = ArabicTextHelper.sanitizeText(textToClean);

    if (translationText.isEmpty) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;

    final textColor = isActive
        ? colorScheme.onSurface
        : colorScheme.onSurfaceVariant;

    final style = AppTypography.translationText.copyWith(
      fontSize: fontSize,
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
