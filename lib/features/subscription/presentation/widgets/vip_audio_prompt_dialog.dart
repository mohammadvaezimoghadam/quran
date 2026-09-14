import 'package:flutter/material.dart';

import '../../../../core/theme/app_typography.dart';
import '../ui/vip_subscription_sheet.dart';

/// Clean, minimal VIP prompt dialog when user requests a VIP reciter on a non-demo Surah.
class VipAudioPromptDialog extends StatelessWidget {
  final String reciterName;
  final String surahName;
  final VoidCallback? onPlayWithDefaultReciter;

  const VipAudioPromptDialog({
    super.key,
    required this.reciterName,
    required this.surahName,
    this.onPlayWithDefaultReciter,
  });

  /// Static helper to display this dialog cleanly
  static Future<void> show({
    required BuildContext context,
    required String reciterName,
    required String surahName,
    VoidCallback? onPlayWithDefaultReciter,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => VipAudioPromptDialog(
        reciterName: reciterName,
        surahName: surahName,
        onPlayWithDefaultReciter: onPlayWithDefaultReciter,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'نیاز به اشتراک',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        content: Text(
          'پخش تلاوت $surahName با صدای $reciterName نیازمند اشتراک است.',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 13.5,
            height: 1.5,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'انصراف',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 13,
                color: colorScheme.outline,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              VipSubscriptionSheet.show(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'مشاهده اشتراک‌ها',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
