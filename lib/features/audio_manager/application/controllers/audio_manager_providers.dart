import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/audio_storage/audio_storage_providers.dart';
import '../../domain/repositories/i_audio_manager_repository.dart';
import '../../infrastructure/repositories/audio_manager_repository_impl.dart';

final audioManagerRepositoryProvider = Provider<IAudioManagerRepository>((ref) {
  final storageService = ref.watch(audioStorageServiceProvider);
  return AudioManagerRepositoryImpl(storageService);
});
