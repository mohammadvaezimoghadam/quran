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
final allRecitersListProvider = FutureProvider<Result<List<ReciterEntity>, Failure>>((ref) async {
  final repository = ref.watch(reciterRepositoryProvider);
  return repository.getAllReciters();
});

/// Filtered reciter list for the main UI (only active ones)
final recitersListProvider =
    FutureProvider<Result<List<ReciterEntity>, Failure>>((ref) async {
  final allRecitersResult = await ref.watch(allRecitersListProvider.future);
  
  return allRecitersResult.when(
    (allReciters) {
      final styleId = ref.watch(selectedReciterStyleIdProvider);
      
      var filtered = allReciters;
      
      if (styleId != null) {
        filtered = filtered.where((r) => r.styleId == styleId).toList();
      }
      
      return Success(filtered);
    },
    (error) => Error(error),
  );
});
