import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/data/local/preferences/preferences_service_provider.dart';
import '../../../../core/services/downloader/file_download_providers.dart';
import '../../../../core/services/audio_storage/audio_storage_providers.dart';
import '../../../../core/services/audio/audio_url_helper.dart';
import '../../../quran_reader/application/ayah_service.dart';
import '../../../quran_reader/application/controllers/reciter_providers.dart';
import '../../../quran_reader/domain/entities/reciter_entity.dart';
import '../../../../core/services/network/network_info_helper.dart';
import '../../../download_manager/infrastructure/datasources/download_manager_local_datasource.dart';
import '../../../subscription/application/vip_subscription_controller.dart';
import '../../../subscription/domain/policy/audio_vip_policy.dart';
import '../../domain/entities/audio_download_task.dart';
import 'surah_downloaded_ayahs_provider.dart';

typedef DownloadTaskMap = Map<String, AudioDownloadTask>;

final audioDownloadControllerProvider = NotifierProvider<AudioDownloadController, DownloadTaskMap>(() {
  return AudioDownloadController();
});

class AudioDownloadController extends Notifier<DownloadTaskMap> {
  static const String _persistedTasksKey = 'persisted_audio_download_tasks_v1';
  final Map<String, CancelToken> _cancelTokens = {};

  @override
  DownloadTaskMap build() {
    ref.onDispose(() {
      for (final token in _cancelTokens.values) {
        token.cancel();
      }
      _cancelTokens.clear();
    });

    final initialTasks = _loadPersistedTasks();
    scheduleMicrotask(_verifyAndSyncTasks);
    return initialTasks;
  }

  DownloadTaskMap _loadPersistedTasks() {
    try {
      final prefs = ref.read(sharedPreferencesInstanceProvider);
      final rawJson = prefs.getString(_persistedTasksKey);
      if (rawJson == null || rawJson.isEmpty) return {};

      final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
      final DownloadTaskMap loaded = {};

      for (final entry in decoded.entries) {
        try {
          final task = AudioDownloadTaskSerialization.fromJsonMap(
            entry.value as Map<String, dynamic>,
          );
          // If task was downloading when the app terminated, restore it as paused
          final restoredStatus = task.status == DownloadTaskStatus.downloading
              ? DownloadTaskStatus.paused
              : task.status;

          // Only keep active queue tasks (paused or failed)
          if (restoredStatus == DownloadTaskStatus.paused ||
              restoredStatus == DownloadTaskStatus.failed ||
              restoredStatus == DownloadTaskStatus.downloading) {
            loaded[entry.key] = task.copyWith(status: restoredStatus);
          }
        } catch (e) {
          developer.log('Error parsing task ${entry.key}: $e', name: 'AudioDownload');
        }
      }
      return loaded;
    } catch (e) {
      developer.log('Error loading persisted download tasks: $e', name: 'AudioDownload');
      return {};
    }
  }

  void _saveTasksToPrefs() {
    try {
      final prefs = ref.read(sharedPreferencesInstanceProvider);
      final activeTasks = <String, dynamic>{};
      for (final entry in state.entries) {
        final task = entry.value;
        if (task.status == DownloadTaskStatus.downloading ||
            task.status == DownloadTaskStatus.paused ||
            task.status == DownloadTaskStatus.failed) {
          activeTasks[entry.key] = task.toJsonMap();
        }
      }
      if (activeTasks.isEmpty) {
        prefs.remove(_persistedTasksKey);
      } else {
        prefs.setString(_persistedTasksKey, jsonEncode(activeTasks));
      }
    } catch (e) {
      developer.log('Error saving persisted download tasks: $e', name: 'AudioDownload');
    }
  }

  Future<void> _verifyAndSyncTasks() async {
    try {
      final storage = ref.read(audioStorageServiceProvider);
      final ayahService = ref.read(ayahServiceProvider);
      var currentTasks = Map<String, AudioDownloadTask>.from(state);
      bool stateChanged = false;

      // 1. Verify and update currently tracked tasks against actual disk files
      for (final key in currentTasks.keys.toList()) {
        final task = currentTasks[key]!;
        final isCompleted = storage.isSurahDownloaded(task.reciterId, task.surahId);
        if (isCompleted) {
          currentTasks.remove(key);
          stateChanged = true;
          continue;
        }

        final actualAyahs = await storage.getDownloadedAyahsCount(
          reciterId: task.reciterId,
          surahId: task.surahId,
          totalAyahs: task.totalAyahs,
        );

        if (task.totalAyahs > 0 && actualAyahs >= task.totalAyahs) {
          await storage.markSurahAsDownloaded(task.reciterId, task.surahId);
          currentTasks.remove(key);
          stateChanged = true;
        } else if (actualAyahs != task.completedAyahs) {
          currentTasks[key] = task.copyWith(
            completedAyahs: actualAyahs,
            currentAyah: actualAyahs > 0 ? actualAyahs : 1,
            progress: task.totalAyahs > 0 ? actualAyahs / task.totalAyahs : 0.0,
            status: (task.status == DownloadTaskStatus.downloading && !_cancelTokens.containsKey(key))
                ? DownloadTaskStatus.paused
                : task.status,
          );
          stateChanged = true;
        }
      }

      // 2. Discover un-tracked partial downloads on physical disk
      // (e.g. downloads made prior to task persistence or interrupted sessions)
      final rootAudioPath = await storage.getRootAudioStorageDirectory();
      final rootDir = Directory(rootAudioPath);
      if (await rootDir.exists()) {
        await for (final reciterEntity in rootDir.list(followLinks: false)) {
          if (reciterEntity is Directory) {
            final reciterDirName = reciterEntity.path.split(Platform.pathSeparator).last;
            final reciterMatch = RegExp(r'^reciter_(\d+)$').firstMatch(reciterDirName);
            if (reciterMatch == null) continue;
            final reciterId = int.tryParse(reciterMatch.group(1) ?? '');
            if (reciterId == null) continue;

            await for (final surahEntity in reciterEntity.list(followLinks: false)) {
              if (surahEntity is Directory) {
                final surahDirName = surahEntity.path.split(Platform.pathSeparator).last;
                final surahMatch = RegExp(r'^surah_(\d+)$').firstMatch(surahDirName);
                if (surahMatch == null) continue;
                final surahId = int.tryParse(surahMatch.group(1) ?? '');
                if (surahId == null) continue;

                // Check if already fully marked
                if (storage.isSurahDownloaded(reciterId, surahId)) continue;

                final key = _buildKey(reciterId, surahId);
                if (currentTasks.containsKey(key)) continue;

                // Check if there are any mp3 files inside
                int fileCount = 0;
                await for (final f in surahEntity.list(followLinks: false)) {
                  if (f is File && f.path.endsWith('.mp3')) {
                    fileCount++;
                  }
                }
                if (fileCount == 0) continue;

                // Fetch total ayahs for this surah
                final ayahsResult = await ayahService.getAyahsBySurah(surahId);
                final totalAyahs = ayahsResult.tryGetSuccess()?.length ?? 0;
                if (totalAyahs == 0) continue;

                final actualAyahs = await storage.getDownloadedAyahsCount(
                  reciterId: reciterId,
                  surahId: surahId,
                  totalAyahs: totalAyahs,
                );

                if (actualAyahs >= totalAyahs) {
                  await storage.markSurahAsDownloaded(reciterId, surahId);
                } else if (actualAyahs > 0) {
                  currentTasks[key] = AudioDownloadTask(
                    surahId: surahId,
                    reciterId: reciterId,
                    status: DownloadTaskStatus.paused,
                    totalAyahs: totalAyahs,
                    completedAyahs: actualAyahs,
                    currentAyah: actualAyahs,
                    progress: actualAyahs / totalAyahs,
                  );
                  stateChanged = true;
                }
              }
            }
          }
        }
      }

      if (stateChanged) {
        state = currentTasks;
        _saveTasksToPrefs();
        ref.invalidate(surahDownloadedAyahsCountProvider);
      }
    } catch (e) {
      developer.log('Error verifying and syncing download tasks: $e', name: 'AudioDownload');
    }
  }

  Future<void> cancelAllDownloads({int? reciterId}) async {
    final storage = ref.read(audioStorageServiceProvider);
    final tasksToCancel = state.values.where((task) {
      if (reciterId != null) {
        return task.reciterId == reciterId;
      }
      return true;
    }).toList();

    for (final task in tasksToCancel) {
      final key = _buildKey(task.reciterId, task.surahId);
      _cancelTokens[key]?.cancel('توسط کاربر لغو شد');
      _cancelTokens.remove(key);
      await storage.deleteSurahAudio(
        reciterId: task.reciterId,
        surahId: task.surahId,
      );
    }

    if (reciterId != null) {
      final updatedState = Map<String, AudioDownloadTask>.from(state);
      updatedState.removeWhere((_, task) => task.reciterId == reciterId);
      state = updatedState;
      _saveTasksToPrefs();
    } else {
      for (final token in _cancelTokens.values) {
        token.cancel('لغو به دلیل پاک‌سازی کلی');
      }
      _cancelTokens.clear();
      state = {};
      _saveTasksToPrefs();
    }

    ref.invalidate(surahDownloadedAyahsCountProvider);
  }

  String _buildKey(int reciterId, int surahId) => 'r${reciterId}_s$surahId';

  Future<void> startDownload({
    required ReciterEntity reciter,
    required int surahId,
  }) async {
    final key = _buildKey(reciter.id, surahId);
    developer.log('startDownload requested: reciter=${reciter.name} (id=${reciter.id}, subfolder=${reciter.subfolder}), surah=$surahId', name: 'AudioDownload');
    
    if (state[key]?.status == DownloadTaskStatus.downloading) {
      developer.log('startDownload ignored: already downloading $key', name: 'AudioDownload');
      return;
    }

    // Check VIP Access constraint
    final isVip = ref.read(hasVipAccessProvider);
    final canDownload = reciter.styleId == 4
        ? AudioVipPolicy.canPlayAudioTranslation(isVip: isVip)
        : AudioVipPolicy.canPlayReciter(
            reciterIdentifier: reciter.identifier,
            surahId: surahId,
            isVip: isVip,
          );

    if (!canDownload) {
      final errorMsg = reciter.styleId == 4
          ? 'دانلود ترجمه صوتی نیازمند اشتراک ویژه است.'
          : 'دانلود این سوره با صدای ${reciter.name} نیازمند اشتراک ویژه است.';
      developer.log('startDownload blocked by AudioVipPolicy: reciter=${reciter.name}, surah=$surahId, isVip=$isVip', name: 'AudioDownload');
      _markAsFailed(key, errorMsg);
      return;
    }

    // Check Wi-Fi Only constraint
    final localDataSource = ref.read(downloadManagerLocalDataSourceProvider);
    final isWifiOnly = localDataSource.getWifiOnlyPreference();
    if (isWifiOnly) {
      final isWifi = await NetworkInfoHelper.isWifiConnected();
      developer.log('isWifiOnly=$isWifiOnly, isWifiConnected=$isWifi', name: 'AudioDownload');
      if (!isWifi) {
        _markAsFailed(key, 'دانلود انجام نشد: تنظیم «فقط با وای‌فای» فعال است.');
        return;
      }
    }

    final ayahService = ref.read(ayahServiceProvider);
    final ayahsResult = await ayahService.getAyahsBySurah(surahId);

    if (ayahsResult.isError()) {
      _markAsFailed(key, 'خطا در دریافت اطلاعات سوره‌');
      return;
    }

    final ayahs = ayahsResult.tryGetSuccess()!;
    if (ayahs.isEmpty) {
      _markAsFailed(key, 'آیه‌ای برای دانلود یافت نشد');
      return;
    }

    final totalAyahs = ayahs.length;
    final existingTask = state[key];
    final initialCompleted = existingTask?.completedAyahs ?? 0;
    final initialProgress = totalAyahs > 0 ? (initialCompleted / totalAyahs).clamp(0.0, 1.0) : 0.0;

    state = {
      ...state,
      key: AudioDownloadTask(
        surahId: surahId,
        reciterId: reciter.id,
        status: DownloadTaskStatus.downloading,
        totalAyahs: totalAyahs,
        currentAyah: existingTask?.currentAyah ?? 1,
        completedAyahs: initialCompleted,
        progress: initialProgress,
      ),
    };
    _saveTasksToPrefs();

    final cancelToken = CancelToken();
    _cancelTokens[key] = cancelToken;

    final downloader = ref.read(fileDownloadServiceProvider);
    final storage = ref.read(audioStorageServiceProvider);

    final dirPath = await storage.getSurahSaveDirectory(
      reciterId: reciter.id,
      surahId: surahId,
    );

    int completedAyahs = 0;
    bool isCanceled = false;

    for (final ayah in ayahs) {
      if (cancelToken.isCancelled) {
        isCanceled = true;
        break;
      }

      final savePath = '$dirPath/ayah_${ayah.ayahNumber}.mp3';
      final file = File(savePath);

      // Skip already downloaded Ayah files
      if (await file.exists() && await file.length() > 0) {
        completedAyahs++;
        final initialProgress = completedAyahs / totalAyahs;
        state = {
          ...state,
          key: state[key]!.copyWith(
            progress: initialProgress,
            completedAyahs: completedAyahs,
            currentAyah: ayah.ayahNumber,
          ),
        };
        continue;
      }

      final url = AudioUrlHelper.buildAyahUrl(
        subfolder: reciter.subfolder,
        surahNumber: surahId,
        ayahNumber: ayah.ayahNumber, 
      );

      state = {
        ...state,
        key: state[key]!.copyWith(
          currentAyah: ayah.ayahNumber,
          completedAyahs: completedAyahs,
        ),
      };

      final result = await downloader.downloadFile(
        url: url,
        savePath: savePath,
        cancelToken: cancelToken,
        onProgress: (received, total) {
          if (total > 0 && !cancelToken.isCancelled) {
            final ayahProgress = received / total;
            final overallProgress = (completedAyahs + ayahProgress) / totalAyahs;
            
            if (state[key]?.status == DownloadTaskStatus.downloading) {
              state = {
                ...state,
                key: state[key]!.copyWith(
                  progress: overallProgress,
                  currentAyah: ayah.ayahNumber,
                  completedAyahs: completedAyahs,
                ),
              };
            }
          }
        },
      );

      if (result.isError()) {
        if (cancelToken.isCancelled) {
          isCanceled = true;
          // Delete incomplete/corrupt file
          if (await file.exists()) {
            try { await file.delete(); } catch (_) {}
          }
        } else {
          _markAsFailed(key, result.tryGetError()!.message);
        }
        return; 
      }

      completedAyahs++;
      if (state[key]?.status == DownloadTaskStatus.downloading) {
        state = {
          ...state,
          key: state[key]!.copyWith(
            completedAyahs: completedAyahs,
            progress: completedAyahs / totalAyahs,
            currentAyah: ayah.ayahNumber,
          ),
        };
        _saveTasksToPrefs();
      }
    }

    _cancelTokens.remove(key);

    if (!isCanceled && !cancelToken.isCancelled) {
      await storage.markSurahAsDownloaded(reciter.id, surahId);
      state = {
        ...state,
        key: state[key]!.copyWith(
          progress: 1.0,
          completedAyahs: totalAyahs,
          status: DownloadTaskStatus.completed,
        ),
      };
      _saveTasksToPrefs();
      ref.invalidate(surahDownloadedAyahsCountProvider);
    }
  }

  void pauseDownload(int reciterId, int surahId) {
    final key = _buildKey(reciterId, surahId);
    if (state[key]?.status == DownloadTaskStatus.downloading) {
      final currentTask = state[key];
      if (currentTask != null) {
        state = {
          ...state,
          key: currentTask.copyWith(status: DownloadTaskStatus.paused),
        };
        _saveTasksToPrefs();
      }
      _cancelTokens[key]?.cancel('توسط کاربر متوقف شد');
      _cancelTokens.remove(key);
      ref.invalidate(surahDownloadedAyahsCountProvider);
    }
  }

  Future<void> resumeDownload({
    required ReciterEntity reciter,
    required int surahId,
  }) async {
    await startDownload(reciter: reciter, surahId: surahId);
  }

  Future<void> resumeDownloadById({
    required int reciterId,
    required int surahId,
  }) async {
    final allRecitersResult = await ref.read(allRecitersListProvider.future);
    final reciter = allRecitersResult
        .tryGetSuccess()
        ?.where((r) => r.id == reciterId)
        .firstOrNull;
    if (reciter != null) {
      await startDownload(reciter: reciter, surahId: surahId);
    }
  }

  Future<void> cancelDownload(int reciterId, int surahId) async {
    final key = _buildKey(reciterId, surahId);
    
    // 1. Cancel running network download if active
    _cancelTokens[key]?.cancel('توسط کاربر لغو شد');
    _cancelTokens.remove(key);

    // 2. Delete ALL partial/complete audio files from physical disk and Hive FIRST
    final storage = ref.read(audioStorageServiceProvider);
    await storage.deleteSurahAudio(reciterId: reciterId, surahId: surahId);

    // 3. Remove the task completely from active state AFTER disk cleanup
    if (state.containsKey(key)) {
      final updatedState = Map<String, AudioDownloadTask>.from(state);
      updatedState.remove(key);
      state = updatedState;
      _saveTasksToPrefs();
    }

    // 4. Invalidate providers so UI surah grids immediately reflect 0 downloaded ayahs
    ref.invalidate(surahDownloadedAyahsCountProvider);
  }

  void _markAsFailed(String key, String error) {
    _cancelTokens.remove(key);
    if (state.containsKey(key)) {
      state = {
        ...state,
        key: state[key]!.copyWith(
          status: DownloadTaskStatus.failed,
          errorMessage: error,
        ),
      };
      _saveTasksToPrefs();
    }
  }
}
