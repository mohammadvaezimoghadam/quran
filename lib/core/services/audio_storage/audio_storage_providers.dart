import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/hive/hive_service_provider.dart';
import 'i_audio_storage_service.dart';
import 'audio_storage_service_impl.dart';

final audioStorageServiceProvider = Provider<IAudioStorageService>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return AudioStorageServiceImpl(hiveService);
});
