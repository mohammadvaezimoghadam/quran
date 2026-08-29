import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/audio_storage/audio_storage_service_impl.dart';
import '../../../../core/services/audio_storage/audio_storage_providers.dart';
import '../../../quran_reader/application/controllers/quran_audio_controller.dart';
import '../../../audio_manager/application/controllers/audio_download_controller.dart';
import '../../../audio_manager/domain/entities/audio_download_task.dart';
import '../../domain/entities/surah_entity.dart';

/// Button states:
/// 1. Downloaded (full)     → Play icon  → plays surah from ayah 1
/// 2. Downloading (active)  → CircularProgress + Pause icon → tap cancels
/// 3. Partially downloaded  → Resume icon → triggers onDownloadTap (opens unified SurahActionDialog)
/// 4. Not downloaded at all → Download icon → triggers onDownloadTap (opens unified SurahActionDialog)
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

    // Check if partially downloaded (canceled/failed with some ayahs done)
    final isPartiallyCanceled = downloadTask != null &&
        (downloadTask.status == DownloadTaskStatus.canceled ||
            downloadTask.status == DownloadTaskStatus.failed) &&
        downloadTask.completedAyahs > 0;

    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box(AudioStorageServiceImpl.boxName).listenable(),
      builder: (context, box, child) {
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
            icon: const Icon(
              Icons.play_arrow_rounded,
              color: AppColors.primary,
              size: 28,
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

        // ── STATE 3: Partially downloaded → resume icon ──
        if (isPartiallyCanceled) {
          return IconButton(
            icon: const Icon(
              Icons.downloading_rounded,
              color: AppColors.goldAccent,
              size: 24,
            ),
            tooltip:
                '${downloadTask.completedAyahs} از ${downloadTask.totalAyahs} آیه دانلود شده - ادامه دانلود',
            onPressed: onDownloadTap,
          );
        }

        // ── STATE 4: Not downloaded → download cloud icon ──
        return IconButton(
          icon: const Icon(
            Icons.cloud_download_outlined,
            color: AppColors.goldAccent,
            size: 24,
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

    return IconButton(
      tooltip:
          'آیه ${task.currentAyah} از ${task.totalAyahs} - برای توقف لمس کنید',
      onPressed: () {
        ref.read(audioDownloadControllerProvider.notifier).cancelDownload(
              selectedReciter.id,
              surah.number,
            );
      },
      icon: SizedBox(
        width: 28,
        height: 28,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: progress > 0 ? progress : null,
              strokeWidth: 2.5,
              color: AppColors.goldAccent,
              backgroundColor: AppColors.goldAccent.withValues(alpha: 0.2),
            ),
            const Icon(
              Icons.pause_rounded,
              size: 14,
              color: AppColors.goldAccent,
            ),
          ],
        ),
      ),
    );
  }
}
