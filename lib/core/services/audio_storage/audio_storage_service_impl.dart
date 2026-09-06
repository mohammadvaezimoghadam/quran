import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/local/hive/i_hive_service.dart';
import 'i_audio_storage_service.dart';

class AudioStorageServiceImpl implements IAudioStorageService {
  static const String boxName = 'audio_downloads_box';
  final IHiveService _hiveService;

  AudioStorageServiceImpl(this._hiveService);

  String _buildKey(int reciterId, int surahId) {
    return 'r${reciterId}_s$surahId';
  }

  @override
  bool isSurahDownloaded(int reciterId, int surahId) {
    return _hiveService.containsKey(_buildKey(reciterId, surahId), boxName: boxName);
  }

  @override
  List<int> getDownloadedSurahsForReciter(int reciterId) {
    final prefix = 'r${reciterId}_s';
    final List<int> downloadedSurahs = [];
    
    for (final key in _hiveService.getKeys(boxName: boxName)) {
      if (key is String && key.startsWith(prefix)) {
        final surahIdStr = key.substring(prefix.length);
        final surahId = int.tryParse(surahIdStr);
        if (surahId != null) {
          downloadedSurahs.add(surahId);
        }
      }
    }
    
    return downloadedSurahs;
  }

  @override
  Future<void> markSurahAsDownloaded(int reciterId, int surahId) async {
    await _hiveService.put(_buildKey(reciterId, surahId), true, boxName: boxName);
  }

  @override
  Future<void> unmarkSurahAsDownloaded(int reciterId, int surahId) async {
    await _hiveService.delete(_buildKey(reciterId, surahId), boxName: boxName);
  }

  @override
  Listenable get downloadStatusListenable =>
      _hiveService.getListenable(boxName: boxName);

  @override
  Future<String> getSurahSaveDirectory({
    required int reciterId,
    required int surahId,
  }) async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/audio_cache/reciter_$reciterId/surah_$surahId');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  @override
  Future<String?> getLocalAyahAudioPath({
    required int reciterId,
    required int surahId,
    required int ayahNumber,
  }) async {
    final dirPath = await getSurahSaveDirectory(
      reciterId: reciterId,
      surahId: surahId,
    );
    final filePath = '$dirPath/ayah_$ayahNumber.mp3';
    
    final file = File(filePath);
    if (await file.exists()) {
      return file.path;
    }
    return null;
  }

  @override
  Future<int> getDownloadedAyahsCount({
    required int reciterId,
    required int surahId,
    required int totalAyahs,
  }) async {
    final dirPath = await getSurahSaveDirectory(
      reciterId: reciterId,
      surahId: surahId,
    );
    int count = 0;
    for (int i = 1; i <= totalAyahs; i++) {
      final file = File('$dirPath/ayah_$i.mp3');
      if (await file.exists() && await file.length() > 0) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  @override
  Future<String> getRootAudioStorageDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/audio_cache');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  @override
  Future<int> getTotalAudioStorageSizeInBytes() async {
    final rootPath = await getRootAudioStorageDirectory();
    final dir = Directory(rootPath);
    if (!await dir.exists()) return 0;
    int totalSize = 0;
    try {
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
    } catch (_) {}
    return totalSize;
  }

  @override
  Future<void> clearAllAudioCache() async {
    final rootPath = await getRootAudioStorageDirectory();
    final dir = Directory(rootPath);
    if (await dir.exists()) {
      try {
        await dir.delete(recursive: true);
      } catch (_) {}
      await dir.create(recursive: true);
    }
    await _hiveService.clear(boxName: boxName);
  }

  @override
  Future<void> deleteSurahAudio({
    required int reciterId,
    required int surahId,
  }) async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/audio_cache/reciter_$reciterId/surah_$surahId');
    if (await dir.exists()) {
      try {
        await for (final entity in dir.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            try {
              await entity.delete();
            } catch (_) {}
          }
        }
        await dir.delete(recursive: true);
      } catch (_) {}
    }
    await unmarkSurahAsDownloaded(reciterId, surahId);
  }

  @override
  List<({int reciterId, int surahId})> getAllDownloadedAudioSurahs() {
    final List<({int reciterId, int surahId})> items = [];
    for (final key in _hiveService.getKeys(boxName: boxName)) {
      if (key is String && key.startsWith('r') && key.contains('_s')) {
        final val = _hiveService.get(key, boxName: boxName);
        if (val == true) {
          final parts = key.substring(1).split('_s');
          if (parts.length == 2) {
            final reciterId = int.tryParse(parts[0]);
            final surahId = int.tryParse(parts[1]);
            if (reciterId != null && surahId != null) {
              items.add((reciterId: reciterId, surahId: surahId));
            }
          }
        }
      }
    }
    return items;
  }

  @override
  Future<int> getSurahDirectorySize({
    required int reciterId,
    required int surahId,
  }) async {
    final surahPath = await getSurahSaveDirectory(
      reciterId: reciterId,
      surahId: surahId,
    );
    final dir = Directory(surahPath);
    if (!await dir.exists()) return 0;
    int totalBytes = 0;
    try {
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          totalBytes += await entity.length();
        }
      }
    } catch (_) {}
    return totalBytes;
  }

  @override
  Future<DateTime?> getSurahLastModified({
    required int reciterId,
    required int surahId,
  }) async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/audio_cache/reciter_$reciterId/surah_$surahId');
    if (!await dir.exists()) return null;
    try {
      DateTime? latest;
      await for (final entity in dir.list(followLinks: false)) {
        if (entity is File) {
          final stat = await entity.stat();
          if (latest == null || stat.modified.isAfter(latest)) {
            latest = stat.modified;
          }
        }
      }
      return latest ?? (await dir.stat()).modified;
    } catch (_) {
      return null;
    }
  }
}

