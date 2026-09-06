import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/audio_storage/audio_storage_providers.dart';
import '../../../audio_manager/application/controllers/audio_download_controller.dart';
import '../../../audio_manager/application/controllers/surah_downloaded_ayahs_provider.dart';
import '../../../translation_manager/application/controllers/translation_manager_controller.dart';
import '../../infrastructure/repositories/download_manager_repository_impl.dart';
import '../states/download_hub_state.dart';
import 'downloaded_items_controller.dart';

final downloadHubControllerProvider =
    NotifierProvider<DownloadHubController, DownloadHubState>(
  DownloadHubController.new,
);

class DownloadHubController extends Notifier<DownloadHubState> {
  @override
  DownloadHubState build() {
    final storageService = ref.watch(audioStorageServiceProvider);
    final listenable = storageService.downloadStatusListenable;

    void onDownloadChanged() {
      loadSummary();
    }

    listenable.addListener(onDownloadChanged);
    ref.onDispose(() {
      listenable.removeListener(onDownloadChanged);
    });

    // Listen to text translation changes to auto-refresh download hub counts
    ref.listen(translationManagerControllerProvider, (previous, next) {
      final prevList = previous?.value?.translations;
      final nextList = next.value?.translations;
      if (prevList != null && nextList != null) {
        final prevDownloaded = prevList.where((t) => t.isDownloaded).length;
        final nextDownloaded = nextList.where((t) => t.isDownloaded).length;
        if (prevDownloaded != nextDownloaded) {
          loadSummary();
        }
      }
    });

    Future.microtask(() => loadSummary());
    return const DownloadHubState();
  }

  /// Reload summary statistics through repository
  Future<void> loadSummary() async {
    state = state.copyWith(isLoading: true);

    final repository = ref.read(downloadManagerRepositoryProvider);
    final result = await repository.getDownloadHubSummary();

    result.when(
      (entity) {
        state = state.copyWith(
          isLoading: false,
          totalAudioStorageBytes: entity.totalAudioStorageBytes,
          storagePath: entity.storagePath,
          isWifiOnly: entity.isWifiOnly,
          activeReciterId: entity.activeReciterId,
          activeReciterName: entity.activeReciterName,
          downloadedQuranSurahs: entity.downloadedQuranSurahs,
          totalQuranSurahs: entity.totalQuranSurahs,
          activeTranslationReciterId: entity.activeTranslationReciterId,
          activeTranslationReciterName: entity.activeTranslationReciterName,
          downloadedTranslationSurahs: entity.downloadedTranslationSurahs,
          totalTranslationSurahs: entity.totalTranslationSurahs,
          downloadedTextTranslations: entity.downloadedTextTranslations,
          totalTextTranslations: entity.totalTextTranslations,
        );
      },
      (error) {
        state = state.copyWith(isLoading: false);
      },
    );
  }

  /// Toggle Wi-Fi Only setting through repository
  Future<void> toggleWifiOnly(bool value) async {
    final repository = ref.read(downloadManagerRepositoryProvider);
    final result = await repository.setWifiOnlyPreference(value);
    if (result.isSuccess()) {
      state = state.copyWith(isWifiOnly: value);
    }
  }

  /// Clear all audio cache via repository
  Future<void> clearAllAudioCache() async {
    await clearAllDownloads();
  }

  /// Clear ALL downloads (audio cache, text translations, active download queue)
  Future<void> clearAllDownloads() async {
    // 1. Cancel all ongoing audio download tasks
    await ref.read(audioDownloadControllerProvider.notifier).cancelAllDownloads();

    // 2. Clear all physical audio and text translation files
    final repository = ref.read(downloadManagerRepositoryProvider);
    await repository.clearAllDownloads();

    // 3. Invalidate audio ayah counter providers
    ref.invalidate(surahDownloadedAyahsCountProvider);

    // 4. Reload downloaded items list
    await ref.read(downloadedItemsControllerProvider.notifier).loadItems();

    // 5. Invalidate translation manager state so dropdowns/lists refresh
    ref.invalidate(translationManagerControllerProvider);

    // 6. Reload hub summary
    await loadSummary();
  }

  /// Delete a specific surah via repository
  Future<void> deleteSurahAudio({
    required int reciterId,
    required int surahId,
  }) async {
    final repository = ref.read(downloadManagerRepositoryProvider);
    await repository.deleteSurahAudio(reciterId: reciterId, surahId: surahId);
    await loadSummary();
  }
}
