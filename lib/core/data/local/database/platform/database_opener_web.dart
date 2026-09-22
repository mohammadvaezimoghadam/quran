import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

Future<Database> openQuranDatabase({
  required String dbName,
  required String assetDbPath,
}) async {
  final factory = databaseFactoryFfiWeb;
  final databasesPath = await factory.getDatabasesPath();
  final path = join(databasesPath, dbName);

  final exists = await factory.databaseExists(path);

  if (!exists) {
    final data = await rootBundle.load(assetDbPath);
    final bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    await factory.writeDatabaseBytes(path, bytes);
  }

  return await factory.openDatabase(path);
}
