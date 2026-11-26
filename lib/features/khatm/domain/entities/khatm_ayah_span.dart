/// Closed 1-based global ayah interval `[start, end]` within `[1, 6236]`.
class KhatmAyahSpan {
  final int start;
  final int end;

  const KhatmAyahSpan({
    required this.start,
    required this.end,
  }) : assert(start <= end);

  /// Number of ayahs covered by this closed interval.
  int get length => end >= start ? (end - start + 1) : 0;

  List<int> toList() => <int>[start, end];

  static KhatmAyahSpan? fromDynamic(dynamic raw) {
    if (raw is KhatmAyahSpan) return raw;
    if (raw is List && raw.length >= 2) {
      final a = (raw[0] as num?)?.toInt();
      final b = (raw[1] as num?)?.toInt();
      if (a != null && b != null) {
        final lo = (a <= b ? a : b).clamp(1, 6236);
        final hi = (a <= b ? b : a).clamp(1, 6236);
        return KhatmAyahSpan(start: lo, end: hi);
      }
    } else if (raw is Map) {
      final a = (raw['start'] as num?)?.toInt();
      final b = (raw['end'] as num?)?.toInt();
      if (a != null && b != null) {
        final lo = (a <= b ? a : b).clamp(1, 6236);
        final hi = (a <= b ? b : a).clamp(1, 6236);
        return KhatmAyahSpan(start: lo, end: hi);
      }
    }
    return null;
  }

  static List<KhatmAyahSpan> listFromDynamic(dynamic raw) {
    if (raw is! List) return const [];
    final items = <KhatmAyahSpan>[];
    for (final entry in raw) {
      final parsed = fromDynamic(entry);
      if (parsed != null) items.add(parsed);
    }
    return mergeSpans(items);
  }

  /// Clamps [spans] to `[minGlobal, maxGlobal]`, sorts, and merges overlapping or
  /// adjacent spans (`next.start <= current.end + 1`).
  static List<KhatmAyahSpan> mergeSpans(
    Iterable<KhatmAyahSpan> spans, {
    int minGlobal = 1,
    int maxGlobal = 6236,
  }) {
    final normalized = <KhatmAyahSpan>[];
    for (final s in spans) {
      if (s.end < minGlobal || s.start > maxGlobal) continue;
      final clampedStart = s.start < minGlobal ? minGlobal : s.start;
      final clampedEnd = s.end > maxGlobal ? maxGlobal : s.end;
      if (clampedStart <= clampedEnd) {
        normalized.add(KhatmAyahSpan(start: clampedStart, end: clampedEnd));
      }
    }
    if (normalized.isEmpty) return const [];

    normalized.sort((a, b) {
      final cmp = a.start.compareTo(b.start);
      return cmp != 0 ? cmp : a.end.compareTo(b.end);
    });

    final merged = <KhatmAyahSpan>[normalized.first];
    for (int i = 1; i < normalized.length; i++) {
      final cur = normalized[i];
      final last = merged.last;
      if (cur.start <= last.end + 1) {
        if (cur.end > last.end) {
          merged[merged.length - 1] = KhatmAyahSpan(
            start: last.start,
            end: cur.end,
          );
        }
      } else {
        merged.add(cur);
      }
    }
    return List<KhatmAyahSpan>.unmodifiable(merged);
  }

  /// Counts total unique ayahs covered across [spans].
  static int countUniqueAyahs(Iterable<KhatmAyahSpan> spans) {
    final merged = mergeSpans(spans);
    int total = 0;
    for (final s in merged) {
      total += s.length;
    }
    return total;
  }

  /// Compares two already-normalized or unnormalized span lists for equality.
  static bool listEquals(List<KhatmAyahSpan> a, List<KhatmAyahSpan> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KhatmAyahSpan &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => start.hashCode ^ end.hashCode;

  @override
  String toString() => '[$start..$end]';
}
