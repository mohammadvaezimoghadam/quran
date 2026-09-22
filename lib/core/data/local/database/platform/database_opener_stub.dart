import 'package:sqflite/sqflite.dart';

Future<Database> openQuranDatabase({
  required String dbName,
  required String assetDbPath,
}) {
  throw UnsupportedError(
    'Cannot open Quran database on this platform without IO or Web support.',
  );
}
