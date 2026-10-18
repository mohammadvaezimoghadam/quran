import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/exceptions/failure.dart';
import '../../domain/entities/tafakor_topic.dart';
import '../../domain/repositories/i_tafakor_topics_repository.dart';
import '../../infrastructure/repositories/tafakor_topics_repository_impl.dart';

/// Legacy/Direct async provider for existing dialogs and consumers
final tafakorTopicsProvider = FutureProvider.autoDispose<List<TafakorTopic>>((ref) async {
  final repo = ref.watch(tafakorTopicsRepositoryProvider);
  final result = await repo.getTopics();
  return result.when(
    (topics) => topics,
    (failure) => throw failure,
  );
});

/// Immutable state for Tafakor topics list screen
class TafakorTopicsState {
  final bool isLoading;
  final List<TafakorTopic> topics;
  final String searchQuery;
  final Failure? error;

  const TafakorTopicsState({
    this.isLoading = false,
    this.topics = const [],
    this.searchQuery = '',
    this.error,
  });

  TafakorTopicsState copyWith({
    bool? isLoading,
    List<TafakorTopic>? topics,
    String? searchQuery,
    Failure? error,
    bool clearError = false,
  }) {
    return TafakorTopicsState(
      isLoading: isLoading ?? this.isLoading,
      topics: topics ?? this.topics,
      searchQuery: searchQuery ?? this.searchQuery,
      error: clearError ? null : (error ?? this.error),
    );
  }

  /// Fast in-memory filtering by name or description without re-fetching
  List<TafakorTopic> get filteredTopics {
    if (searchQuery.trim().isEmpty) return topics;
    final q = searchQuery.trim().toLowerCase();
    return topics.where((t) {
      final nameMatches = t.name.toLowerCase().contains(q);
      final descMatches = t.description?.toLowerCase().contains(q) ?? false;
      return nameMatches || descMatches;
    }).toList();
  }
}

final tafakorTopicsControllerProvider =
    NotifierProvider<TafakorTopicsController, TafakorTopicsState>(
  TafakorTopicsController.new,
);

class TafakorTopicsController extends Notifier<TafakorTopicsState> {
  late final ITafakorTopicsRepository _repository;

  @override
  TafakorTopicsState build() {
    _repository = ref.watch(tafakorTopicsRepositoryProvider);
    Future.microtask(() => loadTopics());
    return const TafakorTopicsState(isLoading: true);
  }

  Future<void> loadTopics({bool isRefresh = false}) async {
    if (!isRefresh && state.topics.isNotEmpty) {
      state = state.copyWith(isLoading: false, clearError: true);
    } else {
      state = state.copyWith(isLoading: true, clearError: true);
    }

    final result = await _repository.getTopics();

    result.when(
      (topics) {
        state = state.copyWith(
          isLoading: false,
          topics: topics,
          clearError: true,
        );
      },
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure,
        );
      },
    );
  }

  void setSearchQuery(String query) {
    if (state.searchQuery != query) {
      state = state.copyWith(searchQuery: query);
    }
  }

  void clearSearch() {
    if (state.searchQuery.isNotEmpty) {
      state = state.copyWith(searchQuery: '');
    }
  }
}
