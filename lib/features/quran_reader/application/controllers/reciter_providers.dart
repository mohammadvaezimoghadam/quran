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

/// Cached FutureProvider for reciter list based on selected style filter
final recitersListProvider =
    FutureProvider<Result<List<ReciterEntity>, Failure>>((ref) async {
  final repository = ref.watch(reciterRepositoryProvider);
  final styleId = ref.watch(selectedReciterStyleIdProvider);

  if (styleId == null) {
    return repository.getAllReciters();
  } else {
    return repository.getRecitersByStyle(styleId);
  }
});
