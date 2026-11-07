import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/extensions/int_extension.dart';
import '../../../../common/extensions/context_extension.dart';
import '../../../../core/services/audio/audio_player_state.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../translation_manager/presentation/widgets/ayah_translation_text.dart';
import '../../application/controllers/quran_audio_controller.dart';
import '../../application/controllers/quran_display_settings_controller.dart';
import '../../application/controllers/quran_reader_controller.dart';
import '../../application/controllers/selected_ayah_action_provider.dart';
import '../../domain/entities/ayah_entity.dart';
import '../../domain/entities/ayah_theme_entity.dart';
import '../../../../common/utils/sajdah_helper.dart';
import '../utils/reciter_download_helper.dart';
import 'ayah_arabic_text.dart';
import 'quran_ornamental_divider.dart';
import 'sajdah_badge.dart';
import 'single_ayah_action_bottom_sheet.dart';

/// Clean component for displaying an individual Ayah card with Telegram-style selection.
class AyahListItem extends ConsumerWidget {
  final AyahEntity ayah;
  final String surahName;
  final int totalAyahsInSurah;
  final bool isPageStart;
  final bool isJuzStart;
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
    this.isJuzStart = false,
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

    // Audio session is active in this surah (playing, buffering/loading next track, or completing track)
    final isSurahAudioActive = ref.watch(
      quranAudioControllerProvider.select((s) {
        if (s.currentSurahId != ayah.surahId) return false;
        return s.status == AudioStatus.playing ||
            s.status == AudioStatus.loading ||
            s.status == AudioStatus.completed;
      }),
    );

    // This specific Ayah is actively being recited right now (playing, not merely buffering/transitioning)
    final isThisAyahReciting = ref.watch(
      quranAudioControllerProvider.select((s) {
        return s.status == AudioStatus.playing &&
            s.currentSurahId == ayah.surahId &&
            s.currentAyahNumber == ayah.ayahNumber;
      }),
    );

    // Active playing Ayah subscription (gated by surah match)
    final isPlayingAyah =
        isAudioForThisSurah &&
        ref.watch(
          activeAyahProvider.select((active) => active == ayah.ayahNumber),
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

    // Multi-selected Ayahs state (Isolated with .select for zero redundant rebuilds)
    final isSelectionMode = ref.watch(
      selectedAyahActionProvider.select((s) => s.isNotEmpty),
    );
    final isSelectedForAction = ref.watch(
      selectedAyahActionProvider.select((s) => s.contains(ayah.ayahNumber)),
    );

    final isAudioPaused = ref.watch(
      quranAudioControllerProvider.select(
        (s) =>
            s.status == AudioStatus.paused && s.currentSurahId == ayah.surahId,
      ),
    );

    // Show right-edge indicator when actively reciting or paused on this ayah
    final showActiveIndicator =
        autoHighlight &&
        (isThisAyahReciting || (isAudioPaused && isPlayingAyah));

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Focus mode dimming during audio playback:
    // When audio is actively in progress in this surah, dim other verses (0.35).
    // During verse-to-verse transitions, all verses stay dimmed until the next verse actually begins playing.
    final shouldDimForFocus =
        isSurahAudioActive && !isSelectionMode && !isThisAyahReciting;
    final focusOpacity = shouldDimForFocus ? 0.35 : 1.0;

    final ayahThemeId = ref.watch(
      quranDisplaySettingsControllerProvider.select((s) => s.ayahThemeId),
    );
    final isAyahThemeSolid = ref.watch(
      quranDisplaySettingsControllerProvider.select((s) => s.isAyahThemeSolid),
    );
    final activeTheme = AyahThemePresets.getById(ayahThemeId);
    final Color defaultBgColor = activeTheme.getBackgroundColor(
      isOdd: ayah.ayahNumber % 2 != 0,
      isSolid: isAyahThemeSolid,
    );

    // Background color: Clean default background! (No full-green tint during audio playback)
    final Color effectiveBgColor = isSelectedForAction
        ? Color.alphaBlend(
            colorScheme.primary.withValues(
              alpha: isDark || activeTheme.isDark ? 0.28 : 0.14,
            ),
            defaultBgColor,
          )
        : defaultBgColor;

    final hasHeader =
        isPageStart ||
        (isJuzStart && ayah.juz != null) ||
        (isHizbStart && ayah.hizb != null);

    final sajdahType = SajdahHelper.getSajdahType(
      ayah.surahId,
      ayah.ayahNumber,
    );

    Future<void> handleDoubleTap() async {
      final currentSelected = ref.read(selectedAyahActionProvider);
      if (currentSelected.isNotEmpty) {
        return;
      }

      HapticFeedback.lightImpact();

      final audioState = ref.read(quranAudioControllerProvider);
      final isAudioPlayingNow =
          audioState.status == AudioStatus.playing &&
          audioState.currentSurahId == ayah.surahId &&
          audioState.currentAyahNumber == ayah.ayahNumber;

      final controller = ref.read(quranAudioControllerProvider.notifier);
      if (isAudioPlayingNow) {
        controller.pause();
      } else {
        final isReady = await ReciterDownloadHelper.checkAndPromptForPlayback(
          context: context,
          surahId: ayah.surahId,
        );
        if (isReady && context.mounted) {
          controller.resumeAutoScrollAndSync();
          controller.playAyah(
            surahId: ayah.surahId,
            ayahNumber: ayah.ayahNumber,
            totalAyahsInSurah: totalAyahsInSurah,
          );
        }
      }
    }

    void handleTap() {
      final currentSelected = ref.read(selectedAyahActionProvider);
      if (currentSelected.isNotEmpty) {
        // Tap toggles selection when selection mode is active
        ref
            .read(selectedAyahActionProvider.notifier)
            .toggleAyah(ayah.ayahNumber);
        return;
      }

      // On Web/Desktop, single-click directly plays/pauses this Ayah
      if (kIsWeb) {
        handleDoubleTap();
        return;
      }

      // On Mobile: single tap toggles between full-screen distraction-free mode and normal controls
      // ref.read(readerControlsProvider.notifier).toggleFullScreenOrControls();
    }

    final ayahWidget = RepaintBoundary(
      child: InkWell(
        onTap: handleTap,
        onDoubleTap: isSelectionMode ? null : handleDoubleTap,
        onLongPress: () {
          final controlsState = ref.read(readerControlsProvider);
          if (controlsState.isControlsHidden) {
            ref.read(readerControlsProvider.notifier).revealControls();
            return;
          }

          final currentSelected = ref.read(selectedAyahActionProvider);
          final isFirstAyahSelection = currentSelected.isEmpty;

          // Long Press selects this Ayah
          ref
              .read(selectedAyahActionProvider.notifier)
              .selectAyah(ayah.ayahNumber);

          // If this is the first Ayah being selected via long-press, open the action sheet
          if (isFirstAyahSelection && context.mounted) {
            SingleAyahActionBottomSheet.show(
              context,
              ayah: ayah,
              surahName: surahName,
              totalAyahsInSurah: totalAyahsInSurah,
            ).then((keepSelection) {
              if (context.mounted && keepSelection != true) {
                ref.read(selectedAyahActionProvider.notifier).clearSelection();
              }
            });
          }
        },
        child: Stack(
          children: [
            // 1. Base Ayah Container (Zero layout shift on selection)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.only(
                right: AppDimens.stackMd,
                left: AppDimens.stackMd,
                top: AppDimens.stackSmMd,
                bottom: AppDimens.stackSmMd,
              ),
              decoration: BoxDecoration(color: effectiveBgColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (hasHeader)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: 6.0,
                            left: 8.0,
                            right: 8.0,
                          ),
                          child: Row(
                            children: [
                              // Page Number (Right in RTL)
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: isPageStart
                                      ? Text(
                                          'صفحه ${ayah.page?.toPersianDigit() ?? ''}',
                                          style: TextStyle(
                                            fontFamily:
                                                AppTypography.fontFamily,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: activeTheme.headerTextColor,
                                          ),
                                          textDirection: TextDirection.rtl,
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              ),

                              // Juz Number (Center)
                              Expanded(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: (isJuzStart && ayah.juz != null)
                                      ? Text(
                                          'جزء ${ayah.juz!.toPersianDigit()}',
                                          style: TextStyle(
                                            fontFamily:
                                                AppTypography.fontFamily,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: activeTheme.headerTextColor,
                                          ),
                                          textDirection: TextDirection.rtl,
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              ),

                              // Hizb Number (Left in RTL)
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: (isHizbStart && ayah.hizb != null)
                                      ? Text(
                                          'حزب ${ayah.hizb!.toPersianDigit()}',
                                          style: TextStyle(
                                            fontFamily:
                                                AppTypography.fontFamily,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                (isDark || activeTheme.isDark)
                                                ? const Color(0xFFFF5252)
                                                : const Color(0xFFD32F2F),
                                          ),
                                          textDirection: TextDirection.rtl,
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: QuranOrnamentalDivider(
                            color: activeTheme.dividerColor,
                            height: 16,
                          ),
                        ),
                      ],
                    ),

                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOutCubic,
                    opacity: focusOpacity,
                    child: context.isWideScreen
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (showArabicText)
                                Expanded(
                                  child: AyahArabicText(
                                    text: ayah.arabicText,
                                    ayahNumber: ayah.ayahNumber,
                                    isActive: showActiveIndicator,
                                    surahId: ayah.surahId,
                                  ),
                                ),
                              if (showArabicText && showTranslation)
                                const SizedBox(width: 24),
                              if (showTranslation)
                                Expanded(
                                  child: AyahTranslationText(
                                    surahId: ayah.surahId,
                                    ayahNumber: ayah.ayahNumber,
                                    fallbackText: ayah.translationText ?? '',
                                    isActive: showActiveIndicator,
                                    isVisible: showTranslation,
                                    fontSize: translationFontSize,
                                    translationId: translationId,
                                  ),
                                ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Main Arabic Ayah Text with Embedded Ayah Marker
                              if (showArabicText)
                                AyahArabicText(
                                  text: ayah.arabicText,
                                  ayahNumber: ayah.ayahNumber,
                                  isActive: showActiveIndicator,
                                  surahId: ayah.surahId,
                                ),
                              // Ayah Persian Translation
                              if (showTranslation)
                                AyahTranslationText(
                                  surahId: ayah.surahId,
                                  ayahNumber: ayah.ayahNumber,
                                  fallbackText: ayah.translationText ?? '',
                                  isActive: showActiveIndicator,
                                  isVisible: showTranslation,
                                  fontSize: translationFontSize,
                                  translationId: translationId,
                                ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
            // 2. Selection Checkbox Overlay
            Positioned(
              top: hasHeader ? 48 : 12,
              right: 8,
              child: IgnorePointer(
                ignoring: !isSelectionMode,
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutBack,
                  scale: isSelectionMode ? 1.0 : 0.0,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isSelectionMode ? 1.0 : 0.0,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            effectiveBgColor, // Matches row background seamlessly
                        boxShadow: [
                          if (isSelectionMode)
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Icon(
                        isSelectedForAction
                            ? CupertinoIcons.checkmark_circle
                            : CupertinoIcons.circle,
                        color: isSelectedForAction
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.5,
                              ),
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // 3. Outlined Sajdah Badge Overlay (Placed directly ON TOP of the Ayah card)
            if (sajdahType != SajdahType.none)
              Positioned(
                top: hasHeader ? 48 : 10,
                left: 14,
                child: SajdahBadge(type: sajdahType),
              ),
          ],
        ),
      ),
    );

    return ayahWidget;
  }
}
