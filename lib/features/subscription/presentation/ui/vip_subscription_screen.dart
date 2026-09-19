import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/extensions/context_extension.dart';
import '../../../../common/extensions/string_extension.dart';
import '../../../../core/routes/route_name.dart';
import '../../../../core/services/payment/models/payment_product.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../application/vip_subscription_controller.dart';
import '../../domain/models/vip_subscription_state.dart';
import '../utils/bazaar_error_dialog_helper.dart';
import '../widgets/subscription_plan_card.dart';

/// Minimalist VIP Subscription Screen accessible from Settings / Profile.
class VipSubscriptionScreen extends ConsumerStatefulWidget {
  const VipSubscriptionScreen({super.key});

  @override
  ConsumerState<VipSubscriptionScreen> createState() =>
      _VipSubscriptionScreenState();
}

class _VipSubscriptionScreenState extends ConsumerState<VipSubscriptionScreen> {
  String? _purchasingProductId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(vipSubscriptionControllerProvider.notifier).syncWithStore();
      final state = ref.read(vipSubscriptionControllerProvider);
      if (state.availableProducts.isEmpty ||
          state.availableProducts.first.formattedPrice == null) {
        ref.read(vipSubscriptionControllerProvider.notifier).fetchLiveProducts();
      }
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: AppTypography.fontFamily,
            color: Colors.white,
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: isError
            ? context.colorScheme.error
            : context.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        ),
      ),
    );
  }

  Future<void> _handlePurchase(
    PaymentProduct product,
    VipSubscriptionController controller,
  ) async {
    setState(() {
      _purchasingProductId = product.id;
    });

    try {
      final result = await controller.purchaseSubscription(product);
      if (!mounted) return;

      if (result.isSuccess) {
        _showSnackBar('اشتراک ویژه شما با موفقیت فعال گردید!');
      } else if (result.isCancelled) {
        _showSnackBar('فرآیند خرید لغو شد.');
      } else if (result.errorMessage != null) {
        await BazaarErrorDialogHelper.show(
          context: context,
          ref: ref,
          errorMessage: result.errorMessage!,
          product: product,
          onSuccess: () {
            _showSnackBar('اشتراک ویژه شما با موفقیت فعال گردید!');
          },
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _purchasingProductId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final state = ref.watch(vipSubscriptionControllerProvider);
    final controller = ref.read(vipSubscriptionControllerProvider.notifier);
    final isVip = ref.watch(hasVipAccessProvider);
    final products = state.availableProducts;

    final bgColor = theme.scaffoldBackgroundColor;
    final cardBg = context.colors.cardBackground;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1B1B);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: cardBg,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: textColor),
          leading: IconButton(
            tooltip: 'بازگشت',
            icon: Icon(
              CupertinoIcons.chevron_forward,
              size: 24,
              color: textColor,
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
          title: Text(
            'اشتراک ویژه',
            style: AppTypography.appBarTitle.copyWith(
              color: textColor,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'همگام‌سازی وضعیت',
              icon: const Icon(CupertinoIcons.arrow_2_circlepath, size: 20),
              splashRadius: 22,
              onPressed: () async {
                await controller.syncWithStore();
                await controller.fetchLiveProducts();
                _showSnackBar('وضعیت اشتراک با کافه بازار بررسی شد.');
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          color: context.colorScheme.primary,
          onRefresh: () async {
            await controller.syncWithStore();
            await controller.fetchLiveProducts();
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            children: [
              // Active Subscription Status (only if user is already VIP)
              if (isVip) ...[
                _buildActiveStatusCard(
                  context: context,
                  state: state,
                  isDark: isDark,
                  cardBg: cardBg,
                ),
                const SizedBox(height: 18),
              ],

              // Borderless Plan Cards with Dedicated Action Buttons
              ...products.map((product) {
                final isPurchasing =
                    state.isLoading && _purchasingProductId == product.id;
                final isAnyPurchasing = state.isLoading;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SubscriptionPlanCard(
                    product: product,
                    isLoading: isPurchasing,
                    isDisabled: isAnyPurchasing && !isPurchasing,
                    isVip: isVip,
                    onPurchase: () => _handlePurchase(product, controller),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  /// Active status card showing expiry date and plan name
  Widget _buildActiveStatusCard({
    required BuildContext context,
    required VipSubscriptionState state,
    required bool isDark,
    required Color cardBg,
  }) {
    final expiryDate = state.vipExpiryDate;
    final remainingDays = expiryDate?.difference(DateTime.now()).inDays;

    final remainingText = remainingDays != null && remainingDays > 0
        ? '$remainingDays روز دیگر'.toPersianDigit()
        : 'امروز'.toPersianDigit();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F766E).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF0F766E),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'اشتراک ویژه شما فعال است',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'اعتبار باقی‌مانده: $remainingText',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11.5,
                        color:
                            isDark ? Colors.white70 : const Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (expiryDate != null) ...[
            const SizedBox(height: 10),
            Divider(
              height: 1,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFEAE7E3),
            ),
            const SizedBox(height: 8),
            Text(
              'تاریخ اتمام: ${expiryDate.year}/${expiryDate.month.toString().padLeft(2, '0')}/${expiryDate.day.toString().padLeft(2, '0')}'
                  .toPersianDigit(),
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 11,
                color: isDark ? Colors.white60 : const Color(0xFF888888),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
