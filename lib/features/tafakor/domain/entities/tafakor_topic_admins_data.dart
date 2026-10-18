import 'tafakor_topic.dart';

class TafakorTopicAdminUser {
  final int id;
  final String phone;
  final String name;
  final String? profileImage;
  final String customTitle;

  const TafakorTopicAdminUser({
    required this.id,
    required this.phone,
    required this.name,
    this.profileImage,
    this.customTitle = 'Admin',
  });

  factory TafakorTopicAdminUser.fromJson(Map<String, dynamic> json) {
    final userMap = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : json;
    final fName = userMap['first_name']?.toString() ?? '';
    final lName = userMap['last_name']?.toString() ?? '';
    final fullName = '$fName $lName'.trim();
    final phone = userMap['phone']?.toString() ?? '';

    return TafakorTopicAdminUser(
      id: userMap['id'] is int
          ? userMap['id'] as int
          : int.tryParse(userMap['id']?.toString() ?? '') ?? 0,
      phone: phone,
      name: fullName.isNotEmpty ? fullName : phone,
      profileImage: userMap['profile_image']?.toString(),
      customTitle: json['custom_title']?.toString() ?? 'Admin',
    );
  }
}

class TafakorTopicAdminsData {
  final int? ownerId;
  final String? ownerPhone;
  final String? ownerName;
  final List<TafakorTopicAdminUser> admins;

  const TafakorTopicAdminsData({
    this.ownerId,
    this.ownerPhone,
    this.ownerName,
    this.admins = const [],
  });

  factory TafakorTopicAdminsData.fromJson(Map<String, dynamic> json) {
    final ownerMap = json['owner'] as Map<String, dynamic>?;
    int? ownerId;
    String? ownerPhone;
    String? ownerName;

    if (ownerMap != null) {
      ownerId = ownerMap['id'] is int
          ? ownerMap['id'] as int
          : int.tryParse(ownerMap['id']?.toString() ?? '');
      ownerPhone = ownerMap['phone']?.toString();
      final fName = ownerMap['first_name']?.toString() ?? '';
      final lName = ownerMap['last_name']?.toString() ?? '';
      final fullName = '$fName $lName'.trim();
      ownerName = fullName.isNotEmpty ? fullName : ownerPhone;
    }

    final rawAdmins = json['admins'] as List<dynamic>? ?? [];
    final adminsList = rawAdmins
        .whereType<Map<String, dynamic>>()
        .map(TafakorTopicAdminUser.fromJson)
        .toList();

    return TafakorTopicAdminsData(
      ownerId: ownerId,
      ownerPhone: ownerPhone,
      ownerName: ownerName,
      admins: adminsList,
    );
  }

  bool isOwner(String? phone) {
    if (phone == null || phone.trim().isEmpty || ownerPhone == null) return false;
    return TafakorTopic.normalizePhone(phone) == TafakorTopic.normalizePhone(ownerPhone!);
  }

  bool isAdmin(String? phone) {
    if (phone == null || phone.trim().isEmpty) return false;
    final normalized = TafakorTopic.normalizePhone(phone);
    return admins.any((a) => TafakorTopic.normalizePhone(a.phone) == normalized);
  }

  bool canPost(String? phone) => isOwner(phone) || isAdmin(phone);
}
