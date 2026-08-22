import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../common/exceptions/failure.dart';
import '../../domain/entities/surah_entity.dart';
import '../../domain/repositories/i_surah_repository.dart';
import '../datasources/surah_local_data_source.dart';
import '../dtos/surah_dto.dart';

final surahRepositoryProvider = Provider<ISurahRepository>((ref) {
  final localDataSource = ref.watch(surahLocalDataSourceProvider);
  return SurahRepository(localDataSource);
});

class SurahRepository implements ISurahRepository {
  final ISurahLocalDataSource _localDataSource;

  SurahRepository(this._localDataSource);

  @override
  Future<Result<List<SurahEntity>, Failure>> getSurahs() async {
    try {
      final surahsDtos = await _localDataSource.getSurahs();
      final surahsEntities = surahsDtos.map((dto) => dto.toDomain()).toList();
      return Success(surahsEntities);
    } catch (e, s) {
      return Error(Failure(
        message: 'خطایی در خواندن لیست سوره‌ها از دیتابیس رخ داد.',
        exception: e is Exception ? e : Exception(e.toString()),
        stackTrace: s,
      ));
    }
  }
}
