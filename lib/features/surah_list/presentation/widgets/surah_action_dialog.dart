import 'package:flutter/material.dart';

import '../../../../common/extensions/surah_name_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/surah_entity.dart';

/// Clean reusable Surah Action Dialog asking user whether to Read Surah, Quick Download, or Manage Audio Download.
class SurahActionDialog extends StatelessWidget {
  final SurahEntity surah;
  final String surahFontFamily;
  final String? message;
  final VoidCallback onReadSurah;
  final VoidCallback onDownloadAudio;
  final VoidCallback? onQuickDownload;

  const SurahActionDialog({
    super.key,
    required this.surah,
    required this.surahFontFamily,
    this.message,
    required this.onReadSurah,
    required this.onDownloadAudio,
    this.onQuickDownload,
  });

  static Future<void> show({
    required BuildContext context,
    required SurahEntity surah,
    required String surahFontFamily,
    String? message,
    required VoidCallback onReadSurah,
    required VoidCallback onDownloadAudio,
    VoidCallback? onQuickDownload,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => SurahActionDialog(
        surah: surah,
        surahFontFamily: surahFontFamily,
        message: message,
        onReadSurah: onReadSurah,
        onDownloadAudio: onDownloadAudio,
        onQuickDownload: onQuickDownload,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text.rich(
        TextSpan(
          style: const TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          children: [
            const TextSpan(text: 'صوت سوره '),
            TextSpan(
              text: surah.nameFa,
              style: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 17,
                color: AppColors.goldAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
      content: Text(
        message ?? 'صوت این سوره به‌طور کامل موجود نیست. می‌توانید سوره را بخوانید و تا آیه دانلودشده گوش دهید.',
        style: const TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 14),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onReadSurah();
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'خواندن سوره',
                style: TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 12.5),
              ),
            ),
            const SizedBox(width: 4),
            if (onQuickDownload != null) ...[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onDownloadAudio();
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'مدیریت دانلود',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12.5,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onQuickDownload!();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'دانلود سریع',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onDownloadAudio();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'دانلود صوت',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
