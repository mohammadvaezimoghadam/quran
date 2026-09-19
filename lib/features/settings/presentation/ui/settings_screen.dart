import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/extensions/context_extension.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../common/extensions/string_extension.dart';
import '../../../../core/routes/route_name.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../quran_reader/presentation/widgets/quick_settings_drawer.dart';
import '../../../subscription/application/vip_subscription_controller.dart';
import '../../../translation_manager/presentation/widgets/translation_manager_bottom_sheet.dart';

/// Clean Apple-Style Settings Screen with iOS Grouped Design & Tafakor Mint Green Palette
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;
    final isDark = context.isDark;
    final isVip = ref.watch(hasVipAccessProvider);
    final vipState = ref.watch(vipSubscriptionControllerProvider);

    final vipSubtitle = isVip
        ? (vipState.remainingDays > 0
            ? 'اشتراک ویژه شما فعال است (${vipState.remainingDays} روز باقی‌مانده)'
                .toPersianDigit()
            : 'اشتراک ویژه فعال است (مشاهده جزییات)')
        : 'دسترسی نامحدود به تمامی قاریان برجسته و ترجمه‌های گویا';

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(62.0),
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 4,
            left: 8.0,
            right: 8.0,
            bottom: 6.0,
          ),
          decoration: BoxDecoration(
            color: colors.cardBackground,
            border: Border(
              bottom: BorderSide(
                color: colors.cardBorder,
                width: 0.8,
              ),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                tooltip: 'بازگشت',
                icon: Icon(
                  CupertinoIcons.chevron_forward,
                  size: 24,
                  color: colorScheme.onSurface,
                ),
                splashRadius: 22,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    context.goNamed(quranHomeRoute);
                  }
                },
              ),
              Expanded(
                child: Text(
                  'تنظیمات',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 48), // Balance for back button
            ],
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        children: [
          // Section 1: Reading Experience & Content
          _buildSectionHeader('مطالعه و محتوا', isDark),
          6.vSpace,
          _buildGroupCard(
            context: context,
            children: [
              _buildSettingsTile(
                context: context,
                title: 'تنظیمات متن و قرائت',
                subtitle: 'اندازه قلم، نوع خط، فاصله خطوط و رنگ اعراب',
                onTap: () => QuickSettingsDrawer.show(context),
              ),
              Divider(
                height: 1,
                thickness: 0.6,
                indent: 16,
                endIndent: 16,
                color: colors.cardBorder,
              ),
              _buildSettingsTile(
                context: context,
                title: 'مدیریت ترجمه‌ها',
                subtitle: 'انتخاب مترجم و تنظیمات نمایش ترجمه',
                onTap: () => TranslationManagerBottomSheet.show(context),
              ),
            ],
          ),
          18.vSpace,

          // Section 2: Premium & VIP Account
          _buildSectionHeader('اشتراک ویژه', isDark),
          6.vSpace,
          _buildGroupCard(
            context: context,
            children: [
              _buildSettingsTile(
                context: context,
                title: 'اشتراک ویژه تفکر',
                subtitle: vipSubtitle,
                trailing: isVip
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(
                            alpha: isDark ? 0.18 : 0.10,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.primary.withValues(
                              alpha: isDark ? 0.35 : 0.25,
                            ),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          'فعال',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      )
                    : null,
                onTap: () => context.pushNamed(vipSubscriptionRoute),
              ),
            ],
          ),
          18.vSpace,

          // Section 3: App Information
          _buildSectionHeader('اطلاعات برنامه', isDark),
          6.vSpace,
          _buildGroupCard(
            context: context,
            children: [
              _buildSettingsTile(
                context: context,
                icon: CupertinoIcons.info_circle,
                title: 'درباره قرآن تفکر',
                subtitle: 'نسخه ۱.۰.۰',
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'قرآن تفکر',
                    applicationVersion: '۱.۰.۰',
                    applicationIcon: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        CupertinoIcons.book,
                        color: colorScheme.primary,
                        size: 26,
                      ),
                    ),
                    children: const [
                      Text(
                        'اپلیکیشن جامع قرآن تفکر با رسم‌الخط‌های استاندارد، ترجمه‌های معتبر و امکانات پیشرفته مطالعه قرآن کریم.',
                        textAlign: TextAlign.justify,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white54 : const Color(0xFF7A756D),
        ),
      ),
    );
  }

  Widget _buildGroupCard({
    required BuildContext context,
    required List<Widget> children,
  }) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.cardBorder,
          width: 0.8,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    IconData? icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    final colorScheme = context.colorScheme;
    final isDark = context.isDark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(
                      alpha: isDark ? 0.14 : 0.08,
                    ),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    color: colorScheme.primary,
                    size: 19,
                  ),
                ),
                12.hSpace,
              ],

              // Title and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    2.vSpace,
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11.5,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),

              8.hSpace,

              // Trailing Indicator (Chevron or Custom Status)
              if (trailing != null) ...[
                trailing,
                6.hSpace,
              ],
              Icon(
                CupertinoIcons.chevron_left,
                size: 13,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
