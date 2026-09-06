import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/word_entity.dart';
import '../../infrastructure/repositories/ayah_repository.dart';

// Provider that takes a tuple (record) of (surahId, ayahNumber)
final ayahWordsProvider = FutureProvider.autoDispose.family<List<WordEntity>, ({int surahId, int ayahNumber})>((ref, args) async {
  final repository = ref.watch(ayahRepositoryProvider);
  
  final result = await repository.getAyahWords(args.surahId, args.ayahNumber);
  
  return result.when(
    (success) => success,
    (error) => throw Exception(error.message),
  );
});

/// Provider for fetching all word-by-word entries for a given Surah
final surahWordsProvider = FutureProvider.autoDispose.family<List<WordEntity>, int>((ref, surahId) async {
  final repository = ref.watch(ayahRepositoryProvider);

  final result = await repository.getSurahWords(surahId);

  return result.when(
    (success) => success,
    (error) => throw Exception(error.message),
  );
});

/// Immutable model holding words of an individual ayah for dictionary view
class SurahAyahWords {
  final int ayahNumber;
  final List<WordEntity> words;

  const SurahAyahWords({
    required this.ayahNumber,
    required this.words,
  });
}

/// Provider that returns pre-grouped, pre-sorted dictionary words to eliminate UI build lag
final surahDictionaryGroupedProvider =
    FutureProvider.autoDispose.family<List<SurahAyahWords>, int>((ref, surahId) async {
  final words = await ref.watch(surahWordsProvider(surahId).future);

  final Map<int, List<WordEntity>> grouped = {};
  for (final w in words) {
    grouped.putIfAbsent(w.ayahNumber, () => []).add(w);
  }

  final sortedAyahs = grouped.keys.toList()..sort();
  return sortedAyahs
      .map((ayahNum) => SurahAyahWords(
            ayahNumber: ayahNum,
            words: grouped[ayahNum]!,
          ))
      .toList();
});
