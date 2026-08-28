import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/downloader/file_download_providers.dart';
import '../../../../core/services/audio_storage/audio_storage_providers.dart';
import '../../../../core/services/audio/audio_url_helper.dart';
import '../../../quran_reader/application/ayah_service.dart';
import '../../../quran_reader/domain/entities/reciter_entity.dart';
import '../../domain/entities/audio_download_task.dart';

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

  String _buildKey(int reciterId, int surahId) => 'r${reciterId}_s$surahId';

  Future<void> startDownload({
    required ReciterEntity reciter,
    required int surahId,
  }) async {
    final key = _buildKey(reciter.id, surahId);
    
    if (state[key]?.status == DownloadTaskStatus.downloading) return;

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

    state = {
      ...state,
      key: AudioDownloadTask(
        surahId: surahId,
        reciterId: reciter.id,
        status: DownloadTaskStatus.downloading,
        totalAyahs: totalAyahs,
        currentAyah: 1,
        completedAyahs: 0,
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

  void cancelDownload(int reciterId, int surahId) {
    final key = _buildKey(reciterId, surahId);
    if (state[key]?.status == DownloadTaskStatus.downloading) {
      _cancelTokens[key]?.cancel('توسط کاربر لغو شد');
      _cancelTokens.remove(key);
      final currentTask = state[key];
      if (currentTask != null) {
        state = {
          ...state,
          key: currentTask.copyWith(status: DownloadTaskStatus.canceled),
        };
      }
    }
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
