import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/exceptions/failure.dart';
import '../../domain/entities/tafakor_post.dart';
import '../../domain/repositories/i_tafakor_posts_repository.dart';
import '../../infrastructure/repositories/tafakor_posts_repository_impl.dart';

enum AyahNotesTab {
  community,
  authors,
  mine,
}

class TafakorAyahAuthor {
  final int authorId;
  final String authorName;
  final String? authorAvatar;
  final String authorPhone;
  final int notesCount;

  const TafakorAyahAuthor({
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.authorPhone,
    required this.notesCount,
  });
}

class AyahNotesState {
  final int surahNumber;
  final int ayahNumber;
  final AyahNotesTab activeTab;
  final String searchQuery;
  final List<TafakorPost> minePosts;
  final List<TafakorPost> communityPosts;
  final int mineTotal;
  final int communityTotal;
  final int minePage;
  final int communityPage;
  final bool hasMoreMine;
  final bool hasMoreCommunity;
  final bool isLoading;
  final bool isLoadingMore;
  final Failure? error;

  const AyahNotesState({
    this.surahNumber = 0,
    this.ayahNumber = 0,
    this.activeTab = AyahNotesTab.community,
    this.searchQuery = '',
    this.minePosts = const [],
    this.communityPosts = const [],
    this.mineTotal = 0,
    this.communityTotal = 0,
    this.minePage = 1,
    this.communityPage = 1,
    this.hasMoreMine = false,
    this.hasMoreCommunity = false,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
  });

  List<TafakorAyahAuthor> get authors {
    final Map<String, TafakorAyahAuthor> map = {};
    for (final post in communityPosts) {
      final key = post.authorId > 0
          ? '${post.authorId}'
          : (post.authorPhone.isNotEmpty ? post.authorPhone : post.authorName);
      if (key.trim().isEmpty) continue;
      if (map.containsKey(key)) {
        final existing = map[key]!;
        map[key] = TafakorAyahAuthor(
          authorId: existing.authorId,
          authorName: existing.authorName,
          authorAvatar: existing.authorAvatar ?? post.authorAvatar,
          authorPhone: existing.authorPhone,
          notesCount: existing.notesCount + 1,
        );
      } else {
        map[key] = TafakorAyahAuthor(
          authorId: post.authorId,
          authorName: post.authorName.isNotEmpty ? post.authorName : 'کاربر تفکر',
          authorAvatar: post.authorAvatar,
          authorPhone: post.authorPhone,
          notesCount: 1,
        );
      }
    }
    return map.values.toList();
  }

  List<TafakorPost> get currentPosts =>
      activeTab == AyahNotesTab.mine ? minePosts : communityPosts;

  int get currentTotal => activeTab == AyahNotesTab.mine
      ? mineTotal
      : (activeTab == AyahNotesTab.authors ? authors.length : communityTotal);

  bool get hasMore => activeTab == AyahNotesTab.mine
      ? hasMoreMine
      : (activeTab == AyahNotesTab.authors ? false : hasMoreCommunity);

  AyahNotesState copyWith({
    int? surahNumber,
    int? ayahNumber,
    AyahNotesTab? activeTab,
    String? searchQuery,
    List<TafakorPost>? minePosts,
    List<TafakorPost>? communityPosts,
    int? mineTotal,
    int? communityTotal,
    int? minePage,
    int? communityPage,
    bool? hasMoreMine,
    bool? hasMoreCommunity,
    bool? isLoading,
    bool? isLoadingMore,
    Failure? error,
    bool clearError = false,
  }) {
    return AyahNotesState(
      surahNumber: surahNumber ?? this.surahNumber,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      activeTab: activeTab ?? this.activeTab,
      searchQuery: searchQuery ?? this.searchQuery,
      minePosts: minePosts ?? this.minePosts,
      communityPosts: communityPosts ?? this.communityPosts,
      mineTotal: mineTotal ?? this.mineTotal,
      communityTotal: communityTotal ?? this.communityTotal,
      minePage: minePage ?? this.minePage,
      communityPage: communityPage ?? this.communityPage,
      hasMoreMine: hasMoreMine ?? this.hasMoreMine,
      hasMoreCommunity: hasMoreCommunity ?? this.hasMoreCommunity,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final ayahNotesControllerProvider =
    NotifierProvider<AyahNotesController, AyahNotesState>(
  AyahNotesController.new,
);

class AyahNotesController extends Notifier<AyahNotesState> {
  late final ITafakorPostsRepository _repository;

  @override
  AyahNotesState build() {
    _repository = ref.watch(tafakorPostsRepositoryProvider);
    return const AyahNotesState();
  }

  Future<void> loadInitial({
    required int surahNumber,
    required int ayahNumber,
    bool isRefresh = false,
  }) async {
    state = state.copyWith(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      isLoading: !isRefresh,
      clearError: true,
    );

    final communityFuture = _repository.getAyahPosts(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      mine: false,
      search: state.searchQuery,
      page: 1,
    );

    final mineFuture = _repository.getAyahPosts(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      mine: true,
      search: state.searchQuery,
      page: 1,
    );

    final results = await Future.wait([communityFuture, mineFuture]);
    final communityResult = results[0];
    final mineResult = results[1];

    List<TafakorPost> communityPosts = state.communityPosts;
    int communityTotal = state.communityTotal;
    bool hasMoreCommunity = false;

    List<TafakorPost> minePosts = state.minePosts;
    int mineTotal = state.mineTotal;
    bool hasMoreMine = false;

    Failure? failure;

    communityResult.when(
      (paginated) {
        communityPosts = paginated.results;
        communityTotal = paginated.count;
        hasMoreCommunity = paginated.next != null;
      },
      (f) => failure = f,
    );

    mineResult.when(
      (paginated) {
        minePosts = paginated.results;
        mineTotal = paginated.count;
        hasMoreMine = paginated.next != null;
      },
      (f) => failure ??= f,
    );

    state = state.copyWith(
      isLoading: false,
      communityPosts: communityPosts,
      communityTotal: communityTotal,
      communityPage: 1,
      hasMoreCommunity: hasMoreCommunity,
      minePosts: minePosts,
      mineTotal: mineTotal,
      minePage: 1,
      hasMoreMine: hasMoreMine,
      error: failure,
      clearError: failure == null,
    );
  }

  void switchTab(AyahNotesTab tab) {
    if (state.activeTab == tab) return;
    state = state.copyWith(activeTab: tab);
  }

  Future<void> setSearch(String query) async {
    if (state.searchQuery == query) return;
    state = state.copyWith(searchQuery: query);
    await loadInitial(
      surahNumber: state.surahNumber,
      ayahNumber: state.ayahNumber,
      isRefresh: true,
    );
  }

  Future<void> refresh() async {
    await loadInitial(
      surahNumber: state.surahNumber,
      ayahNumber: state.ayahNumber,
      isRefresh: true,
    );
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    final isMine = state.activeTab == AyahNotesTab.mine;
    final nextPage = (isMine ? state.minePage : state.communityPage) + 1;

    final result = await _repository.getAyahPosts(
      surahNumber: state.surahNumber,
      ayahNumber: state.ayahNumber,
      mine: isMine,
      search: state.searchQuery,
      page: nextPage,
    );

    result.when(
      (paginated) {
        if (isMine) {
          final existingIds = state.minePosts.map((p) => p.id).toSet();
          final newPosts = paginated.results.where((p) => !existingIds.contains(p.id));
          state = state.copyWith(
            isLoadingMore: false,
            minePosts: [...state.minePosts, ...newPosts],
            minePage: nextPage,
            hasMoreMine: paginated.next != null,
          );
        } else {
          final existingIds = state.communityPosts.map((p) => p.id).toSet();
          final newPosts = paginated.results.where((p) => !existingIds.contains(p.id));
          state = state.copyWith(
            isLoadingMore: false,
            communityPosts: [...state.communityPosts, ...newPosts],
            communityPage: nextPage,
            hasMoreCommunity: paginated.next != null,
          );
        }
      },
      (failure) {
        state = state.copyWith(isLoadingMore: false, error: failure);
      },
    );
  }

  Future<void> toggleReaction(int postId) async {
    final isMine = state.activeTab == AyahNotesTab.mine;
    final targetList = isMine ? state.minePosts : state.communityPosts;
    final index = targetList.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = targetList[index];
    final wasLiked = post.isLiked;
    final updatedReaction = wasLiked ? null : '❤️';
    final updatedSummary = Map<String, int>.from(post.reactionsSummary);
    final currentHeartCount = updatedSummary['❤️'] ?? 0;

    if (wasLiked) {
      if (currentHeartCount > 1) {
        updatedSummary['❤️'] = currentHeartCount - 1;
      } else {
        updatedSummary.remove('❤️');
      }
    } else {
      updatedSummary['❤️'] = currentHeartCount + 1;
    }

    final updatedPost = post.copyWith(
      userReaction: updatedReaction,
      reactionsSummary: updatedSummary,
    );

    final updatedList = List<TafakorPost>.from(targetList);
    updatedList[index] = updatedPost;

    if (isMine) {
      state = state.copyWith(minePosts: updatedList);
    } else {
      state = state.copyWith(communityPosts: updatedList);
    }

    final result = await _repository.reactToPost(postId, '❤️');
    result.when(
      (_) {},
      (failure) {
        final rollbackList = List<TafakorPost>.from(targetList);
        rollbackList[index] = post;
        if (isMine) {
          state = state.copyWith(minePosts: rollbackList);
        } else {
          state = state.copyWith(communityPosts: rollbackList);
        }
      },
    );
  }

  /// Unlinks a specific Ayah from a post and removes it from the current Ayah notes view
  Future<bool> unlinkAyahFromPost({
    required int postId,
    required int surahNumber,
    required int ayahNumber,
  }) async {
    TafakorPost? post;
    for (final p in [...state.communityPosts, ...state.minePosts]) {
      if (p.id == postId) {
        post = p;
        break;
      }
    }
    if (post == null) return false;

    final currentRefs = post.quranReferences;
    final remainingRefs = currentRefs.where((r) =>
      !(r.surahNumber == surahNumber && r.ayahNumber == ayahNumber)
    ).toList();

    final payload = remainingRefs.map((r) => {
      'plugin': 'quran',
      'resource_type': 'ayah',
      'external_id': 'surah:${r.surahNumber},ayah:${r.ayahNumber}',
      'metadata': {
        'surah_number': r.surahNumber,
        'ayah_number': r.ayahNumber,
        'surah_name': r.surahName,
      },
    }).toList();

    final result = await _repository.updatePostReferences(
      postId: postId,
      pluginReferences: payload,
    );

    return result.when(
      (updatedPost) {
        final updatedCommunity = state.communityPosts.where((p) => p.id != postId).toList();
        final updatedMine = state.minePosts.where((p) => p.id != postId).toList();
        final commDiff = state.communityPosts.length - updatedCommunity.length;
        final mineDiff = state.minePosts.length - updatedMine.length;

        state = state.copyWith(
          communityPosts: updatedCommunity,
          minePosts: updatedMine,
          communityTotal: (state.communityTotal - commDiff).clamp(0, 999999),
          mineTotal: (state.mineTotal - mineDiff).clamp(0, 999999),
        );
        return true;
      },
      (failure) {
        state = state.copyWith(error: failure);
        return false;
      },
    );
  }
}
