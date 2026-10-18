import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../common/exceptions/failure.dart';

import '../../domain/entities/tafakor_paginated_posts.dart';
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
  Future<void> loadPosts({required int topicId, bool isRefresh = false}) async {
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
        isLoading: isDifferentTopic || state.posts.isEmpty,
        clearError: true,
        posts: isDifferentTopic ? [] : state.posts,
      );
    }

    final postsFuture = _repository.getTopicPosts(topicId: topicId, page: 1);
    final adminsFuture = _repository.getTopicAdmins(topicId);

    final results = await Future.wait([postsFuture, adminsFuture]);
    final postsResult = results[0] as Result<TafakorPaginatedPosts, Failure>;
    final adminsResult = results[1] as Result<TafakorTopicAdminsData, Failure>;

    TafakorTopicAdminsData? adminsData = state.adminsData;
    adminsResult.when(
      (data) => adminsData = data,
      (_) {},
    );

    postsResult.when(
      (paginated) {
        state = state.copyWith(
          currentTopicId: topicId,
          isLoading: false,
          isRefreshing: false,
          posts: paginated.results,
          totalCount: paginated.count,
          currentPage: 1,
          hasMore: paginated.next != null,
          adminsData: adminsData,
          clearError: true,
        );
      },
      (failure) {
        state = state.copyWith(
          currentTopicId: topicId,
          isLoading: false,
          isRefreshing: false,
          adminsData: adminsData,
          error: failure,
        );
      },
    );
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
  }) async {
    final result = await _repository.createPost(
      topicId: topicId,
      content: content,
      mediaFilePath: mediaFilePath,
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
