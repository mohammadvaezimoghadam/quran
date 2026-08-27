import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/data/local/sqflite/i_sqflite_service.dart';
import '../../../../core/data/local/sqflite/sqflite_service_provider.dart';
import '../dtos/page_navigation_dto.dart';

final pageNavigationLocalDataSourceProvider = Provider<IPageNavigationLocalDataSource>((ref) {
  final sqfliteService = ref.watch(sqfliteServiceProvider);
  return PageNavigationLocalDataSourceImpl(sqfliteService);
});

/// Interface for local data source
abstract class IPageNavigationLocalDataSource {
  /// Queries the local database to find Surah and Ayah details for a given page
  Future<PageNavigationDto?> getSurahInfoByPage(int pageNumber);
}

/// Implementation of the local data source
class PageNavigationLocalDataSourceImpl implements IPageNavigationLocalDataSource {
  final ISqfliteService _sqfliteService;

  PageNavigationLocalDataSourceImpl(this._sqfliteService);

  @override
  Future<PageNavigationDto?> getSurahInfoByPage(int pageNumber) async {
    const sql = '''
      SELECT 
        a.surah_number as surah_id,
        a.number_in_surah as ayah_number,
        s.name as surah_name
      FROM ayahs a
      JOIN surahs s ON a.surah_number = s.id
      WHERE a.page = ?
      ORDER BY a.surah_number ASC, a.number_in_surah ASC
      LIMIT 1
    ''';

    final List<Map<String, dynamic>> maps = await _sqfliteService.rawQuery(
      sql,
      [pageNumber],
    );

    if (maps.isNotEmpty) {
      return PageNavigationDto.fromSqlite(maps.first);
    }
    return null;
  }
}

