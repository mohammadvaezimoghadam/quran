import 'khatm_enums.dart';

/// Single unit/slot allocation within a Group Khatm Campaign.
class GroupKhatmSlot {
  final int id;
  final int campaignId;
  final int? unitNumber;
  final int quantity;
  final GroupKhatmSlotStatus status;
  final int? userId;
  final String? userDisplayName;
  final bool isMine;
  final DateTime? reservedAt;
  final DateTime? expiresAt;
  final DateTime? completedAt;

  const GroupKhatmSlot({
    required this.id,
    required this.campaignId,
    this.unitNumber,
    this.quantity = 1,
    required this.status,
    this.userId,
    this.userDisplayName,
    this.isMine = false,
    this.reservedAt,
    this.expiresAt,
    this.completedAt,
  });

  /// Hours remaining before reservation expires
  int? get hoursRemaining {
    if (expiresAt == null) return null;
    final diff = expiresAt!.difference(DateTime.now());
    return diff.isNegative ? 0 : diff.inHours;
  }

  /// Whether expiry is imminent (less than 6 hours remaining)
  bool get isExpiringSoon {
    final h = hoursRemaining;
    return h != null && h <= 6 && h > 0;
  }

  bool get isFree => status == GroupKhatmSlotStatus.available;
  bool get isReserved => status == GroupKhatmSlotStatus.reserved;
  bool get isCompleted => status == GroupKhatmSlotStatus.completed;

  factory GroupKhatmSlot.fromJson(Map<String, dynamic> json) {
    return GroupKhatmSlot(
      id: json['id'] as int? ?? 0,
      campaignId: json['campaign_id'] as int? ?? 0,
      unitNumber: json['unit_number'] as int?,
      quantity: json['quantity'] as int? ?? 1,
      status: GroupKhatmSlotStatus.fromString(json['status'] as String?),
      userId: json['user_id'] as int?,
      userDisplayName: json['user_display_name'] as String?,
      isMine: json['is_mine'] as bool? ?? false,
      reservedAt: json['reserved_at'] != null ? DateTime.tryParse(json['reserved_at'].toString()) : null,
      expiresAt: json['expires_at'] != null ? DateTime.tryParse(json['expires_at'].toString()) : null,
      completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'campaign_id': campaignId,
      'unit_number': unitNumber,
      'quantity': quantity,
      'status': status.name,
      'user_id': userId,
      'user_display_name': userDisplayName,
      'is_mine': isMine,
      'reserved_at': reservedAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }
}
