import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../common/widgets/app_snackbar.dart';
import '../../../../core/routes/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/services/audio_storage/audio_storage_service_impl.dart';
import '../../../../core/services/audio_storage/audio_storage_providers.dart';
import '../../../quran_reader/application/controllers/quran_audio_controller.dart';
import '../../../quran_reader/application/controllers/quran_display_settings_controller.dart';
import '../../../audio_manager/application/controllers/audio_download_controller.dart';
import '../../../audio_manager/domain/entities/audio_download_task.dart';
import '../../domain/entities/surah_entity.dart';

/// Button states:
/// 1. Downloaded (full)     → Play icon  → plays surah from ayah 1
/// 2. Downloading (active)  → CircularProgress + Pause icon → tap cancels
/// 3. Partially downloaded  → Resume icon → opens dialog to continue/manage
/// 4. Not downloaded at all → Download icon → opens dialog to download/manage
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

    final fontScript = ref.watch(
      quranDisplaySettingsControllerProvider.select((s) => s.fontScript),
    );
    final surahFontFamily = AppTypography.getFontFamilyByScript(fontScript);

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

        // ── STATE 3: Partially downloaded → resume icon + dialog ──
        if (isPartiallyCanceled) {
          return IconButton(
            icon: const Icon(
              Icons.downloading_rounded,
              color: AppColors.goldAccent,
              size: 24,
            ),
            tooltip:
                '${downloadTask.completedAyahs} از ${downloadTask.totalAyahs} آیه دانلود شده - ادامه دانلود',
            onPressed: () {
              onDownloadTap();
              _showResumeDialog(
                  context, ref, selectedReciter, downloadTask, surahFontFamily);
            },
          );
        }

        // ── STATE 4: Not downloaded → download cloud icon + dialog ──
        return IconButton(
          icon: const Icon(
            Icons.cloud_download_outlined,
            color: AppColors.goldAccent,
            size: 24,
          ),
          tooltip: 'دانلود صوت سوره',
          onPressed: () {
            onDownloadTap();
            _showDownloadDialog(context, ref, selectedReciter, surahFontFamily);
          },
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
        onDownloadTap();
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

  /// Dialog shown when tapping Cloud Download icon
  void _showDownloadDialog(
    BuildContext context,
    WidgetRef ref,
    dynamic selectedReciter,
    String surahFontFamily,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text.rich(
          TextSpan(
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            children: [
              const TextSpan(text: 'دانلود صوت سوره '),
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
        content: SizedBox(
          width: double.maxFinite,
          child: Text(
            selectedReciter != null
                ? 'قاری: ${selectedReciter.name} (${surah.numberOfAyahs} آیه)'
                : '${surah.numberOfAyahs} آیه',
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 14,
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        actions: [
          Wrap(
            spacing: 4,
            runSpacing: 4,
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  ref
                      .read(quranDisplaySettingsControllerProvider.notifier)
                      .toggleArabicText(true);
                  context.pushNamed(
                    quranReaderRoute,
                    pathParameters: {'id': surah.number.toString()},
                    queryParameters: {'name': surah.name},
                  );
                },
                child: const Text(
                  'فقط خواندن',
                  style: TextStyle(fontFamily: AppTypography.fontFamily),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  context.pushNamed(
                    audioDownloadManagerRoute,
                    queryParameters: {'surahId': surah.number.toString()},
                  );
                },
                child: const Text(
                  'مدیریت دانلود',
                  style: TextStyle(fontFamily: AppTypography.fontFamily),
                ),
              ),
              if (selectedReciter != null)
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ref
                        .read(audioDownloadControllerProvider.notifier)
                        .startDownload(
                          reciter: selectedReciter,
                          surahId: surah.number,
                        );
                    AppSnackBar.showSuccess(
                      context,
                      'دانلود صوت سوره ${surah.name} شروع شد',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Dialog shown when tapping Resume icon
  void _showResumeDialog(
    BuildContext context,
    WidgetRef ref,
    dynamic selectedReciter,
    AudioDownloadTask task,
    String surahFontFamily,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text.rich(
          TextSpan(
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            children: [
              const TextSpan(text: 'ادامه دانلود سوره '),
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
        content: SizedBox(
          width: double.maxFinite,
          child: Text(
            '${task.completedAyahs} از ${task.totalAyahs} آیه دانلود شده'
            '${selectedReciter != null ? " • ${selectedReciter.name}" : ""}',
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 14,
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        actions: [
          Wrap(
            spacing: 4,
            runSpacing: 4,
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  ref
                      .read(quranDisplaySettingsControllerProvider.notifier)
                      .toggleArabicText(true);
                  context.pushNamed(
                    quranReaderRoute,
                    pathParameters: {'id': surah.number.toString()},
                    queryParameters: {'name': surah.name},
                  );
                },
                child: const Text(
                  'فقط خواندن',
                  style: TextStyle(fontFamily: AppTypography.fontFamily),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  context.pushNamed(
                    audioDownloadManagerRoute,
                    queryParameters: {'surahId': surah.number.toString()},
                  );
                },
                child: const Text(
                  'مدیریت دانلود',
                  style: TextStyle(fontFamily: AppTypography.fontFamily),
                ),
              ),
              if (selectedReciter != null)
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ref
                        .read(audioDownloadControllerProvider.notifier)
                        .startDownload(
                          reciter: selectedReciter,
                          surahId: surah.number,
                        );
                    AppSnackBar.showSuccess(
                      context,
                      'ادامه دانلود سوره ${surah.name} شروع شد',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldAccent,
                    foregroundColor: Colors.black,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'ادامه دانلود',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
