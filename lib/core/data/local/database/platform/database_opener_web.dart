import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

Future<Database> openQuranDatabase({
  required String dbName,
  required String assetDbPath,
}) async {
  // Use basic web worker to ensure universal browser compatibility (Chrome, Edge, Safari, Firefox)
  final options = SqfliteFfiWebOptions(
    sharedWorkerUri: Uri.parse('sqflite_sw.js'),
    forceAsBasicWorker: true,
  );
  databaseFactory = createDatabaseFactoryFfiWeb(options: options);
  final factory = databaseFactory;

  // In Web IndexedDB, use dbName directly as the identifier without getDatabasesPath()
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
}
