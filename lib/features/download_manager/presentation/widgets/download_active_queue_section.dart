import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/constants/surah_constants.dart';
import '../../../../common/extensions/int_extension.dart';
import '../../../../common/extensions/context_extension.dart';
import '../../../../common/widgets/app_cached_network_image.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../audio_manager/application/controllers/audio_download_controller.dart';
import '../../../audio_manager/domain/entities/audio_download_task.dart';
import '../../../quran_reader/application/controllers/reciter_providers.dart';
import '../../../quran_reader/domain/entities/reciter_entity.dart';
import '../../../translation_manager/application/controllers/translation_manager_controller.dart';
import '../../../translation_manager/domain/entities/translation_entity.dart';

class DownloadActiveQueueSection extends ConsumerStatefulWidget {
  const DownloadActiveQueueSection({super.key});

  @override
  ConsumerState<DownloadActiveQueueSection> createState() =>
      _DownloadActiveQueueSectionState();
}

class _DownloadActiveQueueSectionState
    extends ConsumerState<DownloadActiveQueueSection> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 1. Audio Tasks (Quran audio and audio translations)
    final tasksMap = ref.watch(audioDownloadControllerProvider);
    final audioQueueTasks = tasksMap.values.where((task) {
      return task.status == DownloadTaskStatus.downloading ||
          task.status == DownloadTaskStatus.paused ||
          task.status == DownloadTaskStatus.failed;
    }).toList();

    // 2. Text Translation Tasks
    final translationState = ref.watch(translationManagerControllerProvider).value;
    final activeTranslationProgress = translationState?.downloadProgress ?? {};
    final allTranslations = translationState?.translations ?? [];
    final downloadingTranslationIds = activeTranslationProgress.keys.toList();

    // 3. Reciters catalog to distinguish Quran audio from Audio Translation
    final allReciters = ref.watch(allRecitersListProvider).asData?.value.tryGetSuccess() ?? [];

    final totalCount = audioQueueTasks.length + downloadingTranslationIds.length;

    final colors = context.colors;
    final cardBgColor = colors.cardBackground;
    final cardBorderColor = colors.cardBorder;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: cardBorderColor, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Clean text title, count badge, and collapse toggle
            InkWell(
              onTap: totalCount > 0
                  ? () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    }
                  : null,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  children: [
                    Text(
                      'صف دانلودهای جاری',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    if (totalCount > 0) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: context.colorScheme.primary.withValues(
                            alpha: isDark ? 0.16 : 0.08,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${totalCount.toPersianDigit()} مورد',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: context.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: context.colorScheme.outlineVariant.withValues(
                            alpha: isDark ? 0.20 : 0.12,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _isExpanded ? 'بستن' : 'نمایش',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Empty State: Simple, clean text without giant icon
            if (totalCount == 0) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Center(
                  child: Text(
                    'در حال حاضر هیچ دانلودی در صف نیست.',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12.5,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                ),
              ),
            ] else
              AnimatedCrossFade(
                firstChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: totalCount,
                      separatorBuilder: (context, index) => const Divider(height: 18),
                      itemBuilder: (context, index) {
                        // Display audio tasks first, then text translation tasks
                        if (index < audioQueueTasks.length) {
                          final task = audioQueueTasks[index];
                          final surahName = SurahConstants.getSurahName(task.surahId);
                          final reciter = allReciters
                              .where((r) => r.id == task.reciterId)
                              .firstOrNull;

                          return _AudioQueueTaskItem(
                            task: task,
                            surahName: surahName,
                            reciter: reciter,
                            isDark: isDark,
                          );
                        } else {
                          final translationIndex = index - audioQueueTasks.length;
                          final translationId = downloadingTranslationIds[translationIndex];
                          final progress = activeTranslationProgress[translationId] ?? 0.0;
                          final translation = allTranslations
                              .where((t) => t.id == translationId)
                              .firstOrNull;

                          return _TextTranslationQueueTaskItem(
                            translationId: translationId,
                            translation: translation,
                            progress: progress,
                            isDark: isDark,
                          );
                        }
                      },
                    ),
                  ],
                ),
                secondChild: const SizedBox.shrink(),
                crossFadeState: _isExpanded
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                duration: const Duration(milliseconds: 220),
              ),
          ],
        ),
      ),
    );
  }
}

/// Item for Audio downloads (both Arabic Quran recitation and Audio translation)
class _AudioQueueTaskItem extends ConsumerWidget {
  final AudioDownloadTask task;
  final String surahName;
  final ReciterEntity? reciter;
  final bool isDark;

  const _AudioQueueTaskItem({
    required this.task,
    required this.surahName,
    required this.reciter,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAudioTranslation = reciter?.styleId == 4;
    final isDownloading = task.status == DownloadTaskStatus.downloading;
    final isPaused = task.status == DownloadTaskStatus.paused;
    final isFailed = task.status == DownloadTaskStatus.failed;

    final statusBadgeText = isDownloading
        ? 'در حال دانلود...'
        : isPaused
            ? 'متوقف شده'
            : 'خطا در دانلود';

    final statusColor = isDownloading
        ? Colors.green
        : isPaused
            ? Colors.orange
            : context.colorScheme.error;

    final badgeColor = isAudioTranslation
        ? Colors.deepPurple
        : context.colorScheme.primary;
    final badgeLabel = isAudioTranslation ? 'ترجمه گویا' : 'صوت قرآن';
    final badgeIcon = isAudioTranslation
        ? CupertinoIcons.speaker_2
        : CupertinoIcons.waveform;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              margin: const EdgeInsetsDirectional.only(end: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : badgeColor.withValues(alpha: 0.20),
                  width: 1.0,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: (reciter?.imageUrl != null && reciter!.imageUrl!.isNotEmpty)
                    ? AppCachedNetworkImage(
                        imageUrl: reciter!.imageUrl,
                        width: 42,
                        height: 42,
                        fit: BoxFit.cover,
                        fallbackIcon: badgeIcon,
                        backgroundColor: badgeColor.withValues(alpha: 0.12),
                      )
                    : Container(
                        color: badgeColor.withValues(alpha: 0.12),
                        alignment: Alignment.center,
                        child: Icon(badgeIcon, size: 20, color: badgeColor),
                      ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'سوره $surahName',
                          style: const TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '• $badgeLabel',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: badgeColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          reciter != null ? reciter!.name : 'قاری کد ${task.reciterId}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        statusBadgeText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${task.completedAyahs.toPersianDigit()}/${task.totalAyahs.toPersianDigit()})',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 10.5,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                  if (isFailed && task.errorMessage != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.errorMessage!,
                      style: TextStyle(
                        fontSize: 11,
                        color: context.colorScheme.error,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // Action Text Pills (Pause / Resume & Cancel)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isDownloading)
                  InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref
                          .read(audioDownloadControllerProvider.notifier)
                          .pauseDownload(task.reciterId, task.surahId);
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: isDark ? 0.16 : 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'توقف',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.orangeAccent : const Color(0xFFD97706),
                        ),
                      ),
                    ),
                  )
                else if (isPaused || isFailed)
                  InkWell(
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      final allReciters = await ref.read(allRecitersListProvider.future);
                      final r = allReciters
                          .tryGetSuccess()
                          ?.where((item) => item.id == task.reciterId)
                          .firstOrNull;
                      if (r != null) {
                        ref
                            .read(audioDownloadControllerProvider.notifier)
                            .resumeDownload(reciter: r, surahId: task.surahId);
                      }
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: isDark ? 0.16 : 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'ادامه',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.greenAccent : Colors.green.shade700,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    await ref
                        .read(audioDownloadControllerProvider.notifier)
                        .cancelDownload(task.reciterId, task.surahId);
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.colorScheme.error.withValues(alpha: isDark ? 0.16 : 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'لغو',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: context.colorScheme.error,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: task.progress.clamp(0.0, 1.0),
            minHeight: 3,
            backgroundColor: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFF0ECE6),
            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
          ),
        ),
      ],
    );
  }
}

/// Item for Text Translation downloads
class _TextTranslationQueueTaskItem extends ConsumerWidget {
  final String translationId;
  final TranslationEntity? translation;
  final double progress;
  final bool isDark;

  const _TextTranslationQueueTaskItem({
    required this.translationId,
    required this.translation,
    required this.progress,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const badgeColor = Color(0xFF0277BD); // Blue shade for text translation
    final percent = (progress * 100).toInt();

    final title = translation != null
        ? 'ترجمه ${translation!.name}'
        : 'ترجمه متنی ($translationId)';
    final subtitle = translation != null
        ? 'مترجم: ${translation!.translatorName}'
        : 'در حال دریافت فایل داده...';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              margin: const EdgeInsetsDirectional.only(end: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : badgeColor.withValues(alpha: 0.20),
                  width: 1.0,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Container(
                  color: badgeColor.withValues(alpha: 0.12),
                  alignment: Alignment.center,
                  child: const Icon(CupertinoIcons.book, size: 20, color: badgeColor),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        '• متن ترجمه',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: badgeColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${percent.toPersianDigit()}٪',
                        style: const TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: badgeColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Cancel Download button
            InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                ref
                    .read(translationManagerControllerProvider.notifier)
                    .cancelDownload(translationId);
              },
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.colorScheme.error.withValues(alpha: isDark ? 0.16 : 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'لغو',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.error,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 3,
            backgroundColor: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFF0ECE6),
            valueColor: const AlwaysStoppedAnimation<Color>(badgeColor),
          ),
        ),
      ],
    );
  }
}
