import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../../common/constants/app_constants.dart';
import '../../../../../common/extensions/size_extension.dart';
import '../../../../../core/routes/route_name.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../common/widgets/app_snackbar.dart';
import '../../../../translation_manager/presentation/widgets/translation_manager_bottom_sheet.dart';

/// Quick Access Action Item Model
class _QuickAccessItem {
  final String title;
  final String? svgAssetPath;
  final IconData? iconData;
  final VoidCallback onTap;

  const _QuickAccessItem({
    required this.title,
    this.svgAssetPath,
    this.iconData,
    required this.onTap,
  });
}

/// Home Quick Access Action Buttons Grid (فهرست سوره‌ها، ترجمه، تفسیر)
class HomeQuickAccessGrid extends StatelessWidget {
  const HomeQuickAccessGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _QuickAccessItem(
        title: AppConstants.surahListTitle,
        svgAssetPath: 'assets/icons/ic_surah_list.svg',
        onTap: () => context.pushNamed(surahListRoute),
      ),
      _QuickAccessItem(
        title: AppConstants.translationTitle,
        svgAssetPath: 'assets/icons/ic_translation.svg',
        onTap: () => TranslationManagerBottomSheet.show(context),
      ),
      _QuickAccessItem(
        title: AppConstants.settingsTitle,
        iconData: CupertinoIcons.gear_alt,
        onTap: () {
          AppSnackBar.showInfo(context, AppConstants.settingsComingSoon);
        },
      ),
    ];

    return Row(
      children: items.map((item) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.stackXxSm),
            child: _QuickAccessCard(item: item),
          ),
        );
      }).toList(),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final _QuickAccessItem item;

  const _QuickAccessCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBgColor = isDark ? const Color(0xFF192220) : Colors.white;
    final cardBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFEAE7E3);
    final textColor = isDark ? Colors.white : const Color(0xFF1C1B1B);

    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: cardBorderColor,
          width: 1,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16.0,
                  spreadRadius: 0.0,
                  offset: const Offset(0, 4.0),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20.0),
        child: InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(20.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 18.0,
              horizontal: 8.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (item.svgAssetPath != null)
                  SvgPicture.asset(
                    item.svgAssetPath!,
                    width: 48,
                    height: 48,
                  )
                else if (item.iconData != null)
                  Icon(
                    item.iconData,
                    size: 48,
                    color: AppColors.goldAccent,
                  ),
                10.vSpace,
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
