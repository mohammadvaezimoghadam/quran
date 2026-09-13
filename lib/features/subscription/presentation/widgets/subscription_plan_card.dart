import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../core/services/payment/models/payment_product.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class SubscriptionPlanCard extends StatelessWidget {
  final PaymentProduct product;
  final bool isSelected;
  final VoidCallback onTap;

  const SubscriptionPlanCard({
    super.key,
    required this.product,
    required this.isSelected,
    required this.onTap,
  });

  String _formatPrice(int amount) {
    final formatter = NumberFormat('#,###', 'fa');
    return '${formatter.format(amount)} تومان';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final primaryColor = isDark ? const Color(0xFF52C498) : AppColors.primary;
    final cardBg = isSelected
        ? primaryColor.withValues(alpha: isDark ? 0.12 : 0.08)
        : (isDark ? const Color(0xFF222629) : const Color(0xFFF7F6F2));

    final borderColor = isSelected
        ? primaryColor
        : colorScheme.outlineVariant.withValues(alpha: isDark ? 0.25 : 0.4);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 1.6 : 1.0,
            ),
          ),
          child: Row(
            children: [
              // Clean radio indicator without decorative icons
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? primaryColor : colorScheme.outlineVariant,
                    width: 1.8,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryColor,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              // Plan title & optional discount badge in Column (100% overflow proof)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        fontSize: 13.5,
                        color: isSelected ? primaryColor : colorScheme.onSurface,
                      ),
                    ),
                    if (product.discountBadge != null) ...[
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: isDark ? 0.25 : 0.12),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          product.discountBadge!,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Price
              Text(
                _formatPrice(product.priceToman),
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isSelected ? primaryColor : colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
