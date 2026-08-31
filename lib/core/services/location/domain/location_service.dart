import 'package:geolocator/geolocator.dart';
import '../../../../features/prayer_times/domain/entities/city_entity.dart';

/// Contract interface for GPS Location Service
abstract class LocationService {
  /// Checks if location services are enabled and requests permission
  Future<bool> checkAndRequestPermission();

  /// Gets current device GPS position coordinates
  Future<Position?> getCurrentPosition();

  /// Finds the closest city from available cities list using Haversine distance
  CityEntity? findNearestCity({
    required double latitude,
    required double longitude,
    required List<CityEntity> cities,
  });
}
