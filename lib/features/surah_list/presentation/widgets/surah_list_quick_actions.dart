import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/constants/surah_constants.dart';
import '../../../../core/routes/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../quran_reader/application/controllers/quran_display_settings_controller.dart';
import '../../../quran_reader/presentation/widgets/quran_quick_jump_bottom_sheet.dart';
import '../../../quick_access/presentation/widgets/bookmarks_manager_bottom_sheet.dart';

/// Clean, high-contrast quick action cards for "Bookmarks" (نشان شده‌ها)
/// and "Quick Jump" (برو به) positioned directly beneath the search bar.
class SurahListQuickActions extends ConsumerWidget {
  final VoidCallback? onBeforeNavigation;

  const SurahListQuickActions({
    super.key,
    this.onBeforeNavigation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Palette for "نشان شده‌ها" (Gold / Amber)
    final bookmarkBg = isDark
        ? AppColors.goldAccent.withValues(alpha: 0.12)
        : const Color(0xFFFFF8E7);
    final bookmarkBorder = isDark
        ? AppColors.goldAccent.withValues(alpha: 0.28)
        : const Color(0xFFF5E0B3);
    final bookmarkText = isDark
        ? const Color(0xFFF7E2A9)
        : const Color(0xFF8A661C);
    final bookmarkIcon = isDark
        ? const Color(0xFFF7E2A9)
        : AppColors.goldAccent;

    // Palette for "برو به" (Sapphire / Slate Blue)
    final jumpBg = isDark
        ? const Color(0xFF1E6FBF).withValues(alpha: 0.15)
        : const Color(0xFFEFF5FC);
    final jumpBorder = isDark
        ? const Color(0xFF1E6FBF).withValues(alpha: 0.32)
        : const Color(0xFFD3E4F8);
    final jumpText = isDark
        ? const Color(0xFF90C2F7)
        : const Color(0xFF1A5F9E);
    final jumpIcon = isDark
        ? const Color(0xFF90C2F7)
        : const Color(0xFF1E6FBF);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
      child: Row(
        children: [
          // 1. Right Card: نشان شده‌ها (Bookmarks)
          Expanded(
            child: _ActionCardItem(
              title: 'نشان شده‌ها',
              icon: Icons.bookmark_rounded,
              bgColor: bookmarkBg,
              borderColor: bookmarkBorder,
              textColor: bookmarkText,
              iconColor: bookmarkIcon,
              onTap: () {
                onBeforeNavigation?.call();
                BookmarksManagerBottomSheet.show(context);
              },
            ),
          ),
          const SizedBox(width: 10),

          // 2. Left Card: برو به (Jump To)
          Expanded(
            child: _ActionCardItem(
              title: 'برو به',
              icon: CupertinoIcons.arrow_turn_up_left,
              bgColor: jumpBg,
              borderColor: jumpBorder,
              textColor: jumpText,
              iconColor: jumpIcon,
              onTap: () async {
                final target = await QuranQuickJumpBottomSheet.show(context);
                if (target != null && context.mounted) {
                  onBeforeNavigation?.call();
                  ref
                      .read(quranDisplaySettingsControllerProvider.notifier)
                      .toggleArabicText(true);
                  context.pushNamed(
                    quranReaderRoute,
                    pathParameters: {'id': target.surahId.toString()},
                    queryParameters: {
                      'name': SurahConstants.getSurahName(target.surahId),
                      'ayah': target.ayahNumber.toString(),
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCardItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color bgColor;
  final Color borderColor;
  final Color textColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _ActionCardItem({
    required this.title,
    required this.icon,
    required this.bgColor,
    required this.borderColor,
    required this.textColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
