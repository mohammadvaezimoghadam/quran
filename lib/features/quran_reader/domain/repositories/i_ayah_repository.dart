import 'package:multiple_result/multiple_result.dart';
import '../../../../common/exceptions/failure.dart';
import '../entities/ayah_entity.dart';
import '../entities/word_entity.dart';

abstract interface class IAyahRepository {
  /// Fetches all Ayahs for a given Surah ID
  Future<Result<List<AyahEntity>, Failure>> getAyahsBySurah(int surahId);
  
  /// Fetches Word-by-Word translation for a specific Ayah
  Future<Result<List<WordEntity>, Failure>> getAyahWords(int surahId, int ayahNumber);
}
