import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../common/constants/app_constants.dart';
import '../../../../common/exceptions/failure.dart';
import '../../../../common/mixins/dio_exception_mapper.dart';
import '../../../../core/data/remote/tafakor_api_client.dart';
import '../../domain/entities/tafakor_paginated_posts.dart';
import '../../domain/entities/tafakor_post.dart';
import '../../domain/entities/tafakor_topic_admins_data.dart';
import '../../domain/repositories/i_tafakor_posts_repository.dart';
import '../dtos/tafakor_post_dto.dart';


final tafakorPostsRepositoryProvider = Provider<ITafakorPostsRepository>((ref) {
  final apiClient = ref.watch(tafakorApiClientProvider);
  final dio = ref.watch(tafakorDioProvider);
  return TafakorPostsRepositoryImpl(apiClient, dio);
});

class TafakorPostsRepositoryImpl with DioExceptionMapper implements ITafakorPostsRepository {
  final TafakorApiClient _apiClient;
  final Dio _dio;

  TafakorPostsRepositoryImpl(this._apiClient, this._dio);

  @override
  Future<Result<TafakorPost, Failure>> createPost({
    required int topicId,
    required String content,
    String? mediaFilePath,
  }) async {
    try {
      debugPrint('[TafakorPosts] Creating post for topic $topicId...');
      final dynamic requestData;
      if (mediaFilePath != null && mediaFilePath.isNotEmpty) {
        final lower = mediaFilePath.toLowerCase();
        final isVideo = lower.endsWith('.mp4') ||
            lower.endsWith('.mov') ||
            lower.endsWith('.mkv') ||
            lower.endsWith('.webm') ||
            lower.endsWith('.avi') ||
            lower.endsWith('.m4v') ||
            lower.endsWith('.3gp');
        final isAudio = lower.endsWith('.mp3') ||
            lower.endsWith('.m4a') ||
            lower.endsWith('.wav') ||
            lower.endsWith('.ogg') ||
            lower.endsWith('.aac');
        final mediaType = isVideo ? 'video' : (isAudio ? 'audio' : 'image');

        requestData = FormData.fromMap({
          'topic': topicId,
          'content': content,
          'media_type': mediaType,
          'media_file': await MultipartFile.fromFile(mediaFilePath),
        });
      } else {
        requestData = {
          'topic': topicId,
          'content': content,
        };
      }

      final response = await _dio.post('notes/', data: requestData);
      final dto = TafakorPostDto.fromJson(response.data as Map<String, dynamic>);
      debugPrint('[TafakorPosts] Successfully created post ${dto.id}');
      return Success(dto.toDomain());
    } on DioException catch (e, stackTrace) {
      debugPrint('[TafakorPosts] DioException on create: ${e.message}');
      return Error(mapDioExceptionToFailure(e, stackTrace));
    } catch (e, stackTrace) {
      debugPrint('[TafakorPosts] Unexpected error on create: $e');
      return Error(Failure(
        message: 'خطا در ثبت یادداشت: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Result<TafakorPost, Failure>> updatePost({
    required int postId,
    required String content,
  }) async {
    try {
      debugPrint('[TafakorPosts] Updating post $postId...');
      final response = await _dio.patch('notes/$postId/', data: {'content': content});
      final dto = TafakorPostDto.fromJson(response.data as Map<String, dynamic>);
      debugPrint('[TafakorPosts] Successfully updated post ${dto.id}');
      return Success(dto.toDomain());
    } on DioException catch (e, stackTrace) {
      debugPrint('[TafakorPosts] DioException on update: ${e.message}');
      return Error(mapDioExceptionToFailure(e, stackTrace));
    } catch (e, stackTrace) {
      debugPrint('[TafakorPosts] Unexpected error on update: $e');
      return Error(Failure(
        message: 'خطا در ویرایش یادداشت: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Result<TafakorPaginatedPosts, Failure>> getTopicPosts({
    required int topicId,
    int page = 1,
  }) async {
    try {
      debugPrint('[TafakorPosts] Fetching posts for topic: $topicId (page: $page)...');
      final dto = await _apiClient.getPosts(topicId, page);
      debugPrint('[TafakorPosts] Successfully fetched ${dto.results.length} posts (total: ${dto.count})');
      return Success(dto.toDomain());
    } on DioException catch (e, stackTrace) {
      debugPrint('[TafakorPosts] DioException: ${e.message} status: ${e.response?.statusCode}');
      return Error(mapDioExceptionToFailure(e, stackTrace));
    } catch (e, stackTrace) {
      debugPrint('[TafakorPosts] Unexpected error: $e');
      return Error(Failure(
        message: AppConstants.unexpectedError,
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Result<void, Failure>> deletePost(int postId) async {
    try {
      debugPrint('[TafakorPosts] Deleting post $postId...');
      await _apiClient.deletePost(postId);
      debugPrint('[TafakorPosts] Successfully deleted post $postId');
      return const Success(null);
    } on DioException catch (e, stackTrace) {
      debugPrint('[TafakorPosts] DioException on delete: ${e.message}');
      return Error(mapDioExceptionToFailure(e, stackTrace));
    } catch (e, stackTrace) {
      debugPrint('[TafakorPosts] Unexpected error on delete: $e');
      return Error(Failure(
        message: 'خطا در حذف پست: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Result<void, Failure>> reactToPost(int postId, String emoji) async {
    try {
      debugPrint('[TafakorPosts] Reacting to post $postId with emoji: $emoji...');
      await _apiClient.reactToPost(postId, {'emoji': emoji});
      return const Success(null);
    } on DioException catch (e, stackTrace) {
      debugPrint('[TafakorPosts] DioException on react: ${e.message}');
      return Error(mapDioExceptionToFailure(e, stackTrace));
    } catch (e, stackTrace) {
      debugPrint('[TafakorPosts] Unexpected error on react: $e');
      return Error(Failure(
        message: 'خطا در ثبت واکنش: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Result<TafakorTopicAdminsData, Failure>> getTopicAdmins(int topicId) async {
    try {
      debugPrint('[TafakorPosts] Fetching admins for topic $topicId...');
      final response = await _dio.get('notes/topics/$topicId/admins/');
      final data = TafakorTopicAdminsData.fromJson(response.data as Map<String, dynamic>);
      debugPrint('[TafakorPosts] Successfully fetched topic admins (owner: ${data.ownerPhone}, admins: ${data.admins.length})');
      return Success(data);
    } on DioException catch (e, stackTrace) {
      debugPrint('[TafakorPosts] DioException on getTopicAdmins: ${e.message}');
      return Error(mapDioExceptionToFailure(e, stackTrace));
    } catch (e, stackTrace) {
      debugPrint('[TafakorPosts] Unexpected error on getTopicAdmins: $e');
      return Error(Failure(
        message: 'خطا در دریافت لیست ادمین‌های تاپیک: $e',
        stackTrace: stackTrace,
      ));
    }
  }
}

