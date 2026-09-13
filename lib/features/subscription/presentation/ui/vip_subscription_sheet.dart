import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/payment/models/payment_product.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../application/vip_subscription_controller.dart';
import '../widgets/subscription_plan_card.dart';

/// Bottom sheet presenting audio subscription options and checkout via Cafe Bazaar.
class VipSubscriptionSheet extends ConsumerStatefulWidget {
  const VipSubscriptionSheet({super.key});

  /// Convenient static helper to show this sheet from anywhere in the app.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const VipSubscriptionSheet(),
    );
  }

  @override
  ConsumerState<VipSubscriptionSheet> createState() => _VipSubscriptionSheetState();
}

class _VipSubscriptionSheetState extends ConsumerState<VipSubscriptionSheet> {
  PaymentProduct _selectedProduct = PaymentProduct.vipMonthly;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(vipSubscriptionControllerProvider.notifier).syncWithStore();
      final state = ref.read(vipSubscriptionControllerProvider);
      if (state.availableProducts.isEmpty || state.availableProducts.first.formattedPrice == null) {
        ref.read(vipSubscriptionControllerProvider.notifier).fetchLiveProducts();
      }
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
            ? const Color(0xFFC62828)
            : (isDark
                ? const Color(0xFF0F766E)
                : AppColors.primary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final state = ref.watch(vipSubscriptionControllerProvider);
    final controller = ref.read(vipSubscriptionControllerProvider.notifier);
    final products = state.availableProducts;

    // Ensure selected product is from current available products
    final activeSelectedProduct = products.firstWhere(
      (p) => p.id == _selectedProduct.id,
      orElse: () => products.first,
    );

    final buttonBg = isDark ? const Color(0xFF0F766E) : AppColors.primary;

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
                  color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.35 : 0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Minimal Header Row without icons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'اشتراک تلاوت و صوت قرآن',
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
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, size: 22),
                      color: colorScheme.onSurfaceVariant,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),

              Divider(
                height: 1,
                thickness: 0.8,
                color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.15 : 0.3),
              ),

              // Clean Subscription Plans List
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: products.map((product) {
                      final isSelected = product.id == activeSelectedProduct.id;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SubscriptionPlanCard(
                          product: product,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              _selectedProduct = product;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Bottom Sticky Purchase & Restore Bar
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                decoration: BoxDecoration(
                  color: isDark ? colorScheme.surface : Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.15 : 0.3),
                      width: 0.8,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Clean primary purchase button without icons
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: state.isLoading
                            ? null
                            : () async {
                                final result = await controller.purchaseSubscription(activeSelectedProduct);
                                if (!context.mounted) return;
                                if (result.isSuccess) {
                                  _showSnackBar('اشتراک شما با موفقیت فعال شد!');
                                  Navigator.of(context).pop();
                                } else if (result.errorMessage != null) {
                                  _showSnackBar(result.errorMessage!, isError: true);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonBg,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: state.isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'خرید اشتراک (${activeSelectedProduct.title})',
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Security info
                    Center(
                      child: Text(
                        'پرداخت امن کافه بازار',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 11.5,
                          color: colorScheme.outline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
