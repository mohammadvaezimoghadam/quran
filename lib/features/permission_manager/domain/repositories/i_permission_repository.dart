import '../entities/app_permission_item.dart';

abstract class IPermissionRepository {
  /// Fetches current status of all app permissions
  Future<List<AppPermissionItem>> getPermissionsStatus();

  /// Requests or opens settings for the specified permission item
  Future<bool> requestOrOpenPermission(AppPermissionItem item);
}
