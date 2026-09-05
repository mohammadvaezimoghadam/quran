import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

final adhanVolumeTestServiceProvider = Provider<AdhanVolumeTestService>((ref) {
  final service = AdhanVolumeTestService();
  ref.onDispose(() => service.dispose());
  return service;
});

class AdhanVolumeTestService {
  AudioPlayer? _player;
  String? _cachedBeepPath;

  /// Generates a clean 300ms 880Hz PCM WAV beep sound with smooth fade envelope
  Future<Uint8List> _generateBeepWavBytes() async {
    const sampleRate = 44100;
    const durationSeconds = 0.3; // 300ms
    const frequency = 880.0; // 880Hz pitch (A5 note)

    final numSamples = (sampleRate * durationSeconds).toInt();
    final dataSize = numSamples * 2;
    final fileSize = 36 + dataSize;

    final bytes = ByteData(44 + dataSize);

    // RIFF header
    bytes.setUint8(0, 0x52); // R
    bytes.setUint8(1, 0x49); // I
    bytes.setUint8(2, 0x46); // F
    bytes.setUint8(3, 0x46); // F
    bytes.setUint32(4, fileSize, Endian.little);
    bytes.setUint8(8, 0x57); // W
    bytes.setUint8(9, 0x41); // A
    bytes.setUint8(10, 0x56); // V
    bytes.setUint8(11, 0x45); // E

    // fmt subchunk
    bytes.setUint8(12, 0x66); // f
    bytes.setUint8(13, 0x6D); // m
    bytes.setUint8(14, 0x74); // t
    bytes.setUint8(15, 0x20); // ' '
    bytes.setUint32(16, 16, Endian.little); // Subchunk1Size (PCM)
    bytes.setUint16(20, 1, Endian.little); // AudioFormat (PCM)
    bytes.setUint16(22, 1, Endian.little); // NumChannels (Mono)
    bytes.setUint32(24, sampleRate, Endian.little); // SampleRate
    bytes.setUint32(28, sampleRate * 2, Endian.little); // ByteRate
    bytes.setUint16(32, 2, Endian.little); // BlockAlign
    bytes.setUint16(34, 16, Endian.little); // BitsPerSample

    // data subchunk
    bytes.setUint8(36, 0x64); // d
    bytes.setUint8(37, 0x61); // a
    bytes.setUint8(38, 0x74); // t
    bytes.setUint8(39, 0x61); // a
    bytes.setUint32(40, dataSize, Endian.little);

    // Sine wave samples with fade-in and fade-out to prevent audio clicks
    var offset = 44;
    for (var i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      var envelope = 1.0;
      if (i < 500) {
        envelope = i / 500;
      } else if (i > numSamples - 500) {
        envelope = (numSamples - i) / 500;
      }
      final sampleVal = (sin(2 * pi * frequency * t) * 20000 * envelope).toInt();
      bytes.setInt16(offset, sampleVal, Endian.little);
      offset += 2;
    }

    return bytes.buffer.asUint8List();
  }

  /// Plays the test beep at the target volume level (10 to 100)
  Future<void> playTestBeep(int volumeLevel) async {
    try {
      _player ??= AudioPlayer();
      await _player!.setAndroidAudioAttributes(
        const AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          usage: AndroidAudioUsage.alarm,
        ),
      );

      if (_cachedBeepPath == null) {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/adhan_test_beep.wav');
        if (!await file.exists()) {
          final wavBytes = await _generateBeepWavBytes();
          await file.writeAsBytes(wavBytes);
        }
        _cachedBeepPath = file.path;
      }

      await _player!.stop();
      final volume = (volumeLevel / 100.0).clamp(0.0, 1.0);
      await _player!.setVolume(volume);
      await _player!.setFilePath(_cachedBeepPath!);
      await _player!.seek(Duration.zero);
      await _player!.play();
    } catch (_) {
      // Ignore if player busy
    }
  }

  void dispose() {
    _player?.dispose();
    _player = null;
  }
}
