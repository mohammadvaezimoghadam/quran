import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../common/extensions/int_extension.dart';
import '../../../../common/utils/arabic_text_helper.dart';
import '../../../../core/theme/app_typography.dart';
import '../../application/controllers/quran_display_settings_controller.dart';

/// Renders a circular badge marker for an Ayah number using Eastern Arabic/Persian digits.
class AyahNumberMarker extends ConsumerWidget {
  final int number;
  final bool isActive;

  const AyahNumberMarker({
    super.key,
    required this.number,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Isolated check: If showAyahNumbers is false, self-collapse into SizedBox.shrink()
    final showAyahNumber = ref.watch(
      quranDisplaySettingsControllerProvider.select((s) => s.showAyahNumbers),
    );

    if (!showAyahNumber) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    
    final harakatColorHex = ref.watch(
      quranDisplaySettingsControllerProvider.select((s) => s.harakatColor),
    );
    final customColor = ArabicTextHelper.parseHexColor(harakatColorHex);

    final bracketColor = customColor ?? colorScheme.onSurfaceVariant;
    final numberColor = colorScheme.onSurface; // Default text color for the number

    final fontScript = ref.watch(
      quranDisplaySettingsControllerProvider.select((s) => s.fontScript),
    );
    final fontFamily = AppTypography.getFontFamilyByScript(fontScript);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        textDirection: TextDirection.rtl,
        children: [
          // Right Bracket (Ra_bracket)
          SvgPicture.asset(
            'assets/icons/ic_bracket_right.svg',
            height: 24, // Adjust this as needed for proper scale
            colorFilter: ColorFilter.mode(bracketColor, BlendMode.srcIn),
          ),
          
          const SizedBox(width: 2), // Small gap
          
          // Ayah Number
          Padding(
            padding: const EdgeInsets.only(top: 2.0), // Tiny optical adjustment
            child: Text(
              number.toPersianDigit(),
              style: TextStyle(
                color: numberColor,
                fontSize: 20, 
                fontFamily: fontFamily, // Dynamically matches the Arabic verse font!
                fontWeight: FontWeight.bold,
                height: 1.0,
              ),
            ),
          ),
          
          const SizedBox(width: 2), // Small gap
          
          // Left Bracket (La_bracket)
          SvgPicture.asset(
            'assets/icons/ic_bracket_left.svg',
            height: 24, // Adjust this as needed for proper scale
            colorFilter: ColorFilter.mode(bracketColor, BlendMode.srcIn),
          ),
        ],
      ),
    );
  }
}
