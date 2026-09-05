import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../native_bridge/adhan_native_service_provider.dart';
import 'domain/app_permission_service.dart';
import 'infrastructure/app_permission_service_impl.dart';

/// Provider for [AppPermissionService].
/// Injects [AdhanNativeService] to handle native-specific permissions.
final appPermissionServiceProvider = Provider<AppPermissionService>((ref) {
  final nativeService = ref.watch(adhanNativeServiceProvider);
  return AppPermissionServiceImpl(nativeService);
});
