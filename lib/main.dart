import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'core/data/local/preferences/preferences_service_provider.dart';
import 'core/services/audio/audio_player_providers.dart';
import 'core/services/audio/quran_audio_handler.dart';
import 'core/services/audio_storage/audio_storage_service_impl.dart';
import 'core/services/firebase/firebase_initializer.dart';
import 'core/services/notification/firebase_push_notification_service_impl.dart';
import 'core/services/notification/push_notification_providers.dart';
import 'features/bookmarks/infrastructure/datasources/bookmark_local_datasource.dart';
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
  if (kIsWeb) return;
  try {
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
  } catch (_) {}
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    usePathUrlStrategy();
  }

  // Initialize critical local services concurrently for fast startup
  final initFutures = Future.wait([
    _loadCustomFonts().catchError((e) {
      debugPrint('Custom fonts load error: $e');
    }),
    _initAudioSession().catchError((e) {
      debugPrint('Audio session error: $e');
    }),
    Hive.initFlutter().then((_) => Future.wait([
      Hive.openBox(TranslationLocalDataSource.boxName),
      Hive.openBox(AudioStorageServiceImpl.boxName),
      Hive.openBox(BookmarkLocalDataSource.boxName),
    ])).catchError((e) {
      debugPrint('Hive init error: $e');
      return [];
    }),
    SharedPreferences.getInstance(),
    FirebaseInitializer.init().catchError((e) {
      debugPrint('Firebase init error: $e');
    }),
  ]);

  final rawPlayer = AudioPlayer();
  final QuranAudioHandler audioHandler;
  if (kIsWeb) {
    audioHandler = QuranAudioHandler(rawPlayer);
  } else {
    audioHandler = await AudioService.init(
      builder: () => QuranAudioHandler(rawPlayer),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.qurantafakor.app.audio',
        androidNotificationChannelName: 'پخش صوت قرآن',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
        androidNotificationIcon: 'mipmap/ic_launcher',
      ),
    );
  }

  final results = await initFutures;
  final sharedPreferences = results[3] as SharedPreferences;

  // Initialize Push Notification Service in background without blocking app launch
  final pushNotificationService = FirebasePushNotificationServiceImpl();
  unawaited(pushNotificationService.initialize());

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesInstanceProvider.overrideWithValue(sharedPreferences),
        rawAudioPlayerProvider.overrideWithValue(rawPlayer),
        quranAudioHandlerProvider.overrideWithValue(audioHandler),
        pushNotificationServiceProvider.overrideWithValue(pushNotificationService),
      ],
      child: const MainWidget(),
    ),
  );
}
