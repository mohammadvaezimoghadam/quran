import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../common/exceptions/failure.dart';
import '../../../../common/mixins/dio_exception_mapper.dart';
import '../../domain/entities/surah_teasers_result.dart';
import '../../domain/repositories/i_ayah_teaser_repository.dart';
import '../datasources/ayah_teaser_remote_datasource.dart';

class _CachedSurahTeasers {
  final SurahTeasersResult data;
  final DateTime cachedAt;

  _CachedSurahTeasers(this.data) : cachedAt = DateTime.now();

  bool isExpired(Duration ttl) =>
      DateTime.now().difference(cachedAt) > ttl;
}

final ayahTeaserRepositoryProvider = Provider<IAyahTeaserRepository>((ref) {
  final remoteDataSource = ref.watch(ayahTeaserRemoteDataSourceProvider);
  return AyahTeaserRepositoryImpl(remoteDataSource);
});

class AyahTeaserRepositoryImpl
    with DioExceptionMapper
    implements IAyahTeaserRepository {
  final AyahTeaserRemoteDataSource _remoteDataSource;

  /// In-memory cache to guarantee zero-latency Ayah card rendering during reading
  final Map<int, _CachedSurahTeasers> _cache = {};

  /// Cache TTL (default: 5 minutes)
  final Duration cacheTtl;

  AyahTeaserRepositoryImpl(
    this._remoteDataSource, {
    this.cacheTtl = const Duration(minutes: 5),
  });

  @override
  Future<Result<SurahTeasersResult, Failure>> getSurahLatestPosts({
    required int surahNumber,
    bool forceRefresh = false,
  }) async {
    // 1. Check in-memory cache
    if (!forceRefresh && _cache.containsKey(surahNumber)) {
      final cached = _cache[surahNumber]!;
      if (!cached.isExpired(cacheTtl)) {
        debugPrint(
          '[AyahTeaserRepo] Returning in-memory cached teasers for Surah $surahNumber '
          '(${cached.data.totalAyahsWithPosts} ayahs with posts)',
        );
        return Success(cached.data);
      } else {
        _cache.remove(surahNumber);
      }
    }

    // 2. Fetch from remote API
    try {
      debugPrint('[AyahTeaserRepo] Fetching from remote API for Surah $surahNumber...');
      final dto = await _remoteDataSource.fetchSurahLatestPosts(surahNumber);
      final domainResult = dto.toDomain();

      // Store in cache
      _cache[surahNumber] = _CachedSurahTeasers(domainResult);

      debugPrint(
        '[AyahTeaserRepo] Successfully fetched teasers for Surah $surahNumber: '
        '${domainResult.totalAyahsWithPosts} ayahs have notes.',
      );
      return Success(domainResult);
    } on DioException catch (e, stackTrace) {
      debugPrint('[AyahTeaserRepo] DioException fetching teasers for Surah $surahNumber: ${e.message}');
      
      // Try to extract backend error message if present in unified format
      final responseData = e.response?.data;
      String? customMessage;
      if (responseData is Map) {
        if (responseData['detail'] != null) {
          customMessage = responseData['detail'].toString();
        } else if (responseData['error'] != null) {
          customMessage = responseData['error'].toString();
        }
      }

      final failure = mapDioExceptionToFailure(e, stackTrace);
      if (customMessage != null && customMessage.isNotEmpty) {
        return Error(failure.copyWith(message: customMessage));
      }
      return Error(failure);
    } catch (e, stackTrace) {
      debugPrint('[AyahTeaserRepo] Unexpected error fetching teasers: $e');
      return Error(Failure(
        message: 'خطا در دریافت یادداشت‌های سوره: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  void clearCache([int? surahNumber]) {
    if (surahNumber != null) {
      _cache.remove(surahNumber);
      debugPrint('[AyahTeaserRepo] Cache cleared for Surah $surahNumber');
    } else {
      _cache.clear();
      debugPrint('[AyahTeaserRepo] Cache cleared for all Surahs');
    }
  }
}
