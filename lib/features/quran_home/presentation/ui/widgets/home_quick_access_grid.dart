import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../../common/extensions/context_extension.dart';
import '../../../../../common/extensions/size_extension.dart';
import '../../../../../core/routes/route_name.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../translation_manager/presentation/widgets/translation_manager_bottom_sheet.dart';

/// Modern Asymmetric Action Hub:
/// Highlights "فهرست سوره‌ها" as the primary hero gateway,
/// paired with elegant compact companions for "ترجمه‌ها" and "تنظیمات".
class HomeQuickAccessGrid extends StatelessWidget {
  const HomeQuickAccessGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final colors = context.colors;
    final colorScheme = context.colorScheme;

    final primaryMint = colorScheme.primary;
    final cardBorderColor = colors.cardBorder;
    final cardBg = colors.cardBackground;

    return Row(
      children: [
        // 1. Primary Hero Card: "فهرست سوره‌ها" (Apple Hero Card)
        Expanded(
          flex: 5,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: isDark
                  ? Color.alphaBlend(primaryMint.withValues(alpha: 0.08), cardBg)
                  : Color.alphaBlend(primaryMint.withValues(alpha: 0.05), cardBg),
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: primaryMint.withValues(alpha: isDark ? 0.30 : 0.22),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryMint.withValues(alpha: isDark ? 0.12 : 0.05),
                  blurRadius: 10.0,
                  offset: const Offset(0, 2.0),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16.0),
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.pushNamed(surahListRoute);
                },
                borderRadius: BorderRadius.circular(16.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  child: Row(
                    children: [
                      // Quran Surahs Icon
                      SvgPicture.asset(
                        'assets/icons/ic_surah_list.svg',
                        width: 38,
                        height: 38,
                        colorFilter: ColorFilter.mode(
                          primaryMint,
                          BlendMode.srcIn,
                        ),
                      ),
                      10.hSpace,

                      // Surah List Typography
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Text(
                                'فهرست سوره‌ها',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                  height: 1.2,
                                ),
                                maxLines: 1,
                              ),
                            ),
                            3.vSpace,
                            Text(
                              '۱۱۴ سوره قرآن کریم',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 11.0,
                                fontWeight: FontWeight.w600,
                                color: primaryMint,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      4.hSpace,
                      Icon(
                        CupertinoIcons.chevron_left,
                        size: 13,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        8.hSpace,

        // 2. Secondary Companion Card: "ترجمه‌ها"
        Expanded(
          flex: 2,
          child: _buildSecondaryCard(
            context: context,
            title: 'ترجمه‌ها',
            iconWidget: SvgPicture.asset(
              'assets/icons/ic_translation.svg',
              width: 32,
              height: 32,
              colorFilter: ColorFilter.mode(
                primaryMint,
                BlendMode.srcIn,
              ),
            ),
            isDark: isDark,
            bgColor: cardBg,
            borderColor: cardBorderColor,
            onTap: () {
              HapticFeedback.lightImpact();
              TranslationManagerBottomSheet.show(context);
            },
          ),
        ),
        8.hSpace,

        // 3. Secondary Companion Card: "تنظیمات"
        Expanded(
          flex: 2,
          child: _buildSecondaryCard(
            context: context,
            title: 'تنظیمات',
            iconWidget: SvgPicture.asset(
              'assets/icons/ic_settings.svg',
              width: 32,
              height: 32,
              colorFilter: ColorFilter.mode(
                primaryMint,
                BlendMode.srcIn,
              ),
            ),
            isDark: isDark,
            bgColor: cardBg,
            borderColor: cardBorderColor,
            onTap: () {
              HapticFeedback.lightImpact();
              context.pushNamed(settingsRoute);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryCard({
    required BuildContext context,
    required String title,
    required Widget iconWidget,
    required bool isDark,
    required Color bgColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: borderColor,
          width: 0.8,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.025),
                  blurRadius: 8.0,
                  offset: const Offset(0, 2.0),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 6.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: Center(
                    child: iconWidget,
                  ),
                ),
                4.vSpace,
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white.withValues(alpha: 0.9) : const Color(0xFF2C2C2C),
                      height: 1.1,
                    ),
                    maxLines: 1,
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
