import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/data/remote/network_service.dart';

abstract class ITranslationRemoteDataSource {
  Future<Map<String, String>> fetchTranslation(
    String sourceUrl, {
    void Function(int, int)? onReceiveProgress,
    CancelToken? cancelToken,
  });
}

class TranslationRemoteDataSource implements ITranslationRemoteDataSource {
  final Dio _dio;
  TranslationRemoteDataSource(this._dio);

  @override
  Future<Map<String, String>> fetchTranslation(
    String sourceUrl, {
    void Function(int, int)? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
      sourceUrl,
      onReceiveProgress: onReceiveProgress,
      cancelToken: cancelToken,
    );
    final dynamic rawData = response.data;
    final dynamic data = rawData is String ? jsonDecode(rawData) : rawData;

    final Map<String, String> parsedAyahs = {};

    if (data is! Map) {
      throw FormatException(
        'Unexpected translation response payload for $sourceUrl',
      );
    }

    // Parse AlQuran Cloud JSON structure (supports both origin and S3 mirror URLs)
    final nestedData = data['data'];
    if (nestedData is Map && nestedData['surahs'] is List) {
      for (final surah in nestedData['surahs'] as List) {
        final surahNumber = surah['number'];
        for (final ayah in surah['ayahs'] as List) {
          final ayahNumber = ayah['numberInSurah'];
          parsedAyahs['${surahNumber}_$ayahNumber'] = ayah['text'].toString();
        }
      }
    }
    // Parse Fawaz Ahmed JSON structure (supports both origin and S3 mirror URLs)
    else if (data['quran'] is List) {
      for (final item in data['quran'] as List) {
        final surahNumber = item['chapter'];
        final ayahNumber = item['verse'];
        parsedAyahs['${surahNumber}_$ayahNumber'] = item['text'].toString();
      }
    } else {
      throw FormatException('Unsupported translation schema for $sourceUrl');
    }

    return parsedAyahs;
  }
}

final translationRemoteDataSourceProvider = Provider<ITranslationRemoteDataSource>((ref) {
  final dio = ref.watch(networkServiceProvider);
  return TranslationRemoteDataSource(dio);
});
