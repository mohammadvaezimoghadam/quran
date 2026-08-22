import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../common/exceptions/failure.dart';
import '../../domain/entities/recitation_style_entity.dart';
import '../../domain/entities/reciter_entity.dart';
import '../../domain/repositories/i_reciter_repository.dart';
import '../datasources/reciter_local_data_source.dart';

final reciterRepositoryProvider = Provider<IReciterRepository>((ref) {
  final localDataSource = ref.watch(reciterLocalDataSourceProvider);
  return ReciterRepository(localDataSource);
});

class ReciterRepository implements IReciterRepository {
  final IReciterLocalDataSource _localDataSource;

  ReciterRepository(this._localDataSource);

  @override
  Future<Result<List<ReciterEntity>, Failure>> getAllReciters() async {
    try {
      final dtos = await _localDataSource.getAllReciters();
      final entities = dtos.map((dto) => dto.toDomain()).toList();
      return Success(entities);
    } catch (e) {
      return Error(Failure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<ReciterEntity>, Failure>> getRecitersByStyle(int styleId) async {
    try {
      final dtos = await _localDataSource.getRecitersByStyle(styleId);
      final entities = dtos.map((dto) => dto.toDomain()).toList();
      return Success(entities);
    } catch (e) {
      return Error(Failure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<RecitationStyleEntity>, Failure>> getRecitationStyles() async {
    try {
      final dtos = await _localDataSource.getRecitationStyles();
      final entities = dtos.map((dto) => dto.toDomain()).toList();
      return Success(entities);
    } catch (e) {
      return Error(Failure(message: e.toString()));
    }
  }

  @override
  Future<Result<ReciterEntity, Failure>> getReciterById(int id) async {
    try {
      final dto = await _localDataSource.getReciterById(id);
      if (dto == null) {
        return Error(const Failure(message: 'قاری با این شناسه یافت نشد.'));
      }
      return Success(dto.toDomain());
    } catch (e) {
      return Error(Failure(message: e.toString()));
    }
  }
}
