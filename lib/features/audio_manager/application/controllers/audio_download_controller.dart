import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/downloader/file_download_providers.dart';
import '../../../../core/services/audio_storage/audio_storage_providers.dart';
import '../../../../core/services/audio/audio_url_helper.dart';
import '../../../quran_reader/application/ayah_service.dart';
import '../../../quran_reader/domain/entities/reciter_entity.dart';
import '../../../../core/services/network/network_info_helper.dart';
import '../../../download_manager/infrastructure/datasources/download_manager_local_datasource.dart';
import '../../domain/entities/audio_download_task.dart';
import 'surah_downloaded_ayahs_provider.dart';

typedef DownloadTaskMap = Map<String, AudioDownloadTask>;

final audioDownloadControllerProvider = NotifierProvider<AudioDownloadController, DownloadTaskMap>(() {
  return AudioDownloadController();
});

class AudioDownloadController extends Notifier<DownloadTaskMap> {
  final Map<String, CancelToken> _cancelTokens = {};

  @override
  DownloadTaskMap build() {
    ref.onDispose(() {
      for (final token in _cancelTokens.values) {
        token.cancel();
      }
      _cancelTokens.clear();
    });
    return {};
  }

  Future<void> cancelAllDownloads() async {
    for (final token in _cancelTokens.values) {
      token.cancel('لغو به دلیل پاک‌سازی کلی');
    }
    _cancelTokens.clear();
    state = {};
  }

  String _buildKey(int reciterId, int surahId) => 'r${reciterId}_s$surahId';

  Future<void> startDownload({
    required ReciterEntity reciter,
    required int surahId,
  }) async {
    final key = _buildKey(reciter.id, surahId);
    
    if (state[key]?.status == DownloadTaskStatus.downloading) return;

    // Check Wi-Fi Only constraint
    final localDataSource = ref.read(downloadManagerLocalDataSourceProvider);
    final isWifiOnly = localDataSource.getWifiOnlyPreference();
    if (isWifiOnly) {
      final isWifi = await NetworkInfoHelper.isWifiConnected();
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
      }
      _cancelTokens[key]?.cancel('توسط کاربر متوقف شد');
      _cancelTokens.remove(key);
    }
  }

  Future<void> resumeDownload({
    required ReciterEntity reciter,
    required int surahId,
  }) async {
    await startDownload(reciter: reciter, surahId: surahId);
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
    }
  }
}
