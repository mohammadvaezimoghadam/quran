import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/extensions/context_extension.dart';
import '../../../../core/routes/route_name.dart';
import '../../../../core/services/payment/models/payment_product.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../application/vip_subscription_controller.dart';
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
      if (!mounted) return;
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
              // Borderless Plan Cards with Dedicated Action Buttons
              ...products.map((product) {
                final isPurchasing =
                    state.isLoading && _purchasingProductId == product.id;
                final isAnyPurchasing = state.isLoading;
                final isCurrentActivePlan = isVip && state.activePlanId == product.id;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SubscriptionPlanCard(
                    product: product,
                    isLoading: isPurchasing,
                    isDisabled: isVip || (isAnyPurchasing && !isPurchasing),
                    isVip: isVip,
                    buttonText: isVip
                        ? (isCurrentActivePlan ? 'پلن فعال' : 'فعال')
                        : null,
                    onPurchase: isVip ? null : () => _handlePurchase(product, controller),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
