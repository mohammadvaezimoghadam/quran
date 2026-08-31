import '../../../data/local/sqflite/i_sqflite_service.dart';
import '../domain/entities/ayah_target.dart';
import '../domain/quran_navigation_service.dart';

/// SQLite implementation of [IQuranNavigationService]
class SqfliteQuranNavigationServiceImpl implements IQuranNavigationService {
  final ISqfliteService _sqfliteService;

  SqfliteQuranNavigationServiceImpl(this._sqfliteService);

  @override
  Future<AyahTarget?> getTargetBySurah(int surahId, {int ayahNumber = 1}) async {
    if (surahId < 1 || surahId > 114) return null;
    return AyahTarget(
      surahId: surahId,
      ayahNumber: ayahNumber < 1 ? 1 : ayahNumber,
    );
  }

  @override
  Future<AyahTarget?> getTargetByPage(int page) async {
    if (page < 1 || page > 604) return null;

    const sql = '''
      SELECT surah_number, number_in_surah 
      FROM ayahs 
      WHERE page = ? 
      ORDER BY id ASC 
      LIMIT 1
    ''';

    final result = await _sqfliteService.rawQuery(sql, [page]);
    if (result.isEmpty) return null;

    final row = result.first;
    return AyahTarget(
      surahId: row['surah_number'] as int,
      ayahNumber: row['number_in_surah'] as int,
    );
  }

  @override
  Future<AyahTarget?> getTargetByJuz(int juz) async {
    if (juz < 1 || juz > 30) return null;

    const sql = '''
      SELECT surah_number, number_in_surah 
      FROM ayahs 
      WHERE juz = ? 
      ORDER BY id ASC 
      LIMIT 1
    ''';

    final result = await _sqfliteService.rawQuery(sql, [juz]);
    if (result.isEmpty) return null;

    final row = result.first;
    return AyahTarget(
      surahId: row['surah_number'] as int,
      ayahNumber: row['number_in_surah'] as int,
    );
  }

  @override
  Future<AyahTarget?> getTargetByHizb(int hizb) async {
    if (hizb < 1 || hizb > 120) return null;

    final hizbQuarterStart = (hizb - 1) * 2 + 1;

    const sql = '''
      SELECT surah_number, number_in_surah 
      FROM ayahs 
      WHERE hizb_quarter >= ? 
      ORDER BY id ASC 
      LIMIT 1
    ''';

    final result = await _sqfliteService.rawQuery(sql, [hizbQuarterStart]);
    if (result.isEmpty) return null;

    final row = result.first;
    return AyahTarget(
      surahId: row['surah_number'] as int,
      ayahNumber: row['number_in_surah'] as int,
    );
  }
}
