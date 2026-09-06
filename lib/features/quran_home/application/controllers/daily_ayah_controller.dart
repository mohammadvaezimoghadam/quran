import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/local/sqflite/i_sqflite_service.dart';
import '../../../../core/data/local/sqflite/sqflite_service_provider.dart';

class DailyAyahItem {
  final int surahNumber;
  final String surahName;
  final int ayahNumber;
  final String arabicText;
  final String translation;

  const DailyAyahItem({
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
    required this.arabicText,
    required this.translation,
  });

  factory DailyAyahItem.fromMap(Map<String, dynamic> map) {
    return DailyAyahItem(
      surahNumber: map['surah_number'] as int? ?? 1,
      surahName: map['surah_name'] as String? ?? '',
      ayahNumber: map['number_in_surah'] as int? ?? 1,
      arabicText: map['text_uthmani'] as String? ?? '',
      translation: map['translation'] as String? ?? '',
    );
  }
}

final dailyAyahControllerProvider =
    AsyncNotifierProvider<DailyAyahController, DailyAyahItem>(
  DailyAyahController.new,
);

class DailyAyahController extends AsyncNotifier<DailyAyahItem> {
  late final ISqfliteService _sqfliteService;

  @override
  Future<DailyAyahItem> build() async {
    _sqfliteService = ref.watch(sqfliteServiceProvider);
    final now = DateTime.now();
    // Deterministic daily seed: changes every day at midnight
    final dailySeed = now.year * 372 + now.month * 31 + now.day;
    return _fetchAyah(dailySeed);
  }

  Future<DailyAyahItem> _fetchAyah(int seed) async {
    // Select well-proportioned, inspiring Ayahs for the home banner
    final sql = '''
      SELECT 
        a.id,
        a.surah_number,
        a.number_in_surah,
        a.text_uthmani,
        s.name AS surah_name,
        t.text AS translation
      FROM ayahs a
      JOIN surahs s ON a.surah_number = s.id
      LEFT JOIN translations t ON a.id = t.ayah_id AND t.translation_id = 'fa.makarem'
      WHERE LENGTH(a.text_uthmani) BETWEEN 35 AND 200
      ORDER BY ((a.id * 107 + $seed) % 6236) ASC
      LIMIT 1
    ''';

    final List<Map<String, dynamic>> maps = await _sqfliteService.rawQuery(sql);

    if (maps.isNotEmpty) {
      return DailyAyahItem.fromMap(maps.first);
    }

    // Safe fallback to Ayat Al-Kursi or Surah Al-Fatihah
    return const DailyAyahItem(
      surahNumber: 2,
      surahName: 'البقرة',
      ayahNumber: 255,
      arabicText: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
      translation: 'خداوند است که جز او هیچ معبودی نیست؛ زنده و برپادارنده است.',
    );
  }

  /// Manually refresh to another random Ayah
  Future<void> refreshRandomAyah() async {
    state = const AsyncValue.loading();
    final randomSeed = Random().nextInt(100000);
    state = await AsyncValue.guard(() => _fetchAyah(randomSeed));
  }
}
