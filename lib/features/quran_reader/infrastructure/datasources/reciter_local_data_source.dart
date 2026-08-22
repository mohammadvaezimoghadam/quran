import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/local/sqflite/i_sqflite_service.dart';
import '../../../../core/data/local/sqflite/sqflite_service_provider.dart';
import '../dtos/recitation_style_dto.dart';
import '../dtos/reciter_dto.dart';

final reciterLocalDataSourceProvider = Provider<IReciterLocalDataSource>((ref) {
  final sqfliteService = ref.watch(sqfliteServiceProvider);
  return ReciterLocalDataSource(sqfliteService);
});

abstract class IReciterLocalDataSource {
  Future<List<ReciterDto>> getAllReciters();
  Future<List<ReciterDto>> getRecitersByStyle(int styleId);
  Future<List<RecitationStyleDto>> getRecitationStyles();
  Future<ReciterDto?> getReciterById(int id);
}

class ReciterLocalDataSource implements IReciterLocalDataSource {
  final ISqfliteService _sqfliteService;

  ReciterLocalDataSource(this._sqfliteService);

  @override
  Future<List<ReciterDto>> getAllReciters() async {
    const sql = '''
      SELECT 
        r.id,
        r.identifier,
        r.name,
        r.english_name,
        r.arabic_name,
        r.subfolder,
        r.bitrate,
        r.style_id,
        r.image_url,
        s.name AS style_name
      FROM reciters r
      LEFT JOIN recitation_styles s ON r.style_id = s.id
      WHERE LOWER(r.subfolder) NOT IN (
        'xml', 'images_png', 'quranpngs', 'timings_files', 'tools', 
        'translations', 'qurantext', 'qurantext_jpg', 'multilanguage', 
        'english', 'warsh'
      )
      ORDER BY r.id ASC
    ''';

    final List<Map<String, dynamic>> maps = await _sqfliteService.rawQuery(sql);
    return maps.map((map) => ReciterDto.fromSqlite(map)).toList();
  }

  @override
  Future<List<ReciterDto>> getRecitersByStyle(int styleId) async {
    const sql = '''
      SELECT 
        r.id,
        r.identifier,
        r.name,
        r.english_name,
        r.arabic_name,
        r.subfolder,
        r.bitrate,
        r.style_id,
        r.image_url,
        s.name AS style_name
      FROM reciters r
      LEFT JOIN recitation_styles s ON r.style_id = s.id
      WHERE r.style_id = ?
        AND LOWER(r.subfolder) NOT IN (
          'xml', 'images_png', 'quranpngs', 'timings_files', 'tools', 
          'translations', 'qurantext', 'qurantext_jpg', 'multilanguage', 
          'english', 'warsh'
        )
      ORDER BY r.id ASC
    ''';

    final List<Map<String, dynamic>> maps = await _sqfliteService.rawQuery(sql, [styleId]);
    return maps.map((map) => ReciterDto.fromSqlite(map)).toList();
  }

  @override
  Future<List<RecitationStyleDto>> getRecitationStyles() async {
    const sql = '''
      SELECT id, name, english_name
      FROM recitation_styles
      ORDER BY id ASC
    ''';

    final List<Map<String, dynamic>> maps = await _sqfliteService.rawQuery(sql);
    return maps.map((map) => RecitationStyleDto.fromSqlite(map)).toList();
  }

  @override
  Future<ReciterDto?> getReciterById(int id) async {
    const sql = '''
      SELECT 
        r.id,
        r.identifier,
        r.name,
        r.english_name,
        r.arabic_name,
        r.subfolder,
        r.bitrate,
        r.style_id,
        r.image_url,
        s.name AS style_name
      FROM reciters r
      LEFT JOIN recitation_styles s ON r.style_id = s.id
      WHERE r.id = ?
      LIMIT 1
    ''';

    final List<Map<String, dynamic>> maps = await _sqfliteService.rawQuery(sql, [id]);
    if (maps.isEmpty) return null;
    return ReciterDto.fromSqlite(maps.first);
  }
}
