import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../common/exceptions/failure.dart';
import '../domain/entities/ayah_entity.dart';
import '../domain/repositories/i_ayah_repository.dart';
import '../infrastructure/repositories/ayah_repository.dart';

final ayahServiceProvider = Provider<AyahService>((ref) {
  final repository = ref.watch(ayahRepositoryProvider);
  return AyahService(repository);
});

class AyahService {
  final IAyahRepository _repository;

  AyahService(this._repository);

  Future<Result<List<AyahEntity>, Failure>> getAyahsBySurah(int surahId) {
    return _repository.getAyahsBySurah(surahId);
  }
}
