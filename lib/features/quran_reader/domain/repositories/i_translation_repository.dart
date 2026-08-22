import 'package:multiple_result/multiple_result.dart';
import '../../../../common/exceptions/failure.dart';
import '../entities/translation_entity.dart';

abstract interface class ITranslationRepository {
  /// Fetches list of TranslationEntity for a given Surah and Translation ID.
  Future<Result<List<TranslationEntity>, Failure>> getTranslationsBySurah(
    int surahId,
    String translationId,
  );
}
