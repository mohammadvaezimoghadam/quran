import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/data/remote/tafakor_api_client.dart';
import '../dtos/ayah_teaser_dto.dart';

final ayahTeaserRemoteDataSourceProvider =
    Provider<AyahTeaserRemoteDataSource>((ref) {
  final dio = ref.watch(tafakorDioProvider);
  return AyahTeaserRemoteDataSource(dio);
});

class AyahTeaserRemoteDataSource {
  final Dio _dio;

  AyahTeaserRemoteDataSource(this._dio);

  /// Fetches latest posts per Ayah for [surahNumber] from server endpoint:
  /// `GET /api/notes/surah-latest-posts/?surah=<surahNumber>`
  Future<SurahTeasersDto> fetchSurahLatestPosts(int surahNumber) async {
    debugPrint('[AyahTeaserRemoteDS] Requesting latest posts for Surah $surahNumber...');
    final response = await _dio.get(
      'notes/surah-latest-posts/',
      queryParameters: {'surah': surahNumber},
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return SurahTeasersDto.fromJson(data);
    } else if (data is Map) {
      return SurahTeasersDto.fromJson(Map<String, dynamic>.from(data));
    }

    throw const FormatException('فرمت پاسخ دریافتی برای یادداشت‌های سوره معتبر نیست.');
  }
}
