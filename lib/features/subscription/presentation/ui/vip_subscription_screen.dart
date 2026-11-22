import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/extensions/context_extension.dart';
import '../../../../common/extensions/int_extension.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../core/routes/route_name.dart';
import '../../../../core/services/analytics/analytics_providers.dart';
import '../../../../core/services/payment/models/payment_product.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../tafakor/application/controllers/tafakor_auth_controller.dart';
import '../../application/vip_subscription_controller.dart';
import '../utils/bazaar_error_dialog_helper.dart';

/// Modern iOS-styled VIP Subscription Screen with 3 side-by-side vertical cards
/// and a single primary action button.
class VipSubscriptionScreen extends ConsumerStatefulWidget {
  const VipSubscriptionScreen({super.key});

  @override
  ConsumerState<VipSubscriptionScreen> createState() =>
      _VipSubscriptionScreenState();
}

class _VipSubscriptionScreenState extends ConsumerState<VipSubscriptionScreen> {
  String? _purchasingProductId;
  PaymentProduct? _selectedProduct;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(analyticsServiceProvider).logVipView();
      ref.read(vipSubscriptionControllerProvider.notifier).syncWithTafakorBackend();
      ref.read(vipSubscriptionControllerProvider.notifier).syncWithStore();
      ref.read(vipSubscriptionControllerProvider.notifier).fetchLiveProducts();
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
    final isAuth = ref.read(isTafakorAuthenticatedProvider);
    if (!isAuth) {
      final shouldLogin = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('ورود به حساب کاربری', textDirection: TextDirection.rtl),
          content: const Text(
            'برای ثبت و ماندگاری اشتراک در حساب کاربری شما و امکان استفاده در سایر دستگاه‌ها، لطفاً ابتدا وارد حساب خود شوید.',
            textDirection: TextDirection.rtl,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('انصراف'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('ورود با شماره موبایل'),
            ),
          ],
        ),
      );
      if (shouldLogin == true && mounted) {
        context.pushNamed(tafakorLoginRoute);
      }
      return;
    }

    setState(() {
      _purchasingProductId = product.id;
    });

    try {
      final result = await controller.purchaseSubscription(product);
      if (!mounted) return;

      if (result.isSuccess) {
        _showSnackBar('اشتراک ویژه شما با موفقیت فعال گردید!');
      } else if (result.isAlreadyOwned) {
        _showSnackBar('این اشتراک قبلاً خریداری شده است. در حال همگام‌سازی...');
        final restored = await controller.restorePurchases();
        if (mounted) {
          if (restored) {
            _showSnackBar('اشتراک ویژه شما با موفقیت فعال گردید!');
          } else {
            await BazaarErrorDialogHelper.show(
              context: context,
              ref: ref,
              title: 'اشتراک قبلاً خریداری شده',
              errorMessage:
                  'این اشتراک در حساب بازار شما ثبت است اما با سرور همگام نشد. لطفاً گزینه «بازیابی خریدهای قبلی» را لمس کنید.',
              product: product,
            );
          }
        }
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

  String _getShortTitle(PaymentProduct p) {
    if (p.subscriptionPlan == SubscriptionPlan.monthly) return '۱ ماهه';
    if (p.subscriptionPlan == SubscriptionPlan.quarterly) return '۳ ماهه';
    if (p.subscriptionPlan == SubscriptionPlan.semiAnnual) return '۶ ماهه';
    if (p.subscriptionPlan == SubscriptionPlan.yearly) return '۱ ساله';
    return p.title.replaceAll('اشتراک', '').trim();
  }

  String _getDurationSubtitle(PaymentProduct p) {
    if (p.subscriptionPlan == SubscriptionPlan.monthly) return 'دسترسی ۳۰ روزه';
    if (p.subscriptionPlan == SubscriptionPlan.quarterly) return 'دسترسی ۹۰ روزه';
    if (p.subscriptionPlan == SubscriptionPlan.semiAnnual) return 'دسترسی ۱۸۰ روزه';
    if (p.subscriptionPlan == SubscriptionPlan.yearly) return 'دسترسی ۳۶۵ روزه';
    return '${p.durationDays ?? 30} روزه';
  }

  String? _getBadgeText(PaymentProduct p) {
    if (p.isRecommended) return 'پیشنهادی';
    if (p.discountBadge != null && p.discountBadge!.isNotEmpty) {
      return p.discountBadge;
    }
    return null;
  }

  Widget _buildVerticalPlanCard({
    required PaymentProduct product,
    required bool isSelected,
    required bool isVip,
    required bool isCurrentActive,
    required ColorScheme colorScheme,
    required Color cardBg,
    required Color borderColor,
  }) {
    final badge = _getBadgeText(product);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _selectedProduct = product;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? colorScheme.primary : borderColor,
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.28),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Badge slot (fixed height for strict alignment)
              SizedBox(
                height: 22,
                child: badge != null
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.22)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected
                              ? null
                              : Border.all(
                                  color: borderColor,
                                  width: 0.8,
                                ),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              8.vSpace,
              // Title
              Text(
                _getShortTitle(product),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : colorScheme.onSurface,
                ),
              ),
              4.vSpace,
              // Duration Subtitle
              Text(
                _getDurationSubtitle(product),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 10.5,
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.85)
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              14.vSpace,
              // Price Number with superscript/top-right "تومان"
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  textDirection: TextDirection.rtl,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0, left: 3.5),
                      child: Text(
                        'تومان',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.85)
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Text(
                      product.priceToman.toPersianFormatted(),
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                        color: isSelected ? Colors.white : colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isCurrentActive) ...[
                6.vSpace,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.25)
                        : colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'پلن فعال',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = context.colorScheme;
    final colors = context.colors;

    final state = ref.watch(vipSubscriptionControllerProvider);
    final controller = ref.read(vipSubscriptionControllerProvider.notifier);
    final isVip = ref.watch(hasVipAccessProvider);

    final rawProducts = state.availableProducts;
    final displayedProducts = rawProducts.isNotEmpty
        ? rawProducts.take(3).toList()
        : PaymentProduct.allSubscriptions;

    // Pick selected product (fallback to recommended or first)
    final selectedProduct = _selectedProduct ??
        displayedProducts.firstWhere(
          (p) => p.isRecommended,
          orElse: () => displayedProducts.length > 1
              ? displayedProducts[1]
              : displayedProducts.first,
        );

    final bgColor = theme.scaffoldBackgroundColor;
    final cardBg = colors.cardBackground;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1B1B);

    final isThisPurchasing =
        state.isLoading && _purchasingProductId == selectedProduct.id;
    final isAnyPurchasing = state.isLoading;

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
          color: colorScheme.primary,
          onRefresh: () async {
            await controller.syncWithStore();
            await controller.fetchLiveProducts();
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 24,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 3 Side-by-Side Vertical Rectangular Subscription Cards
                            IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  for (int i = 0; i < displayedProducts.length; i++) ...[
                                    if (i > 0) 8.hSpace,
                                    _buildVerticalPlanCard(
                                      product: displayedProducts[i],
                                      isSelected:
                                          selectedProduct.id == displayedProducts[i].id,
                                      isVip: isVip,
                                      isCurrentActive: isVip &&
                                          state.activePlanId == displayedProducts[i].id,
                                      colorScheme: colorScheme,
                                      cardBg: cardBg,
                                      borderColor: colors.cardBorder,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            24.vSpace,

                            // Clean Benefits Texts without box and without icons (Right-aligned)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'دسترسی کامل به آرشیو تمامی قاریان برجسته جهان اسلام',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 12.5,
                                      height: 1.6,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  4.vSpace,
                                  Text(
                                    'پخش ترجمه صوتی گویای فارسی آیه به آیه',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 12.5,
                                      height: 1.6,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  4.vSpace,
                                  Text(
                                    'تفاسیر معتبر و واژه‌شناسی لغت به لغت قرآن کریم',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 12.5,
                                      height: 1.6,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  4.vSpace,
                                  Text(
                                    'اصوات آرامش‌بخش محیطی و افکت‌های صوتی پیشرفته',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 12.5,
                                      height: 1.6,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            16.vSpace,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Center(
            heightFactor: 1.0,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isAnyPurchasing
                            ? null
                            : () => _handlePurchase(selectedProduct, controller),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isThisPurchasing
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                isVip
                                    ? 'تمدید اشتراک ${_getShortTitle(selectedProduct)} • ${selectedProduct.priceToman.toPersianFormatted()} تومان'
                                    : 'خرید اشتراک ${_getShortTitle(selectedProduct)} • ${selectedProduct.priceToman.toPersianFormatted()} تومان',
                                style: const TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    8.vSpace,
                    Text(
                      'پرداخت امن از طریق کافه بازار • بدون تمدید خودکار • فعال‌سازی آنی',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
