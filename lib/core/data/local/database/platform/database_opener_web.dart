import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

DatabaseFactory? _webDbFactory;

Future<Database> openQuranDatabase({
  required String dbName,
  required String assetDbPath,
}) async {
  debugPrint('🔍 [Web Database] openQuranDatabase invoked for $dbName (asset: $assetDbPath)');
  try {
    if (_webDbFactory == null) {
      debugPrint('🔍 [Web Database] Creating databaseFactoryFfiWeb with basic worker...');
      final options = SqfliteFfiWebOptions(
        sharedWorkerUri: Uri.parse('sqflite_sw.js'),
        // ignore: invalid_use_of_visible_for_testing_member
        forceAsBasicWorker: true,
      );
      _webDbFactory = createDatabaseFactoryFfiWeb(options: options);
      databaseFactory = _webDbFactory!;
      debugPrint('✅ [Web Database] databaseFactoryFfiWeb created.');
    }
    final factory = _webDbFactory!;

    final path = dbName;
    debugPrint('🔍 [Web Database] Checking if database exists: $path...');
    final exists = await factory.databaseExists(path);
    debugPrint('🔍 [Web Database] Database exists? $exists');

    if (!exists) {
      debugPrint('⏳ [Web Database] Loading asset $assetDbPath into memory...');
      final data = await rootBundle.load(assetDbPath);
      final bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      debugPrint('⏳ [Web Database] Writing ${bytes.lengthInBytes} bytes to IndexedDB...');
      await factory.writeDatabaseBytes(path, bytes);
      debugPrint('✅ [Web Database] Database written to IndexedDB successfully.');
    }

    debugPrint('🚀 [Web Database] Calling factory.openDatabase($path)...');
    final db = await factory.openDatabase(path);
    debugPrint('✅ [Web Database] Database opened successfully! Version: ${await db.getVersion()}');
    return db;
  } catch (e, st) {
    debugPrint('🛑 [Web Database Error] Failed to open database: $e\n$st');
    rethrow;
  }
}
