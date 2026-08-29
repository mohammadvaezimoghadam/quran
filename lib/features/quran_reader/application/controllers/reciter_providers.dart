import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../common/exceptions/failure.dart';
import '../../domain/entities/recitation_style_entity.dart';
import '../../domain/entities/reciter_entity.dart';
import '../../infrastructure/repositories/reciter_repository.dart';

/// Cached FutureProvider for recitation styles
final recitationStylesProvider =
    FutureProvider<Result<List<RecitationStyleEntity>, Failure>>((ref) async {
  final repository = ref.watch(reciterRepositoryProvider);
  return repository.getRecitationStyles();
});

/// Notifier for selected style filter in reciter selection bottom sheet
class SelectedReciterStyleIdNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void setStyleId(int? styleId) {
    state = styleId;
  }
}

final selectedReciterStyleIdProvider =
    NotifierProvider<SelectedReciterStyleIdNotifier, int?>(
  SelectedReciterStyleIdNotifier.new,
);

/// Provider for the entire catalog of reciters (all available reciters)
final allRecitersListProvider =
    FutureProvider<Result<List<ReciterEntity>, Failure>>((ref) async {
  final repository = ref.watch(reciterRepositoryProvider);
  return repository.getAllReciters();
});

/// Provider for Arabic Reciters only (styleId != 4)
final arabicRecitersListProvider =
    FutureProvider<Result<List<ReciterEntity>, Failure>>((ref) async {
  final allRecitersResult = await ref.watch(allRecitersListProvider.future);

  return allRecitersResult.when(
    (allReciters) {
      final styleId = ref.watch(selectedReciterStyleIdProvider);

      var filtered = allReciters.where((r) => r.styleId != 4).toList();

      if (styleId != null && styleId != 4) {
        filtered = filtered.where((r) => r.styleId == styleId).toList();
      }

      return Success(filtered);
    },
    (error) => Error(error),
  );
});

/// Provider for Audio Translation Reciters only (styleId == 4)
final translationRecitersListProvider =
    FutureProvider<Result<List<ReciterEntity>, Failure>>((ref) async {
  final allRecitersResult = await ref.watch(allRecitersListProvider.future);

  return allRecitersResult.when(
    (allReciters) {
      final filtered = allReciters.where((r) => r.styleId == 4).toList();
      return Success(filtered);
    },
    (error) => Error(error),
  );
});

/// Filtered reciter list for general UI (Arabic reciters by default)
final recitersListProvider =
    FutureProvider<Result<List<ReciterEntity>, Failure>>((ref) async {
  final styleId = ref.watch(selectedReciterStyleIdProvider);
  if (styleId == 4) {
    return ref.watch(translationRecitersListProvider.future);
  }
  return ref.watch(arabicRecitersListProvider.future);
});
