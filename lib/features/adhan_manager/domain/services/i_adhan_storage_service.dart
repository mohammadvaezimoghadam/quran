abstract class IAdhanStorageService {
  /// Checks if the audio file for the specified moezzin is fully downloaded and available locally.
  Future<bool> isMoezzinDownloaded(String moezzinId);

  /// Gets the absolute local path to the downloaded MP3 file for the specified moezzin.
  /// Returns null if the file does not exist.
  Future<String?> getMoezzinAudioPath(String moezzinId);

  /// Gets the directory where Adhan MP3 files are stored.
  Future<String> getAdhanSaveDirectory();

  /// Deletes the audio file for the specified moezzin if it exists.
  Future<void> deleteMoezzinAudio(String moezzinId);
}
