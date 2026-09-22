import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'i_database_service.dart';
import 'platform/database_opener.dart';

final databaseServiceProvider = Provider<IDatabaseService>((ref) {
  return DatabaseServiceImpl();
});

final class DatabaseServiceImpl implements IDatabaseService {
  Database? _database;
  static const String _dbName = 'quran.db';
  static const String _assetDbPath = 'assets/database/quran.db';

  @override
  Future<Database> getDatabase() async {
    if (_database != null) return _database!;
    _database = await openQuranDatabase(
      dbName: _dbName,
      assetDbPath: _assetDbPath,
    );
    return _database!;
  }
}
