import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'i_hive_service.dart';
import 'hive_service_impl.dart';

/// Provides a singleton instance of the HiveService.
final hiveServiceProvider = Provider<IHiveService>((ref) {
  return HiveServiceImpl();
});
