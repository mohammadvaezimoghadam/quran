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
  bool _isExpanded = false;

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
            // Header Row: Clean text title & count badge
            Row(
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
                if (totalCount > 0)
                  Text(
                    '${totalCount.toPersianDigit()} مورد',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 11.5,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
              ],
            ),

            // Empty State
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
            ] else ...[
              const SizedBox(height: 8),
              // List of downloading items (Initial 3 or All)
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _isExpanded
                    ? totalCount
                    : (totalCount > 3 ? 3 : totalCount),
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
              // Show more / Collapse button at the bottom (Unboxed, clean)
              if (totalCount > 3) ...[
                const SizedBox(height: 12),
                Center(
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Text(
                        _isExpanded ? 'بستن لیست' : 'نمایش بیشتر',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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

    final badgeColor = isAudioTranslation
        ? Colors.deepPurple
        : context.colorScheme.primary;
    final badgeLabel = isAudioTranslation ? 'ترجمه گویا' : 'صوت قرآن';
    final badgeIcon = isAudioTranslation
        ? CupertinoIcons.speaker_2
        : CupertinoIcons.waveform;

    final cleanReciterName = reciter != null
        ? reciter!.name
            .replaceAll('استاد ', '')
            .replaceAll('قاری:', '')
            .trim()
        : 'قاری کد ${task.reciterId}';

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
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          cleanReciterName,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 11,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
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
            // Action buttons (Icon for pause/resume + plain text 'حذف')
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isDownloading)
                  IconButton(
                    tooltip: 'توقف',
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    icon: Icon(
                      CupertinoIcons.pause_circle,
                      size: 22,
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      ref
                          .read(audioDownloadControllerProvider.notifier)
                          .pauseDownload(task.reciterId, task.surahId);
                    },
                  )
                else if (isPaused || isFailed)
                  IconButton(
                    tooltip: 'ادامه',
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    icon: Icon(
                      CupertinoIcons.play_circle,
                      size: 22,
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      await ref
                          .read(audioDownloadControllerProvider.notifier)
                          .resumeDownloadById(
                            reciterId: task.reciterId,
                            surahId: task.surahId,
                          );
                    },
                  ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    await ref
                        .read(audioDownloadControllerProvider.notifier)
                        .cancelDownload(task.reciterId, task.surahId);
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Text(
                      'حذف',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
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
            valueColor: AlwaysStoppedAnimation<Color>(badgeColor),
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
            // Cancel Download button (Plain unboxed text)
            InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                ref
                    .read(translationManagerControllerProvider.notifier)
                    .cancelDownload(translationId);
              },
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Text(
                  'حذف',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
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
