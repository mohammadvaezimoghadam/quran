import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/downloader/file_download_providers.dart';
import '../../domain/entities/moezzin.dart';
import 'adhan_manager_providers.dart';
import '../states/adhan_download_state.dart';

final adhanDownloadControllerProvider = NotifierProvider<AdhanDownloadController, AdhanDownloadState>(() {
  return AdhanDownloadController();
});

class AdhanDownloadController extends Notifier<AdhanDownloadState> {
  final Map<String, CancelToken> _cancelTokens = {};

  @override
  AdhanDownloadState build() {
    return const AdhanDownloadState();
  }

  Future<void> downloadMoezzinAudio(Moezzin moezzin) async {
    if (state.isDownloading[moezzin.id] == true) return;

    final storageService = ref.read(adhanStorageServiceProvider);
    final downloadService = ref.read(fileDownloadServiceProvider);

    // Prepare state
    state = state.copyWith(
      isDownloading: {...state.isDownloading, moezzin.id: true},
      downloadProgresses: {...state.downloadProgresses, moezzin.id: 0.0},
      downloadErrors: {...state.downloadErrors}..remove(moezzin.id),
    );

    try {
      final saveDir = await storageService.getAdhanSaveDirectory();
      final savePath = '$saveDir/adhan_${moezzin.id}.mp3';

      final cancelToken = CancelToken();
      _cancelTokens[moezzin.id] = cancelToken;

      final result = await downloadService.downloadFile(
        url: moezzin.downloadUrl,
        savePath: savePath,
        cancelToken: cancelToken,
        onProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            state = state.copyWith(
              downloadProgresses: {...state.downloadProgresses, moezzin.id: progress},
            );
          }
        },
      );

      result.when(
        (file) {
          // Success
          state = state.copyWith(
            isDownloading: {...state.isDownloading, moezzin.id: false},
            downloadProgresses: {...state.downloadProgresses, moezzin.id: 1.0},
          );
        },
        (error) {
          // Failure
          state = state.copyWith(
            isDownloading: {...state.isDownloading, moezzin.id: false},
            downloadErrors: {...state.downloadErrors, moezzin.id: error.message},
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isDownloading: {...state.isDownloading, moezzin.id: false},
        downloadErrors: {...state.downloadErrors, moezzin.id: 'خطا در دانلود فایل: $e'},
      );
    } finally {
      _cancelTokens.remove(moezzin.id);
    }
  }

  void cancelDownload(String moezzinId) {
    if (_cancelTokens.containsKey(moezzinId)) {
      _cancelTokens[moezzinId]?.cancel('لغو توسط کاربر');
      _cancelTokens.remove(moezzinId);
      
      state = state.copyWith(
        isDownloading: {...state.isDownloading, moezzinId: false},
        downloadProgresses: {...state.downloadProgresses, moezzinId: 0.0},
        downloadErrors: {...state.downloadErrors}..remove(moezzinId),
      );
    }
  }
}
