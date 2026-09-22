import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> openQuranDatabase({
  required String dbName,
  required String assetDbPath,
}) async {
  final databasesPath = await getDatabasesPath();
  final path = join(databasesPath, dbName);

  final exists = await databaseExists(path);

  if (!exists) {
    try {
      await Directory(dirname(path)).create(recursive: true);
    } catch (_) {}

    final data = await rootBundle.load(assetDbPath);
    final bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    await File(path).writeAsBytes(bytes, flush: true);
  }

  return await openDatabase(path);
}
