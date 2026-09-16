import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/route_name.dart';
import '../../../../core/theme/app_typography.dart';

/// Minimal, clean VIP Subscription Required dialog.
/// Simple short text without icons, directing user to the subscriptions screen.
class VipRequiredDialog extends StatelessWidget {
  final String? reciterName;
  final bool isTranslation;
  final String? customTitle;
  final String? customMessage;

  const VipRequiredDialog({
    super.key,
    this.reciterName,
    this.isTranslation = false,
    this.customTitle,
    this.customMessage,
  });

  /// Displays the dialog cleanly, and if the user clicks "مشاهده اشتراک‌ها",
  /// navigates to the subscription screen and awaits the user's return.
  /// Returns `true` if the user navigated to the subscription screen, or `false` if dismissed/canceled.
  static Future<bool> show({
    required BuildContext context,
    String? reciterName,
    bool isTranslation = false,
    String? customTitle,
    String? customMessage,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => VipRequiredDialog(
        reciterName: reciterName,
        isTranslation: isTranslation,
        customTitle: customTitle,
        customMessage: customMessage,
      ),
    );

    if (result == true && context.mounted) {
      await context.pushNamed(vipSubscriptionRoute);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final titleText = customTitle ?? 'نیاز به اشتراک';

    final String messageText;
    if (customMessage != null) {
      messageText = customMessage!;
    } else if (reciterName != null && reciterName!.isNotEmpty) {
      messageText = isTranslation
          ? 'برای استفاده از این ترجمه گویا، نیاز به اشتراک دارید.'
          : 'برای استفاده از صوت این قاری، نیاز به اشتراک دارید.';
    } else {
      messageText = 'برای استفاده از این بخش، نیاز به اشتراک دارید.';
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.25),
            width: 0.8,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title (Clean & Simple, No icon)
              Text(
                titleText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 12),

              // Body Message (Short & Concise)
              Text(
                messageText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 13.5,
                  height: 1.45,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 20),

              // Action Buttons (No icon on primary button)
              Row(
                children: [
                  // Cancel button
                  Expanded(
                    flex: 1,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'انصراف',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.outline,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Primary button without icon
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'مشاهده اشتراک‌ها',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
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
