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
    final isGold = product.isRecommended;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? (isGold
                    ? AppColors.goldMetallic.withValues(alpha: 0.1)
                    : AppColors.primary.withValues(alpha: 0.08))
                : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? (isGold ? AppColors.goldDarkBorder : AppColors.primary)
                  : (isGold
                      ? AppColors.goldAccent.withValues(alpha: 0.5)
                      : AppColors.outlineVariant.withValues(alpha: 0.5)),
              width: isSelected || isGold ? 2.0 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: (isGold ? AppColors.goldAccent : AppColors.primary)
                          .withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? (isGold ? AppColors.goldDarkBorder : AppColors.primary)
                            : AppColors.outlineVariant,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isGold ? AppColors.goldDarkBorder : AppColors.primary,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              product.title,
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isGold ? AppColors.goldDarkBorder : AppColors.onSurface,
                              ),
                            ),
                            if (product.discountBadge != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isGold
                                      ? AppColors.goldMetallic
                                      : AppColors.primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  product.discountBadge!,
                                  style: const TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          product.description,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatPrice(product.priceToman),
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isGold ? AppColors.goldDarkBorder : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
