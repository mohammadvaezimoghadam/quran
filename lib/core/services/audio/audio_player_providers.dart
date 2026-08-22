import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import 'i_audio_player_service.dart';
import 'just_audio_player_service.dart';

final rawAudioPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  ref.onDispose(() {
    player.dispose();
  });
  return player;
});

final audioPlayerServiceProvider = Provider<IAudioPlayerService>((ref) {
  final rawPlayer = ref.watch(rawAudioPlayerProvider);
  final service = JustAudioPlayerService(audioPlayer: rawPlayer);
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});
