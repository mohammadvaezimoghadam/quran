import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../common/exceptions/failure.dart';
import '../../domain/entities/ayah_entity.dart';
import '../../domain/entities/word_entity.dart';
import '../../domain/repositories/i_ayah_repository.dart';
import '../datasources/ayah_local_data_source.dart';

final ayahRepositoryProvider = Provider<IAyahRepository>((ref) {
  final localDataSource = ref.watch(ayahLocalDataSourceProvider);
  return AyahRepository(localDataSource);
});

class AyahRepository implements IAyahRepository {
  final IAyahLocalDataSource _localDataSource;

  AyahRepository(this._localDataSource);

  @override
  Future<Result<List<AyahEntity>, Failure>> getAyahsBySurah(int surahId) async {
    try {
      final dtos = await _localDataSource.getAyahsBySurah(surahId);
      
      if (dtos.isEmpty) {
        return Error(const Failure(message: 'هیچ آیه‌ای برای این سوره یافت نشد.'));
      }

      final entities = dtos.map((dto) => dto.toDomain()).toList();
      return Success(entities);
    } catch (e, s) {
      return Error(Failure(
        message: 'خطا در دریافت آیات: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<List<WordEntity>, Failure>> getAyahWords(int surahId, int ayahNumber) async {
    try {
      final dtos = await _localDataSource.getAyahWords(surahId, ayahNumber);
      
      final entities = dtos.map((dto) => dto.toDomain()).toList();
      return Success(entities);
    } catch (e, s) {
      return Error(Failure(
        message: 'خطا در واکشی لغت‌نامه: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
        stackTrace: s,
      ));
    }
  }
}
