import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'i_audio_storage_service.dart';

class AudioStorageServiceImpl implements IAudioStorageService {
  static const String boxName = 'audio_downloads_box';
  final Box _box;

  AudioStorageServiceImpl(this._box);

  String _buildKey(int reciterId, int surahId) {
    return 'r${reciterId}_s$surahId';
  }

  @override
  bool isSurahDownloaded(int reciterId, int surahId) {
    return _box.containsKey(_buildKey(reciterId, surahId));
  }

  @override
  List<int> getDownloadedSurahsForReciter(int reciterId) {
    final prefix = 'r${reciterId}_s';
    final List<int> downloadedSurahs = [];
    
    for (final key in _box.keys) {
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
    await _box.put(_buildKey(reciterId, surahId), true);
  }

  @override
  Future<void> unmarkSurahAsDownloaded(int reciterId, int surahId) async {
    await _box.delete(_buildKey(reciterId, surahId));
  }

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
}

