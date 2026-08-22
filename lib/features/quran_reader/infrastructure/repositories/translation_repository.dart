import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../common/exceptions/failure.dart';
import '../../domain/entities/translation_entity.dart';
import '../../domain/repositories/i_translation_repository.dart';
import '../datasources/translation_local_data_source.dart';

final translationRepositoryProvider = Provider<ITranslationRepository>((ref) {
  final localDataSource = ref.watch(translationLocalDataSourceProvider);
  return TranslationRepository(localDataSource);
});

class TranslationRepository implements ITranslationRepository {
  final ITranslationLocalDataSource _localDataSource;

  TranslationRepository(this._localDataSource);

  @override
  Future<Result<List<TranslationEntity>, Failure>> getTranslationsBySurah(
    int surahId,
    String translationId,
  ) async {
    try {
      final dtos = await _localDataSource.getTranslationsBySurah(surahId, translationId);

      if (dtos.isEmpty) {
        return Error(const Failure(message: 'ترجمه‌ای برای این سوره یافت نشد.'));
      }

      final entities = dtos.map((dto) => dto.toDomain()).toList();
      return Success(entities);
    } catch (e, s) {
      return Error(Failure(
        message: 'خطا در خواندن ترجمه از دیتابیس: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
        stackTrace: s,
      ));
    }
  }
}
