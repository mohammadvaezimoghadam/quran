import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/widgets/app_snackbar.dart';
import '../../../../core/routes/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/services/audio_storage/audio_storage_providers.dart';
import '../../../download_manager/application/controllers/download_hub_controller.dart';
import '../../../download_manager/application/controllers/downloaded_items_controller.dart';
import '../../../quran_reader/application/controllers/quran_audio_controller.dart';
import '../../../quran_reader/application/controllers/quran_display_settings_controller.dart';
import '../../../quran_reader/domain/entities/reciter_entity.dart';
import '../../../quran_reader/domain/enums/audio_playback_mode.dart';
import '../../../surah_list/application/controllers/surah_list_controller.dart';
import '../../../surah_list/domain/entities/surah_entity.dart';
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

    final storageService = ref.watch(audioStorageServiceProvider);
    return ListenableBuilder(
      listenable: storageService.downloadStatusListenable,
      builder: (context, child) {

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
          onTap: (isDownloaded || hasPartialDownload)
              ? () {
                  if (selectedReciter != null) {
                    _showSurahOptionsBottomSheet(
                      context: context,
                      ref: ref,
                      surah: surah,
                      reciter: selectedReciter,
                      isDownloaded: isDownloaded,
                      hasPartialDownload: hasPartialDownload,
                      downloadedAyahsCount: downloadedAyahsCount,
                      fontFamily: fontFamily,
                    );
                  }
                }
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

  void _showSurahOptionsBottomSheet({
    required BuildContext context,
    required WidgetRef ref,
    required SurahEntity surah,
    required ReciterEntity reciter,
    required bool isDownloaded,
    required bool hasPartialDownload,
    required int? downloadedAyahsCount,
    required String? fontFamily,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isAudioTranslation = reciter.styleId == 4;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return Material(
          color: isDark ? const Color(0xFF1E2624) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: SafeArea(
              child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Surah Info Header
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isAudioTranslation
                            ? CupertinoIcons.speaker_2_fill
                            : CupertinoIcons.waveform,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'سوره ${surah.name} (${surah.number})',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: fontFamily,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isAudioTranslation
                                ? 'گوینده: ${reciter.name}'
                                : 'قاری: ${reciter.name}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDownloaded
                            ? Colors.green.withValues(alpha: 0.12)
                            : Colors.orange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isDownloaded
                            ? 'دانلود کامل'
                            : '$downloadedAyahsCount/${surah.numberOfAyahs} آیه',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDownloaded ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 10),

                // Action 1: Play Surah (if downloaded)
                if (isDownloaded)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.play_circle_fill,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    title: const Text(
                      'پخش صوت سوره',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      isAudioTranslation
                          ? 'پخش ترجمه گویا از آیه ۱'
                          : 'پخش تلاوت از آیه ۱',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () async {
                      Navigator.pop(sheetCtx);

                      if (isAudioTranslation) {
                        await ref
                            .read(quranAudioControllerProvider.notifier)
                            .selectTranslationReciter(reciter);
                        ref
                            .read(quranAudioControllerProvider.notifier)
                            .setPlaybackMode(AudioPlaybackMode.onlyTranslation);
                      } else {
                        await ref
                            .read(quranAudioControllerProvider.notifier)
                            .selectReciter(reciter);
                        ref
                            .read(quranAudioControllerProvider.notifier)
                            .setPlaybackMode(AudioPlaybackMode.onlyQuran);
                      }

                      if (context.mounted) {
                        context.pushNamed(
                          quranReaderRoute,
                          pathParameters: {'id': surah.number.toString()},
                        );
                        ref.read(quranAudioControllerProvider.notifier).playAyah(
                              surahId: surah.number,
                              ayahNumber: 1,
                              totalAyahsInSurah: surah.numberOfAyahs,
                            );
                      }
                    },
                  ),

                // Action 2: Resume / Complete Download (if partial)
                if (hasPartialDownload)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.cloud_download_fill,
                        color: Colors.green,
                        size: 24,
                      ),
                    ),
                    title: const Text(
                      'ادامه و تکمیل دانلود',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'دانلود آیه‌های باقیمانده (${surah.numberOfAyahs - (downloadedAyahsCount ?? 0)} آیه)',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      Navigator.pop(sheetCtx);
                      ref
                          .read(audioDownloadControllerProvider.notifier)
                          .startDownload(
                            reciter: reciter,
                            surahId: surah.number,
                          );
                      AppSnackBar.showSuccess(
                        context,
                        'دانلود سوره ${surah.name} شروع شد.',
                      );
                    },
                  ),

                // Action 3: Delete from storage
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      CupertinoIcons.trash_fill,
                      color: AppColors.error,
                      size: 22,
                    ),
                  ),
                  title: const Text(
                    'حذف از حافظه دستگاه',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                  subtitle: const Text(
                    'پاک‌سازی فایل‌های صوتی ذخیره شده این سوره',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.error,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.error),
                  onTap: () {
                    _showDeleteConfirmDialog(
                      context: context,
                      sheetContext: sheetCtx,
                      ref: ref,
                      surah: surah,
                      reciter: reciter,
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      );
    },
    );
  }

  void _showDeleteConfirmDialog({
    required BuildContext context,
    required BuildContext sheetContext,
    required WidgetRef ref,
    required SurahEntity surah,
    required ReciterEntity reciter,
  }) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(
          'حذف صوت سوره ${surah.name}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Text(
          'آیا از حذف کامل فایل‌های صوتی سوره ${surah.name} با صدای «${reciter.name}» از حافظه دستگاه اطمینان دارید؟',
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('انصراف'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              Navigator.pop(sheetContext);

              final storage = ref.read(audioStorageServiceProvider);
              await storage.deleteSurahAudio(
                reciterId: reciter.id,
                surahId: surah.number,
              );

              ref.invalidate(surahDownloadedAyahsCountProvider);
              ref.read(downloadedItemsControllerProvider.notifier).loadItems();
              ref.read(downloadHubControllerProvider.notifier).loadSummary();

              if (context.mounted) {
                AppSnackBar.showSuccess(
                  context,
                  'صوت سوره ${surah.name} با موفقیت از حافظه پاک شد.',
                );
              }
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
