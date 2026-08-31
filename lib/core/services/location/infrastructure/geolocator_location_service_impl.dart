import 'package:geolocator/geolocator.dart';
import '../../../../features/prayer_times/domain/entities/city_entity.dart';
import '../domain/location_service.dart';

/// Geolocator implementation of LocationService
class GeolocatorLocationServiceImpl implements LocationService {
  const GeolocatorLocationServiceImpl();

  @override
  Future<bool> checkAndRequestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  @override
  Future<Position?> getCurrentPosition() async {
    final hasPermission = await checkAndRequestPermission();
    if (!hasPermission) return null;

    try {
      // Try last known position first for instant response
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        return lastKnown;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 4),
        ),
      );
    } catch (_) {
      try {
        return await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.lowest,
            timeLimit: Duration(seconds: 2),
          ),
        );
      } catch (_) {
        return null;
      }
    }
  }

  @override
  CityEntity? findNearestCity({
    required double latitude,
    required double longitude,
    required List<CityEntity> cities,
  }) {
    if (cities.isEmpty) return null;

    CityEntity? nearestCity;
    double minDistanceInMeters = double.infinity;

    for (final city in cities) {
      final distance = Geolocator.distanceBetween(
        latitude,
        longitude,
        city.latitude,
        city.longitude,
      );

      if (distance < minDistanceInMeters) {
        minDistanceInMeters = distance;
        nearestCity = city;
      }
    }

    return nearestCity;
  }
}
