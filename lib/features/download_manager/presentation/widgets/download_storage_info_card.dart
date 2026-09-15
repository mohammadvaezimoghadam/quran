import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: colorScheme.error.withValues(
                        alpha: isDark ? 0.16 : 0.08,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'حذف همه',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.error,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Divider(
              height: 1,
              thickness: 0.6,
              color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.18 : 0.35),
            ),
            const SizedBox(height: 8),

            // Storage Path Row with Clean "کپی" Text Pill
            Row(
              children: [
                Expanded(
                  child: Text(
                    state.storagePath.isEmpty
                        ? 'مسیر: در حال خواندن...'
                        : 'مسیر: ${state.storagePath}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 11,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: state.storagePath.isEmpty
                      ? null
                      : () {
                          HapticFeedback.lightImpact();
                          Clipboard.setData(
                            ClipboardData(text: state.storagePath),
                          );
                          AppSnackBar.showSuccess(
                            context,
                            'مسیر ذخیره‌سازی کپی شد.',
                          );
                        },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(
                        alpha: isDark ? 0.14 : 0.08,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'کپی',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Divider(
              height: 1,
              thickness: 0.6,
              color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.18 : 0.35),
            ),
            const SizedBox(height: 6),

            // Wi-Fi Only Switch Tile
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'دانلود فقط با اتصال وای‌فای',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'عدم مصرف اینترنت سیم‌کارت',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 10.5,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
                CupertinoSwitch(
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
