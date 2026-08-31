import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/local/preferences/preferences_service_provider.dart';
import '../../../../core/services/location/domain/location_service.dart';
import '../../../../core/services/location/infrastructure/geolocator_location_service_impl.dart';
import '../../domain/entities/city_entity.dart';
import '../../domain/repositories/prayer_times_repository.dart';
import '../../infrastructure/datasources/prayer_times_local_data_source.dart';
import '../../infrastructure/repositories/prayer_times_repository_impl.dart';
import '../states/prayer_times_state.dart';

/// Provider for local data source of prayer times
final prayerTimesLocalDataSourceProvider =
    Provider<PrayerTimesLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesInstanceProvider);
  return PrayerTimesLocalDataSource(prefs);
});

/// Provider for GPS Location Service
final locationServiceProvider = Provider<LocationService>((ref) {
  return const GeolocatorLocationServiceImpl();
});

/// Provider for prayer times repository
final prayerTimesRepositoryProvider = Provider<PrayerTimesRepository>((ref) {
  final localDataSource = ref.watch(prayerTimesLocalDataSourceProvider);
  final locationService = ref.watch(locationServiceProvider);
  return PrayerTimesRepositoryImpl(localDataSource, locationService);
});

/// Ticker provider that ticks every 1 second to update prayer countdown timers
final prayerCountdownTickerProvider =
    StreamProvider.autoDispose<DateTime>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
});

/// Main controller provider for Prayer Times feature
final prayerTimesControllerProvider =
    NotifierProvider<PrayerTimesController, PrayerTimesState>(() {
  return PrayerTimesController();
});

class PrayerTimesController extends Notifier<PrayerTimesState> {
  @override
  PrayerTimesState build() {
    // Fetch initial data asynchronously after building
    Future.microtask(() => loadInitialData());
    return const PrayerTimesState();
  }

  /// Loads initial cities, saved selected city, saved hijri adjustment and calculates prayer times
  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repository = ref.read(prayerTimesRepositoryProvider);

      final citiesResult = await repository.getIranianCities();
      final savedCityResult = await repository.getSavedCity();
      final hijriAdjResult = await repository.getSavedHijriAdjustment();
      final date = DateTime.now();

      final cities = citiesResult.tryGetSuccess() ?? [];
      final defaultTehran = cities.firstWhere(
        (c) => c.isDefault || c.id == 'tehran',
        orElse: () => const CityEntity(
          id: 'tehran',
          namePersian: 'تهران',
          nameEnglish: 'Tehran',
          province: 'تهران',
          latitude: 35.6892,
          longitude: 51.3890,
          isDefault: true,
          isGpsLocation: false,
        ),
      );

      final savedCity = savedCityResult.tryGetSuccess() ?? defaultTehran;
      final hijriAdjustment = hijriAdjResult.tryGetSuccess() ?? 0;

      final prayerTimesResult = await repository.getPrayerTimes(
        city: savedCity,
        date: date,
        hijriAdjustment: hijriAdjustment,
      );

      final prayerTimes = prayerTimesResult.tryGetSuccess();

      state = state.copyWith(
        isLoading: false,
        cities: cities,
        selectedCity: savedCity,
        selectedDate: date,
        hijriAdjustment: hijriAdjustment,
        prayerTimes: prayerTimes,
        errorMessage: null,
      );

      if (prayerTimes == null) {
        await _fallbackToDefaultCity();
      }
    } catch (_) {
      await _fallbackToDefaultCity();
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Changes selected city and saves selection
  Future<void> selectCity(CityEntity city) async {
    final repository = ref.read(prayerTimesRepositoryProvider);
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final saveResult = await repository.saveCity(city);
      saveResult.when(
        (_) {
          state = state.copyWith(selectedCity: city);
        },
        (failure) {
          state = state.copyWith(errorMessage: failure.message);
        },
      );
      await _recalculatePrayerTimes();
    } catch (e) {
      state = state.copyWith(errorMessage: 'خطا در تغییر شهر: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Changes target date for prayer times calculation
  Future<void> changeDate(DateTime date) async {
    state = state.copyWith(selectedDate: date);
    await _recalculatePrayerTimes();
  }

  /// Updates Hijri calendar adjustment (-2 to +2 days) and saves selection
  Future<void> setHijriAdjustment(int adjustmentDays) async {
    final repository = ref.read(prayerTimesRepositoryProvider);
    final saveResult = await repository.saveHijriAdjustment(adjustmentDays);

    saveResult.when(
      (_) async {
        state = state.copyWith(hijriAdjustment: adjustmentDays);
        await _recalculatePrayerTimes();
      },
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
    );
  }

  /// Detects city via GPS and sets it as selected city. Fallbacks smoothly to default city (Tehran) on any error.
  Future<void> detectCurrentLocation() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repository = ref.read(prayerTimesRepositoryProvider);
      final gpsResult = await repository.getCurrentLocationCity();

      await gpsResult.when(
        (gpsCity) async {
          if (gpsCity != null) {
            await selectCity(gpsCity);
          } else {
            await _fallbackToDefaultCity();
          }
        },
        (failure) async {
          await _fallbackToDefaultCity();
        },
      );
    } catch (_) {
      await _fallbackToDefaultCity();
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Fallback helper to default city (Tehran) if GPS or location fails
  Future<void> _fallbackToDefaultCity() async {
    final cities = state.cities.isNotEmpty
        ? state.cities
        : (await ref.read(prayerTimesRepositoryProvider).getIranianCities())
                .tryGetSuccess() ??
            [];

    final tehranCity = cities.firstWhere(
      (c) => c.isDefault || c.id == 'tehran',
      orElse: () => const CityEntity(
        id: 'tehran',
        namePersian: 'تهران',
        nameEnglish: 'Tehran',
        province: 'تهران',
        latitude: 35.6892,
        longitude: 51.3890,
        isDefault: true,
        isGpsLocation: false,
      ),
    );

    final fallbackCity = state.selectedCity ?? tehranCity;
    state = state.copyWith(selectedCity: fallbackCity, errorMessage: null);
    await _recalculatePrayerTimes();
  }

  /// Recalculates prayer times for current city, date and hijri adjustment
  Future<void> _recalculatePrayerTimes() async {
    final city = state.selectedCity;
    if (city == null) return;

    final repository = ref.read(prayerTimesRepositoryProvider);
    final date = state.selectedDate ?? DateTime.now();

    final prayerTimesResult = await repository.getPrayerTimes(
      city: city,
      date: date,
      hijriAdjustment: state.hijriAdjustment,
    );

    prayerTimesResult.when(
      (prayerTimes) {
        state = state.copyWith(prayerTimes: prayerTimes, errorMessage: null);
      },
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
    );
  }
}
