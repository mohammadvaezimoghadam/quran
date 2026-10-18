import '../../../../common/utils/jalali_date.dart';
import 'khatm_enums.dart';
import 'khatm_session_item.dart';

/// Aggregate root representing a user's Personal Khatm Plan.
class KhatmPlan {
  final String id;
  final String title;
  final KhatmUnitType unitType;
  final int rangeFrom;
  final int rangeTo;
  final KhatmPlanningMode planningMode;
  final int sessionCount;
  final int quotaPerSession;
  final KhatmCadence cadence;
  final List<int> selectedWeekdays;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final List<KhatmSessionItem> sessions;
  final DateTime createdAt;
  final bool isArchived;

  const KhatmPlan({
    required this.id,
    required this.title,
    required this.unitType,
    required this.rangeFrom,
    required this.rangeTo,
    required this.planningMode,
    required this.sessionCount,
    required this.quotaPerSession,
    required this.cadence,
    this.selectedWeekdays = const [],
    required this.startDateTime,
    required this.endDateTime,
    required this.sessions,
    required this.createdAt,
    this.isArchived = false,
  });

  // ── Computed Properties ──────────────────────────────────────────────────

  /// Total count of units across the selected range.
  int get totalUnits => rangeTo - rangeFrom + 1;

  /// Count of completed sessions so far.
  int get completedSessionsCount =>
      sessions.where((s) => s.isCompleted).length;

  /// Total units read in completed sessions + partial progress in active sessions.
  double get totalUnitsRead {
    double sum = 0.0;
    for (final s in sessions) {
      if (s.isCompleted) {
        sum += s.unitCount;
      } else if (s.progress > 0) {
        sum += s.unitCount * s.progress;
      }
    }
    return sum;
  }

  /// Total units read in completed sessions.
  int get completedUnits => sessions
      .where((s) => s.isCompleted)
      .fold(0, (sum, s) => sum + s.unitCount);

  /// Units remaining to complete this plan.
  int get remainingUnits => (totalUnits - completedUnits).clamp(0, totalUnits);

  /// Progress fraction from 0.0 to 1.0 (includes active session reading progress).
  double get progressPercentage =>
      totalUnits > 0 ? (totalUnitsRead / totalUnits).clamp(0.0, 1.0) : 0.0;

  /// Percentage formatted as integer (0 to 100).
  /// Never returns 100 unless all sessions/units are truly completed.
  int get progressPercentInt {
    if (isCompleted) return 100;
    final percent = (progressPercentage * 100).floor();
    return percent >= 100 ? 99 : percent;
  }

  /// True when all sessions have been marked completed.
  bool get isCompleted =>
      sessions.isNotEmpty && completedSessionsCount >= sessions.length;

  /// First incomplete session (even if missed/overdue).
  KhatmSessionItem? get nextPendingSession {
    for (final s in sessions) {
      if (!s.isCompleted) return s;
    }
    return null;
  }

  /// Persian label for the unit (صفحه، حزب، جزء، سوره، آیه).
  String get unitLabel => unitType.labelFa;

  /// Formatted Persian start date string (e.g. ۱۴۰۵/۰۷/۲۳).
  String get startDateFa => JalaliDate.fromDateTime(startDateTime).formatFa();

  /// Formatted Persian end date string (e.g. ۱۴۰۵/۰۷/۲۷).
  String get endDateFa => JalaliDate.fromDateTime(endDateTime).formatFa();

  // ── CopyWith & Serialization ─────────────────────────────────────────────

  KhatmPlan copyWith({
    String? id,
    String? title,
    KhatmUnitType? unitType,
    int? rangeFrom,
    int? rangeTo,
    KhatmPlanningMode? planningMode,
    int? sessionCount,
    int? quotaPerSession,
    KhatmCadence? cadence,
    List<int>? selectedWeekdays,
    DateTime? startDateTime,
    DateTime? endDateTime,
    List<KhatmSessionItem>? sessions,
    DateTime? createdAt,
    bool? isArchived,
  }) {
    return KhatmPlan(
      id: id ?? this.id,
      title: title ?? this.title,
      unitType: unitType ?? this.unitType,
      rangeFrom: rangeFrom ?? this.rangeFrom,
      rangeTo: rangeTo ?? this.rangeTo,
      planningMode: planningMode ?? this.planningMode,
      sessionCount: sessionCount ?? this.sessionCount,
      quotaPerSession: quotaPerSession ?? this.quotaPerSession,
      cadence: cadence ?? this.cadence,
      selectedWeekdays: selectedWeekdays ?? this.selectedWeekdays,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      sessions: sessions ?? this.sessions,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'unitType': unitType.name,
      'rangeFrom': rangeFrom,
      'rangeTo': rangeTo,
      'planningMode': planningMode.name,
      'sessionCount': sessionCount,
      'quotaPerSession': quotaPerSession,
      'cadence': cadence.name,
      'selectedWeekdays': selectedWeekdays,
      'startDateTime': startDateTime.toIso8601String(),
      'endDateTime': endDateTime.toIso8601String(),
      'sessions': sessions.map((s) => s.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'isArchived': isArchived,
    };
  }

  factory KhatmPlan.fromMap(Map<dynamic, dynamic> map) {
    final unitTypeName = map['unitType'] as String? ?? 'page';
    final planningModeName = map['planningMode'] as String? ?? 'bySessionCount';
    final cadenceName = map['cadence'] as String? ?? 'daily';

    final unitType = KhatmUnitType.values.firstWhere(
      (e) => e.name == unitTypeName,
      orElse: () => KhatmUnitType.page,
    );

    final planningMode = KhatmPlanningMode.values.firstWhere(
      (e) => e.name == planningModeName,
      orElse: () => KhatmPlanningMode.bySessionCount,
    );

    final cadence = KhatmCadence.values.firstWhere(
      (e) => e.name == cadenceName,
      orElse: () => KhatmCadence.daily,
    );

    final rawSessions = map['sessions'] as List<dynamic>? ?? [];
    final sessions = rawSessions
        .map((s) => KhatmSessionItem.fromMap(s as Map<dynamic, dynamic>))
        .toList();

    final rawWeekdays = map['selectedWeekdays'] as List<dynamic>? ?? [];
    final selectedWeekdays =
        rawWeekdays.map((e) => (e as num).toInt()).toList();

    return KhatmPlan(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? 'ختم شخصی',
      unitType: unitType,
      rangeFrom: (map['rangeFrom'] as num?)?.toInt() ?? 1,
      rangeTo: (map['rangeTo'] as num?)?.toInt() ?? 604,
      planningMode: planningMode,
      sessionCount: (map['sessionCount'] as num?)?.toInt() ?? sessions.length,
      quotaPerSession: (map['quotaPerSession'] as num?)?.toInt() ?? 1,
      cadence: cadence,
      selectedWeekdays: selectedWeekdays,
      startDateTime: map['startDateTime'] != null
          ? DateTime.tryParse(map['startDateTime'].toString()) ?? DateTime.now()
          : DateTime.now(),
      endDateTime: map['endDateTime'] != null
          ? DateTime.tryParse(map['endDateTime'].toString()) ?? DateTime.now()
          : DateTime.now(),
      sessions: sessions,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isArchived: map['isArchived'] == true,
    );
  }
}
