import '../database/i_database_service.dart';
import 'i_sqflite_service.dart';

/// Implementation of ISqfliteService using IDatabaseService
class SqfliteServiceImpl implements ISqfliteService {
  final IDatabaseService _databaseService;

  SqfliteServiceImpl(this._databaseService);

  @override
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await _databaseService.getDatabase();
    return await db.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    final db = await _databaseService.getDatabase();
    return await db.rawQuery(sql, arguments);
  }
}
