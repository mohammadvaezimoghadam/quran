import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../common/exceptions/failure.dart';
import '../domain/entities/translation_entity.dart';
import '../domain/repositories/i_translation_repository.dart';
import '../infrastructure/repositories/translation_repository.dart';

final translationServiceProvider = Provider<TranslationService>((ref) {
  final repository = ref.watch(translationRepositoryProvider);
  return TranslationService(repository);
});

class TranslationService {
  final ITranslationRepository _repository;

  TranslationService(this._repository);

  Future<Result<List<TranslationEntity>, Failure>> getTranslationsBySurah(
    int surahId,
    String translationId,
  ) {
    return _repository.getTranslationsBySurah(surahId, translationId);
  }
}
