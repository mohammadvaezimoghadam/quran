import 'khatm_ayah_span.dart';
import 'khatm_enums.dart';

/// Offline-first local reading progress for a single user-claimed Group Khatm slot.
///
/// Stored per `(inviteCode, slotId)` in Hive so progress rings, exact resume coordinates
/// (`lastSurahId`, `lastAyahNumber`, `lastPage`), covered global-ayah spans (`coveredSpans`),
/// multi-repetition Surah counters, and offline completions work seamlessly without backend
/// round-trips on every scroll.
class GroupKhatmSlotProgress {
  final String inviteCode;
  final int slotId;
  final GroupKhatmUnitType unitType;
  final int unitNumber;
  final int targetQuantity;
  final int completedRepetitions;
  final double currentPassProgress;
  final int? lastSurahId;
  final int? lastAyahNumber;
  final int? lastPage;
  final List<KhatmAyahSpan> coveredSpans;
  final bool awaitingNextPass;
  final bool isCompletedLocally;
  final bool pendingServerSync;
  final DateTime updatedAt;

  const GroupKhatmSlotProgress({
    required this.inviteCode,
    required this.slotId,
    required this.unitType,
    required this.unitNumber,
    this.targetQuantity = 1,
    this.completedRepetitions = 0,
    this.currentPassProgress = 0.0,
    this.lastSurahId,
    this.lastAyahNumber,
    this.lastPage,
    this.coveredSpans = const [],
    this.awaitingNextPass = false,
    this.isCompletedLocally = false,
    this.pendingServerSync = false,
    required this.updatedAt,
  });

  static String buildStorageKey(String inviteCode, int slotId) =>
      '${inviteCode}_$slotId';

  String get storageKey => buildStorageKey(inviteCode, slotId);

  int get safeTargetQuantity => targetQuantity < 1 ? 1 : targetQuantity;

  /// Current active pass index (1-based) for multi-repetition Surah slots.
  int get currentRepetitionNumber =>
      (completedRepetitions + 1).clamp(1, safeTargetQuantity);

  /// Total completion fraction (0.0 to 1.0) across all repetitions of this slot.
  double get overallProgress {
    if (isCompletedLocally) return 1.0;
    final qty = safeTargetQuantity;
    if (qty <= 1) return currentPassProgress.clamp(0.0, 1.0);
    return ((completedRepetitions + currentPassProgress.clamp(0.0, 1.0)) / qty)
        .clamp(0.0, 1.0);
  }

  int get progressPercentInt {
    if (isCompletedLocally) return 100;
    return (overallProgress * 100).floor().clamp(0, 99);
  }

  GroupKhatmSlotProgress copyWith({
    GroupKhatmUnitType? unitType,
    int? unitNumber,
    int? targetQuantity,
    int? completedRepetitions,
    double? currentPassProgress,
    int? lastSurahId,
    int? lastAyahNumber,
    int? lastPage,
    List<KhatmAyahSpan>? coveredSpans,
    bool? awaitingNextPass,
    bool? isCompletedLocally,
    bool? pendingServerSync,
    DateTime? updatedAt,
  }) {
    return GroupKhatmSlotProgress(
      inviteCode: inviteCode,
      slotId: slotId,
      unitType: unitType ?? this.unitType,
      unitNumber: unitNumber ?? this.unitNumber,
      targetQuantity: targetQuantity ?? this.targetQuantity,
      completedRepetitions: completedRepetitions ?? this.completedRepetitions,
      currentPassProgress: currentPassProgress ?? this.currentPassProgress,
      lastSurahId: lastSurahId ?? this.lastSurahId,
      lastAyahNumber: lastAyahNumber ?? this.lastAyahNumber,
      lastPage: lastPage ?? this.lastPage,
      coveredSpans: coveredSpans ?? this.coveredSpans,
      awaitingNextPass: awaitingNextPass ?? this.awaitingNextPass,
      isCompletedLocally: isCompletedLocally ?? this.isCompletedLocally,
      pendingServerSync: pendingServerSync ?? this.pendingServerSync,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'inviteCode': inviteCode,
      'slotId': slotId,
      'unitType': unitType.name,
      'unitNumber': unitNumber,
      'targetQuantity': targetQuantity,
      'completedRepetitions': completedRepetitions,
      'currentPassProgress': currentPassProgress,
      'lastSurahId': lastSurahId,
      'lastAyahNumber': lastAyahNumber,
      'lastPage': lastPage,
      'coveredSpans': coveredSpans.map((s) => s.toList()).toList(),
      'awaitingNextPass': awaitingNextPass,
      'isCompletedLocally': isCompletedLocally,
      'pendingServerSync': pendingServerSync,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory GroupKhatmSlotProgress.fromMap(Map<dynamic, dynamic> map) {
    return GroupKhatmSlotProgress(
      inviteCode: map['inviteCode']?.toString() ?? '',
      slotId: (map['slotId'] as num?)?.toInt() ?? 0,
      unitType: GroupKhatmUnitType.fromString(map['unitType']?.toString()),
      unitNumber: (map['unitNumber'] as num?)?.toInt() ?? 1,
      targetQuantity: (map['targetQuantity'] as num?)?.toInt() ?? 1,
      completedRepetitions:
          (map['completedRepetitions'] as num?)?.toInt() ?? 0,
      currentPassProgress:
          (map['currentPassProgress'] as num?)?.toDouble() ?? 0.0,
      lastSurahId: (map['lastSurahId'] as num?)?.toInt(),
      lastAyahNumber: (map['lastAyahNumber'] as num?)?.toInt(),
      lastPage: (map['lastPage'] as num?)?.toInt(),
      coveredSpans: KhatmAyahSpan.listFromDynamic(map['coveredSpans']),
      awaitingNextPass: map['awaitingNextPass'] == true,
      isCompletedLocally: map['isCompletedLocally'] == true,
      pendingServerSync: map['pendingServerSync'] == true,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
