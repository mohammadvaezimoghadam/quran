import 'package:flutter/foundation.dart';

/// Represents a validated Quran Ayah reference attached to a Tafakor post.
@immutable
class TafakorQuranReference {
  final int surahNumber;
  final int ayahNumber;
  final String surahName;

  const TafakorQuranReference({
    required this.surahNumber,
    required this.ayahNumber,
    required this.surahName,
  });

  /// Canonical external_id representation (e.g. "surah:1,ayah:6")
  String get canonicalId => 'surah:$surahNumber,ayah:$ayahNumber';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TafakorQuranReference &&
          runtimeType == other.runtimeType &&
          surahNumber == other.surahNumber &&
          ayahNumber == other.ayahNumber;

  @override
  int get hashCode => surahNumber.hashCode ^ ayahNumber.hashCode;

  @override
  String toString() => 'TafakorQuranReference($canonicalId, name: $surahName)';
}

