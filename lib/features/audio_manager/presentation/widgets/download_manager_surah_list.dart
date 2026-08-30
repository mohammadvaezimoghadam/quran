import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/services/audio_storage/audio_storage_providers.dart';
import '../../../../core/services/audio_storage/audio_storage_service_impl.dart';
import '../../../surah_list/application/controllers/surah_list_controller.dart';
import '../../../surah_list/domain/entities/surah_entity.dart';
import '../../../quran_reader/application/controllers/quran_display_settings_controller.dart';
import '../../application/states/download_manager_state.dart';
import '../../application/states/download_manager_selected_surahs_provider.dart';
import '../../application/controllers/audio_download_controller.dart';
import '../../application/controllers/surah_downloaded_ayahs_provider.dart';
import '../../domain/entities/audio_download_task.dart';

class DownloadManagerSurahList extends ConsumerStatefulWidget {
  final int? initialSurahId;

  const DownloadManagerSurahList({
    super.key,
    this.initialSurahId,
  });

  @override
  ConsumerState<DownloadManagerSurahList> createState() =>
      _DownloadManagerSurahListState();
}

class _DownloadManagerSurahListState
    extends ConsumerState<DownloadManagerSurahList> {
  late ScrollController _scrollController;
  bool _hasScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Calculate the initial scroll offset for the given surah number
  double _calcOffset(double gridWidth, int surahNumber) {
    // Total horizontal padding: 12 (left) + 12 (right) = 24
    // Total cross axis spacing: 8 * 3 = 24
    final availableWidth = gridWidth - 24 - 24;
    final itemWidth = availableWidth / 4;
    final itemHeight = itemWidth / 0.95; // childAspectRatio = 0.95
    final rowIndex = (surahNumber - 1) ~/ 4;
    // Each row = itemHeight + 8 (mainAxisSpacing), minus the top padding offset
    return rowIndex * (itemHeight + 8.0);
  }

  @override
  Widget build(BuildContext context) {
    final surahState = ref.watch(surahListControllerProvider);
    final selectedReciter = ref.watch(downloadManagerSelectedReciterProvider);
    final selectedSurahs = ref.watch(downloadManagerSelectedSurahsProvider);

    final fontScript = ref.watch(
      quranDisplaySettingsControllerProvider.select((s) => s.fontScript),
    );
    final fontFamily = AppTypography.getFontFamilyByScript(fontScript);

    if (surahState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (surahState.errorMessage != null) {
      return Center(child: Text('خطا: ${surahState.errorMessage}'));
    }

    final surahs = surahState.surahs;
    final initialSurahId = widget.initialSurahId;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Jump smoothly to the surah position only once on first load
        if (!_hasScrolled &&
            initialSurahId != null &&
            initialSurahId > 4 &&
            surahs.isNotEmpty) {
          _hasScrolled = true;
          final targetOffset = _calcOffset(constraints.maxWidth, initialSurahId);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Future.delayed(const Duration(milliseconds: 100), () {
              if (!mounted || !_scrollController.hasClients) return;
              final maxScroll = _scrollController.position.maxScrollExtent;
              _scrollController.animateTo(
                targetOffset.clamp(0.0, maxScroll),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
              );
            });
          });
        }

        return GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.95,
          ),
          itemCount: surahs.length,
          itemBuilder: (context, index) {
            final surah = surahs[index];
            final isSelected = selectedSurahs.contains(surah.number);

            return _SurahGridItem(
              key: ValueKey('surah_${surah.number}'),
              surah: surah,
              fontFamily: fontFamily,
              selectedReciter: selectedReciter,
              isSelected: isSelected,
            );
          },
        );
      },
    );
  }
}

class _SurahGridItem extends ConsumerWidget {
  final SurahEntity surah;
  final String fontFamily;
  final dynamic selectedReciter;
  final bool isSelected;

  const _SurahGridItem({
    super.key,
    required this.surah,
    required this.fontFamily,
    required this.selectedReciter,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box(AudioStorageServiceImpl.boxName).listenable(),
      builder: (context, box, child) {
        final storageService = ref.read(audioStorageServiceProvider);

        final isDownloaded = selectedReciter != null
            ? storageService.isSurahDownloaded(
                selectedReciter.id, surah.number)
            : false;

        // Active download task
        final taskKey = selectedReciter != null
            ? 'r${selectedReciter.id}_s${surah.number}'
            : null;
        final downloadTask = taskKey != null
            ? ref.watch(audioDownloadControllerProvider
                .select((map) => map[taskKey]))
            : null;
        final isDownloading = downloadTask != null &&
            downloadTask.status == DownloadTaskStatus.downloading;

        // Downloaded ayah count (from filesystem, auto-invalidated)
        int? downloadedAyahsCount;
        if (selectedReciter != null && !isDownloaded && !isDownloading) {
          final countAsync = ref.watch(
            surahDownloadedAyahsCountProvider((
              reciterId: selectedReciter.id,
              surahId: surah.number,
              totalAyahs: surah.numberOfAyahs,
            )),
          );
          downloadedAyahsCount = countAsync.when(
            data: (count) => count,
            loading: () => null,
            error: (_, _) => null,
          );
        }

        // Determine ayah progress text
        String? ayahProgressText;
        if (isDownloading) {
          ayahProgressText =
              '${downloadTask.completedAyahs}/${downloadTask.totalAyahs}';
        } else if (downloadedAyahsCount != null && downloadedAyahsCount > 0) {
          ayahProgressText = '$downloadedAyahsCount/${surah.numberOfAyahs}';
        }

        final hasPartialDownload = !isDownloaded &&
            !isDownloading &&
            downloadedAyahsCount != null &&
            downloadedAyahsCount > 0;

        // Tooltip
        final tooltipMessage = isDownloading
            ? 'آیه ${downloadTask.currentAyah} از ${downloadTask.totalAyahs} در حال دانلود (کلیک=توقف)'
            : isDownloaded
                ? 'کامل دانلود شده'
                : hasPartialDownload
                    ? '$downloadedAyahsCount از ${surah.numberOfAyahs} آیه دانلود شده'
                    : null;

        Widget itemCard = Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: BoxDecoration(
            color: isDownloaded
                ? colorScheme.primary.withValues(alpha: 0.1)
                : isDownloading
                    ? AppColors.goldAccent.withValues(alpha: 0.2)
                    : hasPartialDownload
                        ? Colors.orange.withValues(alpha: 0.1)
                        : isSelected
                            ? AppColors.goldAccent.withValues(alpha: 0.15)
                            : colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDownloaded
                  ? colorScheme.primary
                  : isDownloading || isSelected
                      ? AppColors.goldAccent
                      : hasPartialDownload
                          ? Colors.orange
                          : colorScheme.outlineVariant,
              width: isDownloaded ||
                      isDownloading ||
                      isSelected ||
                      hasPartialDownload
                  ? 1.5
                  : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Right: Ayah Count / Progress Badge
              Align(
                alignment: Alignment.topRight,
                child: ayahProgressText != null
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDownloading
                              ? AppColors.goldAccent.withValues(alpha: 0.15)
                              : Colors.orange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          ayahProgressText,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: isDownloading
                                ? AppColors.goldAccent
                                : Colors.orange,
                          ),
                        ),
                      )
                    : Text(
                        '${surah.numberOfAyahs} آیه',
                        style: TextStyle(
                          fontSize: 9,
                          color: colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.8),
                        ),
                      ),
              ),

              // Main content (Centered vertically)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Surah Number & Arabic Name
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${surah.number}.',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDownloaded
                                    ? colorScheme.primary
                                    : isDownloading || isSelected
                                        ? AppColors.goldAccent
                                        : hasPartialDownload
                                            ? Colors.orange
                                            : colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              surah.name,
                              style: TextStyle(
                                fontFamily: fontFamily,
                                fontSize: 18,
                                color: isDownloaded
                                    ? colorScheme.primary
                                    : isDownloading || isSelected
                                        ? AppColors.goldAccent
                                        : hasPartialDownload
                                            ? Colors.orange
                                            : colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Status Icon & Text
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isDownloaded) ...[
                          Icon(Icons.check_circle,
                              color: colorScheme.primary, size: 14),
                          const SizedBox(width: 4),
                          Text('دانلود شده',
                              style: TextStyle(
                                  fontSize: 9, color: colorScheme.primary)),
                        ] else if (isDownloading) ...[
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              value: downloadTask.progress > 0
                                  ? downloadTask.progress
                                  : null,
                              strokeWidth: 2,
                              color: AppColors.goldAccent,
                              backgroundColor:
                                  AppColors.goldAccent.withValues(alpha: 0.2),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text('در حال دانلود',
                              style: TextStyle(
                                  fontSize: 9, color: AppColors.goldAccent)),
                        ] else if (isSelected) ...[
                          const Icon(Icons.check_circle,
                              color: AppColors.goldAccent, size: 14),
                          const SizedBox(width: 4),
                          const Text('انتخاب شده',
                              style: TextStyle(
                                  fontSize: 9, color: AppColors.goldAccent)),
                        ] else ...[
                          Icon(
                            Icons.radio_button_unchecked,
                            color: colorScheme.outlineVariant,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text('دانلود نشده',
                              style: TextStyle(
                                  fontSize: 9,
                                  color: colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.7))),
                        ]
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

        if (tooltipMessage != null) {
          itemCard = Tooltip(
            message: tooltipMessage,
            child: itemCard,
          );
        }

        return GestureDetector(
          onTap: isDownloaded
              ? null
              : isDownloading
                  ? () {
                      if (selectedReciter != null) {
                        ref
                            .read(audioDownloadControllerProvider.notifier)
                            .cancelDownload(
                              selectedReciter.id,
                              surah.number,
                            );
                      }
                    }
                  : () {
                      ref
                          .read(downloadManagerSelectedSurahsProvider.notifier)
                          .toggleSurah(surah.number);
                    },
          child: itemCard,
        );
      },
    );
  }
}
