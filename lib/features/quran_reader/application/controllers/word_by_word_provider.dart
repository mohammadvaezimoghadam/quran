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
