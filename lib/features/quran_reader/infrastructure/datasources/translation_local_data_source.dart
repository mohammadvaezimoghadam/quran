import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/local/sqflite/i_sqflite_service.dart';
import '../../../../core/data/local/sqflite/sqflite_service_provider.dart';
import '../dtos/translation_dto.dart';

final translationLocalDataSourceProvider = Provider<ITranslationLocalDataSource>((ref) {
  final sqfliteService = ref.watch(sqfliteServiceProvider);
  return TranslationLocalDataSource(sqfliteService);
});

abstract class ITranslationLocalDataSource {
  Future<List<TranslationDto>> getTranslationsBySurah(int surahId, String translationId);
}

class TranslationLocalDataSource implements ITranslationLocalDataSource {
  final ISqfliteService _sqfliteService;

  TranslationLocalDataSource(this._sqfliteService);

  @override
  Future<List<TranslationDto>> getTranslationsBySurah(int surahId, String translationId) async {
    const sql = '''
      SELECT 
        t.id,
        t.translation_id,
        t.ayah_id,
        a.number_in_surah,
        t.text
      FROM translations t
      JOIN ayahs a ON t.ayah_id = a.id
      WHERE a.surah_number = ? AND t.translation_id = ?
      ORDER BY a.number_in_surah ASC
    ''';

    final List<Map<String, dynamic>> maps = await _sqfliteService.rawQuery(
      sql,
      [surahId, translationId],
    );

    return maps.map((map) => TranslationDto.fromSqlite(map)).toList();
  }
}
