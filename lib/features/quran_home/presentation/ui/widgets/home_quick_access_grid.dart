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

    final primaryEmerald = colorScheme.primary;
    final iconColor = isDark ? colors.goldAccent : colorScheme.primary;

    final cardBorderColor = colors.cardBorder;
    final secondaryBg = colors.cardBackground;

    return Row(
      children: [
        // 1. Primary Hero Card: "فهرست سوره‌ها" (Prominent & Inviting)
        Expanded(
          flex: 5,
          child: Container(
            height: 82,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: isDark
                    ? [
                        const Color(0xFF1E332B),
                        const Color(0xFF13221C),
                      ]
                    : [
                        const Color(0xFFF0F7F3),
                        const Color(0xFFE5EFE9),
                      ],
              ),
              border: Border.all(
                color: isDark
                    ? primaryEmerald.withValues(alpha: 0.35)
                    : primaryEmerald.withValues(alpha: 0.25),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryEmerald.withValues(alpha: isDark ? 0.2 : 0.08),
                  blurRadius: 12.0,
                  offset: const Offset(0, 3.0),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20.0),
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.pushNamed(surahListRoute);
                },
                borderRadius: BorderRadius.circular(20.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                  child: Row(
                    children: [
                      // Quran Icon
                      SvgPicture.asset(
                        'assets/icons/ic_surah_list.svg',
                        width: 40,
                        height: 40,
                        colorFilter: ColorFilter.mode(
                          iconColor,
                          BlendMode.srcIn,
                        ),
                      ),
                      8.hSpace,

                      // Surah List Typography (Zero Overflow Guarantee)
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
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF16241E),
                                  height: 1.2,
                                ),
                                maxLines: 1,
                              ),
                            ),
                            2.vSpace,
                            Text(
                              '۱۱۴ سوره قرآن',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 11.0,
                                fontWeight: FontWeight.w500,
                                color: isDark ? primaryEmerald : const Color(0xFF3F7760),
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
                        color: isDark ? Colors.white54 : Colors.black45,
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
              width: 36,
              height: 36,
              colorFilter: ColorFilter.mode(
                iconColor,
                BlendMode.srcIn,
              ),
            ),
            isDark: isDark,
            bgColor: secondaryBg,
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
              width: 36,
              height: 36,
              colorFilter: ColorFilter.mode(
                iconColor,
                BlendMode.srcIn,
              ),
            ),
            isDark: isDark,
            bgColor: secondaryBg,
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
      height: 82,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.035),
                  blurRadius: 10.0,
                  offset: const Offset(0, 3.0),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 6.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 36,
                  height: 36,
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
                      color: isDark ? Colors.white70 : const Color(0xFF2C2C2C),
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
