import 'package:flutter/foundation.dart';

abstract class IAudioStorageService {
  /// Check if a specific Surah is completely downloaded for a given Reciter.
  bool isSurahDownloaded(int reciterId, int surahId);

  /// Get a list of all Surah IDs that have been downloaded for a specific Reciter.
  List<int> getDownloadedSurahsForReciter(int reciterId);

  /// Mark a Surah as fully downloaded in the local database.
  Future<void> markSurahAsDownloaded(int reciterId, int surahId);

  /// Remove the downloaded mark for a Surah (e.g. upon deletion).
  Future<void> unmarkSurahAsDownloaded(int reciterId, int surahId);

  /// Get the directory where a specific Surah's audio is stored.
  Future<String> getSurahSaveDirectory({
    required int reciterId,
    required int surahId,
  });

  /// Get the exact path of an Ayah audio file on disk, if it exists.
  Future<String?> getLocalAyahAudioPath({
    required int reciterId,
    required int surahId,
    required int ayahNumber,
  });

  /// Get the number of sequential downloaded Ayah files for a given Surah and Reciter.
  Future<int> getDownloadedAyahsCount({
    required int reciterId,
    required int surahId,
    required int totalAyahs,
  });

  /// Get the root directory path where all audio files are cached.
  Future<String> getRootAudioStorageDirectory();

  /// Calculate the total size in bytes of all downloaded audio files on disk.
  Future<int> getTotalAudioStorageSizeInBytes();

  /// Delete all audio files from disk and clear the download box cache.
  Future<void> clearAllAudioCache();

  /// Delete audio files for a specific Surah and unmark it as downloaded.
  Future<void> deleteSurahAudio({
    required int reciterId,
    required int surahId,
  });

  /// Provides a [Listenable] stream/notifier for changes in audio download status.
  Listenable get downloadStatusListenable;

  /// Get all downloaded Surahs across all reciters as a list of (reciterId, surahId) records.
  List<({int reciterId, int surahId})> getAllDownloadedAudioSurahs();

  /// Calculate the total size in bytes of a specific Surah audio folder.
  Future<int> getSurahDirectorySize({
    required int reciterId,
    required int surahId,
  });

  /// Get the last modified timestamp of a downloaded Surah folder.
  Future<DateTime?> getSurahLastModified({
    required int reciterId,
    required int surahId,
  });
}

