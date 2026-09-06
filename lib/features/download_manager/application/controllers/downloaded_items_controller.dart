import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/audio_storage/audio_storage_providers.dart';
import '../../../audio_manager/application/controllers/surah_downloaded_ayahs_provider.dart';
import '../../../translation_manager/application/controllers/translation_manager_controller.dart';
import '../../domain/entities/downloaded_item_entity.dart';
import '../../infrastructure/repositories/download_manager_repository_impl.dart';
import 'download_hub_controller.dart';

final downloadedItemsControllerProvider =
    AsyncNotifierProvider<DownloadedItemsController, List<DownloadedItemEntity>>(
  DownloadedItemsController.new,
);

class DownloadedItemsController extends AsyncNotifier<List<DownloadedItemEntity>> {
  @override
  FutureOr<List<DownloadedItemEntity>> build() async {
    final storageService = ref.watch(audioStorageServiceProvider);
    final listenable = storageService.downloadStatusListenable;

    void onStorageChanged() {
      loadItems();
    }

    listenable.addListener(onStorageChanged);
    ref.onDispose(() {
      listenable.removeListener(onStorageChanged);
    });

    // Also reload when text translations change
    ref.listen(translationManagerControllerProvider, (previous, next) {
      final prevList = previous?.value?.translations;
      final nextList = next.value?.translations;
      if (prevList != null && nextList != null) {
        final prevDownloaded = prevList.where((t) => t.isDownloaded).length;
        final nextDownloaded = nextList.where((t) => t.isDownloaded).length;
        if (prevDownloaded != nextDownloaded) {
          loadItems();
        }
      }
    });

    return _fetchItems();
  }

  Future<List<DownloadedItemEntity>> _fetchItems() async {
    final repository = ref.read(downloadManagerRepositoryProvider);
    final result = await repository.getAllDownloadedItems();
    return result.tryGetSuccess() ?? [];
  }

  /// Reload all downloaded items from disk and Hive smoothly without wiping UI
  Future<void> loadItems() async {
    try {
      final items = await _fetchItems();
      state = AsyncData(items);
    } catch (e, st) {
      if (!state.hasValue) {
        state = AsyncError(e, st);
      }
    }
  }

  /// Delete an audio item
  Future<void> deleteAudioItem({
    required int reciterId,
    required int surahId,
  }) async {
    final repository = ref.read(downloadManagerRepositoryProvider);
    await repository.deleteSurahAudio(reciterId: reciterId, surahId: surahId);
    ref.invalidate(surahDownloadedAyahsCountProvider);
    // Trigger hub summary refresh
    ref.read(downloadHubControllerProvider.notifier).loadSummary();
    await loadItems();
  }

  /// Delete a text translation item
  Future<void> deleteTextTranslation(String translationId) async {
    await ref
        .read(translationManagerControllerProvider.notifier)
        .deleteTranslation(translationId);
    // Trigger hub summary refresh
    ref.read(downloadHubControllerProvider.notifier).loadSummary();
    await loadItems();
  }
}
