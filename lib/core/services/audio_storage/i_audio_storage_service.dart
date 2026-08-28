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
}
