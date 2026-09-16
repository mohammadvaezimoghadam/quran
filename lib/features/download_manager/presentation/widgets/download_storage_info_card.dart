import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/extensions/context_extension.dart';
import '../../../../common/widgets/app_snackbar.dart';
import '../../../../core/theme/app_typography.dart';
import '../../application/controllers/download_hub_controller.dart';
import '../../application/states/download_hub_state.dart';

class DownloadStorageInfoCard extends ConsumerWidget {
  final DownloadHubState state;

  const DownloadStorageInfoCard({
    super.key,
    required this.state,
  });

  void _showClearCacheDialog(BuildContext context, WidgetRef ref) {
    showCupertinoDialog(
      context: context,
      builder: (dialogCtx) => CupertinoAlertDialog(
        title: const Text(
          'پاک‌سازی کل فایل‌های دانلودی',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(
            'آیا از حذف تمام فایل‌های دانلود شده (صوت قرآن، ترجمه گویا و متن ترجمه‌ها) از حافظه دستگاه اطمینان دارید؟ این عملیات غیرقابل بازگشت است.',
            style: TextStyle(fontSize: 13, height: 1.5),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('انصراف'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await ref
                  .read(downloadHubControllerProvider.notifier)
                  .clearAllDownloads();
              if (context.mounted) {
                AppSnackBar.showSuccess(
                  context,
                  'تمامی فایل‌های دانلودی با موفقیت پاک‌سازی شدند.',
                );
              }
            },
            child: const Text('حذف همه'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;
    final isDark = context.isDark;

    final cardBgColor = colors.cardBackground;
    final cardBorderColor = colors.cardBorder;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 6.0,
      ),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cardBorderColor, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Storage Stats + Clean "حذف همه" Text Pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'فضای ذخیره‌سازی محلی',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'حجم فایل‌های ذخیره شده: ${state.formattedStorageSize}',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => _showClearCacheDialog(context, ref),
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Text(
                      'حذف همه',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.error,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Divider(
              height: 1,
              thickness: 0.5,
              color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.18 : 0.35),
            ),
            const SizedBox(height: 6),

            // Wi-Fi Only Switch Row (Compact, no caption)
            Row(
              children: [
                Expanded(
                  child: Text(
                    'دانلود فقط با اتصال وای‌فای',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                SizedBox(
                  height: 24,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: CupertinoSwitch(
                      activeTrackColor: colorScheme.primary,
                      value: state.isWifiOnly,
                      onChanged: (val) async {
                        await ref
                            .read(downloadHubControllerProvider.notifier)
                            .toggleWifiOnly(val);
                        if (context.mounted) {
                          if (val) {
                            AppSnackBar.showSuccess(
                              context,
                              'دانلود فقط با اتصال وای‌فای فعال شد.',
                            );
                          } else {
                            AppSnackBar.showInfo(
                              context,
                              'دانلود با اینترنت سیم‌کارت مجاز شد.',
                            );
                          }
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
    );
  }
}
