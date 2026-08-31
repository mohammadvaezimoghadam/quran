import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/sqflite/sqflite_service_provider.dart';
import 'domain/quran_navigation_service.dart';
import 'infrastructure/sqflite_quran_navigation_service_impl.dart';

/// Riverpod Provider for [IQuranNavigationService]
final quranNavigationServiceProvider = Provider<IQuranNavigationService>((ref) {
  final sqfliteService = ref.watch(sqfliteServiceProvider);
  return SqfliteQuranNavigationServiceImpl(sqfliteService);
});
