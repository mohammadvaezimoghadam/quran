import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/route_name.dart';
import '../../../../core/theme/app_typography.dart';

/// Clean Apple-style VIP Subscription Required dialog.
/// Displays an elegant prompt informing the user of the subscription requirement
/// with a direct action to navigate to the Subscriptions screen.
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

  /// Displays the dialog cleanly
  static Future<void> show({
    required BuildContext context,
    String? reciterName,
    bool isTranslation = false,
    String? customTitle,
    String? customMessage,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => VipRequiredDialog(
        reciterName: reciterName,
        isTranslation: isTranslation,
        customTitle: customTitle,
        customMessage: customMessage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final titleText = customTitle ?? 'نیاز به اشتراک ویژه';

    final String messageText;
    if (customMessage != null) {
      messageText = customMessage!;
    } else if (reciterName != null && reciterName!.isNotEmpty) {
      if (isTranslation) {
        messageText =
            'استفاده از ترجمه گویای «$reciterName» نیازمند اشتراک ویژه است.\nبرای دسترسی به تمامی قاریان و ترجمه‌های گویا، می‌توانید اشتراک ویژه تهیه کنید.';
      } else {
        messageText =
            'استفاده از تلاوت «$reciterName» نیازمند اشتراک ویژه است.\nبرای دسترسی به تمامی قاریان و صوت‌ها، می‌توانید اشتراک ویژه تهیه کنید.';
      }
    } else {
      messageText =
          'برای دسترسی به این بخش، نیاز به تهیه اشتراک ویژه دارید.\nبا تهیه اشتراک، به تمامی قاریان، ترجمه‌های گویا و امکانات اختصاصی دسترسی خواهید داشت.';
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.25),
            width: 0.8,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 12,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Star badge circle
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.25),
                    width: 1.2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    CupertinoIcons.star_circle_fill,
                    size: 32,
                    color: colorScheme.primary,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Title
              Text(
                titleText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 16.5,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 10),

              // Body Message
              Text(
                messageText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 13.0,
                  height: 1.55,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 22),

              // Action Buttons
              Row(
                children: [
                  // Cancel / Dismiss button
                  Expanded(
                    flex: 1,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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

                  const SizedBox(width: 10),

                  // Go to Subscriptions button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.pushNamed(vipSubscriptionRoute);
                      },
                      icon: const Icon(
                        CupertinoIcons.arrow_left,
                        size: 15,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'مشاهده اشتراک‌ها',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
