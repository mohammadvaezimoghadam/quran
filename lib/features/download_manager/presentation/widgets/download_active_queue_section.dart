import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/constants/surah_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../audio_manager/application/controllers/audio_download_controller.dart';
import '../../../audio_manager/domain/entities/audio_download_task.dart';
import '../../../quran_reader/application/controllers/reciter_providers.dart';
import '../../../quran_reader/domain/entities/reciter_entity.dart';
import '../../../translation_manager/application/controllers/translation_manager_controller.dart';
import '../../../translation_manager/domain/entities/translation_entity.dart';

class DownloadActiveQueueSection extends ConsumerWidget {
  const DownloadActiveQueueSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 12.0,
                  offset: const Offset(0, 3.0),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                const Icon(
                  CupertinoIcons.arrow_down_circle_fill,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'صف دانلودهای جاری',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (totalCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$totalCount مورد',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Empty State
            if (totalCount == 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        CupertinoIcons.checkmark_seal_fill,
                        size: 38,
                        color: Colors.green.withValues(alpha: 0.7),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'در حال حاضر هیچ دانلودی در صف نیست.',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              // List of all downloading items
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: totalCount,
                separatorBuilder: (context, index) => const Divider(height: 20),
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

    final statusText = isDownloading
        ? 'در حال دانلود...'
        : isPaused
            ? 'متوقف شده'
            : (task.errorMessage ?? 'خطا');

    final statusColor = isDownloading
        ? Colors.green
        : isPaused
            ? Colors.orange
            : AppColors.error;

    final badgeColor = isAudioTranslation
        ? Colors.deepPurple
        : AppColors.primary;
    final badgeLabel = isAudioTranslation ? 'ترجمه گویا' : 'صوت قرآن';
    final badgeIcon = isAudioTranslation
        ? CupertinoIcons.speaker_2_fill
        : CupertinoIcons.waveform;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: badgeColor.withValues(alpha: 0.25),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(badgeIcon, size: 10, color: badgeColor),
                            const SizedBox(width: 3),
                            Text(
                              badgeLabel,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: badgeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'سوره $surahName',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
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
                        statusText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${task.completedAyahs}/${task.totalAyahs})',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Action Buttons (Pause / Resume & Cancel)
            if (isDownloading)
              IconButton(
                tooltip: 'توقف موقت',
                icon: const Icon(CupertinoIcons.pause_circle, size: 22, color: Colors.orange),
                onPressed: () {
                  ref
                      .read(audioDownloadControllerProvider.notifier)
                      .pauseDownload(task.reciterId, task.surahId);
                },
              )
            else if (isPaused || isFailed)
              IconButton(
                tooltip: 'ادامه دانلود',
                icon: const Icon(CupertinoIcons.play_circle, size: 22, color: Colors.green),
                onPressed: () async {
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
              ),
            IconButton(
              tooltip: 'لغو دانلود',
              icon: const Icon(CupertinoIcons.xmark_circle, size: 22, color: AppColors.error),
              onPressed: () async {
                await ref
                    .read(audioDownloadControllerProvider.notifier)
                    .cancelDownload(task.reciterId, task.surahId);
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: task.progress.clamp(0.0, 1.0),
            minHeight: 5,
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: badgeColor.withValues(alpha: 0.25),
                            width: 0.8,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(CupertinoIcons.book_fill, size: 10, color: badgeColor),
                            SizedBox(width: 3),
                            Text(
                              'متن ترجمه',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: badgeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                        '$percent٪',
                        style: const TextStyle(
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
            IconButton(
              tooltip: 'لغو دانلود',
              icon: const Icon(CupertinoIcons.xmark_circle, size: 22, color: AppColors.error),
              onPressed: () {
                ref
                    .read(translationManagerControllerProvider.notifier)
                    .cancelDownload(translationId);
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 5,
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
