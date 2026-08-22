import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../common/exceptions/failure.dart';
import '../infrastructure/repositories/home_repository_impl.dart';
import '../domain/entities/ayah_of_the_day.dart';
import '../domain/repositories/i_home_repository.dart';

/// Provider for Application Layer HomeService placed at the top of the file
final homeServiceProvider = Provider<HomeService>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return HomeService(repository);
});

/// Application Service orchestrating Home feature business logic
class HomeService {
  final IHomeRepository _repository;

  HomeService(this._repository);

  /// Retrieves the verse of the day from domain repository
  Future<Result<AyahOfTheDay, Failure>> getAyahOfTheDay() {
    return _repository.getAyahOfTheDay();
  }
}
