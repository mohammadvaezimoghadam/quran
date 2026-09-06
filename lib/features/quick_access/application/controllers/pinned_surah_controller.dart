import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../surah_list/application/controllers/surah_list_controller.dart';
import '../../../surah_list/domain/entities/surah_entity.dart';
import '../../infrastructure/repositories/quick_access_repository_impl.dart';

/// Provider for managing the pinned surah ID persisted in SharedPreferences
final pinnedSurahIdProvider =
    NotifierProvider<PinnedSurahNotifier, int?>(PinnedSurahNotifier.new);

class PinnedSurahNotifier extends Notifier<int?> {
  @override
  int? build() {
    final repository = ref.watch(quickAccessRepositoryProvider);
    return repository.getPinnedSurahId();
  }

  /// Sets or clears the pinned surah
  Future<void> setPinnedSurah(int? surahId) async {
    final repository = ref.read(quickAccessRepositoryProvider);
    final result = await repository.savePinnedSurahId(surahId);
    result.when(
      (_) => state = surahId,
      (failure) => null, // Keep existing state on error
    );
  }
}

/// Provider that resolves the currently pinned SurahEntity from the surah list
final pinnedSurahProvider = Provider<SurahEntity?>((ref) {
  final pinnedId = ref.watch(pinnedSurahIdProvider);
  if (pinnedId == null) return null;

  final surahs = ref.watch(surahListControllerProvider.select((s) => s.surahs));
  return surahs.where((s) => s.number == pinnedId).firstOrNull;
});
