import 'dart:math';

/// Immutable record representing a sliced unit range for a single session.
class KhatmSliceRange {
  final int fromUnit;
  final int toUnit;

  const KhatmSliceRange({
    required this.fromUnit,
    required this.toUnit,
  });

  int get count => toUnit - fromUnit + 1;

  @override
  String toString() => '[$fromUnit - $toUnit] ($count)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KhatmSliceRange &&
          runtimeType == other.runtimeType &&
          fromUnit == other.fromUnit &&
          toUnit == other.toUnit;

  @override
  int get hashCode => fromUnit.hashCode ^ toUnit.hashCode;
}

/// Slicing engine that partitions a unit range [rangeFrom, rangeTo] into discrete sessions.
class KhatmSlicingEngine {
  /// Mode 1: Remainder-Balanced Slicing based on total sessions count.
  /// Evenly distributes the remainder across the first sessions so quotas differ by at most 1 unit.
  /// Example: 604 units across 5 sessions:
  /// base = 120, remainder = 4 -> [1-121], [122-242], [243-363], [364-484], [485-604]
  static List<KhatmSliceRange> sliceBySessionCount({
    required int rangeFrom,
    required int rangeTo,
    required int sessionCount,
  }) {
    final start = min(rangeFrom, rangeTo);
    final end = max(rangeFrom, rangeTo);
    final totalUnits = end - start + 1;

    // Safety checks
    if (totalUnits <= 0) return const [];
    final safeCount = sessionCount.clamp(1, totalUnits);

    final base = totalUnits ~/ safeCount;
    final remainder = totalUnits % safeCount;

    final slices = <KhatmSliceRange>[];
    int cursor = start;

    for (int i = 0; i < safeCount; i++) {
      final quota = base + (i < remainder ? 1 : 0);
      final sliceEnd = cursor + quota - 1;
      slices.add(KhatmSliceRange(fromUnit: cursor, toUnit: sliceEnd));
      cursor += quota;
    }

    return slices;
  }

  /// Mode 2: Fixed Quota Slicing based on units per session.
  /// Partitions the range into chunks of [quotaPerSession], with the final session
  /// receiving whatever remainder is left.
  /// Example: 604 units with quota = 10 -> 60 sessions of 10 units + 1 session of 4 units (total 61 sessions).
  static List<KhatmSliceRange> sliceByUnitQuota({
    required int rangeFrom,
    required int rangeTo,
    required int quotaPerSession,
  }) {
    final start = min(rangeFrom, rangeTo);
    final end = max(rangeFrom, rangeTo);
    final totalUnits = end - start + 1;

    if (totalUnits <= 0) return const [];
    final safeQuota = quotaPerSession.clamp(1, totalUnits);

    final slices = <KhatmSliceRange>[];
    int cursor = start;

    while (cursor <= end) {
      final sliceEnd = min(end, cursor + safeQuota - 1);
      slices.add(KhatmSliceRange(fromUnit: cursor, toUnit: sliceEnd));
      cursor = sliceEnd + 1;
    }

    return slices;
  }
}
