import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

DatabaseFactory? _webDbFactory;

Future<Database> openQuranDatabase({
  required String dbName,
  required String assetDbPath,
}) async {
  try {
    if (_webDbFactory == null) {
      final options = SqfliteFfiWebOptions(
        sharedWorkerUri: Uri.parse('sqflite_sw.js'),
        forceAsBasicWorker: true,
      );
      _webDbFactory = createDatabaseFactoryFfiWeb(options: options);
      databaseFactory = _webDbFactory!;
    }
    final factory = _webDbFactory!;

    final path = dbName;
    final exists = await factory.databaseExists(path);

    if (!exists) {
      debugPrint('⏳ [Web Database] Initializing Quran database from assets into IndexedDB...');
      final data = await rootBundle.load(assetDbPath);
      final bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      await factory.writeDatabaseBytes(path, bytes);
      debugPrint('✅ [Web Database] Database written to IndexedDB successfully.');
    }

    return await factory.openDatabase(path);
  } catch (e, st) {
    debugPrint('🛑 [Web Database Error] Failed to open database: $e\n$st');
    rethrow;
  }
}
