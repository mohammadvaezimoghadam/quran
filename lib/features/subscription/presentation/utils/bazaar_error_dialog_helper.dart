import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/extensions/context_extension.dart';
import '../../../../common/widgets/app_snackbar.dart';
import '../../../../core/services/payment/models/payment_product.dart';
import '../../../../core/services/payment/payment_providers.dart';
import '../../../../core/theme/app_typography.dart';
import '../../application/vip_subscription_controller.dart';

/// User-friendly error dialog for Cafe Bazaar purchase failures,
/// with developer quick-action to enable Mock Mode when testing on emulators.
abstract class BazaarErrorDialogHelper {
  static Future<void> show({
    required BuildContext context,
    required WidgetRef ref,
    required String errorMessage,
    required PaymentProduct product,
    VoidCallback? onSuccess,
  }) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Header
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.exclamationmark_triangle_fill,
                  color: Colors.amber,
                  size: 26,
                ),
              ),
              const SizedBox(height: 14),

              // Title
              Text(
                'عدم اتصال به کافه بازار',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(dialogCtx).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),

              // Error Message
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 13,
                  height: 1.5,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),

              // Developer Emulator Mock Hint in Debug Mode
              if (kDebugMode) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.blueGrey.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.wrench,
                        size: 16,
                        color: Colors.blueGrey,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'تست روی شبیه‌ساز: کافه بازار روی این شبیه‌ساز نیست. می‌توانید حالت تستی (Mock) را برای ادامه بررسی فعال کنید.',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 11,
                            color: isDark ? Colors.white60 : Colors.black54,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 18),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(dialogCtx).pop(),
                      child: Text(
                        'بستن',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 13.5,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                  if (kDebugMode) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: dialogCtx.colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.of(dialogCtx).pop();
                          // Enable Mock Mode for developer testing on emulator
                          ref.read(isMockPaymentProvider.notifier).setMockMode(true);

                          AppSnackBar.showSuccess(
                            context,
                            'حالت شبیه‌ساز پرداخت فعال شد. در حال انجام خرید تستی...',
                          );

                          final result = await ref
                              .read(vipSubscriptionControllerProvider.notifier)
                              .purchaseSubscription(product);

                          if (result.isSuccess && context.mounted) {
                            AppSnackBar.showSuccess(
                              context,
                              'اشتراک ویژه تستی با موفقیت فعال شد!',
                            );
                            onSuccess?.call();
                          }
                        },
                        child: const Text(
                          'خرید تستی',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
