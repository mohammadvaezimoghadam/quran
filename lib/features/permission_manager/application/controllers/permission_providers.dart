import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/native_bridge/adhan_native_service_provider.dart';
import '../../domain/entities/app_permission_item.dart';
import '../../domain/repositories/i_permission_repository.dart';
import '../../infrastructure/repositories/permission_repository.dart';
import 'permission_controller.dart';

final permissionRepositoryProvider = Provider<IPermissionRepository>((ref) {
  final nativeService = ref.watch(adhanNativeServiceProvider);
  return PermissionRepository(nativeService);
});

final permissionControllerProvider =
    NotifierProvider<PermissionController, AsyncValue<List<AppPermissionItem>>>(
  PermissionController.new,
);
