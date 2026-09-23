import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_service_impl.dart';
import 'i_sqflite_service.dart';
import 'sqflite_service_impl.dart';

/// Provider for ISqfliteService placed at top of file
final sqfliteServiceProvider = Provider<ISqfliteService>((ref) {
  if (kIsWeb) {
    return const SqfliteServiceWebStub();
  }
  final dbService = ref.watch(databaseServiceProvider);
  return SqfliteServiceImpl(dbService);
});

/// Web-safe stub that safely returns empty results instead of hanging on SQLite WASM/Workers
class SqfliteServiceWebStub implements ISqfliteService {
  const SqfliteServiceWebStub();

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
    return const [];
  }

  @override
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    return const [];
  }
}
