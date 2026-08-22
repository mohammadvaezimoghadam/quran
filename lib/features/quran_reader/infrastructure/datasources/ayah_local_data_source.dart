import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/local/sqflite/i_sqflite_service.dart';
import '../../../../core/data/local/sqflite/sqflite_service_provider.dart';
import '../dtos/ayah_dto.dart';
import '../dtos/word_dto.dart';

final ayahLocalDataSourceProvider = Provider<IAyahLocalDataSource>((ref) {
  final sqfliteService = ref.watch(sqfliteServiceProvider);
  return AyahLocalDataSource(sqfliteService);
});

abstract class IAyahLocalDataSource {
  Future<List<AyahDto>> getAyahsBySurah(int surahId);
  Future<List<WordDto>> getAyahWords(int surahId, int ayahNumber);
}

class AyahLocalDataSource implements IAyahLocalDataSource {
  final ISqfliteService _sqfliteService;

  AyahLocalDataSource(this._sqfliteService);

  @override
  Future<List<AyahDto>> getAyahsBySurah(int surahId) async {
    const sql = '''
      SELECT 
        a.id,
        a.surah_number,
        a.number_in_surah,
        a.text_uthmani,
        a.page,
        a.juz,
        a.hizb_quarter,
        t.text AS translation
      FROM ayahs a
      LEFT JOIN translations t ON a.id = t.ayah_id AND t.translation_id = 'fa.ansarian'
      WHERE a.surah_number = ?
      ORDER BY a.number_in_surah ASC
    ''';

    final List<Map<String, dynamic>> maps = await _sqfliteService.rawQuery(
      sql,
      [surahId],
    );

    return maps.map((map) => AyahDto.fromSqlite(map)).toList();
  }

  @override
  Future<List<WordDto>> getAyahWords(int surahId, int ayahNumber) async {
    const sql = '''
      SELECT * FROM words 
      WHERE surah_id = ? AND ayah_number = ? 
      ORDER BY word_position ASC
    ''';

    final List<Map<String, dynamic>> maps = await _sqfliteService.rawQuery(
      sql,
      [surahId, ayahNumber],
    );

    return maps.map((map) => WordDto.fromSqlite(map)).toList();
  }
}
