import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/audio/audio_player_providers.dart';
import '../../application/controllers/quran_audio_controller.dart';

/// Ultra-sleek top-edge interactive progress bar.
/// Sits flush at the top edge of the audio player capsule.
/// Offers a generous touch target (12px) with a slim 3.5px visual bar.
class AudioTopEdgeProgressBar extends ConsumerWidget {
  final EdgeInsetsGeometry padding;
  final double height;

  const AudioTopEdgeProgressBar({
    super.key,
    this.padding = EdgeInsets.zero,
    this.height = 3.5,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final duration = ref.watch(quranAudioControllerProvider.select((s) => s.duration));
    final position = ref.watch(quranAudioControllerProvider.select((s) => s.position));

    final durationMs = duration.inMilliseconds.toDouble();
    final positionMs = position.inMilliseconds.toDouble();
    final progress = (durationMs > 0) ? (positionMs / durationMs).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) {
              if (durationMs > 0 && totalWidth > 0) {
                // RTL reading: 0% starts on the right, 100% ends on the left
                final ratio = ((totalWidth - details.localPosition.dx) / totalWidth).clamp(0.0, 1.0);
                ref.read(audioPlayerServiceProvider).seek(
                      Duration(milliseconds: (ratio * durationMs).toInt()),
                    );
              }
            },
            onHorizontalDragUpdate: (details) {
              if (durationMs > 0 && totalWidth > 0) {
                // RTL reading: 0% starts on the right, 100% ends on the left
                final ratio = ((totalWidth - details.localPosition.dx) / totalWidth).clamp(0.0, 1.0);
                ref.read(audioPlayerServiceProvider).seek(
                      Duration(milliseconds: (ratio * durationMs).toInt()),
                    );
              }
            },
            child: SizedBox(
              height: 7.0, // Touch target height
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: height,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(1.5),
                    child: Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        // Inactive background track
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.16),
                          ),
                        ),
                        // Active progress track (expands from Right to Left)
                        FractionallySizedBox(
                          alignment: Alignment.centerRight,
                          widthFactor: progress,
                          child: Container(
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Compact tabular timestamp for audio playback.
class AudioTimestampText extends ConsumerWidget {
  final bool isElapsed;

  const AudioTimestampText({
    super.key,
    required this.isElapsed,
  });

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final duration = ref.watch(quranAudioControllerProvider.select((s) => s.duration));
    final position = ref.watch(quranAudioControllerProvider.select((s) => s.position));

    final text = isElapsed ? _formatDuration(position) : _formatDuration(duration);

    return Text(
      text,
      style: TextStyle(
        fontSize: 10.0,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}

/// Legacy progress slider kept for backwards compatibility if needed.
class AudioMiniProgressSlider extends ConsumerWidget {
  final bool showTimestamps;

  const AudioMiniProgressSlider({
    super.key,
    this.showTimestamps = false,
  });

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final audioState = ref.watch(quranAudioControllerProvider);

    final durationMs = audioState.duration.inMilliseconds.toDouble();
    final positionMs = audioState.position.inMilliseconds.toDouble();

    final maxVal = durationMs > 0 ? durationMs : 1.0;
    final currentVal = durationMs > 0 ? positionMs.clamp(0.0, durationMs) : 0.0;

    final sliderWidget = SliderTheme(
      data: SliderTheme.of(context).copyWith(
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 3.5),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 7),
        trackHeight: 2.5,
        activeTrackColor: colorScheme.primary,
        inactiveTrackColor: colorScheme.primary.withValues(alpha: 0.15),
        thumbColor: colorScheme.primary,
      ),
      child: SizedBox(
        height: 12,
        child: Slider(
          value: currentVal,
          max: maxVal,
          onChanged: durationMs > 0
              ? (value) {
                  ref
                      .read(audioPlayerServiceProvider)
                      .seek(Duration(milliseconds: value.toInt()));
                }
              : null,
        ),
      ),
    );

    if (!showTimestamps) {
      return sliderWidget;
    }

    final posText = _formatDuration(audioState.position);
    final durText = _formatDuration(audioState.duration);
    final timeStyle = TextStyle(
      fontSize: 9.0,
      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        sliderWidget,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(posText, style: timeStyle),
              Text(durText, style: timeStyle),
            ],
          ),
        ),
      ],
    );
  }
}

