import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/surah_entity.dart';

/// Clean reusable Surah Action Dialog asking user whether to Read Surah or Download Audio.
class SurahActionDialog extends StatelessWidget {
  final SurahEntity surah;
  final String surahFontFamily;
  final String? message;
  final VoidCallback onReadSurah;
  final VoidCallback onDownloadAudio;

  const SurahActionDialog({
    super.key,
    required this.surah,
    required this.surahFontFamily,
    this.message,
    required this.onReadSurah,
    required this.onDownloadAudio,
  });

  static Future<void> show({
    required BuildContext context,
    required SurahEntity surah,
    required String surahFontFamily,
    String? message,
    required VoidCallback onReadSurah,
    required VoidCallback onDownloadAudio,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => SurahActionDialog(
        surah: surah,
        surahFontFamily: surahFontFamily,
        message: message,
        onReadSurah: onReadSurah,
        onDownloadAudio: onDownloadAudio,
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
              text: surah.name,
              style: TextStyle(
                fontFamily: surahFontFamily,
                fontSize: 20,
                color: AppColors.goldAccent,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      content: Text(
        message ?? 'صوت این سوره به‌طور کامل موجود نیست. می‌توانید سوره را بخوانید و تا آیه دانلودشده گوش دهید.',
        style: const TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 14),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onReadSurah();
              },
              child: const Text(
                'خواندن سوره',
                style: TextStyle(fontFamily: AppTypography.fontFamily),
              ),
            ),
            const SizedBox(width: 4),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onDownloadAudio();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'دانلود صوت',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
