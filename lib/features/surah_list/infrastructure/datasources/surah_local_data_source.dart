import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/data/local/sqflite/i_sqflite_service.dart';
import '../../../../core/data/local/sqflite/sqflite_service_provider.dart';
import '../dtos/surah_dto.dart';

final surahLocalDataSourceProvider = Provider<ISurahLocalDataSource>((ref) {
  final sqfliteService = ref.watch(sqfliteServiceProvider);
  return SurahLocalDataSource(sqfliteService);
});

abstract class ISurahLocalDataSource {
  Future<List<SurahDto>> getSurahs();
  Future<SurahDto?> getSurahById(int id);
}

class SurahLocalDataSource implements ISurahLocalDataSource {
  final ISqfliteService _sqfliteService;

  SurahLocalDataSource(this._sqfliteService);

  @override
  Future<List<SurahDto>> getSurahs() async {
    final List<Map<String, dynamic>> maps = await _sqfliteService.query(
      'surahs',
      orderBy: 'id ASC',
    );

    return maps.map((map) => SurahDto.fromSqlite(map)).toList();
  }

  @override
  Future<SurahDto?> getSurahById(int id) async {
    final List<Map<String, dynamic>> maps = await _sqfliteService.query(
      'surahs',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return SurahDto.fromSqlite(maps.first);
    }
    return null;
  }
}
