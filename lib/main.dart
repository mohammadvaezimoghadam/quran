import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/translation_manager/infrastructure/datasources/translation_local_datasource.dart';
import 'core/data/local/preferences/preferences_service_provider.dart';
import 'main_widget.dart';

Future<void> _loadCustomFonts() async {
  try {
    final thuluthLoader = FontLoader('Thuluth')
      ..addFont(rootBundle.load('assets/fonts/Thuluth.ttf'));
    await thuluthLoader.load();
  } catch (_) {}
}

/// Configure audio session for proper interaction with other apps, phone calls,
/// and headphone events on real Android/iOS devices.
Future<void> _initAudioSession() async {
  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration(
    avAudioSessionCategory: AVAudioSessionCategory.playback,
    avAudioSessionMode: AVAudioSessionMode.defaultMode,
    androidAudioAttributes: AndroidAudioAttributes(
      contentType: AndroidAudioContentType.music,
      usage: AndroidAudioUsage.media,
    ),
    androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
    androidWillPauseWhenDucked: true,
  ));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _loadCustomFonts();
  await _initAudioSession();
  
  await Hive.initFlutter();
  await Hive.openBox(TranslationLocalDataSource.boxName);
  
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesInstanceProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MainWidget(),
    ),
  );
}
