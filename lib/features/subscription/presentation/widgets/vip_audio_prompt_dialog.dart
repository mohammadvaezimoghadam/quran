import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../../../../common/widgets/app_modal_header.dart';
import '../../../../core/routes/route_name.dart';
import '../../../../core/theme/app_typography.dart';

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
      builder: (ctx) => VipAudioPromptDialog(
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
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 16, left: 16, right: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppModalHeader(
                title: 'نیاز به اشتراک',
                bottomSpacing: 8,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'پخش تلاوت $surahName با صدای $reciterName نیازمند اشتراک است.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 13.5,
                    height: 1.5,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
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
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.pushNamed(vipSubscriptionRoute);
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
            ],
          ),
        ),
      ),
    );
  }
}
