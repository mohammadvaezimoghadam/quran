import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_service_impl.dart';
import 'i_sqflite_service.dart';
import 'sqflite_service_impl.dart';

/// Provider for ISqfliteService placed at top of file
final sqfliteServiceProvider = Provider<ISqfliteService>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return SqfliteServiceImpl(dbService);
});
