import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/app_permission_item.dart';
import '../../domain/repositories/i_permission_repository.dart';
import 'permission_providers.dart';

class PermissionController extends Notifier<AsyncValue<List<AppPermissionItem>>>
    with WidgetsBindingObserver {
  late final IPermissionRepository _repository;

  @override
  AsyncValue<List<AppPermissionItem>> build() {
    _repository = ref.watch(permissionRepositoryProvider);
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
    });

    _fetchInitial();
    return const AsyncValue.loading();
  }

  Future<void> _fetchInitial() async {
    await loadPermissions();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      loadPermissions();
    }
  }

  Future<void> loadPermissions() async {
    try {
      final items = await _repository.getPermissionsStatus();
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> togglePermission(AppPermissionItem item) async {
    await _repository.requestOrOpenPermission(item);
    await loadPermissions();
  }

  bool hasUngrantedPermissions() {
    final current = state.value;
    if (current == null) return false;
    final coreCategories = [
      PermissionTypeCategory.notifications,
      PermissionTypeCategory.exactAlarm,
      PermissionTypeCategory.displayOverApps,
      PermissionTypeCategory.batterySaver,
    ];
    return current.any((item) => !item.isGranted && coreCategories.contains(item.category));
  }

  bool isCategoryGranted(PermissionTypeCategory category) {
    final current = state.value;
    if (current == null) return false;
    final item = current.firstWhere(
      (element) => element.category == category,
      orElse: () => AppPermissionItem(
        id: '',
        title: '',
        subtitle: '',
        category: category,
        isGranted: false,
      ),
    );
    return item.isGranted;
  }

  AppPermissionItem? getItemForCategory(PermissionTypeCategory category) {
    final current = state.value;
    if (current == null) return null;
    try {
      return current.firstWhere((element) => element.category == category);
    } catch (_) {
      return null;
    }
  }
}
