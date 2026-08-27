import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/data/remote/network_service.dart';

abstract class ITranslationRemoteDataSource {
  Future<Map<String, String>> fetchTranslation(String sourceUrl, {void Function(int, int)? onReceiveProgress});
}

class TranslationRemoteDataSource implements ITranslationRemoteDataSource {
  final Dio _dio;
  TranslationRemoteDataSource(this._dio);

  @override
  Future<Map<String, String>> fetchTranslation(String sourceUrl, {void Function(int, int)? onReceiveProgress}) async {
    final response = await _dio.get(sourceUrl, onReceiveProgress: onReceiveProgress);
    final data = response.data;
    
    Map<String, String> parsedAyahs = {};
    
    // Parse AlQuran Cloud JSON format
    if (sourceUrl.contains('api.alquran.cloud')) {
      final surahs = data['data']['surahs'];
      for (var surah in surahs) {
        final surahNumber = surah['number'];
        for (var ayah in surah['ayahs']) {
          final ayahNumber = ayah['numberInSurah'];
          parsedAyahs['${surahNumber}_$ayahNumber'] = ayah['text'].toString();
        }
      }
    } 
    // Parse Fawaz Ahmed (jsdelivr) JSON format
    else if (sourceUrl.contains('jsdelivr')) {
      final quranList = data['quran'] as List;
      for (var item in quranList) {
        final surahNumber = item['chapter'];
        final ayahNumber = item['verse'];
        parsedAyahs['${surahNumber}_$ayahNumber'] = item['text'].toString();
      }
    }
    
    return parsedAyahs;
  }
}

final translationRemoteDataSourceProvider = Provider<ITranslationRemoteDataSource>((ref) {
  final dio = ref.watch(networkServiceProvider);
  return TranslationRemoteDataSource(dio);
});
