import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'i_audio_storage_service.dart';
import 'audio_storage_service_impl.dart';

final audioStorageServiceProvider = Provider<IAudioStorageService>((ref) {
  final box = Hive.box(AudioStorageServiceImpl.boxName);
  return AudioStorageServiceImpl(box);
});
