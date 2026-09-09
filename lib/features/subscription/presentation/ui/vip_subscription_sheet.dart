import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/payment/models/payment_product.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../application/vip_subscription_controller.dart';
import '../widgets/nazr_donation_card.dart';
import '../widgets/subscription_plan_card.dart';
import '../widgets/vip_benefits_list.dart';

/// Bottom sheet presenting the VIP subscription paywall and cultural donation options.
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

class _VipSubscriptionSheetState extends ConsumerState<VipSubscriptionSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  PaymentProduct _selectedProduct = PaymentProduct.vipYearly;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: AppTypography.fontFamily),
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: isError ? AppColors.error : AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vipSubscriptionControllerProvider);
    final controller = ref.read(vipSubscriptionControllerProvider.notifier);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // Drag handle & Header
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.goldMetallic.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      color: AppColors.goldDarkBorder,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'اشتراک ویژه قرآن تفکر',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          'همراهی معنوی و دسترسی به امکانات پیشرفته',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Active Subscription / Trial Status Banner
            if (state.hasVipAccess)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (state.isVip ? Colors.green : Colors.amber)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (state.isVip ? Colors.green : Colors.amber)
                        .withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      state.isVip
                          ? Icons.check_circle_rounded
                          : Icons.hourglass_top_rounded,
                      color: state.isVip ? Colors.green : Colors.amber[800],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.isVip
                            ? (state.vipExpiryDate == null
                                ? 'اشتراک مادام‌العمر شما فعال است.'
                                : 'اشتراک VIP فعال است (${state.remainingDays} روز باقی مانده)')
                            : 'مهلت تست ۳ روزه فعال است (${state.remainingDays} روز باقی مانده)',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: state.isVip ? Colors.green[800] : Colors.amber[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Free 3-Day Trial Prompt if not used and not VIP
            if (!state.hasVipAccess && !state.isTrialUsed)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.goldMetallic.withValues(alpha: 0.18),
                      AppColors.primary.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.goldAccent.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.card_giftcard_rounded,
                      color: AppColors.goldDarkBorder,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'هدیه اولین ورود: ۳ روز تست رایگان VIP',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            'تمام امکانات ویژه را ۳ روز بدون هزینه تجربه کنید',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 10.5,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: state.isLoading
                          ? null
                          : () async {
                              final success = await controller.activateFreeTrial();
                              if (success) {
                                _showSnackBar('مهلت ۳ روزه تست رایگان VIP با موفقیت فعال شد! 🎉');
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.goldDarkBorder,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'فعال‌سازی',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Tab Bar: Plans vs Nazr
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.onSurfaceVariant,
                labelStyle: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                tabs: const [
                  Tab(text: '💎 پلن‌های اشتراک'),
                  Tab(text: '💚 نذر و حمایت فرهنگی'),
                ],
              ),
            ),

            // Tab View Body
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Subscriptions
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const VipBenefitsList(),
                      const SizedBox(height: 16),
                      const Text(
                        'انتخاب دوره اشتراک:',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...PaymentProduct.allSubscriptions.map(
                        (product) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: SubscriptionPlanCard(
                            product: product,
                            isSelected: _selectedProduct.id == product.id,
                            onTap: () {
                              setState(() {
                                _selectedProduct = product;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Tab 2: Nazr / Donation
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.teal.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.teal.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.volunteer_activism_rounded,
                              color: Colors.teal,
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'مشارکت در طرح نذر فرهنگی قرآنی به تداوم توسعه، تولید محتوای صوتی باکیفیت و رایگان ماندن خدمات پایه کمک می‌کند. به پاس قدردانی، اشتراک VIP به عنوان هدیه برای شما فعال خواهد شد.',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 12,
                                  height: 1.6,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...PaymentProduct.allNazrPackages.map(
                        (product) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: NazrDonationCard(
                            product: product,
                            onDonate: state.isLoading
                                ? () {}
                                : () async {
                                    final result = await controller.purchaseNazr(product);
                                    if (result.isSuccess) {
                                      _showSnackBar('از نذر و حمایت معنوی شما سپاسگزاریم! اشتراک هدیه VIP فعال شد. 🌟');
                                    } else if (!result.isCancelled) {
                                      _showSnackBar(result.errorMessage ?? 'خطا در پرداخت', isError: true);
                                    }
                                  },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Bottom Actions: Purchase Button & Restore
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: state.isLoading
                          ? null
                          : () async {
                              final result =
                                  await controller.purchaseSubscription(_selectedProduct);
                              if (result.isSuccess) {
                                _showSnackBar('اشتراک VIP با موفقیت فعال شد! 🎉');
                              } else if (!result.isCancelled) {
                                _showSnackBar(
                                  result.errorMessage ?? 'خطا در فعال‌سازی اشتراک',
                                  isError: true,
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: state.isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'خرید و فعال‌سازی ${_selectedProduct.title}',
                              style: const TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: state.isLoading
                        ? null
                        : () async {
                            final restored = await controller.restorePurchases();
                            if (restored) {
                              _showSnackBar('خریدهای قبلی شما با موفقیت بازیابی شد.');
                            } else {
                              _showSnackBar('خریدی برای بازیابی یافت نشد.');
                            }
                          },
                    child: const Text(
                      'بازیابی خریدهای قبلی',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
