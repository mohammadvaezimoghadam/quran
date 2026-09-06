import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/widgets/app_snackbar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../application/controllers/download_hub_controller.dart';
import '../../application/states/download_hub_state.dart';

class DownloadStorageInfoCard extends ConsumerWidget {
  final DownloadHubState state;

  const DownloadStorageInfoCard({
    super.key,
    required this.state,
  });

  void _showClearCacheDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text(
          'پاک‌سازی کل فایل‌های دانلودی',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: const Text(
          'آیا از حذف تمام فایل‌های دانلود شده (صوت قرآن، ترجمه گویا و متن ترجمه‌ها) از حافظه دستگاه اطمینان دارید؟ این عملیات غیرقابل بازگشت است.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('انصراف'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBgColor = isDark ? const Color(0xFF192220) : Colors.white;
    final cardBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFEAE7E3);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: cardBorderColor, width: 1),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16.0,
                  offset: const Offset(0, 4.0),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Storage Icon + Stats
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.goldAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    CupertinoIcons.square_stack_3d_up_fill,
                    color: AppColors.goldAccent,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'فضای ذخیره‌سازی محلی',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'حجم فایل‌های ذخیره شده: ${state.formattedStorageSize}',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'پاک‌سازی کل دانلودها',
                  icon: const Icon(CupertinoIcons.trash, color: AppColors.error, size: 20),
                  onPressed: () => _showClearCacheDialog(context, ref),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Storage Path Display with Copy Action
            Text(
              'مسیر ذخیره در دستگاه:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.25)
                    : const Color(0xFFF7F5F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? Colors.white10 : const Color(0xFFE4DFD7),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Text(
                        state.storagePath.isEmpty
                            ? 'در حال خواندن مسیر...'
                            : state.storagePath,
                        textDirection: TextDirection.ltr,
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: state.storagePath.isEmpty
                        ? null
                        : () {
                            Clipboard.setData(
                              ClipboardData(text: state.storagePath),
                            );
                            AppSnackBar.showSuccess(
                              context,
                              'مسیر ذخیره‌سازی کپی شد.',
                            );
                          },
                    borderRadius: BorderRadius.circular(6),
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(
                        CupertinoIcons.doc_on_clipboard,
                        size: 16,
                        color: AppColors.goldAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Wi-Fi Only Switch Tile
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () async {
                final newVal = !state.isWifiOnly;
                await ref
                    .read(downloadHubControllerProvider.notifier)
                    .toggleWifiOnly(newVal);
                if (context.mounted) {
                  if (newVal) {
                    AppSnackBar.showSuccess(
                      context,
                      'دانلود فقط با اتصال وای‌فای (Wi-Fi) فعال شد.',
                    );
                  } else {
                    AppSnackBar.showInfo(
                      context,
                      'دانلود با اینترنت سیم‌کارت (دیتا) مجاز شد.',
                    );
                  }
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'دانلود فقط با اتصال وای‌فای (Wi-Fi)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'جلوگیری از مصرف بسته اینترنت سیم‌کارت',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CupertinoSwitch(
                      activeTrackColor: AppColors.primary,
                      value: state.isWifiOnly,
                      onChanged: (val) async {
                        await ref
                            .read(downloadHubControllerProvider.notifier)
                            .toggleWifiOnly(val);
                        if (context.mounted) {
                          if (val) {
                            AppSnackBar.showSuccess(
                              context,
                              'دانلود فقط با اتصال وای‌فای (Wi-Fi) فعال شد.',
                            );
                          } else {
                            AppSnackBar.showInfo(
                              context,
                              'دانلود با اینترنت سیم‌کارت (دیتا) مجاز شد.',
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
