import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/constants/app_constants.dart';
import '../../../../core/data/remote/network_service.dart';
import '../dtos/surah_dto.dart';

final surahRemoteDataSourceProvider = Provider<ISurahRemoteDataSource>((ref) {
  final dio = ref.watch(networkServiceProvider);
  return SurahRemoteDataSource(dio);
});

abstract class ISurahRemoteDataSource {
  Future<List<SurahDto>> getSurahs();
}

class SurahRemoteDataSource implements ISurahRemoteDataSource {
  final Dio _dio;
  List<SurahDto>? _cache;

  SurahRemoteDataSource(this._dio);

  @override
  Future<List<SurahDto>> getSurahs() async {
    if (_cache != null && _cache!.isNotEmpty) {
      return _cache!;
    }
    try {
      debugPrint('🌐 [SurahRemoteDataSource] Fetching surahs from ${AppConstants.alQuranCloudBaseUrl}/surah ...');
      final response = await _dio.get('${AppConstants.alQuranCloudBaseUrl}/surah');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] as List<dynamic>;
        _cache = data.map((item) {
          final map = item as Map<String, dynamic>;
          final number = map['number'] as int;
          return SurahDto(
            number: number,
            name: map['name'] as String? ?? '',
            englishName: map['englishName'] as String? ?? '',
            englishNameTranslation: map['englishNameTranslation'] as String? ?? '',
            numberOfAyahs: map['numberOfAyahs'] as int? ?? 0,
            revelationType: map['revelationType'] as String? ?? '',
            startPage: _getSurahStartPage(number),
            startJuz: _getSurahStartJuz(number),
          );
        }).toList();
        debugPrint('✅ [SurahRemoteDataSource] Loaded ${_cache!.length} surahs successfully from API.');
        return _cache!;
      }
      throw Exception('API returned status ${response.statusCode}');
    } catch (e, st) {
      debugPrint('🛑 [SurahRemoteDataSource Error] $e\n$st');
      rethrow;
    }
  }

  static int _getSurahStartPage(int surahNumber) {
    if (surahNumber >= 1 && surahNumber <= _surahStartPages.length) {
      return _surahStartPages[surahNumber - 1];
    }
    return 1;
  }

  static int _getSurahStartJuz(int surahNumber) {
    if (surahNumber >= 1 && surahNumber <= _surahStartJuz.length) {
      return _surahStartJuz[surahNumber - 1];
    }
    return 1;
  }

  // Standard Medina Mushaf 114 Surah Start Pages
  static const List<int> _surahStartPages = [
    1, 2, 50, 77, 106, 128, 151, 177, 187, 208, 221, 235, 249, 255, 262, 267,
    282, 293, 305, 312, 322, 332, 342, 350, 359, 367, 377, 385, 396, 404, 411,
    415, 418, 428, 434, 440, 446, 453, 458, 467, 477, 483, 489, 496, 499, 502,
    507, 511, 515, 518, 520, 523, 526, 528, 531, 534, 537, 542, 545, 549, 551,
    553, 554, 556, 558, 560, 562, 564, 566, 568, 570, 572, 574, 575, 577, 578,
    580, 582, 583, 585, 586, 587, 587, 589, 590, 591, 591, 592, 593, 594, 595,
    595, 596, 596, 597, 597, 598, 598, 599, 599, 600, 600, 601, 601, 601, 602,
    602, 602, 603, 603, 603, 604, 604, 604
  ];

  // Standard Medina Mushaf 114 Surah Start Juz
  static const List<int> _surahStartJuz = [
    1, 1, 3, 4, 6, 7, 8, 9, 10, 11, 11, 12, 13, 13, 14, 14,
    15, 15, 16, 16, 17, 17, 18, 18, 18, 19, 19, 20, 20, 21, 21,
    21, 21, 22, 22, 22, 23, 23, 23, 24, 24, 24, 25, 25, 25, 26,
    26, 26, 26, 26, 26, 26, 27, 27, 27, 27, 27, 28, 28, 28, 28,
    28, 28, 28, 28, 28, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29,
    29, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30,
    30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30,
    30, 30, 30, 30, 30, 30, 30, 30
  ];
}
