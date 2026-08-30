import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/constants/app_constants.dart';
import '../../../../common/extensions/int_extension.dart';
import '../../../../core/services/audio/audio_player_state.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../application/controllers/quran_audio_controller.dart';
import '../../application/controllers/quran_reader_controller.dart';
import '../../application/controllers/selected_ayah_action_provider.dart';
import '../../domain/enums/audio_playback_mode.dart';
import '../../domain/enums/current_track_type.dart';
import 'audio_mini_progress_slider.dart';
import 'quick_settings_drawer.dart';
import '../../../../common/widgets/reciter/reciter_avatar_button.dart';
import '../../../../common/widgets/reciter/reciter_selection_bottom_sheet.dart';
import '../utils/reciter_download_helper.dart';

class AudioPlayerBottomBar extends ConsumerWidget {
  final int surahId;
  final bool isFullScreen;
  final bool isCollapsed;
  final VoidCallback? onToggleCollapse;

  const AudioPlayerBottomBar({
    super.key,
    this.surahId = 1,
    this.isFullScreen = false,
    this.isCollapsed = false,
    this.onToggleCollapse,
  });

  String _formatReciterName(String? rawName) {
    if (rawName == null || rawName.isEmpty) return 'استاد پرهیزگار';

    var cleaned = rawName.replaceAll(RegExp(r'\s*[\(\[\{].*?[\)\]\}]'), '').trim();
    cleaned = cleaned.replaceAll(RegExp(r'\d+kbps', caseSensitive: false), '').trim();

    if (!cleaned.startsWith('استاد')) {
      cleaned = 'استاد $cleaned';
    }

    return cleaned;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Fine-grained selectors: Prevent rebuilding entire bottom bar on every audio position tick!
    final audioStatus = ref.watch(quranAudioControllerProvider.select((s) => s.status));
    final isAutoScrollSuspended = ref.watch(quranAudioControllerProvider.select((s) => s.isAutoScrollSuspended));
    final selectedReciter = ref.watch(quranAudioControllerProvider.select((s) => s.selectedReciter));
    final selectedTranslationReciter = ref.watch(quranAudioControllerProvider.select((s) => s.selectedTranslationReciter));
    final currentTrackType = ref.watch(quranAudioControllerProvider.select((s) => s.currentTrackType));
    final playbackMode = ref.watch(quranAudioControllerProvider.select((s) => s.playbackMode));
    final currentAyahNumber = ref.watch(quranAudioControllerProvider.select((s) => s.currentAyahNumber));
    final totalAyahsInSurah = ref.watch(quranAudioControllerProvider.select((s) => s.totalAyahsInSurah));
    
    final audioController = ref.read(quranAudioControllerProvider.notifier);

    final isPlaying = audioStatus == AudioStatus.playing;
    final isActive = audioStatus == AudioStatus.playing || audioStatus == AudioStatus.loading;
    // Show the correct reciter name based on what's currently playing
    final isTranslationTrack = currentTrackType == CurrentTrackType.translation;
    final activeReciterName = isActive && isTranslationTrack
        ? _formatReciterName(selectedTranslationReciter?.name)
        : _formatReciterName(selectedReciter?.name);
    
    // Determine if we should show track type badge (only in mixed modes)
    final isMixedMode = playbackMode == AudioPlaybackMode.quranThenTranslation || 
                        playbackMode == AudioPlaybackMode.translationThenQuran;
    final trackTypeLabel = isTranslationTrack ? '🔊 ترجمه' : '🔊 تلاوت';

    void onTogglePlay() async {
      if (isPlaying) {
        audioController.pause();
      } else if (audioStatus == AudioStatus.paused) {
        audioController.resume();
      } else {
        // Mode-aware download check: verifies ALL required sources
        final isReady = await ReciterDownloadHelper.checkAndPromptForPlayback(
          context: context,
          ref: ref,
          surahId: surahId,
        );
        if (!isReady) return;

        final ayahs = ref.read(quranReaderControllerProvider).ayahs;
        final startAyah = ayahs.isNotEmpty ? ayahs.first.ayahNumber : 1;
        audioController.playAyah(
          surahId: surahId,
          ayahNumber: startAyah,
          totalAyahsInSurah: ayahs.isNotEmpty ? ayahs.length : 7,
        );
      }
    }

    const double discRadius = 42.0;
    const double discDiameter = discRadius * 2; // 84.0px

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: Colors.transparent,
            margin: const EdgeInsets.symmetric(
              horizontal: AppDimens.marginPage,
              vertical: AppDimens.stackSm,
            ),
            height: discDiameter + 36, // 120.0px total stack height (proportional scaled height)
            child: Stack(
              alignment: Alignment.centerRight,
              clipBehavior: Clip.none,
              children: [
                // 1. Sleek horizontal capsule bar — slides right (behind reciter avatar disc) when collapsed
                Positioned(
                  left: 0,
                  right: discRadius + 4,
                  top: 36,
                  bottom: 8,
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOutCubic,
                    offset: isCollapsed ? const Offset(1.2, 0) : Offset.zero,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 250),
                      opacity: isCollapsed ? 0.0 : 1.0,
                      child: IgnorePointer(
                        ignoring: isCollapsed,
                        child: Container(
                          padding: const EdgeInsets.only(
                            left: AppDimens.stackXs,
                            right: discRadius + 10,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHigh,
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(AppDimens.radiusFull),
                              right: Radius.circular(AppDimens.radiusSm),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: colorScheme.primary.withValues(alpha: 0.18),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            textDirection: TextDirection.ltr,
                            children: [
                              // 1. Settings Button (Visual Left - prominent & larger)
                              IconButton(
                                iconSize: 28,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                                icon: Icon(
                                  CupertinoIcons.gear_alt_fill,
                                  color: colorScheme.primary,
                                ),
                                tooltip: 'تنظیمات نمایش',
                                onPressed: () => QuickSettingsDrawer.show(context),
                              ),

                              // 2. Next Ayah Button (Left of Middle Section)
                              IconButton(
                                iconSize: 18,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                icon: Icon(
                                  CupertinoIcons.backward_fill,
                                  color: (currentAyahNumber != null &&
                                          totalAyahsInSurah != null &&
                                          currentAyahNumber < totalAyahsInSurah)
                                      ? colorScheme.onSurface
                                      : colorScheme.onSurfaceVariant.withValues(alpha: 0.25),
                                ),
                                tooltip: 'آیه بعدی',
                                onPressed: (currentAyahNumber != null &&
                                        totalAyahsInSurah != null &&
                                        currentAyahNumber < totalAyahsInSurah)
                                    ? () => audioController.playNextAyah()
                                    : null,
                              ),

                              // 3. Middle Section: Reciter Name, Ayah Number & Constant-Height Mini Slider
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppDimens.stackXs,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: GestureDetector(
                                          onTap: () => ReciterSelectionBottomSheet.show(context),
                                          behavior: HitTestBehavior.opaque,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  '$activeReciterName • ${AppConstants.ayahLabel} ${currentAyahNumber ?? 1}',
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelSmall
                                                      ?.copyWith(
                                                        fontWeight: FontWeight.bold,
                                                        color: colorScheme.primary,
                                                        fontSize: 12.5,
                                                      ),
                                                ),
                                              ),
                                              if (isMixedMode && isActive) ...[
                                                const SizedBox(width: 4),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                                  decoration: BoxDecoration(
                                                    color: colorScheme.primary.withValues(alpha: 0.1),
                                                    borderRadius: BorderRadius.circular(4),
                                                    border: Border.all(
                                                      color: colorScheme.primary.withValues(alpha: 0.3),
                                                      width: 0.5,
                                                    )
                                                  ),
                                                  child: Text(
                                                    trackTypeLabel,
                                                    style: TextStyle(
                                                      fontSize: 8.5,
                                                      fontWeight: FontWeight.bold,
                                                      color: colorScheme.primary,
                                                      fontFamily: AppTypography.fontFamily,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              const SizedBox(width: 2),
                                              Icon(
                                                CupertinoIcons.chevron_down,
                                                size: 14,
                                                color: colorScheme.primary.withValues(alpha: 0.75),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // Always present slider widget
                                      const AudioMiniProgressSlider(),
                                    ],
                                  ),
                                ),
                              ),

                              // 4. Previous Ayah Button (Right of Middle Section)
                              IconButton(
                                iconSize: 18,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                icon: Icon(
                                  CupertinoIcons.forward_fill,
                                  color: (currentAyahNumber != null && currentAyahNumber > 1)
                                      ? colorScheme.onSurface
                                      : colorScheme.onSurfaceVariant.withValues(alpha: 0.25),
                                ),
                                tooltip: 'آیه قبلی',
                                onPressed: (currentAyahNumber != null && currentAyahNumber > 1)
                                    ? () => audioController.playPreviousAyah()
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 2. Side Handle Tab (زائده کشویی یکپارچه) – rendered BEHIND reciter disc so it seamlessly emerges from under the disc
                Positioned(
                  right: discRadius - 4, // 38.0px from right edge, physically anchored underneath reciter avatar disc
                  top: 43,
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    offset: isCollapsed ? Offset.zero : const Offset(0.8, 0),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 250),
                      opacity: isCollapsed ? 1.0 : 0.0,
                      child: IgnorePointer(
                        ignoring: !isCollapsed,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onToggleCollapse,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                            ),
                            child: Container(
                              padding: const EdgeInsets.only(
                                left: 12,
                                right: discRadius + 8, // Extends under avatar disc while exposing label & icon cleanly
                                top: 7,
                                bottom: 7,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHigh,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  bottomLeft: Radius.circular(20),
                                ),
                                border: Border.all(
                                  color: colorScheme.primary.withValues(alpha: 0.35),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.18),
                                    blurRadius: 10,
                                    offset: const Offset(-4, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    CupertinoIcons.chevron_left_2,
                                    size: 16,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'پلیر',
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 3. Overlapping Floating Reciter Disc Avatar (anchored over top of the side handle tab)
                Positioned(
                  right: 0,
                  top: 24,
                  child: ReciterAvatarButton(
                    radius: discRadius,
                    isPlayButton: true,
                    onTap: onTogglePlay,
                  ),
                ),

                // 3. Ultra-sleek Floating Capsule Pill for Re-Sync with Live Equalizer Animation ("ادامه تلاوت • آیه ۲۴")
                if (isAutoScrollSuspended && audioStatus != AudioStatus.stopped && currentAyahNumber != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: Center(
                      child: Material(
                        color: colorScheme.primary,
                        elevation: 6,
                        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                        child: InkWell(
                          onTap: () {
                            ref.read(selectedAyahActionProvider.notifier).clearSelection();
                            audioController.resumeAutoScrollAndSync();
                          },
                          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6.5,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const _AnimatedAudioEqualizer(
                                  color: Colors.white,
                                  height: 13.0,
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  'بازگشت به تلاوت • ${AppConstants.ayahLabel} ${currentAyahNumber.toPersianDigit()}',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.1,
                                    fontFamily: AppTypography.fontFamily,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact micro 3-bar animated audio equalizer widget
class _AnimatedAudioEqualizer extends StatefulWidget {
  final Color color;
  final double height;

  const _AnimatedAudioEqualizer({
    required this.color,
    this.height = 13.0,
  });

  @override
  State<_AnimatedAudioEqualizer> createState() => _AnimatedAudioEqualizerState();
}

class _AnimatedAudioEqualizerState extends State<_AnimatedAudioEqualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final val = _controller.value;
        return SizedBox(
          height: widget.height,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBar(0.35 + 0.65 * (val * 1.0 % 1.0)),
              const SizedBox(width: 2),
              _buildBar(0.25 + 0.75 * ((val + 0.33) % 1.0)),
              const SizedBox(width: 2),
              _buildBar(0.45 + 0.55 * ((val + 0.66) % 1.0)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBar(double factor) {
    final clampedFactor = factor.clamp(0.2, 1.0);
    return Container(
      width: 2.5,
      height: widget.height * clampedFactor,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
