import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/extensions/string_extension.dart';
import '../../../../core/services/payment/models/payment_product.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../application/vip_subscription_controller.dart';
import '../../domain/models/vip_subscription_state.dart';
import '../widgets/subscription_plan_card.dart';

/// Minimalist VIP Subscription Screen accessible from Settings.
class VipSubscriptionScreen extends ConsumerStatefulWidget {
  const VipSubscriptionScreen({super.key});

  @override
  ConsumerState<VipSubscriptionScreen> createState() =>
      _VipSubscriptionScreenState();
}

class _VipSubscriptionScreenState extends ConsumerState<VipSubscriptionScreen> {
  PaymentProduct _selectedProduct = PaymentProduct.vipMonthly;

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
    final isDark = theme.brightness == Brightness.dark;

    final state = ref.watch(vipSubscriptionControllerProvider);
    final controller = ref.read(vipSubscriptionControllerProvider.notifier);
    final isVip = ref.watch(hasVipAccessProvider);
    final products = state.availableProducts;

    final activeSelectedProduct = products.firstWhere(
      (p) => p.id == _selectedProduct.id,
      orElse: () => products.isNotEmpty ? products.first : _selectedProduct,
    );

    final bgColor = isDark ? const Color(0xFF0F1615) : const Color(0xFFF7F5F0);
    final cardBg = isDark ? const Color(0xFF162220) : Colors.white;
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
              onPressed: () async {
                await controller.syncWithStore();
                await controller.fetchLiveProducts();
                _showSnackBar('وضعیت اشتراک با کافه بازار بررسی شد.');
              },
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomAction(
          context: context,
          isDark: isDark,
          state: state,
          isVip: isVip,
          activeSelectedProduct: activeSelectedProduct,
          controller: controller,
        ),
        body: RefreshIndicator(
          color: AppColors.primary,
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

              // Plan Cards List
              ...products.map((product) {
                final isSelected = product.id == activeSelectedProduct.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF0F766E).withValues(alpha: 0.35),
          width: 1.2,
        ),
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
                        color: isDark ? Colors.white70 : const Color(0xFF666666),
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

  /// Sticky Bottom Checkout Action Bar - Clean & Minimal
  Widget _buildBottomAction({
    required BuildContext context,
    required bool isDark,
    required VipSubscriptionState state,
    required bool isVip,
    required PaymentProduct activeSelectedProduct,
    required VipSubscriptionController controller,
  }) {
    final buttonBg = isDark ? const Color(0xFF0F766E) : AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF162220) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: state.isLoading
                ? null
                : () async {
                    final result = await controller
                        .purchaseSubscription(activeSelectedProduct);
                    if (result.isSuccess) {
                      _showSnackBar('اشتراک ویژه شما با موفقیت فعال گردید!');
                    } else if (!result.isCancelled &&
                        result.errorMessage != null) {
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            child: state.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    isVip ? 'تمدید اشتراک ویژه' : 'خرید اشتراک ویژه',
                    style: const TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
