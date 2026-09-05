enum PermissionTypeCategory {
  location,
  batterySaver,
  displayOverApps,
  notifications,
  exactAlarm,
  backgroundWindow,
  autoStart,
}

class AppPermissionItem {
  final String id;
  final String title;
  final String subtitle;
  final PermissionTypeCategory category;
  final bool isGranted;

  const AppPermissionItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.isGranted,
  });

  AppPermissionItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    PermissionTypeCategory? category,
    bool? isGranted,
  }) {
    return AppPermissionItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      category: category ?? this.category,
      isGranted: isGranted ?? this.isGranted,
    );
  }
}
