import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/data/local/preferences/preferences_service_provider.dart';
import '../../../../core/services/audio_storage/audio_storage_providers.dart';
import '../../../../core/services/audio_storage/i_audio_storage_service.dart';

const String prefWifiOnlyKey = 'pref_download_wifi_only';

final downloadManagerLocalDataSourceProvider =
    Provider<IDownloadManagerLocalDataSource>((ref) {
  final storageService = ref.watch(audioStorageServiceProvider);
  final prefs = ref.watch(sharedPreferencesInstanceProvider);
  return DownloadManagerLocalDataSourceImpl(
    storageService,
    prefs,
  );
});

abstract class IDownloadManagerLocalDataSource {
  Future<int> getTotalAudioStorageSizeInBytes();
  Future<String> getRootAudioStorageDirectory();
  bool getWifiOnlyPreference();
  Future<void> setWifiOnlyPreference(bool isWifiOnly);
  List<int> getDownloadedSurahsForReciter(int reciterId);
  Future<void> clearAllAudioCache();
  Future<void> deleteSurahAudio({required int reciterId, required int surahId});
  List<({int reciterId, int surahId})> getAllDownloadedAudioSurahs();
  Future<int> getSurahDirectorySize({required int reciterId, required int surahId});
  Future<DateTime?> getSurahLastModified({required int reciterId, required int surahId});
}

class DownloadManagerLocalDataSourceImpl
    implements IDownloadManagerLocalDataSource {
  final IAudioStorageService _storageService;
  final SharedPreferences _prefs;

  DownloadManagerLocalDataSourceImpl(this._storageService, this._prefs);

  @override
  Future<int> getTotalAudioStorageSizeInBytes() {
    return _storageService.getTotalAudioStorageSizeInBytes();
  }

  @override
  Future<String> getRootAudioStorageDirectory() {
    return _storageService.getRootAudioStorageDirectory();
  }

  @override
  bool getWifiOnlyPreference() {
    return _prefs.getBool(prefWifiOnlyKey) ?? false;
  }

  @override
  Future<void> setWifiOnlyPreference(bool isWifiOnly) {
    return _prefs.setBool(prefWifiOnlyKey, isWifiOnly);
  }

  @override
  List<int> getDownloadedSurahsForReciter(int reciterId) {
    return _storageService.getDownloadedSurahsForReciter(reciterId);
  }

  @override
  Future<void> clearAllAudioCache() {
    return _storageService.clearAllAudioCache();
  }

  @override
  Future<void> deleteSurahAudio({
    required int reciterId,
    required int surahId,
  }) {
    return _storageService.deleteSurahAudio(
      reciterId: reciterId,
      surahId: surahId,
    );
  }

  @override
  List<({int reciterId, int surahId})> getAllDownloadedAudioSurahs() {
    return _storageService.getAllDownloadedAudioSurahs();
  }

  @override
  Future<int> getSurahDirectorySize({
    required int reciterId,
    required int surahId,
  }) {
    return _storageService.getSurahDirectorySize(
      reciterId: reciterId,
      surahId: surahId,
    );
  }

  @override
  Future<DateTime?> getSurahLastModified({
    required int reciterId,
    required int surahId,
  }) {
    return _storageService.getSurahLastModified(
      reciterId: reciterId,
      surahId: surahId,
    );
  }
}
