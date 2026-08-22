import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'i_database_service.dart';

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
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _dbName);

    final exists = await databaseExists(path);

    if (!exists) {
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      final data = await rootBundle.load(_assetDbPath);
      final bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      await File(path).writeAsBytes(bytes, flush: true);
    }

    return await openDatabase(path);
  }
}
