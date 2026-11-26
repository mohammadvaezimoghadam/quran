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
  final DateTime clientUpdatedAt;
  final DateTime? deletedAt;
  final bool isDirty;

  KhatmPlan({
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
    DateTime? clientUpdatedAt,
    DateTime? deletedAt,
    this.isDirty = true,
  })  : clientUpdatedAt = (clientUpdatedAt ?? createdAt).toUtc(),
        deletedAt = deletedAt?.toUtc();

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
    return (progressPercentage * 100).floor().clamp(0, 99);
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
    DateTime? clientUpdatedAt,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
    bool? isDirty,
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
      clientUpdatedAt: (clientUpdatedAt ?? this.clientUpdatedAt).toUtc(),
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt)?.toUtc(),
      isDirty: isDirty ?? this.isDirty,
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
      'clientUpdatedAt': clientUpdatedAt.toUtc().toIso8601String(),
      'deletedAt': deletedAt?.toUtc().toIso8601String(),
      'isDirty': isDirty,
    };
  }

  /// Maps entity to Django DRF PersonalKhatmPlanSerializer schema for cloud sync
  Map<String, dynamic> toServerMap() {
    final startStr =
        '${startDateTime.year.toString().padLeft(4, '0')}-${startDateTime.month.toString().padLeft(2, '0')}-${startDateTime.day.toString().padLeft(2, '0')}';
    final endStr =
        '${endDateTime.year.toString().padLeft(4, '0')}-${endDateTime.month.toString().padLeft(2, '0')}-${endDateTime.day.toString().padLeft(2, '0')}';

    return {
      'client_id': id,
      'title': title,
      'unit_type': unitType.name,
      'range_from': rangeFrom,
      'range_to': rangeTo,
      'planning_mode': planningMode.name,
      'session_count': sessionCount,
      'quota_per_session': quotaPerSession,
      'cadence': cadence.name,
      'selected_weekdays': selectedWeekdays,
      'start_date': startStr,
      'end_date': endStr,
      'sessions_progress': sessions.map((s) => s.toMap()).toList(),
      'completed_sessions': completedSessionsCount,
      'is_completed': isCompleted,
      'is_archived': isArchived,
      'client_updated_at': clientUpdatedAt.toUtc().toIso8601String(),
      'deleted_at': deletedAt?.toUtc().toIso8601String(),
    };
  }

  /// Parses server plan from Django REST Framework into local Flutter domain entity
  factory KhatmPlan.fromServerMap(Map<String, dynamic> map) {
    final unitTypeName = map['unit_type'] as String? ?? 'page';
    final planningModeName =
        map['planning_mode'] as String? ?? 'bySessionCount';
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

    final rawSessions = (map['sessions_progress'] as List<dynamic>?) ?? [];
    final sessions = rawSessions
        .map((s) => KhatmSessionItem.fromMap(s as Map<dynamic, dynamic>))
        .toList();

    final startDate =
        DateTime.tryParse(map['start_date']?.toString() ?? '') ??
        DateTime.now();
    final endDate =
        DateTime.tryParse(map['end_date']?.toString() ?? '') ?? DateTime.now();
    final createdAt =
        DateTime.tryParse(map['created_at']?.toString() ?? '') ??
        DateTime.now();

    final clientUpdatedAt =
        (map['client_updated_at'] != null
            ? DateTime.tryParse(map['client_updated_at'].toString())?.toUtc()
            : null) ??
        (map['updated_at'] != null
            ? DateTime.tryParse(map['updated_at'].toString())?.toUtc()
            : null) ??
        createdAt.toUtc();

    final deletedAt = map['deleted_at'] != null
        ? DateTime.tryParse(map['deleted_at'].toString())?.toUtc()
        : null;

    final rawClientId = map['client_id']?.toString();
    final resolvedId = (rawClientId != null && rawClientId.isNotEmpty)
        ? rawClientId
        : (map['id']?.toString() ?? '');

    return KhatmPlan(
      id: resolvedId,
      title: map['title']?.toString() ?? '',
      unitType: unitType,
      rangeFrom: map['range_from'] as int? ?? 1,
      rangeTo: map['range_to'] as int? ?? unitType.maxUnits,
      planningMode: planningMode,
      sessionCount: map['session_count'] as int? ?? 30,
      quotaPerSession: (map['quota_per_session'] as num?)?.toInt() ?? 1,
      cadence: cadence,
      selectedWeekdays:
          ((map['selected_weekdays'] as List<dynamic>?) ?? [6, 1, 3])
              .map((e) => (e as num).toInt())
              .toList(),
      startDateTime: startDate,
      endDateTime: endDate,
      sessions: sessions,
      createdAt: createdAt,
      isArchived: map['is_archived'] as bool? ?? false,
      clientUpdatedAt: clientUpdatedAt,
      deletedAt: deletedAt,
      isDirty: false,
    );
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

    final createdAt = map['createdAt'] != null
        ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
        : DateTime.now();

    // Legacy Hive compatibility: infer clientUpdatedAt from latest completion/creation time
    DateTime fallbackUpdatedAt = createdAt.toUtc();
    for (final s in sessions) {
      final completedAt = s.completedAt?.toUtc();
      if (completedAt != null && completedAt.isAfter(fallbackUpdatedAt)) {
        fallbackUpdatedAt = completedAt;
      }
    }

    final parsedClientUpdatedAt = map['clientUpdatedAt'] != null
        ? DateTime.tryParse(map['clientUpdatedAt'].toString())?.toUtc()
        : null;
    final parsedDeletedAt = map['deletedAt'] != null
        ? DateTime.tryParse(map['deletedAt'].toString())?.toUtc()
        : null;
    final parsedIsDirty = map['isDirty'] is bool ? map['isDirty'] as bool : true;

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
      createdAt: createdAt,
      isArchived: map['isArchived'] == true,
      clientUpdatedAt: parsedClientUpdatedAt ?? fallbackUpdatedAt,
      deletedAt: parsedDeletedAt,
      isDirty: parsedIsDirty,
    );
  }
}
