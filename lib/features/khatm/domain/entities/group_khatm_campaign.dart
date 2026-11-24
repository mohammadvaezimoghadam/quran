import 'group_khatm_category.dart';
import 'group_khatm_slot.dart';
import 'khatm_enums.dart';

/// Collective Group Khatm Campaign entity matching the backend DRF serializer.
class GroupKhatmCampaign {
  final int id;
  final String inviteCode;
  final GroupKhatmCategory? category;
  final int? creatorId;
  final String creatorDisplayName;
  final String title;
  final String? description;
  final String unitType; // 'juz', 'hizb', 'surah'
  final String? unitTypeDisplay;
  final int targetUnits;
  final int? targetSurahId;
  final String? targetSurahName;
  final int reservedUnits;
  final int completedUnits;
  final int remainingUnits;
  final double progressPercentage;
  final bool isPublic;
  final GroupKhatmStatus status;
  final String? statusDisplay;
  final DateTime? deadline;
  final DateTime createdAt;
  final bool isCreator;
  final List<GroupKhatmSlot> slots;
  final String? inviteUrl;
  final int myActiveSlotsCount;

  const GroupKhatmCampaign({
    required this.id,
    required this.inviteCode,
    this.category,
    this.creatorId,
    required this.creatorDisplayName,
    required this.title,
    this.description,
    required this.unitType,
    this.unitTypeDisplay,
    required this.targetUnits,
    this.targetSurahId,
    this.targetSurahName,
    this.reservedUnits = 0,
    this.completedUnits = 0,
    required this.remainingUnits,
    required this.progressPercentage,
    this.isPublic = true,
    required this.status,
    this.statusDisplay,
    this.deadline,
    required this.createdAt,
    this.isCreator = false,
    this.slots = const [],
    this.inviteUrl,
    this.myActiveSlotsCount = 0,
  });

  bool get isCompleted => status == GroupKhatmStatus.completed || progressPercentage >= 100.0;
  bool get isExpired => status == GroupKhatmStatus.expired;

  String? get categoryTitle => category?.title;
  GroupKhatmUnitType get unitTypeEnum => GroupKhatmUnitType.fromString(unitType);
  String get unitTypeLabel => unitTypeDisplay ?? unitTypeEnum.labelFa;
  double get progressPercent => progressPercentage;
  int? get targetSurah => targetSurahId;

  /// Slots claimed or completed by current authenticated user
  List<GroupKhatmSlot> get mySlots => slots.where((s) => s.isMine).toList();

  factory GroupKhatmCampaign.fromJson(Map<String, dynamic> json) {
    return GroupKhatmCampaign(
      id: json['id'] as int? ?? 0,
      inviteCode: json['invite_code'] as String? ?? '',
      category: json['category'] != null && json['category'] is Map<String, dynamic>
          ? GroupKhatmCategory.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      creatorId: json['creator_id'] as int?,
      creatorDisplayName: json['creator_display_name'] as String? ?? 'کاربر قرآن',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      unitType: json['unit_type'] as String? ?? 'juz',
      unitTypeDisplay: json['unit_type_display'] as String?,
      targetUnits: json['target_units'] as int? ?? 30,
      targetSurahId: json['target_surah_id'] as int?,
      targetSurahName: json['target_surah_name'] as String?,
      reservedUnits: json['reserved_units'] as int? ?? 0,
      completedUnits: json['completed_units'] as int? ?? 0,
      remainingUnits: json['remaining_units'] as int? ?? 0,
      progressPercentage: (json['progress_percentage'] as num?)?.toDouble() ?? 0.0,
      isPublic: json['is_public'] as bool? ?? true,
      status: GroupKhatmStatus.fromString(json['status'] as String?),
      statusDisplay: json['status_display'] as String?,
      deadline: json['deadline'] != null ? DateTime.tryParse(json['deadline'].toString()) : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isCreator: json['is_creator'] as bool? ?? false,
      slots: json['slots'] != null && json['slots'] is List
          ? (json['slots'] as List)
              .map((s) => GroupKhatmSlot.fromJson(s as Map<String, dynamic>))
              .toList()
          : const [],
      inviteUrl: json['invite_url'] as String?,
      myActiveSlotsCount: json['my_active_slots_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invite_code': inviteCode,
      'category': category?.toJson(),
      'creator_id': creatorId,
      'creator_display_name': creatorDisplayName,
      'title': title,
      'description': description,
      'unit_type': unitType,
      'unit_type_display': unitTypeDisplay,
      'target_units': targetUnits,
      'target_surah_id': targetSurahId,
      'target_surah_name': targetSurahName,
      'reserved_units': reservedUnits,
      'completed_units': completedUnits,
      'remaining_units': remainingUnits,
      'progress_percentage': progressPercentage,
      'is_public': isPublic,
      'status': status.name,
      'status_display': statusDisplay,
      'deadline': deadline?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'is_creator': isCreator,
      'slots': slots.map((s) => s.toJson()).toList(),
      'invite_url': inviteUrl,
      'my_active_slots_count': myActiveSlotsCount,
    };
  }
}
