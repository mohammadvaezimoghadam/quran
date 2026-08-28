import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/audio_storage/audio_storage_providers.dart';
import 'audio_download_controller.dart';

/// Provides the count of sequentially downloaded ayahs for a given surah.
/// Automatically invalidates when download task status changes.
final surahDownloadedAyahsCountProvider = FutureProvider.family
    .autoDispose<int, ({int reciterId, int surahId, int totalAyahs})>(
  (ref, params) async {
    // Watch download task status so this provider re-fetches when
    // a download completes, cancels, or starts for this surah.
    final taskKey = 'r${params.reciterId}_s${params.surahId}';
    ref.watch(
      audioDownloadControllerProvider.select((map) => map[taskKey]?.status),
    );

    final storage = ref.read(audioStorageServiceProvider);
    return storage.getDownloadedAyahsCount(
      reciterId: params.reciterId,
      surahId: params.surahId,
      totalAyahs: params.totalAyahs,
    );
  },
);
