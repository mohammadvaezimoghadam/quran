import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../../domain/services/i_adhan_storage_service.dart';

class AdhanStorageServiceImpl implements IAdhanStorageService {
  Future<Directory> _getAdhanDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/adhans');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  @override
  Future<String> getAdhanSaveDirectory() async {
    final dir = await _getAdhanDirectory();
    return dir.path;
  }

  @override
  Future<String?> getMoezzinAudioPath(String moezzinId) async {
    final dir = await _getAdhanDirectory();
    final file = File('${dir.path}/adhan_$moezzinId.mp3');
    if (await file.exists()) {
      return file.path;
    }
    return null;
  }

  @override
  Future<bool> isMoezzinDownloaded(String moezzinId) async {
    final path = await getMoezzinAudioPath(moezzinId);
    return path != null;
  }

  @override
  Future<void> deleteMoezzinAudio(String moezzinId) async {
    final path = await getMoezzinAudioPath(moezzinId);
    if (path != null) {
      final file = File(path);
      await file.delete();
    }
  }
}
