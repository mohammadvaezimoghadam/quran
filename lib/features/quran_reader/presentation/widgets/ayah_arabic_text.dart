import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/utils/arabic_text_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../application/controllers/quran_display_settings_controller.dart';
import 'ayah_number_marker.dart';

/// Renders the Arabic text of an Ayah with an inline number marker
/// and custom diacritics (Tashkeel) coloring.
///
/// Uses a single [RichText] widget with per-rune [TextSpan] splitting.
/// Flutter's text shaping engine (HarfBuzz) processes the entire paragraph
/// as one unit regardless of [TextSpan] boundaries, so Arabic cursive
/// joining and glyph positioning are fully preserved. The span boundaries
/// only switch the paint color between base letters and diacritics.
class AyahArabicText extends ConsumerWidget {
  final String text;
  final int ayahNumber;
  final bool isActive;
  final int? pageIndicatorNumber;

  const AyahArabicText({
    super.key,
    required this.text,
    required this.ayahNumber,
    this.isActive = false,
    this.pageIndicatorNumber,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    final arabicFontSize = ref.watch(
      quranDisplaySettingsControllerProvider.select((s) => s.arabicFontSize),
    );
    final fontScript = ref.watch(
      quranDisplaySettingsControllerProvider.select((s) => s.fontScript),
    );
    final harakatColorHex = ref.watch(
      quranDisplaySettingsControllerProvider.select((s) => s.harakatColor),
    );

    final fontFamily = AppTypography.getFontFamilyByScript(fontScript);
    final harakatColor = ArabicTextHelper.parseHexColor(harakatColorHex);

    final baseStyle = AppTypography.displayQuranReader.copyWith(
      fontFamily: fontFamily,
      fontSize: arabicFontSize,
      color: colorScheme.onSurface,
    );

    final sanitizedText = ArabicTextHelper.removeAnnotationMarks(text);

    final bool useCustomColor = harakatColor != null &&
        harakatColor != colorScheme.onSurface;

    final List<InlineSpan> textChildren;

    if (useCustomColor) {
      textChildren = [
        ...ArabicTextHelper.buildColoredSpans(
          text: sanitizedText,
          baseStyle: baseStyle,
          baseColor: colorScheme.onSurface,
          harakatColor: harakatColor,
        ),
      ];
    } else {
      textChildren = [
        TextSpan(text: sanitizedText),
      ];
    }

    if (pageIndicatorNumber != null) {
      textChildren.insert(
        0,
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(
              'صفحه $pageIndicatorNumber',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.goldAccent,
              ),
            ),
          ),
        ),
      );
    }

    // Append the Ayah number marker at the end.
    textChildren.add(
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: AyahNumberMarker(
          number: ayahNumber,
          isActive: isActive,
        ),
      ),
    );

    return RichText(
      textAlign: TextAlign.center,
      textDirection: TextDirection.rtl,
      text: TextSpan(
        style: baseStyle,
        children: textChildren,
      ),
    );
  }
}
