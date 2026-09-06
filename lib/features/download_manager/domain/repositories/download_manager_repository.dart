import 'package:multiple_result/multiple_result.dart';

import '../../../../common/exceptions/failure.dart';
import '../entities/download_hub_summary_entity.dart';
import '../entities/downloaded_item_entity.dart';

/// Contract interface for managing offline download metrics, preferences, and disk cache.
abstract class IDownloadManagerRepository {
  /// Fetches consolidated metrics regarding storage and offline downloads.
  Future<Result<DownloadHubSummaryEntity, Failure>> getDownloadHubSummary();

  /// Updates the user preference for downloading on Wi-Fi only.
  Future<Result<void, Failure>> setWifiOnlyPreference(bool isWifiOnly);

  /// Clears all downloaded audio files from physical disk and resets database cache.
  Future<Result<void, Failure>> clearAllAudioCache();

  /// Deletes audio files for a specific Surah and updates local cache.
  Future<Result<void, Failure>> deleteSurahAudio({
    required int reciterId,
    required int surahId,
  });

  /// Retrieves a unified list of all downloaded items (Quran audio, translation audio, text translations).
  Future<Result<List<DownloadedItemEntity>, Failure>> getAllDownloadedItems();

  /// Clears ALL downloaded items (audio cache and downloaded text translations).
  Future<Result<void, Failure>> clearAllDownloads();
}
