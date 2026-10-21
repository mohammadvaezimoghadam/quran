import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Platform bridge connecting Flutter audio controllers to native Android AudioEffects
/// (PresetReverb and Vintage Radio Bandpass Equalizer).
class NativeAudioEffectsBridge {
  static const _channel = MethodChannel('com.qurantafakor.app/audio_effects');

  /// Applies or disables the native hardware bandpass Equalizer for Vintage Radio effect.
  static Future<bool> applyRadioFilter({
    required int sessionId,
    required bool enabled,
  }) async {
    if (defaultTargetPlatform != TargetPlatform.android || sessionId <= 0) {
      return false;
    }
    try {
      final res = await _channel.invokeMethod<bool>('applyRadioFilter', {
        'sessionId': sessionId,
        'enabled': enabled,
      });
      return res ?? false;
    } catch (e) {
      debugPrint('⚠️ [NativeAudioEffectsBridge] applyRadioFilter error: $e');
      return false;
    }
  }

  /// Applies or disables native hardware Reverb effect.
  static Future<bool> applyReverb({
    required int sessionId,
    required int preset,
    required bool enabled,
  }) async {
    if (defaultTargetPlatform != TargetPlatform.android || sessionId <= 0) {
      return false;
    }
    try {
      final res = await _channel.invokeMethod<bool>('applyReverb', {
        'sessionId': sessionId,
        'preset': preset,
        'enabled': enabled,
      });
      return res ?? false;
    } catch (e) {
      debugPrint('⚠️ [NativeAudioEffectsBridge] applyReverb error: $e');
      return false;
    }
  }

  /// Releases native audio effect hardware handles.
  static Future<void> release() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _channel.invokeMethod('release');
    } catch (e) {
      debugPrint('⚠️ [NativeAudioEffectsBridge] release error: $e');
    }
  }
}
