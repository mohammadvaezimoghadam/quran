import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dio/dio.dart';
import 'package:flutter_patcher/flutter_patcher.dart';
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

Future<void> _checkAndApplyPatch() async {
  try {
    const serverIp = '192.168.1.103';
    const port = 8080;

    final currentPatch = await FlutterPatcher.currentVersion;
    final versionCode = await FlutterPatcher.appVersionCode;
    final abi = await FlutterPatcher.deviceAbi;

    debugPrint('🔍 [Patcher] Current Patch: $currentPatch, AppVersionCode: $versionCode, ABI: $abi');

    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 4),
      receiveTimeout: const Duration(seconds: 15),
    ));

    final url = 'http://$serverIp:$port/check';
    final response = await dio.get(
      url,
      queryParameters: {
        'app_version_code': versionCode,
        'abi': abi,
      },
    );

    if (response.statusCode != 200 || response.data == null) {
      debugPrint('⚠️ [Patcher] Server responded with code: ${response.statusCode}');
      return;
    }

    final data = response.data;
    if (data is! Map || data['has_update'] != true) {
      debugPrint('ℹ️ [Patcher] No update available.');
      return;
    }

    debugPrint('📦 [Patcher] Update found: version=${data['version']}, url=${data['patch_url']}');

    final patch = PatchInfo(
      version: data['version'].toString(),
      patchUrl: data['patch_url'].toString(),
      md5: (data['md5'] ?? '').toString(),
      targetVersionCode: data['target_version_code'] as int? ?? 1,
    );

    final result = await FlutterPatcher.applyPatch(
      patch,
      onProgress: (p) {
        final percent = ((p.fraction ?? 0) * 100).toStringAsFixed(0);
        debugPrint('⏳ [Patcher Progress] ${p.phase.name}: $percent%');
      },
    );

    if (result.ok) {
      debugPrint('✅ [Patcher] Patch applied successfully! Restart the app to take effect.');
    } else {
      debugPrint('❌ [Patcher] Failed to apply patch: ${result.error} - ${result.message}');
    }
  } catch (e) {
    debugPrint('❌ [Patcher Error] $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterPatcher.init();
  _checkAndApplyPatch();

  await _loadCustomFonts();
  await _initAudioSession();

  // Initialize Firebase and Push Notification Service
  await FirebaseInitializer.init();
  final pushNotificationService = FirebasePushNotificationServiceImpl();
  await pushNotificationService.initialize();

  final rawPlayer = AudioPlayer();
  final audioHandler = await AudioService.init(
    builder: () => QuranAudioHandler(rawPlayer),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.qurantafakor.app.audio',
      androidNotificationChannelName: 'پخش صوت قرآن',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      androidNotificationIcon: 'mipmap/ic_launcher',
    ),
  );

  await Hive.initFlutter();
  await Hive.openBox(TranslationLocalDataSource.boxName);
  await Hive.openBox(AudioStorageServiceImpl.boxName);
  await Hive.openBox(BookmarkLocalDataSource.boxName);

  final sharedPreferences = await SharedPreferences.getInstance();

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
