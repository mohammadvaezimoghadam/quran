import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/city_entity.dart';
import '../../domain/entities/prayer_times_entity.dart';

part 'prayer_times_state.freezed.dart';

/// State representation for Prayer Times feature
@freezed
abstract class PrayerTimesState with _$PrayerTimesState {
  const factory PrayerTimesState({
    @Default(true) bool isLoading,
    CityEntity? selectedCity,
    @Default([]) List<CityEntity> cities,
    PrayerTimesEntity? prayerTimes,
    DateTime? selectedDate,
    @Default(0) int hijriAdjustment,
    String? errorMessage,
  }) = _PrayerTimesState;
}
