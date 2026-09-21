import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../common/extensions/surah_name_extension.dart';
import '../../../../common/widgets/app_cached_network_image.dart';
import '../../../../common/widgets/app_modal_header.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../quran_reader/domain/entities/reciter_entity.dart';
import '../../domain/entities/surah_entity.dart';

/// Clean reusable Surah Action Dialog asking user whether to Read Surah, Quick Download, or Manage Audio Download.
class SurahActionDialog extends StatelessWidget {
  final SurahEntity surah;
  final String surahFontFamily;
  final String? message;
  final ReciterEntity? reciter;
  final bool isTranslation;
  final VoidCallback onReadSurah;
  final VoidCallback onDownloadAudio;
  final VoidCallback? onQuickDownload;
  final VoidCallback? onPlayOnlyQuran;

  const SurahActionDialog({
    super.key,
    required this.surah,
    required this.surahFontFamily,
    this.message,
    this.reciter,
    this.isTranslation = false,
    required this.onReadSurah,
    required this.onDownloadAudio,
    this.onQuickDownload,
    this.onPlayOnlyQuran,
  });

  static Future<void> show({
    required BuildContext context,
    required SurahEntity surah,
    required String surahFontFamily,
    String? message,
    ReciterEntity? reciter,
    bool isTranslation = false,
    required VoidCallback onReadSurah,
    required VoidCallback onDownloadAudio,
    VoidCallback? onQuickDownload,
    VoidCallback? onPlayOnlyQuran,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => SurahActionDialog(
        surah: surah,
        surahFontFamily: surahFontFamily,
        message: message,
        reciter: reciter,
        isTranslation: isTranslation,
        onReadSurah: onReadSurah,
        onDownloadAudio: onDownloadAudio,
        onQuickDownload: onQuickDownload,
        onPlayOnlyQuran: onPlayOnlyQuran,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final titlePrefix = isTranslation ? 'صوت ترجمه گویای سوره ' : 'صوت تلاوت سوره ';
    final downloadButtonLabel = isTranslation ? 'دانلود ترجمه گویا' : 'دانلود صوت';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 12, left: 16, right: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppModalHeader(
              leadingAction: reciter != null
                  ? Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                          width: 1.0,
                        ),
                      ),
                      child: ClipOval(
                        child: AppCachedNetworkImage.circle(
                          imageUrl: reciter?.imageUrl,
                          size: 36,
                          fallbackIcon: isTranslation
                              ? CupertinoIcons.speaker_2_fill
                              : CupertinoIcons.person_fill,
                        ),
                      ),
                    )
                  : null,
              titleWidget: Text.rich(
                TextSpan(
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(text: titlePrefix),
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
              bottomSpacing: 8,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                message ??
                    'صوت این سوره به‌طور کامل موجود نیست. می‌توانید سوره را بخوانید و تا آیه دانلودشده گوش دهید.',
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 13.5,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              runSpacing: 6,
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
                if (isTranslation && onPlayOnlyQuran != null)
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onPlayOnlyQuran!();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'فقط صوت قاری',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
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
                    child: Text(
                      downloadButtonLabel,
                      style: const TextStyle(
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
        ),
      ),
    );
  }
}
