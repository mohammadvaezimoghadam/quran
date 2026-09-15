import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/constants/surah_constants.dart';
import '../../../../common/extensions/context_extension.dart';
import '../../../../common/extensions/int_extension.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../quran_reader/application/controllers/reciter_providers.dart';
import '../../domain/entities/audio_download_task.dart';
import '../../application/controllers/audio_download_controller.dart';

/// Interactive, collapsible active download queue bar in AudioDownloadManagerScreen.
/// Allows pausing, resuming, cancelling, and tracking active downloads in real-time.
class AudioDownloadQueueBar extends ConsumerStatefulWidget {
  const AudioDownloadQueueBar({super.key});

  @override
  ConsumerState<AudioDownloadQueueBar> createState() => _AudioDownloadQueueBarState();
}

class _AudioDownloadQueueBarState extends ConsumerState<AudioDownloadQueueBar> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final tasksMap = ref.watch(audioDownloadControllerProvider);
    final activeTasks = tasksMap.values.where((task) {
      return task.status == DownloadTaskStatus.downloading ||
          task.status == DownloadTaskStatus.paused ||
          task.status == DownloadTaskStatus.failed;
    }).toList();

    if (activeTasks.isEmpty) {
      return const SizedBox.shrink();
    }

    final hasDownloading = activeTasks.any((t) => t.status == DownloadTaskStatus.downloading);
    final allReciters = ref.watch(allRecitersListProvider).asData?.value.tryGetSuccess() ?? [];

    final colors = context.colors;
    final colorScheme = context.colorScheme;
    final isDark = context.isDark;

    final cardBgColor = colors.cardBackground;
    final borderColor = colors.cardBorder;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimens.marginPage,
        vertical: AppDimens.stackXs,
      ),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10.0,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Bar
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
              child: Row(
                children: [
                  Icon(
                    hasDownloading
                        ? CupertinoIcons.arrow_down_circle
                        : CupertinoIcons.pause_circle,
                    color: hasDownloading ? colorScheme.primary : Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'صف دانلود جاری',
                    style: const TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: (hasDownloading ? colorScheme.primary : Colors.orange)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${activeTasks.length.toPersianDigit()} سوره',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: hasDownloading ? colorScheme.primary : Colors.orange,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Quick Pause / Resume All Action
                  TextButton.icon(
                    onPressed: () async {
                      final controller = ref.read(audioDownloadControllerProvider.notifier);
                      if (hasDownloading) {
                        for (final task in activeTasks) {
                          if (task.status == DownloadTaskStatus.downloading) {
                            controller.pauseDownload(task.reciterId, task.surahId);
                          }
                        }
                      } else {
                        final recitersAsync = await ref.read(allRecitersListProvider.future);
                        final recitersList = recitersAsync.tryGetSuccess() ?? [];
                        for (final task in activeTasks) {
                          if (task.status == DownloadTaskStatus.paused ||
                              task.status == DownloadTaskStatus.failed) {
                            final r = recitersList.firstWhere(
                              (item) => item.id == task.reciterId,
                              orElse: () => allReciters.first,
                            );
                            controller.resumeDownload(reciter: r, surahId: task.surahId);
                          }
                        }
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: Icon(
                      hasDownloading ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
                      size: 13,
                      color: hasDownloading ? Colors.orange : Colors.green,
                    ),
                    label: Text(
                      hasDownloading ? 'توقف همه' : 'ادامه همه',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: hasDownloading ? Colors.orange : Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _isExpanded ? CupertinoIcons.chevron_up : CupertinoIcons.chevron_down,
                    size: 14,
                    color: isDark ? Colors.white60 : Colors.black45,
                  ),
                ],
              ),
            ),
          ),

          // Expanded Task List
          if (_isExpanded) ...[
            const Divider(height: 1),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 180),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                itemCount: activeTasks.length,
                separatorBuilder: (context, index) => const Divider(height: 16),
                itemBuilder: (context, index) {
                  final task = activeTasks[index];
                  final surahName = SurahConstants.getSurahName(task.surahId);
                  final reciter = allReciters
                      .where((r) => r.id == task.reciterId)
                      .firstOrNull;

                  return _QueueTaskRow(
                    task: task,
                    surahName: surahName,
                    reciter: reciter,
                    isDark: isDark,
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QueueTaskRow extends ConsumerWidget {
  final AudioDownloadTask task;
  final String surahName;
  final dynamic reciter;
  final bool isDark;

  const _QueueTaskRow({
    required this.task,
    required this.surahName,
    required this.reciter,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;
    final isDownloading = task.status == DownloadTaskStatus.downloading;
    final isPaused = task.status == DownloadTaskStatus.paused;
    final isFailed = task.status == DownloadTaskStatus.failed;

    final statusColor = isDownloading
        ? colorScheme.primary
        : isPaused
            ? Colors.orange
            : colorScheme.error;

    final statusText = isDownloading
        ? 'در حال دانلود'
        : isPaused
            ? 'متوقف شده'
            : 'خطا';

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
                      Text(
                        'سوره $surahName',
                        style: const TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '• $statusText',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 10.5,
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
                  if (isFailed && task.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        task.errorMessage!,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 10,
                          color: colorScheme.error,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            // Controls: Pause / Resume & Cancel
            if (isDownloading)
              InkWell(
                onTap: () {
                  ref
                      .read(audioDownloadControllerProvider.notifier)
                      .pauseDownload(task.reciterId, task.surahId);
                },
                borderRadius: BorderRadius.circular(16),
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(
                    CupertinoIcons.pause_circle_fill,
                    size: 22,
                    color: Colors.orange,
                  ),
                ),
              )
            else if (isPaused || isFailed)
              InkWell(
                onTap: () async {
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
                borderRadius: BorderRadius.circular(16),
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(
                    CupertinoIcons.play_circle_fill,
                    size: 22,
                    color: Colors.green,
                  ),
                ),
              ),
            const SizedBox(width: 4),
            InkWell(
              onTap: () async {
                await ref
                    .read(audioDownloadControllerProvider.notifier)
                    .cancelDownload(task.reciterId, task.surahId);
              },
              borderRadius: BorderRadius.circular(16),
              child: Icon(
                CupertinoIcons.xmark_circle,
                size: 20,
                color: colorScheme.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.radiusXs),
          child: LinearProgressIndicator(
            value: task.progress.clamp(0.0, 1.0),
            minHeight: 4,
            backgroundColor: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : colors.cardBorder,
            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
          ),
        ),
      ],
    );
  }
}
