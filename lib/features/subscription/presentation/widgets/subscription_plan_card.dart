import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../common/extensions/context_extension.dart';
import '../../../../core/services/payment/models/payment_product.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';

/// Clean, borderless subscription plan card with no radio buttons
/// and an individual state-managed purchase action button.
class SubscriptionPlanCard extends StatelessWidget {
  final PaymentProduct product;
  final VoidCallback? onPurchase;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isLoading;
  final bool isDisabled;
  final bool isVip;
  final String? buttonText;

  const SubscriptionPlanCard({
    super.key,
    required this.product,
    this.onPurchase,
    this.onTap,
    this.isSelected = false,
    this.isLoading = false,
    this.isDisabled = false,
    this.isVip = false,
    this.buttonText,
  });

  String _formatPrice(int amount) {
    final formatter = NumberFormat('#,###', 'fa');
    return '${formatter.format(amount)} تومان';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;
    final isDark = context.isDark;
    final primaryColor = colorScheme.primary;

    final handleAction = onPurchase ?? onTap;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: (isLoading || isDisabled) ? null : () => handleAction?.call(),
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: colors.cardBackground,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            // Border is intentionally omitted per user request
          ),
          child: Row(
            children: [
              // Plan title, discount badge & price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          product.title,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.0,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        if (product.discountBadge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(
                                alpha: isDark ? 0.22 : 0.12,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              product.discountBadge!,
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _formatPrice(product.priceToman),
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                        color: isDark ? Colors.white70 : const Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Individual state-managed purchase button
              SizedBox(
                height: 36,
                child: ElevatedButton(
                  onPressed: (isLoading || isDisabled)
                      ? null
                      : () => handleAction?.call(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        primaryColor.withValues(alpha: 0.35),
                    disabledForegroundColor:
                        Colors.white.withValues(alpha: 0.7),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          buttonText ?? (isVip ? 'تمدید' : 'خرید'),
                          style: const TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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
