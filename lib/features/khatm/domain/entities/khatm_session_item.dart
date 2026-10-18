import '../../../../common/extensions/int_extension.dart';
import '../../../../common/extensions/surah_name_extension.dart';
import '../../../../common/utils/jalali_date.dart';
import '../../../study_plan/domain/entities/study_plan.dart'
    show getSurahAndAyahFromGlobalIndex;
import 'khatm_enums.dart';

/// Represents a single scheduled reading session within a [KhatmPlan].
class KhatmSessionItem {
  final int sessionIndex; // 0-based index
  final int fromUnit;
  final int toUnit;
  final DateTime scheduledDate;
  final bool isCompleted;
  final DateTime? completedAt;
  final double progress; // 0.0 to 1.0
  final int? lastReadUnit;

  const KhatmSessionItem({
    required this.sessionIndex,
    required this.fromUnit,
    required this.toUnit,
    required this.scheduledDate,
    this.isCompleted = false,
    this.completedAt,
    this.progress = 0.0,
    this.lastReadUnit,
  });

  /// Total count of units allocated to this session.
  int get unitCount => toUnit - fromUnit + 1;

  /// Effective progress fraction for this session (0.0 to 1.0).
  double get effectiveProgress => isCompleted ? 1.0 : progress.clamp(0.0, 1.0);

  /// Progress formatted as integer (0 to 100).
  int get progressPercentInt => (effectiveProgress * 100).toInt().clamp(0, 100);

  /// Display title for the timeline.
  String computeTitle(KhatmUnitType unitType) {
    if (unitType == KhatmUnitType.surah) {
      if (fromUnit == toUnit) {
        return 'سوره ${fromUnit.surahNameFa}';
      }
      return 'سوره ${fromUnit.surahNameFa} تا ${toUnit.surahNameFa}';
    }

    if (unitType == KhatmUnitType.ayah) {
      final fromPos = getSurahAndAyahFromGlobalIndex(fromUnit.clamp(1, 6236));
      final toPos = getSurahAndAyahFromGlobalIndex(toUnit.clamp(1, 6236));
      final fromSurahName = fromPos.surahId.surahNameFa;

      if (fromPos.surahId == toPos.surahId) {
        if (fromPos.ayahNumber == toPos.ayahNumber) {
          return '$fromSurahName آیه ${fromPos.ayahNumber.toPersianDigit()}';
        }
        return '$fromSurahName آیه ${fromPos.ayahNumber.toPersianDigit()} تا ${toPos.ayahNumber.toPersianDigit()}';
      } else {
        final toSurahName = toPos.surahId.surahNameFa;
        return '$fromSurahName (${fromPos.ayahNumber.toPersianDigit()}) تا $toSurahName (${toPos.ayahNumber.toPersianDigit()})';
      }
    }

    final prefix = unitType.labelFa;

    if (fromUnit == toUnit) {
      return '$prefix ${fromUnit.toPersianDigit()}';
    }
    return '$prefix ${fromUnit.toPersianDigit()} تا ${toUnit.toPersianDigit()}';
  }

  /// Formatted Shamsi date string for this session (e.g. ۱۴۰۵/۰۷/۲۳).
  String get scheduledDateFa {
    return JalaliDate.fromDateTime(scheduledDate).formatFa();
  }

  /// Calculates dynamic status relative to the current date [now].
  KhatmSessionStatus computeStatus([DateTime? now]) {
    if (isCompleted) return KhatmSessionStatus.completed;

    final current = now ?? DateTime.now();
    final today = DateTime(current.year, current.month, current.day);
    final scheduled =
        DateTime(scheduledDate.year, scheduledDate.month, scheduledDate.day);

    if (scheduled.isAtSameMomentAs(today)) {
      return KhatmSessionStatus.current;
    }
    if (scheduled.isBefore(today)) {
      return KhatmSessionStatus.missed;
    }
    return KhatmSessionStatus.pending;
  }

  KhatmSessionItem copyWith({
    int? sessionIndex,
    int? fromUnit,
    int? toUnit,
    DateTime? scheduledDate,
    bool? isCompleted,
    DateTime? completedAt,
    double? progress,
    int? lastReadUnit,
  }) {
    return KhatmSessionItem(
      sessionIndex: sessionIndex ?? this.sessionIndex,
      fromUnit: fromUnit ?? this.fromUnit,
      toUnit: toUnit ?? this.toUnit,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      progress: progress ?? this.progress,
      lastReadUnit: lastReadUnit ?? this.lastReadUnit,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sessionIndex': sessionIndex,
      'fromUnit': fromUnit,
      'toUnit': toUnit,
      'scheduledDate': scheduledDate.toIso8601String(),
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'progress': progress,
      'lastReadUnit': lastReadUnit,
    };
  }

  factory KhatmSessionItem.fromMap(Map<dynamic, dynamic> map) {
    final isCompleted = map['isCompleted'] == true;
    final rawProgress = (map['progress'] as num?)?.toDouble();
    return KhatmSessionItem(
      sessionIndex: (map['sessionIndex'] as num?)?.toInt() ?? 0,
      fromUnit: (map['fromUnit'] as num?)?.toInt() ?? 1,
      toUnit: (map['toUnit'] as num?)?.toInt() ?? 1,
      scheduledDate: map['scheduledDate'] != null
          ? DateTime.tryParse(map['scheduledDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isCompleted: isCompleted,
      completedAt: map['completedAt'] != null
          ? DateTime.tryParse(map['completedAt'].toString())
          : null,
      progress: rawProgress ?? (isCompleted ? 1.0 : 0.0),
      lastReadUnit: (map['lastReadUnit'] as num?)?.toInt(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KhatmSessionItem &&
          runtimeType == other.runtimeType &&
          sessionIndex == other.sessionIndex &&
          fromUnit == other.fromUnit &&
          toUnit == other.toUnit &&
          scheduledDate == other.scheduledDate &&
          isCompleted == other.isCompleted &&
          completedAt == other.completedAt &&
          progress == other.progress &&
          lastReadUnit == other.lastReadUnit;

  @override
  int get hashCode =>
      sessionIndex.hashCode ^
      fromUnit.hashCode ^
      toUnit.hashCode ^
      scheduledDate.hashCode ^
      isCompleted.hashCode ^
      completedAt.hashCode ^
      progress.hashCode ^
      lastReadUnit.hashCode;
}
