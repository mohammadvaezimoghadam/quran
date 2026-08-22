import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../common/constants/app_constants.dart';
import '../../../../common/exceptions/failure.dart';
import '../../../../common/mixins/dio_exception_mapper.dart';
import '../../domain/entities/ayah_of_the_day.dart';
import '../../domain/repositories/i_home_repository.dart';
import '../data_sources/remote/home_remote_data_source.dart';
import '../dtos/ayah_dto.dart';

final homeRepositoryProvider = Provider<IHomeRepository>((ref) {
  final remoteDataSource = ref.watch(homeRemoteDataSourceProvider);
  return HomeRepositoryImpl(remoteDataSource);
});

/// Implementation of [IHomeRepository] handling network calls and error mapping
class HomeRepositoryImpl with DioExceptionMapper implements IHomeRepository {
  final HomeRemoteDataSource _remoteDataSource;

  HomeRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<AyahOfTheDay, Failure>> getAyahOfTheDay() async {
    try {
      final ayahNumber = _calculateDailyAyahNumber();
      final response = await _remoteDataSource.getAyahEditions(ayahNumber);
      final ayahOfTheDay = _mapEditionsToAyahOfTheDay(response.data);

      if (ayahOfTheDay != null) {
        return Success(ayahOfTheDay);
      } else {
        return Error(const Failure(message: AppConstants.incompleteAyahDataError));
      }
    } on DioException catch (e, stackTrace) {
      return Error(mapDioExceptionToFailure(e, stackTrace));
    } catch (e, stackTrace) {
      return Error(Failure(
        message: AppConstants.ayahOfTheDayFetchError,
        stackTrace: stackTrace,
      ));
    }
  }

  /// Maps API editions array into AyahOfTheDay domain entity
  AyahOfTheDay? _mapEditionsToAyahOfTheDay(List<AyahDto> editions) {
    if (editions.length < 3) return null;

    final arabicDto = editions[0];      // quran-uthmani
    final translationDto = editions[1]; // fa.makarem
    final audioDto = editions[2];       // ar.alafasy

    return arabicDto.toDomain(
      translation: translationDto.text,
      audioUrl: audioDto.audio ?? '',
    );
  }

  /// Calculates a consistent daily Ayah index based on the day of the year (1 to 6236)
  int _calculateDailyAyahNumber() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    return (dayOfYear % 6236) + 1;
  }
}
