import 'package:flutter/foundation.dart';
import 'ayah_teaser_item.dart';

/// Aggregates all latest Ayah teasers for a Surah.
@immutable
class SurahTeasersResult {
  final int surah;
  final int totalAyahsWithPosts;
  final List<AyahTeaserItem> items;
  final Map<int, AyahTeaserItem> _byAyah;

  SurahTeasersResult({
    required this.surah,
    required this.totalAyahsWithPosts,
    required this.items,
  }) : _byAyah = {for (final item in items) item.ayah: item};

  /// Direct O(1) lookup to find the latest post teaser for a specific Ayah.
  AyahTeaserItem? getForAyah(int ayahNumber) => _byAyah[ayahNumber];

  /// Checks if any note teaser exists for the given Ayah.
  bool hasTeaserForAyah(int ayahNumber) => _byAyah.containsKey(ayahNumber);

  /// Map of Ayah number -> AyahTeaserItem
  Map<int, AyahTeaserItem> get byAyah => _byAyah;

  static final empty = SurahTeasersResult(
    surah: 0,
    totalAyahsWithPosts: 0,
    items: const [],
  );

  @override
  String toString() =>
      'SurahTeasersResult(surah: $surah, ayahsWithPosts: $totalAyahsWithPosts)';
}

