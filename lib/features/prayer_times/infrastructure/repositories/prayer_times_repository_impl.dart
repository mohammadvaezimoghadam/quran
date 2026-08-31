import 'package:adhan_dart/adhan_dart.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../../../common/exceptions/failure.dart';
import '../../../../common/extensions/int_extension.dart';
import '../../../../core/services/location/domain/location_service.dart';
import '../../domain/entities/city_entity.dart';
import '../../domain/entities/prayer_times_entity.dart';
import '../../domain/repositories/prayer_times_repository.dart';
import '../datasources/prayer_times_local_data_source.dart';

/// Implementation of PrayerTimesRepository using AdhanDart, ShamsiDate, Hijri, and Local Data Source
class PrayerTimesRepositoryImpl implements PrayerTimesRepository {
  final PrayerTimesLocalDataSource _localDataSource;
  final LocationService _locationService;

  PrayerTimesRepositoryImpl(
    this._localDataSource,
    this._locationService,
  );

  @override
  Future<Result<PrayerTimesEntity, Failure>> getPrayerTimes({
    required CityEntity city,
    required DateTime date,
    int hijriAdjustment = 0,
  }) async {
    try {
      // 1. Calculate Prayer Times using AdhanDart with University of Tehran Geophysics parameters
      final coordinates = Coordinates(city.latitude, city.longitude);
      final params = CalculationMethodParameters.tehran();
      final adhanTimes = PrayerTimes(
        coordinates: coordinates,
        date: date,
        calculationParameters: params,
      );

      // Calculate Shia Midnight (Time halfway between Sunset/غروب آفتاب and next day's Fajr matching Tehran Geophysics Institute & Bade Saba)
      final fajrNextDay = PrayerTimes(
        coordinates: coordinates,
        date: date.add(const Duration(days: 1)),
        calculationParameters: params,
      ).fajr;

      final sunsetTime = adhanTimes.sunset;
      final midnightDiff =
          fajrNextDay.difference(sunsetTime).inMilliseconds ~/ 2;
      final shiaMidnight =
          sunsetTime.add(Duration(milliseconds: midnightDiff));

      // 2. Format Shamsi Date (هجری شمسی)
      final jalali = Jalali.fromDateTime(date);
      final shamsiMonthName = _getShamsiMonthName(jalali.month);
      final shamsiDateStr =
          '${jalali.day.toPersianDigit()} $shamsiMonthName ${jalali.year.toPersianDigit()}';

      // 3. Format Hijri Date (هجری قمری) with user adjustment
      final adjustedHijriDate = date.add(Duration(days: hijriAdjustment));
      final hijri = HijriCalendar.fromDate(adjustedHijriDate);
      final hijriMonthName = _getHijriMonthName(hijri.hMonth);
      final hijriDateStr =
          '${hijri.hDay.toPersianDigit()} $hijriMonthName ${hijri.hYear.toPersianDigit()}';

      final entity = PrayerTimesEntity(
        city: city,
        date: date,
        shamsiDate: shamsiDateStr,
        hijriDate: hijriDateStr,
        fajr: adhanTimes.fajr.toLocal(),
        sunrise: adhanTimes.sunrise.toLocal(),
        dhuhr: adhanTimes.dhuhr.toLocal(),
        asr: adhanTimes.asr.toLocal(),
        sunset: adhanTimes.sunset.toLocal(),
        maghrib: adhanTimes.maghrib.toLocal(),
        isha: adhanTimes.isha.toLocal(),
        midnight: shiaMidnight.toLocal(),
      );

      return Success(entity);
    } catch (e, stackTrace) {
      return Error(
        Failure(
          message: 'خطا در محاسبه اوقات شرعی: $e',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<CityEntity, Failure>> getSavedCity() async {
    try {
      final citiesResult = await getIranianCities();
      final cities = citiesResult.tryGetSuccess() ?? [];

      if (cities.isEmpty) {
        return const Error(Failure(message: 'لیست شهرها یافت نشد.'));
      }

      final savedId = _localDataSource.getSavedCityId();
      final savedCity = cities.firstWhere(
        (c) => c.id == savedId,
        orElse: () => cities.firstWhere(
          (c) => c.isDefault,
          orElse: () => cities.first,
        ),
      );

      return Success(savedCity);
    } catch (e, stackTrace) {
      return Error(
        Failure(
          message: 'خطا در دریافت شهر ذخیره‌شده: $e',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<void, Failure>> saveCity(CityEntity city) async {
    try {
      await _localDataSource.saveCityId(city.id);
      return const Success(null);
    } catch (e, stackTrace) {
      return Error(
        Failure(
          message: 'خطا در ذخیره شهر انتخاب شده: $e',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<List<CityEntity>, Failure>> getIranianCities() async {
    try {
      final cities = await _localDataSource.getIranianCities();
      return Success(cities);
    } catch (e, stackTrace) {
      return Error(
        Failure(
          message: 'خطا در بارگذاری لیست شهرها: $e',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<List<String>, Failure>> getProvinces() async {
    try {
      final citiesResult = await getIranianCities();
      final cities = citiesResult.tryGetSuccess() ?? [];
      final provinces = cities.map((c) => c.province).toSet().toList()..sort();
      return Success(provinces);
    } catch (e, stackTrace) {
      return Error(
        Failure(
          message: 'خطا در دریافت لیست استان‌ها: $e',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<List<CityEntity>, Failure>> getCitiesByProvince(String province) async {
    try {
      final citiesResult = await getIranianCities();
      final cities = citiesResult.tryGetSuccess() ?? [];
      final filtered = cities.where((c) => c.province == province).toList();
      return Success(filtered);
    } catch (e, stackTrace) {
      return Error(
        Failure(
          message: 'خطا در دریافت شهرهای استان: $e',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<CityEntity?, Failure>> getCurrentLocationCity() async {
    try {
      final position = await _locationService.getCurrentPosition();
      if (position == null) {
        return const Error(
          Failure(message: 'موقعیت مکانی دستگاه (GPS) دریافت نشد یا غیرفعال است.'),
        );
      }

      final citiesResult = await getIranianCities();
      final cities = citiesResult.tryGetSuccess() ?? [];

      final nearestCity = _locationService.findNearestCity(
        latitude: position.latitude,
        longitude: position.longitude,
        cities: cities,
      );

      if (nearestCity == null) {
        return const Error(
          Failure(message: 'شهری در نزدیکی موقعیت جغرافیایی شما یافت نشد.'),
        );
      }

      final gpsCity = nearestCity.copyWith(
        latitude: position.latitude,
        longitude: position.longitude,
        isGpsLocation: true,
      );
      return Success(gpsCity);
    } catch (e, stackTrace) {
      return Error(
        Failure(
          message: 'خطا در شناسایی خودکار موقعیت مکانی: $e',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<int, Failure>> getSavedHijriAdjustment() async {
    try {
      final adjustment = _localDataSource.getSavedHijriAdjustment();
      return Success(adjustment);
    } catch (e, stackTrace) {
      return Error(
        Failure(
          message: 'خطا در دریافت انحراف تقویم قمری: $e',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<void, Failure>> saveHijriAdjustment(int adjustmentDays) async {
    try {
      await _localDataSource.saveHijriAdjustment(adjustmentDays);
      return const Success(null);
    } catch (e, stackTrace) {
      return Error(
        Failure(
          message: 'خطا در ذخیره انحراف تقویم قمری: $e',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  String _getShamsiMonthName(int month) {
    const months = [
      'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور',
      'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند'
    ];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }

  String _getHijriMonthName(int month) {
    const months = [
      'محرم', 'صفر', 'ربيع‌الأول', 'ربيع‌الثانی', 'جمادی‌الأولی', 'جمادی‌الثانية',
      'رجب', 'شعبان', 'رمضان', 'شوال', 'ذوالقعدة', 'ذوالحجة'
    ];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }
}
