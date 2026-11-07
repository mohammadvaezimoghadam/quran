import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../common/utils/sajdah_helper.dart';
import '../../../../core/theme/app_typography.dart';

/// A clean, minimalist outline icon overlay for Sajdah (prostration) verses.
/// Displays just the standalone outline icon without any box, border, or vivid colors.
class SajdahBadge extends StatelessWidget {
  final SajdahType type;

  const SajdahBadge({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    if (type == SajdahType.none) return const SizedBox.shrink();

    final isWajib = type == SajdahType.wajib;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Neutral monochrome color matching the theme's subtle icon/text tone (no red, no tint)
    final iconColor = isDark
        ? Colors.white.withValues(alpha: 0.55)
        : colorScheme.onSurfaceVariant.withValues(alpha: 0.55);

    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: isWajib ? 'سجده واجب' : 'سجده مستحب',
        child: InkResponse(
          onTap: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                content: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/ic_sajdah_outline.svg',
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        iconColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isWajib
                            ? 'این آیه دارای سجده واجب است (با قرائت یا شنیدن آن، سجده واجب می‌شود).'
                            : 'این آیه دارای سجده مستحب است.',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 13,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          radius: 18,
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: SvgPicture.asset(
              'assets/icons/ic_sajdah_outline.svg',
              width: 19,
              height: 19,
              colorFilter: ColorFilter.mode(
                iconColor,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
