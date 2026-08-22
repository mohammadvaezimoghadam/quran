import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/audio/audio_player_providers.dart';
import '../../application/controllers/quran_audio_controller.dart';

/// Reusable mini progress slider for audio player.
/// Maintains fixed height to avoid layout shift when track changes.
class AudioMiniProgressSlider extends ConsumerWidget {
  const AudioMiniProgressSlider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final audioState = ref.watch(quranAudioControllerProvider);

    final durationMs = audioState.duration.inMilliseconds.toDouble();
    final positionMs = audioState.position.inMilliseconds.toDouble();

    final maxVal = durationMs > 0 ? durationMs : 1.0;
    final currentVal = durationMs > 0 ? positionMs.clamp(0.0, durationMs) : 0.0;

    return SliderTheme(
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
  }
}
