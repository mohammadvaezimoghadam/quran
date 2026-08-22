import 'package:sqflite/sqflite.dart';

abstract interface class IDatabaseService {
  Future<Database> getDatabase();
}
