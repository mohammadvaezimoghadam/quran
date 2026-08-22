import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../common/exceptions/failure.dart';
import '../domain/entities/surah_entity.dart';
import '../domain/repositories/i_surah_repository.dart';
import '../infrastructure/repositories/surah_repository.dart';

/// Provider for Application Layer SurahService
final surahServiceProvider = Provider<SurahService>((ref) {
  final repository = ref.watch(surahRepositoryProvider);
  return SurahService(repository);
});

/// Application Service orchestrating Surah feature business logic
class SurahService {
  final ISurahRepository _repository;

  SurahService(this._repository);

  /// Retrieves the list of all Surahs from the domain repository
  Future<Result<List<SurahEntity>, Failure>> getSurahs() {
    return _repository.getSurahs();
  }
}
