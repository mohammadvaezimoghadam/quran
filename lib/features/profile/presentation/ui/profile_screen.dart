import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/extensions/context_extension.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../common/extensions/string_extension.dart';
import '../../../../core/routes/route_name.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../subscription/application/vip_subscription_controller.dart';
import '../../../subscription/domain/models/vip_subscription_state.dart';

/// Dedicated Profile Screen featuring user status, subscription details card,
/// and direct navigation to VIP Subscription checkout.
class ProfileScreen extends ConsumerWidget {
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const ProfileScreen({
    super.key,
    this.showBackButton = true,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final colorScheme = context.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final isVip = ref.watch(hasVipAccessProvider);
    final vipState = ref.watch(vipSubscriptionControllerProvider);
    final controller = ref.read(vipSubscriptionControllerProvider.notifier);

    final primaryColor = colorScheme.primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
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
                if (showBackButton)
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
                      if (onBackPressed != null) {
                        onBackPressed!();
                      } else if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        context.goNamed(quranHomeRoute);
                      }
                    },
                  )
                else
                  const SizedBox(width: 48),
                Expanded(
                  child: Text(
                    'پروفایل کاربری',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'همگام‌سازی وضعیت',
                  icon: const Icon(CupertinoIcons.arrow_2_circlepath, size: 20),
                  splashRadius: 22,
                  onPressed: () async {
                    await controller.syncWithStore();
                    await controller.fetchLiveProducts();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'وضعیت اشتراک با کافه بازار بررسی شد.',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 13,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        backgroundColor: primaryColor,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            // User Header
            _buildUserHeader(
              context: context,
              isVip: isVip,
              isDark: isDark,
              primaryColor: primaryColor,
            ),
            20.vSpace,

            // Subscription Status Card
            _buildSectionHeader('وضعیت حساب', isDark),
            8.vSpace,
            _buildSubscriptionStatusCard(
              context: context,
              isVip: isVip,
              vipState: vipState,
              isDark: isDark,
              colors: colors,
              primaryColor: primaryColor,
            ),
            20.vSpace,

            // VIP Subscription Navigation Item
            _buildSectionHeader('اشتراک ویژه', isDark),
            8.vSpace,
            _buildGroupCard(
              context: context,
              children: [
                _buildProfileTile(
                  context: context,
                  title: 'اشتراک ویژه',
                  subtitle: isVip
                      ? 'مشاهده پلن‌ها و تمدید اعتبار اشتراک تفکر'
                      : 'دسترسی نامحدود به تمامی قاریان و ترجمه‌های گویا',
                  onTap: () => context.pushNamed(vipSubscriptionRoute),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Top User Header Avatar and Badge
  Widget _buildUserHeader({
    required BuildContext context,
    required bool isVip,
    required bool isDark,
    required Color primaryColor,
  }) {
    final colorScheme = context.colorScheme;

    return Center(
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: isDark ? 0.20 : 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              CupertinoIcons.person_solid,
              size: 38,
              color: primaryColor,
            ),
          ),
          12.vSpace,
          Text(
            'کاربر قرآن تفکر',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          6.vSpace,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: isVip
                  ? primaryColor.withValues(alpha: isDark ? 0.22 : 0.12)
                  : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isVip
                      ? CupertinoIcons.checkmark_seal_fill
                      : CupertinoIcons.person,
                  size: 13,
                  color: isVip
                      ? primaryColor
                      : (isDark ? Colors.white60 : Colors.black54),
                ),
                5.hSpace,
                Text(
                  isVip ? 'عضویت ویژه تفکر' : 'کاربر عادی',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: isVip
                        ? primaryColor
                        : (isDark ? Colors.white70 : Colors.black54),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Dedicated Subscription Status Card
  Widget _buildSubscriptionStatusCard({
    required BuildContext context,
    required bool isVip,
    required VipSubscriptionState vipState,
    required bool isDark,
    required dynamic colors,
    required Color primaryColor,
  }) {
    final expiryDate = vipState.vipExpiryDate;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isVip
            ? primaryColor.withValues(alpha: isDark ? 0.12 : 0.08)
            : colors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isVip
                ? 'اشتراک ویژه شما فعال است'
                : 'وضعیت اشتراک: کاربر عادی',
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isVip && expiryDate != null) ...[
            12.vSpace,
            Divider(
              height: 1,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFEAE7E3),
            ),
            10.vSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'تاریخ پایان اعتبار:',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    color: isDark ? Colors.white60 : const Color(0xFF888888),
                  ),
                ),
                Text(
                  '${expiryDate.year}/${expiryDate.month.toString().padLeft(2, '0')}/${expiryDate.day.toString().padLeft(2, '0')}'
                      .toPersianDigit(),
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.90)
                        : const Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ],
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

  Widget _buildProfileTile({
    required BuildContext context,
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
                        color: colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
              8.hSpace,
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
