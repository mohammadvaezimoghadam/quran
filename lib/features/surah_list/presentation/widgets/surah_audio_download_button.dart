import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/extensions/context_extension.dart';
import '../../../../common/extensions/int_extension.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/services/audio_storage/audio_storage_providers.dart';
import '../../../quran_reader/application/controllers/quran_audio_controller.dart';
import '../../../audio_manager/application/controllers/audio_download_controller.dart';
import '../../../audio_manager/domain/entities/audio_download_task.dart';
import '../../domain/entities/surah_entity.dart';

/// Button states:
/// 1. Downloaded (full)     → Play icon (Cupertino) → plays surah from ayah 1
/// 2. Downloading (active)  → CircularProgress + percentage text → tap cancels
/// 3. Partially downloaded  → Resume icon → triggers onDownloadTap
/// 4. Not downloaded at all → Download Cloud icon (Cupertino) → triggers onDownloadTap
class SurahAudioDownloadButton extends ConsumerWidget {
  final SurahEntity surah;
  final VoidCallback onDownloadTap;

  const SurahAudioDownloadButton({
    super.key,
    required this.surah,
    required this.onDownloadTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedReciter = ref.watch(
      quranAudioControllerProvider.select((s) => s.selectedReciter),
    );
    final storageService = ref.read(audioStorageServiceProvider);
    final colors = context.colors;
    final colorScheme = context.colorScheme;

    // Watch download task for this specific surah
    final taskKey = selectedReciter != null
        ? 'r${selectedReciter.id}_s${surah.number}'
        : null;
    final downloadTask = taskKey != null
        ? ref.watch(
            audioDownloadControllerProvider.select((map) => map[taskKey]),
          )
        : null;
    final isDownloading = downloadTask != null &&
        downloadTask.status == DownloadTaskStatus.downloading;

    // Check if partially downloaded or paused (with some ayahs done)
    final isPausedOrPartial = downloadTask != null &&
        (downloadTask.status == DownloadTaskStatus.paused ||
            downloadTask.status == DownloadTaskStatus.canceled ||
            downloadTask.status == DownloadTaskStatus.failed) &&
        downloadTask.completedAyahs > 0;

    return ListenableBuilder(
      listenable: storageService.downloadStatusListenable,
      builder: (context, child) {
        final isDownloaded = selectedReciter != null &&
            storageService.isSurahDownloaded(selectedReciter.id, surah.number);

        // ── STATE 1: Actively downloading → progress circle + pause ──
        if (isDownloading) {
          return _buildDownloadingState(
            context,
            ref,
            downloadTask,
            selectedReciter!,
          );
        }

        // ── STATE 2: Fully downloaded → play icon ──
        if (isDownloaded) {
          return IconButton(
            icon: Icon(
              CupertinoIcons.play_arrow_solid,
              color: colorScheme.primary,
              size: 24,
            ),
            tooltip: 'پخش صوت سوره',
            onPressed: () {
              onDownloadTap();
              ref.read(quranAudioControllerProvider.notifier).playAyah(
                    surahId: surah.number,
                    ayahNumber: 1,
                    totalAyahsInSurah: surah.numberOfAyahs,
                  );
            },
          );
        }

        // ── STATE 3: Partially downloaded or paused → resume icon ──
        if (isPausedOrPartial) {
          return IconButton(
            icon: Icon(
              CupertinoIcons.arrow_down_circle_fill,
              color: colors.goldAccent,
              size: 22,
            ),
            tooltip:
                '${downloadTask.completedAyahs} از ${downloadTask.totalAyahs} آیه دانلود شده - ادامه دانلود',
            onPressed: onDownloadTap,
          );
        }

        // ── STATE 4: Not downloaded → Download Cloud icon ──
        return IconButton(
          icon: Icon(
            CupertinoIcons.cloud_download,
            color: colors.goldAccent,
            size: 22,
          ),
          tooltip: 'دانلود صوت سوره',
          onPressed: onDownloadTap,
        );
      },
    );
  }

  Widget _buildDownloadingState(
    BuildContext context,
    WidgetRef ref,
    AudioDownloadTask task,
    dynamic selectedReciter,
  ) {
    final progress = task.progress;
    final percent = (progress * 100).clamp(0, 100).toInt();
    final goldAccent = context.colors.goldAccent;

    return IconButton(
      tooltip:
          'آیه ${task.currentAyah.toPersianDigit()} از ${task.totalAyahs.toPersianDigit()} ($percent٪) - برای توقف لمس کنید',
      onPressed: () {
        ref.read(audioDownloadControllerProvider.notifier).cancelDownload(
              selectedReciter.id,
              surah.number,
            );
      },
      icon: SizedBox(
        width: 32,
        height: 32,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: progress > 0 ? progress : null,
              strokeWidth: 2.5,
              color: goldAccent,
              backgroundColor: goldAccent.withValues(alpha: 0.2),
            ),
            Text(
              percent > 0 ? '${percent.toPersianDigit()}٪' : '...',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: goldAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
