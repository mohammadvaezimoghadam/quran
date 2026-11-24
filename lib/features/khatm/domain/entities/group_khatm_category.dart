/// Intention/Category entity for Group Khatms (اموات، شفا، فرج، حاجت و...).
class GroupKhatmCategory {
  final int id;
  final String title;
  final String slug;
  final String? icon;
  final int displayOrder;
  final bool isActive;

  const GroupKhatmCategory({
    required this.id,
    required this.title,
    required this.slug,
    this.icon,
    this.displayOrder = 0,
    this.isActive = true,
  });

  factory GroupKhatmCategory.fromJson(Map<String, dynamic> json) {
    return GroupKhatmCategory(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      icon: json['icon'] as String?,
      displayOrder: json['display_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'icon': icon,
      'display_order': displayOrder,
      'is_active': isActive,
    };
  }
}
