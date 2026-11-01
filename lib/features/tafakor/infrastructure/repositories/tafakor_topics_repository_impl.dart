import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../common/constants/app_constants.dart';
import '../../../../common/exceptions/failure.dart';
import '../../../../common/mixins/dio_exception_mapper.dart';
import '../../../../core/data/remote/tafakor_api_client.dart';
import '../../domain/entities/tafakor_topic.dart';
import '../../domain/repositories/i_tafakor_topics_repository.dart';

final tafakorTopicsRepositoryProvider = Provider<ITafakorTopicsRepository>((ref) {
  final apiClient = ref.watch(tafakorApiClientProvider);
  return TafakorTopicsRepositoryImpl(apiClient);
});

class TafakorTopicsRepositoryImpl with DioExceptionMapper implements ITafakorTopicsRepository {
  final TafakorApiClient _apiClient;
  static List<TafakorTopic>? _cachedTopics;

  TafakorTopicsRepositoryImpl(this._apiClient);

  @override
  Future<Result<List<TafakorTopic>, Failure>> getTopics() async {
    try {
      debugPrint('[TafakorTopics] Fetching topics from server...');
      final dtos = await _apiClient.getTopics();
      debugPrint('[TafakorTopics] Successfully fetched ${dtos.length} topics');
      final topics = dtos.map((d) => d.toDomain()).toList();
      _cachedTopics = topics;
      return Success(topics);
    } on DioException catch (e, stackTrace) {
      debugPrint('[TafakorTopics] DioException: ${e.message ?? ""} status: ${e.response?.statusCode ?? ""}');
      if (_cachedTopics != null && _cachedTopics!.isNotEmpty) {
        debugPrint('[TafakorTopics] Serving ${_cachedTopics!.length} cached topics after error');
        return Success(_cachedTopics!);
      }
      return Error(mapDioExceptionToFailure(e, stackTrace));
    } catch (e, stackTrace) {
      debugPrint('[TafakorTopics] Unexpected error: $e');
      if (_cachedTopics != null && _cachedTopics!.isNotEmpty) {
        debugPrint('[TafakorTopics] Serving ${_cachedTopics!.length} cached topics after error');
        return Success(_cachedTopics!);
      }
      return Error(Failure(
        message: AppConstants.unexpectedError,
        stackTrace: stackTrace,
      ));
    }
  }
}
