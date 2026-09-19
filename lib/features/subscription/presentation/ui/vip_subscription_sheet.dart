import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/extensions/context_extension.dart';
import '../../../../core/services/payment/models/payment_product.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../application/vip_subscription_controller.dart';
import '../utils/bazaar_error_dialog_helper.dart';
import '../widgets/subscription_plan_card.dart';
import '../widgets/vip_required_dialog.dart';

/// Bottom sheet presenting audio subscription options and direct checkout.
class VipSubscriptionSheet extends ConsumerStatefulWidget {
  const VipSubscriptionSheet({super.key});

  /// Convenient static helper to show this dialog from anywhere in the app.
  static Future<void> show(BuildContext context) {
    return VipRequiredDialog.show(context: context);
  }

  @override
  ConsumerState<VipSubscriptionSheet> createState() =>
      _VipSubscriptionSheetState();
}

class _VipSubscriptionSheetState extends ConsumerState<VipSubscriptionSheet> {
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
        _showSnackBar('اشتراک شما با موفقیت فعال شد!');
        Navigator.of(context).pop();
      } else if (result.isCancelled) {
        _showSnackBar('فرآیند خرید لغو شد.');
      } else if (result.errorMessage != null) {
        await BazaarErrorDialogHelper.show(
          context: context,
          ref: ref,
          errorMessage: result.errorMessage!,
          product: product,
          onSuccess: () {
            if (context.mounted) {
              _showSnackBar('اشتراک شما با موفقیت فعال شد!');
              Navigator.of(context).pop();
            }
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
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final state = ref.watch(vipSubscriptionControllerProvider);
    final controller = ref.read(vipSubscriptionControllerProvider.notifier);
    final isVip = ref.watch(hasVipAccessProvider);
    final products = state.availableProducts;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Minimal Drag handle
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant
                      .withValues(alpha: isDark ? 0.35 : 0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Minimal Header Row without icons
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    const SizedBox(width: 48),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'اشتراک تلاوت و صوت قرآن',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'دسترسی به تمام قاریان برجسته و ترجمه گویا',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'بستن',
                      icon: Icon(
                        CupertinoIcons.xmark_circle_fill,
                        size: 24,
                        color: isDark ? Colors.white38 : Colors.black26,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              Divider(
                height: 1,
                thickness: 0.8,
                color: colorScheme.outlineVariant
                    .withValues(alpha: isDark ? 0.15 : 0.3),
              ),

              // Clean, Borderless Subscription Plans List with Direct Buttons
              Flexible(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...products.map((product) {
                        final isPurchasing = state.isLoading &&
                            _purchasingProductId == product.id;
                        final isAnyPurchasing = state.isLoading;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: SubscriptionPlanCard(
                            product: product,
                            isLoading: isPurchasing,
                            isDisabled: isAnyPurchasing && !isPurchasing,
                            isVip: isVip,
                            onPurchase: () =>
                                _handlePurchase(product, controller),
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                      // Restore Purchases button
                      Center(
                        child: TextButton(
                          onPressed: state.isLoading
                              ? null
                              : () async {
                                  final restored =
                                      await controller.restorePurchases();
                                  if (!context.mounted) return;
                                  if (restored) {
                                    _showSnackBar(
                                        'خریدهای شما با موفقیت بازیابی شد!');
                                    Navigator.of(context).pop();
                                  } else {
                                    _showSnackBar(
                                        'خریدی برای بازیابی یافت نشد.');
                                  }
                                },
                          child: Text(
                            'بازیابی خرید قبلی',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 12.5,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ],
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
