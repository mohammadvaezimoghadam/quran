import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/constants/surah_constants.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../core/services/audio/audio_player_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../quran_reader/application/controllers/quran_audio_controller.dart';
import '../../../quran_reader/application/controllers/quran_display_settings_controller.dart';
import '../../../quran_reader/presentation/ui/quran_reader_screen.dart';
import '../../application/controllers/mini_audio_player_controller.dart';

/// Masterpiece Telegram-style dark gold floating micro-capsule mini audio player.
/// Designed for 0 rebuild spillover to parent screens (e.g. HomeScreen).
class MiniAudioPlayerBar extends ConsumerWidget {
  const MiniAudioPlayerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch dismiss state, audio status, and current surah ID
    final isDismissed = ref.watch(
      miniAudioPlayerControllerProvider.select((s) => s.isDismissed),
    );
    final audioStatus = ref.watch(
      quranAudioControllerProvider.select((s) => s.status),
    );
    final currentSurahId = ref.watch(
      quranAudioControllerProvider.select((s) => s.currentSurahId),
    );

    // Hide ONLY if user explicitly dismissed or no surah session or completely stopped
    if (isDismissed ||
        audioStatus == AudioStatus.stopped ||
        currentSurahId == null) {
      return const SizedBox.shrink();
    }

    final currentAyahNumber = ref.watch(
      quranAudioControllerProvider.select((s) => s.currentAyahNumber ?? 1),
    );
    final totalAyahsInSurah = ref.watch(
      quranAudioControllerProvider.select((s) => s.totalAyahsInSurah ?? 286),
    );
    final displaySettings = ref.watch(quranDisplaySettingsControllerProvider);
    final userFontFamily =
        AppTypography.getFontFamilyByScript(displaySettings.fontScript);

    final surahName = SurahConstants.getSurahName(currentSurahId);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      height: 54 + bottomInset,
      alignment: Alignment.topRight,
      color: Colors.transparent,
      padding: EdgeInsets.only(
        left: AppDimens.marginPage,
        right: AppDimens.marginPage,
        bottom: bottomInset > 0 ? bottomInset : AppDimens.stackSm,
      ),
      child: Material(
        color: Colors.transparent,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFA171A21), // Premium deep dark slate capsule
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: AppColors.goldAccent.withValues(alpha: 0.28),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. Corner Action: Play / Pause Button attached to far right corner
                      const Padding(
                        padding: EdgeInsets.only(left: 6.0, right: 4.0),
                        child: _MiniPlayPauseButton(),
                      ),

                      // 2. Middle Interactive Zone: Surah Name (User Font) + Ayah Badge
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => QuranReaderScreen(
                                surahId: currentSurahId,
                                surahName: 'سوره $surahName',
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6.0,
                            vertical: 4.0,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                'سوره $surahName',
                                style: TextStyle(
                                  fontFamily: userFontFamily,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFF4E0A5), // Elegant Gold
                                ),
                              ),
                              6.hSpace,
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer
                                      .withValues(alpha: 0.35),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'آیه $currentAyahNumber از $totalAyahsInSurah',
                                  style: const TextStyle(
                                    fontFamily: AppTypography.vazirmatnFont,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Subtle vertical separator
                      Container(
                        width: 1,
                        height: 18,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),

                      // 3. Corner Action: Separate Close Button attached to far left corner
                      InkWell(
                        onTap: () {
                          ref
                              .read(miniAudioPlayerControllerProvider.notifier)
                              .dismiss();
                          ref
                              .read(quranAudioControllerProvider.notifier)
                              .stop();
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(
                            left: 10.0,
                            right: 12.0,
                            top: 10.0,
                            bottom: 10.0,
                          ),
                          child: Icon(
                            CupertinoIcons.xmark,
                            size: 14,
                            color: Colors.white60,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Smooth Live Progress Line across the bottom edge of capsule
                const _MiniAudioProgressBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Smooth Live Progress Bar at the bottom of the capsule
class _MiniAudioProgressBar extends ConsumerWidget {
  const _MiniAudioProgressBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = ref.watch(
      quranAudioControllerProvider.select((s) => s.position),
    );
    final duration = ref.watch(
      quranAudioControllerProvider.select((s) => s.duration),
    );

    final double progress = (duration.inMilliseconds > 0)
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      tween: Tween<double>(begin: 0.0, end: progress),
      builder: (context, value, child) {
        return LinearProgressIndicator(
          value: value,
          minHeight: 2.5,
          backgroundColor: Colors.white.withValues(alpha: 0.08),
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.goldAccent),
        );
      },
    );
  }
}

/// Action button with Glowing Gold state and Loading Spinner during transitions
class _MiniPlayPauseButton extends ConsumerWidget {
  const _MiniPlayPauseButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(
      quranAudioControllerProvider.select((s) => s.status),
    );

    final isPlaying = status == AudioStatus.playing;
    final isLoading = status == AudioStatus.loading;

    return GestureDetector(
      onTap: () {
        final controller = ref.read(quranAudioControllerProvider.notifier);
        if (isPlaying) {
          controller.pause();
        } else {
          controller.resume();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isPlaying ? AppColors.goldAccent : const Color(0xFF2A2E39),
          shape: BoxShape.circle,
          boxShadow: isPlaying
              ? [
                  BoxShadow(
                    color: AppColors.goldAccent.withValues(alpha: 0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(
                  isPlaying
                      ? CupertinoIcons.pause_fill
                      : CupertinoIcons.play_fill,
                  size: 15,
                  color: isPlaying ? Colors.black : Colors.white,
                ),
        ),
      ),
    );
  }
}
