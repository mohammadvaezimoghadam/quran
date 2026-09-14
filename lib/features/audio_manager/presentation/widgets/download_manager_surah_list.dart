import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/constants/app_constants.dart';
import '../../../../common/extensions/int_extension.dart';
import '../../../../common/extensions/surah_name_extension.dart';
import '../../../../common/widgets/app_snackbar.dart';
import '../../../../core/routes/route_name.dart';
import '../../../../core/services/audio_storage/audio_storage_providers.dart';
import '../../../../core/services/network/network_info_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../download_manager/application/controllers/download_hub_controller.dart';
import '../../../download_manager/application/controllers/downloaded_items_controller.dart';
import '../../../download_manager/infrastructure/datasources/download_manager_local_datasource.dart';
import '../../../quran_reader/application/controllers/quran_audio_controller.dart';
import '../../../quran_reader/application/controllers/quran_display_settings_controller.dart';
import '../../../quran_reader/domain/entities/reciter_entity.dart';
import '../../../quran_reader/domain/enums/audio_playback_mode.dart';
import '../../../subscription/application/vip_subscription_controller.dart';
import '../../../subscription/domain/policy/audio_vip_policy.dart';
import '../../../subscription/presentation/ui/vip_subscription_sheet.dart';
import '../../../subscription/presentation/utils/audio_vip_helper.dart';
import '../../../surah_list/application/controllers/surah_list_controller.dart';
import '../../../surah_list/domain/entities/surah_entity.dart';
import '../../application/controllers/audio_download_controller.dart';
import '../../application/controllers/surah_downloaded_ayahs_provider.dart';
import '../../application/states/download_manager_state.dart';
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

  void _scrollToInitialSurah(int initialSurahId, int totalSurahs) {
    if (_hasScrolled || initialSurahId <= 1 || totalSurahs == 0) return;
    _hasScrolled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (!mounted || !_scrollController.hasClients) return;
        const itemExtent = 74.0;
        final targetOffset = (initialSurahId - 1) * itemExtent;
        final maxScroll = _scrollController.position.maxScrollExtent;
        _scrollController.animateTo(
          targetOffset.clamp(0.0, maxScroll),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      });
    });
  }

  Future<void> _handleDownloadAll({
    required BuildContext context,
    required WidgetRef ref,
    required List<SurahEntity> surahs,
    required ReciterEntity? selectedReciter,
  }) async {
    if (selectedReciter == null) return;

    final isWifiOnly = ref
        .read(downloadManagerLocalDataSourceProvider)
        .getWifiOnlyPreference();
    if (isWifiOnly) {
      final isWifi = await NetworkInfoHelper.isWifiConnected();
      if (!isWifi) {
        if (context.mounted) {
          AppSnackBar.showError(
            context,
            'دانلود انجام نشد: تنظیم «فقط با وای‌فای» فعال است. لطفاً وای‌فای را روشن کرده یا این گزینه را در مدیریت دانلود غیرفعال کنید.',
          );
        }
        return;
      }
    }

    final storage = ref.read(audioStorageServiceProvider);
    final unDownloadedSurahs = surahs
        .where((s) => !storage.isSurahDownloaded(selectedReciter.id, s.number))
        .toList();

    if (unDownloadedSurahs.isEmpty) {
      if (context.mounted) {
        AppSnackBar.showSuccess(
          context,
          'تمامی سوره‌ها با صدای «${selectedReciter.name}» قبلاً دانلود شده‌اند.',
        );
      }
      return;
    }

    final isVip = ref.read(hasVipAccessProvider);
    final isTranslation = selectedReciter.styleId == 4;

    final permittedSurahs = <int>[];
    final lockedSurahs = <int>[];

    for (final s in unDownloadedSurahs) {
      final allowed = isTranslation
          ? AudioVipPolicy.canPlayAudioTranslation(isVip: isVip)
          : AudioVipPolicy.canPlayReciter(
              reciterIdentifier: selectedReciter.identifier,
              surahId: s.number,
              isVip: isVip,
            );
      if (allowed) {
        permittedSurahs.add(s.number);
      } else {
        lockedSurahs.add(s.number);
      }
    }

    if (lockedSurahs.isNotEmpty && permittedSurahs.isEmpty) {
      if (context.mounted) {
        if (isTranslation) {
          VipSubscriptionSheet.show(context);
        } else {
          AudioVipHelper.checkAndPromptVip(
            context: context,
            ref: ref,
            surahId: lockedSurahs.first,
            targetReciter: selectedReciter,
          );
        }
      }
      return;
    }

    final count = permittedSurahs.length;
    for (final surahId in permittedSurahs) {
      ref
          .read(audioDownloadControllerProvider.notifier)
          .startDownload(
            reciter: selectedReciter,
            surahId: surahId,
          );
    }

    if (context.mounted) {
      if (lockedSurahs.isNotEmpty) {
        AppSnackBar.showWarning(
          context,
          'دانلود ${count.toPersianDigit()} سوره رایگان آغاز شد. دانلود باقی سوره‌ها نیازمند اشتراک VIP است.',
        );
        VipSubscriptionSheet.show(context);
      } else {
        AppSnackBar.showSuccess(
          context,
          'دانلود ${count.toPersianDigit()} سوره آغاز شد.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final surahState = ref.watch(surahListControllerProvider);
    final selectedReciter = ref.watch(downloadManagerSelectedReciterProvider);

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

    final surahs = surahState.filteredSurahs;
    if (widget.initialSurahId != null) {
      _scrollToInitialSurah(widget.initialSurahId!, surahs.length);
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Section Header: "لیست سوره‌ها" + "دانلود همه"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'لیست سوره‌ها',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              InkWell(
                onTap: () => _handleDownloadAll(
                  context: context,
                  ref: ref,
                  surahs: surahs,
                  selectedReciter: selectedReciter,
                ),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    'دانلود همه',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.goldAccent : const Color(0xFFB57A22),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Surah ListView or Empty Search State
        if (surahs.isEmpty)
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  AppConstants.noSurahFound,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.6,
                  ),
                ),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: surahs.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                thickness: 0.7,
                color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.2 : 0.4),
              ),
              itemBuilder: (context, index) {
                final surah = surahs[index];
                return _SurahListItem(
                  key: ValueKey('surah_${surah.number}'),
                  surah: surah,
                  fontFamily: fontFamily,
                  selectedReciter: selectedReciter,
                );
              },
            ),
          ),
      ],
    );
  }
}

class _SurahListItem extends ConsumerWidget {
  final SurahEntity surah;
  final String fontFamily;
  final ReciterEntity? selectedReciter;

  const _SurahListItem({
    super.key,
    required this.surah,
    required this.fontFamily,
    required this.selectedReciter,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    final storageService = ref.watch(audioStorageServiceProvider);

    return ListenableBuilder(
      listenable: storageService.downloadStatusListenable,
      builder: (context, child) {
        final isDownloaded = selectedReciter != null
            ? storageService.isSurahDownloaded(
                selectedReciter!.id, surah.number)
            : false;

        final taskKey = selectedReciter != null
            ? 'r${selectedReciter!.id}_s${surah.number}'
            : null;
        final downloadTask = taskKey != null
            ? ref.watch(audioDownloadControllerProvider
                .select((map) => map[taskKey]))
            : null;
        final isDownloading = downloadTask != null &&
            downloadTask.status == DownloadTaskStatus.downloading;
        final isPaused = downloadTask != null &&
            downloadTask.status == DownloadTaskStatus.paused;

        int? downloadedAyahsCount;
        if (selectedReciter != null && !isDownloaded && !isDownloading && !isPaused) {
          final countAsync = ref.watch(
            surahDownloadedAyahsCountProvider((
              reciterId: selectedReciter!.id,
              surahId: surah.number,
              totalAyahs: surah.numberOfAyahs,
            )),
          );
          downloadedAyahsCount = countAsync.when(
            data: (count) => count,
            loading: () => null,
            error: (_, _) => null,
          );
        } else if (isDownloading || isPaused) {
          downloadedAyahsCount = downloadTask.completedAyahs;
        }

        final hasPartialDownload = !isDownloaded &&
            !isDownloading &&
            !isPaused &&
            downloadedAyahsCount != null &&
            downloadedAyahsCount > 0;

        final isVip = ref.watch(hasVipAccessProvider);
        final isTranslation = selectedReciter?.styleId == 4;
        final isLocked = selectedReciter != null &&
            !isDownloaded &&
            (isTranslation
                ? !AudioVipPolicy.canPlayAudioTranslation(isVip: isVip)
                : !AudioVipPolicy.canPlayReciter(
                    reciterIdentifier: selectedReciter!.identifier,
                    surahId: surah.number,
                    isVip: isVip,
                  ));

        return InkWell(
          onTap: () {
            if (isDownloaded) {
              if (selectedReciter != null) {
                _playSurah(
                  context: context,
                  ref: ref,
                  surah: surah,
                  reciter: selectedReciter!,
                );
              }
            } else if (hasPartialDownload) {
              if (selectedReciter != null) {
                _showSurahOptionsBottomSheet(
                  context: context,
                  ref: ref,
                  surah: surah,
                  reciter: selectedReciter!,
                  isDownloaded: isDownloaded,
                  hasPartialDownload: hasPartialDownload,
                  downloadedAyahsCount: downloadedAyahsCount,
                  fontFamily: fontFamily,
                );
              }
            } else if (isDownloading) {
              if (selectedReciter != null) {
                ref
                    .read(audioDownloadControllerProvider.notifier)
                    .pauseDownload(selectedReciter!.id, surah.number);
              }
            } else if (isPaused) {
              if (selectedReciter != null) {
                ref
                    .read(audioDownloadControllerProvider.notifier)
                    .resumeDownload(
                      reciter: selectedReciter!,
                      surahId: surah.number,
                    );
              }
            } else {
              _startSurahDownload(context, ref, isLocked, isTranslation);
            }
          },
          onLongPress: (isDownloaded || hasPartialDownload || isDownloading || isPaused)
              ? () {
                  if (selectedReciter != null) {
                    _showSurahOptionsBottomSheet(
                      context: context,
                      ref: ref,
                      surah: surah,
                      reciter: selectedReciter!,
                      isDownloaded: isDownloaded,
                      hasPartialDownload: hasPartialDownload || isPaused,
                      downloadedAyahsCount: downloadedAyahsCount ?? downloadTask?.completedAyahs,
                      fontFamily: fontFamily,
                    );
                  }
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 11.0, horizontal: 4.0),
            child: Row(
              children: [
                // Right Badge: Surah Number
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : const Color(0xFFF0EBE1),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    surah.number.toPersianDigit(),
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : const Color(0xFF4A453A),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Center Info: Surah Name & Meta
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'سوره ${surah.nameFa}',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/ic_kaaba.svg',
                            width: 12,
                            height: 12,
                            colorFilter: const ColorFilter.mode(
                              AppColors.goldAccent,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            surah.revelationTypeFa,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Text(
                              '•',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 11.5,
                                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                          Text(
                            'جزء ${surah.startJuz.toPersianDigit()}',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 11.5,
                              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Text(
                              '•',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 11.5,
                                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                          Text(
                            '${surah.numberOfAyahs.toPersianDigit()} ${AppConstants.ayahLabel}',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 11.5,
                              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Left Action Widget
                _buildActionWidget(
                  context: context,
                  ref: ref,
                  isDark: isDark,
                  colorScheme: colorScheme,
                  isDownloaded: isDownloaded,
                  isDownloading: isDownloading,
                  isPaused: isPaused,
                  hasPartialDownload: hasPartialDownload,
                  downloadTask: downloadTask,
                  downloadedAyahsCount: downloadedAyahsCount,
                  isLocked: isLocked,
                  isTranslation: isTranslation,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionWidget({
    required BuildContext context,
    required WidgetRef ref,
    required bool isDark,
    required ColorScheme colorScheme,
    required bool isDownloaded,
    required bool isDownloading,
    required bool isPaused,
    required bool hasPartialDownload,
    required AudioDownloadTask? downloadTask,
    required int? downloadedAyahsCount,
    required bool isLocked,
    required bool isTranslation,
  }) {
    // 1. Downloaded State: Transforms into "حذف" button with outlined trash can (No border)
    if (isDownloaded) {
      return InkWell(
        onTap: () {
          if (selectedReciter != null) {
            _showDeleteConfirmDialog(
              context: context,
              sheetContext: null,
              ref: ref,
              surah: surah,
              reciter: selectedReciter!,
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: isDark ? 0.16 : 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.delete_outline_rounded,
                size: 15,
                color: AppColors.error,
              ),
              SizedBox(width: 5),
              Text(
                'حذف',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 2. Downloading State: Progress % and X (cancel/stop) button inside same button (No border)
    if (isDownloading && downloadTask != null) {
      final percent = (downloadTask.progress * 100).clamp(0, 100).toInt();
      final accentColor = isDark ? AppColors.goldAccent : const Color(0xFFB57A22);

      return InkWell(
        onTap: () {
          if (selectedReciter != null) {
            ref
                .read(audioDownloadControllerProvider.notifier)
                .pauseDownload(selectedReciter!.id, surah.number);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: isDark ? 0.16 : 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 13,
                height: 13,
                child: CircularProgressIndicator(
                  value: downloadTask.progress > 0 ? downloadTask.progress : null,
                  strokeWidth: 2,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${percent.toPersianDigit()}٪',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.close_rounded,
                size: 15,
                color: accentColor.withValues(alpha: 0.85),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Paused or Partial Download State: Shows downloaded ayahs count and resumes on tap (No border)
    if (isPaused || hasPartialDownload) {
      final completed = downloadTask?.completedAyahs ?? downloadedAyahsCount ?? 0;
      final orangeColor = isDark ? Colors.orangeAccent : const Color(0xFFD97706);

      return InkWell(
        onTap: () {
          if (selectedReciter != null) {
            if (isPaused) {
              ref
                  .read(audioDownloadControllerProvider.notifier)
                  .resumeDownload(
                    reciter: selectedReciter!,
                    surahId: surah.number,
                  );
            } else {
              _startSurahDownload(context, ref, isLocked, isTranslation);
            }
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: isDark ? 0.16 : 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.arrow_down,
                size: 13,
                color: orangeColor,
              ),
              const SizedBox(width: 5),
              Text(
                'ادامه (${completed.toPersianDigit()}/${surah.numberOfAyahs.toPersianDigit()})',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: orangeColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 4. Idle / Not Downloaded State: Action pill with No Border
    final pillBgColor = isDark
        ? AppColors.goldAccent.withValues(alpha: 0.12)
        : const Color(0xFFFBF4E8);
    final pillTextColor = isDark
        ? AppColors.goldAccent
        : const Color(0xFFB57A22);

    return InkWell(
      onTap: () => _startSurahDownload(context, ref, isLocked, isTranslation),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: pillBgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isLocked ? Icons.lock_rounded : CupertinoIcons.arrow_down,
              size: 13.5,
              color: pillTextColor,
            ),
            const SizedBox(width: 6),
            Text(
              'دانلود',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: pillTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _playSurah({
    required BuildContext context,
    required WidgetRef ref,
    required SurahEntity surah,
    required ReciterEntity reciter,
  }) async {
    final isAudioTranslation = reciter.styleId == 4;
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
  }

  Future<void> _startSurahDownload(
    BuildContext context,
    WidgetRef ref,
    bool isLocked,
    bool isTranslation,
  ) async {
    if (selectedReciter == null) return;

    if (isLocked) {
      if (isTranslation) {
        VipSubscriptionSheet.show(context);
      } else {
        AudioVipHelper.checkAndPromptVip(
          context: context,
          ref: ref,
          surahId: surah.number,
          targetReciter: selectedReciter!,
        );
      }
      return;
    }

    final isWifiOnly = ref
        .read(downloadManagerLocalDataSourceProvider)
        .getWifiOnlyPreference();
    if (isWifiOnly) {
      final isWifi = await NetworkInfoHelper.isWifiConnected();
      if (!isWifi) {
        if (context.mounted) {
          AppSnackBar.showError(
            context,
            'دانلود انجام نشد: تنظیم «فقط با وای‌فای» فعال است. لطفاً وای‌فای را روشن کرده یا این گزینه را در مدیریت دانلود غیرفعال کنید.',
          );
        }
        return;
      }
    }

    ref.read(audioDownloadControllerProvider.notifier).startDownload(
          reciter: selectedReciter!,
          surahId: surah.number,
        );

    if (context.mounted) {
      AppSnackBar.showSuccess(
        context,
        'دانلود سوره ${surah.nameFa} شروع شد.',
      );
    }
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
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          surah.number.toPersianDigit(),
                          style: const TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'سوره ${surah.nameFa}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isAudioTranslation
                                  ? 'ترجمه گویا: ${reciter.name}'
                                  : 'با صدای: ${reciter.name}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        isDownloaded
                            ? 'دانلود کامل'
                            : '${(downloadedAyahsCount ?? 0).toPersianDigit()} از ${surah.numberOfAyahs.toPersianDigit()} آیه',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDownloaded ? Colors.green : Colors.orange,
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
                        'دانلود آیه‌های باقیمانده (${(surah.numberOfAyahs - (downloadedAyahsCount ?? 0)).toPersianDigit()} آیه)',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 11.5,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () {
                        Navigator.pop(sheetCtx);
                        final isVip = ref.read(hasVipAccessProvider);
                        final isTranslation = reciter.styleId == 4;
                        final isLocked = isTranslation
                            ? !AudioVipPolicy.canPlayAudioTranslation(isVip: isVip)
                            : !AudioVipPolicy.canPlayReciter(
                                reciterIdentifier: reciter.identifier,
                                surahId: surah.number,
                                isVip: isVip,
                              );
                        if (isLocked) {
                          if (isTranslation) {
                            VipSubscriptionSheet.show(context);
                          } else {
                            AudioVipHelper.checkAndPromptVip(
                              context: context,
                              ref: ref,
                              surahId: surah.number,
                              targetReciter: reciter,
                            );
                          }
                          return;
                        }
                        ref
                            .read(audioDownloadControllerProvider.notifier)
                            .startDownload(
                              reciter: reciter,
                              surahId: surah.number,
                            );
                        AppSnackBar.showSuccess(
                          context,
                          'دانلود سوره ${surah.nameFa} شروع شد.',
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
    BuildContext? sheetContext,
    required WidgetRef ref,
    required SurahEntity surah,
    required ReciterEntity reciter,
  }) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(
          'حذف صوت سوره ${surah.nameFa}',
          style: const TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        content: Text(
          'آیا از حذف کامل فایل‌های صوتی سوره ${surah.nameFa} با صدای «${reciter.name}» از حافظه دستگاه اطمینان دارید؟',
          style: const TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text(
              'انصراف',
              style: TextStyle(fontFamily: AppTypography.fontFamily),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              if (sheetContext != null && sheetContext.mounted) {
                Navigator.pop(sheetContext);
              }

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
                  'صوت سوره ${surah.nameFa} با موفقیت از حافظه پاک شد.',
                );
              }
            },
            child: const Text(
              'حذف',
              style: TextStyle(fontFamily: AppTypography.fontFamily),
            ),
          ),
        ],
      ),
    );
  }
}
