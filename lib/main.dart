import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/data/local/preferences/preferences_service_provider.dart';
import 'core/services/audio/audio_player_providers.dart';
import 'core/services/audio/quran_audio_handler.dart';
import 'core/services/audio_storage/audio_storage_service_impl.dart';
import 'features/translation_manager/infrastructure/datasources/translation_local_datasource.dart';
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

  final rawPlayer = AudioPlayer();
  final audioHandler = await AudioService.init(
    builder: () => QuranAudioHandler(rawPlayer),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.mohammadvaezimoghadam.quran.audio',
      androidNotificationChannelName: 'پخش صوت قرآن',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      androidNotificationIcon: 'mipmap/ic_launcher',
    ),
  );

  await Hive.initFlutter();
  await Hive.openBox(TranslationLocalDataSource.boxName);
  await Hive.openBox(AudioStorageServiceImpl.boxName);

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesInstanceProvider.overrideWithValue(sharedPreferences),
        rawAudioPlayerProvider.overrideWithValue(rawPlayer),
        quranAudioHandlerProvider.overrideWithValue(audioHandler),
      ],
      child: const MainWidget(),
    ),
  );
}
