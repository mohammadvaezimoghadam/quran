import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/exceptions/failure.dart';
import '../../domain/entities/tafakor_post.dart';
import '../../domain/entities/tafakor_topic_admins_data.dart';
import '../../domain/repositories/i_tafakor_posts_repository.dart';
import '../../infrastructure/repositories/tafakor_posts_repository_impl.dart';

class TafakorTopicFeedState {
  final int? currentTopicId;
  final bool isLoading;
  final bool isRefreshing;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final int totalCount;
  final List<TafakorPost> posts;
  final TafakorTopicAdminsData? adminsData;
  final Failure? error;

  const TafakorTopicFeedState({
    this.currentTopicId,
    this.isLoading = false,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.currentPage = 1,
    this.totalCount = 0,
    this.posts = const [],
    this.adminsData,
    this.error,
  });

  TafakorTopicFeedState copyWith({
    int? currentTopicId,
    bool? isLoading,
    bool? isRefreshing,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    int? totalCount,
    List<TafakorPost>? posts,
    TafakorTopicAdminsData? adminsData,
    Failure? error,
    bool clearError = false,
  }) {
    return TafakorTopicFeedState(
      currentTopicId: currentTopicId ?? this.currentTopicId,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
      posts: posts ?? this.posts,
      adminsData: adminsData ?? this.adminsData,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final tafakorTopicFeedControllerProvider =
    NotifierProvider<TafakorTopicFeedController, TafakorTopicFeedState>(
  TafakorTopicFeedController.new,
);

class TafakorTopicFeedController extends Notifier<TafakorTopicFeedState> {
  late final ITafakorPostsRepository _repository;

  @override
  TafakorTopicFeedState build() {
    _repository = ref.watch(tafakorPostsRepositoryProvider);
    return const TafakorTopicFeedState();
  }

  /// Initial load or refresh of the topic posts and admins permission data
  Future<void> loadPosts({
    required int topicId,
    bool isRefresh = false,
    int? highlightPostId,
    TafakorPost? initialHighlightPost,
  }) async {
    final isDifferentTopic = state.currentTopicId != topicId;

    if (isRefresh) {
      state = state.copyWith(
        currentTopicId: topicId,
        isLoading: false,
        isRefreshing: true,
        clearError: true,
      );
    } else {
      state = state.copyWith(
        currentTopicId: topicId,
        isLoading: true,
        clearError: true,
        posts: isDifferentTopic ? [] : state.posts,
      );
    }

    // Load topic posts directly
    final postsResult = await _repository.getTopicPosts(topicId: topicId, page: 1);

    await postsResult.when(
      (paginated) async {
        var allPosts = List<TafakorPost>.from(paginated.results);
        var currentPage = 1;
        var hasMore = paginated.next != null;
        var totalCount = paginated.count;

        // If a specific post needs highlighting and is not in page 1, fetch subsequent pages until found (up to 5 pages)
        if (highlightPostId != null && !allPosts.any((p) => p.id == highlightPostId)) {
          while (hasMore && currentPage < 5 && !allPosts.any((p) => p.id == highlightPostId)) {
            currentPage++;
            final nextResult = await _repository.getTopicPosts(topicId: topicId, page: currentPage);
            final foundInNext = nextResult.when(
              (nextPaginated) {
                final existingIds = allPosts.map((p) => p.id).toSet();
                final newPosts = nextPaginated.results.where((p) => !existingIds.contains(p.id)).toList();
                allPosts.addAll(newPosts);
                hasMore = nextPaginated.next != null;
                totalCount = nextPaginated.count;
                return allPosts.any((p) => p.id == highlightPostId);
              },
              (_) {
                hasMore = false;
                return false;
              },
            );
            if (foundInNext) break;
          }
        }

        // If still not found in fetched pages, but we have initialHighlightPost, insert it chronologically!
        if (highlightPostId != null &&
            initialHighlightPost != null &&
            !allPosts.any((p) => p.id == highlightPostId)) {
          final targetDt = DateTime.tryParse(initialHighlightPost.createdAt ?? '');
          int insertIndex = allPosts.length;
          if (targetDt != null) {
            for (int i = 0; i < allPosts.length; i++) {
              final postDt = DateTime.tryParse(allPosts[i].createdAt ?? '');
              if (postDt != null && targetDt.isAfter(postDt)) {
                insertIndex = i;
                break;
              }
            }
          }
          allPosts.insert(insertIndex, initialHighlightPost);
        }

        state = state.copyWith(
          currentTopicId: topicId,
          isLoading: false,
          isRefreshing: false,
          posts: allPosts,
          totalCount: totalCount,
          currentPage: currentPage,
          hasMore: hasMore,
          clearError: true,
        );
      },
      (failure) {
        state = state.copyWith(
          currentTopicId: topicId,
          isLoading: false,
          isRefreshing: false,
          error: failure,
        );
      },
    );

    // Asynchronously load topic admins in background without blocking the UI feed
    _repository.getTopicAdmins(topicId).then((adminsResult) {
      adminsResult.when(
        (data) {
          if (state.currentTopicId == topicId) {
            state = state.copyWith(adminsData: data);
          }
        },
        (_) {},
      );
    });
  }


  /// Pagination: load next 20 posts when scrolled to bottom
  Future<void> loadNextPage({required int topicId}) async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.currentPage + 1;

    final result = await _repository.getTopicPosts(topicId: topicId, page: nextPage);

    result.when(
      (paginated) {
        final existingIds = state.posts.map((p) => p.id).toSet();
        final newPosts = paginated.results.where((p) => !existingIds.contains(p.id)).toList();
        final updatedPosts = [...state.posts, ...newPosts];

        state = state.copyWith(
          isLoadingMore: false,
          posts: updatedPosts,
          totalCount: paginated.count,
          currentPage: nextPage,
          hasMore: paginated.next != null,
        );
      },
      (failure) {
        state = state.copyWith(isLoadingMore: false);
      },
    );
  }

  /// Creates a new post in the current topic and adds it to the bottom of the feed
  Future<bool> createPost({
    required int topicId,
    required String content,
    String? mediaFilePath,
    List<Map<String, dynamic>>? pluginReferences,
  }) async {
    final result = await _repository.createPost(
      topicId: topicId,
      content: content,
      mediaFilePath: mediaFilePath,
      pluginReferences: pluginReferences,
    );

    return result.when(
      (newPost) {
        state = state.copyWith(
          posts: [newPost, ...state.posts],
          totalCount: state.totalCount + 1,
        );
        return true;
      },
      (failure) {
        state = state.copyWith(error: failure);
        return false;
      },
    );
  }

  /// Updates an existing post's text content
  Future<bool> updatePost({
    required int postId,
    required String content,
  }) async {
    final result = await _repository.updatePost(
      postId: postId,
      content: content,
    );

    return result.when(
      (updatedPost) {
        final updatedList = state.posts.map((p) {
          if (p.id == postId) {
            return updatedPost;
          }
          return p;
        }).toList();

        state = state.copyWith(posts: updatedList);
        return true;
      },
      (failure) {
        state = state.copyWith(error: failure);
        return false;
      },
    );
  }

  /// Updates the plugin_references (Quran Ayahs) of a post
  Future<bool> updatePostReferences({
    required int postId,
    required List<Map<String, dynamic>> pluginReferences,
  }) async {
    final result = await _repository.updatePostReferences(
      postId: postId,
      pluginReferences: pluginReferences,
    );

    return result.when(
      (updatedPost) {
        final updatedList = state.posts.map((p) {
          if (p.id == postId) {
            return updatedPost;
          }
          return p;
        }).toList();

        state = state.copyWith(posts: updatedList);
        return true;
      },
      (failure) {
        state = state.copyWith(error: failure);
        return false;
      },
    );
  }

  /// Updates a post locally in the state (e.g. when references are added/removed via bottom sheet)
  void updatePostLocally(TafakorPost updatedPost) {
    final updatedList = state.posts.map((p) {
      if (p.id == updatedPost.id) {
        return updatedPost;
      }
      return p;
    }).toList();
    state = state.copyWith(posts: updatedList);
  }

  /// Deletes a post locally and on the server
  Future<bool> deletePost(int postId) async {
    final result = await _repository.deletePost(postId);
    return result.when(
      (_) {
        state = state.copyWith(
          posts: state.posts.where((p) => p.id != postId).toList(),
          totalCount: (state.totalCount - 1).clamp(0, 999999),
        );
        return true;
      },
      (failure) => false,
    );
  }

  /// Optimistically toggles heart reaction on a post
  Future<void> toggleReaction(int postId, {String emoji = '❤️'}) async {
    final oldPosts = state.posts;
    final index = oldPosts.indexWhere((p) => p.id == postId);
    if (index == -1) return;
    final post = oldPosts[index];

    final isCurrentlyLiked = post.userReaction == emoji;
    final newReaction = isCurrentlyLiked ? null : emoji;
    final newSummary = Map<String, int>.from(post.reactionsSummary);

    if (isCurrentlyLiked) {
      final count = (newSummary[emoji] ?? 1) - 1;
      if (count <= 0) {
        newSummary.remove(emoji);
      } else {
        newSummary[emoji] = count;
      }
    } else {
      if (post.userReaction != null) {
        final oldCount = (newSummary[post.userReaction!] ?? 1) - 1;
        if (oldCount <= 0) {
          newSummary.remove(post.userReaction!);
        } else {
          newSummary[post.userReaction!] = oldCount;
        }
      }
      newSummary[emoji] = (newSummary[emoji] ?? 0) + 1;
    }

    final updatedPost = post.copyWith(
      userReaction: newReaction,
      reactionsSummary: newSummary,
    );
    final updatedList = List<TafakorPost>.from(oldPosts);
    updatedList[index] = updatedPost;
    state = state.copyWith(posts: updatedList);

    final result = await _repository.reactToPost(postId, isCurrentlyLiked ? '' : emoji);
    result.when(
      (_) {},
      (failure) {
        // Rollback on network failure
        state = state.copyWith(posts: oldPosts);
      },
    );
  }
}
