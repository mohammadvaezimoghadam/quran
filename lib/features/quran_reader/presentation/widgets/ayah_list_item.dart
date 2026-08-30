import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/services.dart';

import '../../../../common/extensions/ayah_extension.dart';
import '../../../../common/extensions/int_extension.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../common/widgets/app_snackbar.dart';
import '../../../../core/services/audio/audio_player_state.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../application/controllers/quran_audio_controller.dart';
import '../../application/controllers/quran_display_settings_controller.dart';
import '../../application/controllers/quran_reader_controller.dart';
import '../../application/controllers/selected_ayah_action_provider.dart';
import '../../domain/entities/ayah_entity.dart';
import 'ayah_action_buttons.dart';
import 'ayah_arabic_text.dart';
import 'ayah_bottom_action_chips.dart';
import '../../../translation_manager/application/controllers/ayah_translation_provider.dart';
import '../../../translation_manager/presentation/widgets/ayah_translation_text.dart';
import 'word_by_word_bottom_sheet.dart';
import 'quran_ornamental_divider.dart';
import '../utils/reciter_download_helper.dart';

/// Clean component for displaying an individual Ayah card.
class AyahListItem extends ConsumerWidget {
  final AyahEntity ayah;
  final String surahName;
  final int totalAyahsInSurah;
  final bool isPageStart;
  final bool isHizbStart;
  final String? translationId;
  final VoidCallback? onBookmarkTap;
  final VoidCallback? onPlayTap;
  final VoidCallback? onShareTap;

  const AyahListItem({
    super.key,
    required this.ayah,
    required this.surahName,
    required this.totalAyahsInSurah,
    this.isPageStart = false,
    this.isHizbStart = false,
    this.translationId,
    this.onBookmarkTap,
    this.onPlayTap,
    this.onShareTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    // Gate: Only consider highlight if audio is playing THIS surah
    final isAudioForThisSurah = ref.watch(
      quranAudioControllerProvider.select(
        (s) => s.currentSurahId == ayah.surahId,
      ),
    );

    // Active playing Ayah subscription (gated by surah match)
    final isPlayingAyah =
        isAudioForThisSurah &&
        ref.watch(
          activeAyahProvider.select((active) => active == ayah.ayahNumber),
        );
    final isAudioPlayingNow =
        isPlayingAyah &&
        ref.watch(
          quranAudioControllerProvider.select(
            (s) => s.status == AudioStatus.playing,
          ),
        );
        
    final showTranslation = ref.watch(
      quranDisplaySettingsControllerProvider.select((s) => s.showTranslation),
    );
    final translationFontSize = ref.watch(
      quranDisplaySettingsControllerProvider.select(
        (s) => s.translationFontSize,
      ),
    );
    final autoHighlight = ref.watch(
      quranDisplaySettingsControllerProvider.select((s) => s.autoHighlight),
    );
    final showArabicText = ref.watch(
      quranDisplaySettingsControllerProvider.select((s) => s.showArabicText),
    );

    // Selected Ayah for context action (copy/share/bookmark)
    final isSelectedForAction = ref.watch(
      selectedAyahActionProvider.select(
        (selected) => selected == ayah.ayahNumber,
      ),
    );

    final isAudioActive = isPlayingAyah && autoHighlight;
    final borderRadius = BorderRadius.circular(AppDimens.radiusSm);

    return RepaintBoundary(
      child: InkWell(
      onTap: () {
        final controlsState = ref.read(readerControlsProvider);
        if (controlsState.isControlsHidden) {
          ref.read(readerControlsProvider.notifier).revealControls();
          return;
        }

        final anySelected = ref.read(selectedAyahActionProvider) != null;
        if (anySelected) {
          // Tap anywhere dismisses the action menu
          ref.read(selectedAyahActionProvider.notifier).clearSelection();
        } else {
          // Single tap plays/pauses ayah audio directly
          final controller = ref.read(quranAudioControllerProvider.notifier);
          if (isAudioPlayingNow) {
            controller.pause();
          } else {
            final reciter = ref.read(quranAudioControllerProvider).selectedReciter;
            if (reciter != null) {
              ReciterDownloadHelper.checkAndPromptSurahDownload(
                context: context,
                ref: ref,
                reciter: reciter,
                surahId: ayah.surahId,
              ).then((isDownloaded) {
                if (isDownloaded) {
                  controller.resumeAutoScrollAndSync();
                  controller.playAyah(
                    surahId: ayah.surahId,
                    ayahNumber: ayah.ayahNumber,
                    totalAyahsInSurah: totalAyahsInSurah,
                  );
                }
              });
            } else {
              controller.resumeAutoScrollAndSync();
              controller.playAyah(
                surahId: ayah.surahId,
                ayahNumber: ayah.ayahNumber,
                totalAyahsInSurah: totalAyahsInSurah,
              );
            }
          }
        }

        // If full-screen mode is active, hide headers and collapse controls again after clicking the ayah
        if (controlsState.isFullScreen) {
          ref.read(readerControlsProvider.notifier).toggleControls();
        }
      },
      onLongPress: () {
        final controlsState = ref.read(readerControlsProvider);
        if (controlsState.isControlsHidden) {
          ref.read(readerControlsProvider.notifier).revealControls();
          return;
        }

        // Long Press opens context action menu for copy/share/bookmark
        ref
            .read(selectedAyahActionProvider.notifier)
            .selectAyah(ayah.ayahNumber);
      },
      borderRadius: borderRadius,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(vertical: AppDimens.stackXs),
        padding: const EdgeInsets.all(AppDimens.stackSmMd),
        decoration: BoxDecoration(
          color: isAudioActive
              ? colorScheme.primary.withValues(alpha: 0.1)
              : (isSelectedForAction
                    ? colorScheme.surfaceContainerHigh
                    : Colors.transparent),
          borderRadius: borderRadius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Stage 2 Action Bar: Animated fan-out when Ayah is focused
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: AyahActionButtons(
                      isVisible: isSelectedForAction,
                      isPlaying: isAudioPlayingNow,
                      onPlayTap: () {
                        final controller = ref.read(
                          quranAudioControllerProvider.notifier,
                        );
                        final audioState = ref.read(
                          quranAudioControllerProvider,
                        );

                        // Clear selection menu & resume auto-scroll so Re-Sync button does not appear
                        ref
                            .read(selectedAyahActionProvider.notifier)
                            .clearSelection();
                        controller.resumeAutoScrollAndSync();

                        if (isAudioPlayingNow) {
                          controller.pause();
                        } else if (audioState.status == AudioStatus.paused &&
                            audioState.currentAyahNumber == ayah.ayahNumber) {
                          controller.resume();
                        } else {
                          final reciter = audioState.selectedReciter;
                          if (reciter != null) {
                            ReciterDownloadHelper.checkAndPromptSurahDownload(
                              context: context,
                              ref: ref,
                              reciter: reciter,
                              surahId: ayah.surahId,
                            ).then((isDownloaded) {
                              if (isDownloaded) {
                                controller.playAyah(
                                  surahId: ayah.surahId,
                                  ayahNumber: ayah.ayahNumber,
                                  totalAyahsInSurah: totalAyahsInSurah,
                                );
                              }
                            });
                          } else {
                            controller.playAyah(
                              surahId: ayah.surahId,
                              ayahNumber: ayah.ayahNumber,
                              totalAyahsInSurah: totalAyahsInSurah,
                            );
                          }
                        }
                      },
                      onCopyTap: () async {
                        ref
                            .read(selectedAyahActionProvider.notifier)
                            .clearSelection();

                        final translationAsync = ref.read(
                          ayahTranslationProvider(
                            ayah.surahId,
                            ayah.ayahNumber,
                            translationId,
                          ),
                        );
                        final currentTranslation = translationAsync.value ?? ayah.translationText;
                        final ayahWithTranslation = ayah.copyWith(
                          translationText: currentTranslation,
                        );

                        final shareableText = ayahWithTranslation.toShareableText(
                          surahName: surahName,
                        );
                        await Clipboard.setData(
                          ClipboardData(text: shareableText),
                        );

                        if (context.mounted) {
                          AppSnackBar.showSuccess(
                            context,
                            'آیه با موفقیت کپی شد',
                          );
                        }
                      },
                      onBookmarkTap: () {
                        ref
                            .read(selectedAyahActionProvider.notifier)
                            .clearSelection();
                        AppSnackBar.showInfo(
                          context,
                          'قابلیت نشانک‌گذاری آیه به زودی اضافه خواهد شد',
                        );
                      },
                      onShareTap: () {
                        ref
                            .read(selectedAyahActionProvider.notifier)
                            .clearSelection();
                        AppSnackBar.showInfo(
                          context,
                          'قابلیت اشتراک‌گذاری آیه به زودی اضافه خواهد شد',
                        );
                      },
                    ),
                  ),
                  if (isSelectedForAction) AppDimens.stackSmMd.vSpace,
                ],
              ),
            ),

            if (isPageStart || (isHizbStart && ayah.hizb != null))
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6.0, left: 8.0, right: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (isPageStart)
                          Text(
                            'صفحه ${ayah.page?.toPersianDigit() ?? ''}',
                            style: const TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.goldAccent,
                            ),
                            textDirection: TextDirection.rtl,
                          )
                        else
                          const SizedBox.shrink(),

                        if (isHizbStart && ayah.hizb != null)
                          Text(
                            'حزب ${ayah.hizb!.toPersianDigit()}',
                            style: const TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.goldAccent,
                            ),
                            textDirection: TextDirection.rtl,
                          )
                        else
                          const SizedBox.shrink(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: QuranOrnamentalDivider(
                      color: AppColors.goldAccent.withValues(alpha: 0.6),
                      height: 16,
                    ),
                  ),
                ],
              ),

            // Main Arabic Ayah Text with Embedded Ayah Marker
            if (showArabicText)
              AyahArabicText(
                text: ayah.arabicText,
                ayahNumber: ayah.ayahNumber,
                isActive: isAudioActive,
              ),

            // Ayah Persian Translation
            AyahTranslationText(
              surahId: ayah.surahId,
              ayahNumber: ayah.ayahNumber,
              fallbackText: ayah.translationText ?? '',
              isActive: isAudioActive,
              isVisible: showTranslation,
              fontSize: translationFontSize,
              translationId: translationId,
            ),

            // Soft, subtle Bottom Action Chips (Tafsir & Vocabulary)
            AyahBottomActionChips(
              isVisible: isSelectedForAction,
              onTafsirTap: () {
                ref.read(selectedAyahActionProvider.notifier).clearSelection();
                AppSnackBar.showInfo(
                  context,
                  'تفسیر آیه به زودی اضافه خواهد شد',
                );
              },
              onDictionaryTap: () {
                ref.read(selectedAyahActionProvider.notifier).clearSelection();
                WordByWordBottomSheet.show(
                  context,
                  surahId: ayah.surahId,
                  surahName: surahName,
                  ayahNumber: ayah.ayahNumber,
                );
              },
            ),
          ],
        ),
      ),
    ),
    );
  }
}
