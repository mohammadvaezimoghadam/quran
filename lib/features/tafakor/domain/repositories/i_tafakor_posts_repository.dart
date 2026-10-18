import 'package:multiple_result/multiple_result.dart';
import '../../../../common/exceptions/failure.dart';
import '../entities/tafakor_paginated_posts.dart';
import '../entities/tafakor_post.dart';
import '../entities/tafakor_topic_admins_data.dart';

abstract class ITafakorPostsRepository {
  Future<Result<TafakorPaginatedPosts, Failure>> getTopicPosts({
    required int topicId,
    int page = 1,
  });

  Future<Result<TafakorPost, Failure>> createPost({
    required int topicId,
    required String content,
    String? mediaFilePath,
  });

  Future<Result<TafakorPost, Failure>> updatePost({
    required int postId,
    required String content,
  });

  Future<Result<void, Failure>> deletePost(int postId);

  Future<Result<void, Failure>> reactToPost(int postId, String emoji);

  Future<Result<TafakorTopicAdminsData, Failure>> getTopicAdmins(int topicId);
}

