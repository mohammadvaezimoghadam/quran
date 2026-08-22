import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/constants/surah_constants.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../core/services/audio/audio_player_state.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../quran_reader/application/controllers/quran_audio_controller.dart';
import '../../../quran_reader/presentation/ui/quran_reader_screen.dart';
import '../../application/controllers/mini_audio_player_controller.dart';

/// Ultra-optimized Telegram-style dark floating micro-capsule mini audio player.
/// Designed for 0 rebuild spillover to parent screens (e.g. HomeScreen).
class MiniAudioPlayerBar extends ConsumerWidget {
  const MiniAudioPlayerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Isolated selection: Only watch dismissal & status changes to avoid unnecessary parent rebuilds
    final isDismissed = ref.watch(
      miniAudioPlayerControllerProvider.select((s) => s.isDismissed),
    );
    final audioStatus = ref.watch(
      quranAudioControllerProvider.select((s) => s.status),
    );
    final currentSurahId = ref.watch(
      quranAudioControllerProvider.select((s) => s.currentSurahId),
    );

    // Hide if dismissed by user, audio is stopped/completed, or no active surah
    if (isDismissed ||
        audioStatus == AudioStatus.stopped ||
        audioStatus == AudioStatus.completed ||
        currentSurahId == null) {
      return const SizedBox.shrink();
    }

    final currentAyahNumber = ref.watch(
      quranAudioControllerProvider.select((s) => s.currentAyahNumber ?? 1),
    );

    final surahName = SurahConstants.getSurahName(currentSurahId);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      height: 46 + bottomInset,
      alignment: Alignment.topRight,
      color: Colors.transparent,
      padding: EdgeInsets.only(
        right: AppDimens.marginPage,
        bottom: bottomInset > 0 ? bottomInset : AppDimens.stackSm,
      ),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFA1E1E1E), // Telegram-style deep dark background
          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppDimens.radiusFull),
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Isolated Sub-Widget: Play/Pause Button + Live Progress Ring
                // Only this sub-widget rebuilds during high-frequency position ticks
                const _MiniPlayPauseButtonWithProgress(),
                10.hSpace,

                // 2. Surah Persian Name & Ayah Text
                Text(
                  'سوره $surahName • آیه $currentAyahNumber',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                8.hSpace,

                // 3. Mini Close Button (Stop playback & Dismiss pill)
                GestureDetector(
                  onTap: () {
                    ref.read(miniAudioPlayerControllerProvider.notifier).dismiss();
                    ref.read(quranAudioControllerProvider.notifier).stop();
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
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
        ),
      ),
    );
  }
}

/// Isolated Sub-Widget for Play/Pause action and Nano Progress Ring.
/// Isolates high-frequency position rebuilds to this 28x28 widget only.
class _MiniPlayPauseButtonWithProgress extends ConsumerWidget {
  const _MiniPlayPauseButtonWithProgress();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(
      quranAudioControllerProvider.select((s) => s.status),
    );
    final position = ref.watch(
      quranAudioControllerProvider.select((s) => s.position),
    );
    final duration = ref.watch(
      quranAudioControllerProvider.select((s) => s.duration),
    );

    final isPlaying = status == AudioStatus.playing;
    final colorScheme = Theme.of(context).colorScheme;

    final double progress = (duration.inMilliseconds > 0)
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return SizedBox(
      width: 28,
      height: 28,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Track Ring
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 2,
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          // Live Progress Ring
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 2,
              color: colorScheme.primary,
              strokeCap: StrokeCap.round,
            ),
          ),
          // Play/Pause Action Target
          GestureDetector(
            onTap: () {
              final controller = ref.read(quranAudioControllerProvider.notifier);
              if (isPlaying) {
                controller.pause();
              } else {
                controller.resume();
              }
            },
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPlaying ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
                size: 13,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
