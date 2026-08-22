import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/constants/app_constants.dart';
import '../../../../common/widgets/app_audio_play_button.dart';
import '../../../../core/services/audio/audio_player_state.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../application/controllers/quran_audio_controller.dart';
import '../../application/controllers/quran_reader_controller.dart';
import '../../application/controllers/selected_ayah_action_provider.dart';
import 'audio_mini_progress_slider.dart';
import 'reciter_avatar_button.dart';
import 'reciter_selection_bottom_sheet.dart';

class AudioPlayerBottomBar extends ConsumerWidget {
  final int surahId;

  const AudioPlayerBottomBar({
    super.key,
    this.surahId = 1,
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
    final audioState = ref.watch(quranAudioControllerProvider);
    final audioController = ref.read(quranAudioControllerProvider.notifier);

    final isPlaying = audioState.status == AudioStatus.playing;
    final isLoading = audioState.status == AudioStatus.loading;
    final isAutoScrollSuspended = audioState.isAutoScrollSuspended;
    final reciterName = _formatReciterName(audioState.selectedReciter?.name);

    const double discRadius = 35.0;
    const double discDiameter = discRadius * 2; // 70.0px

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
            height: discDiameter + 34, // 104.0px total stack height (ensures hit-testing bounds)
            child: Stack(
              alignment: Alignment.centerRight,
              clipBehavior: Clip.none,
              children: [
                // 1. Sleek capsule box extending out towards the left
                Positioned(
                  left: 0,
                  right: discRadius + 4,
                  top: 34,
                  bottom: 8,
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
                        // Controls Grouped on Visual Left
                        IconButton(
                          iconSize: 20,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => audioController.stop(),
                        ),

                        AppAudioPlayButton(
                          isPlaying: isPlaying,
                          isLoading: isLoading,
                          color: colorScheme.primary,
                          iconSize: 26,
                          onTap: () {
                            if (isPlaying) {
                              audioController.pause();
                            } else if (audioState.status == AudioStatus.paused) {
                              audioController.resume();
                            } else {
                              final ayahs = ref.read(quranReaderControllerProvider).ayahs;
                              final startAyah = ayahs.isNotEmpty ? ayahs.first.ayahNumber : 1;
                              audioController.playAyah(
                                surahId: surahId,
                                ayahNumber: startAyah,
                                totalAyahsInSurah: ayahs.isNotEmpty ? ayahs.length : 7,
                              );
                            }
                          },
                        ),

                        IconButton(
                          iconSize: 20,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                          icon: Icon(
                            audioState.isAutoPlayNext
                                ? Icons.repeat_one_on_rounded
                                : Icons.repeat_one_rounded,
                            color: audioState.isAutoPlayNext
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                          ),
                          tooltip: 'پخش خودکار آیه بعدی',
                          onPressed: () => audioController.toggleAutoPlayNext(),
                        ),

                        // Middle Section: Reciter Name, Ayah Number & Constant-Height Mini Slider
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
                                            '$reciterName • ${AppConstants.ayahLabel} ${audioState.currentAyahNumber ?? 1}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: colorScheme.primary,
                                                  fontSize: 11.5,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          size: 14,
                                          color: colorScheme.primary.withValues(alpha: 0.75),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                // Always present slider widget
                                const AudioMiniProgressSlider(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. Overlapping Larger Floating Reciter Disc
                Positioned(
                  right: 0,
                  top: 26,
                  child: ReciterAvatarButton(radius: discRadius),
                ),

                // 3. Ultra-sleek mini Re-Sync Pill placed centered right above the reciter avatar
                if (isAutoScrollSuspended && audioState.status != AudioStatus.stopped && audioState.currentAyahNumber != null)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: SizedBox(
                      width: discDiameter,
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
                                horizontal: 10,
                                vertical: 4,
                              ),
                              child: const Text(
                                'ادامه تلاوت',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.1,
                                ),
                              ),
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
