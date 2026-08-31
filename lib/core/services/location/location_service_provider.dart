import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'domain/location_service.dart';
import 'infrastructure/geolocator_location_service_impl.dart';

/// Provider for LocationService interface
final locationServiceProvider = Provider<LocationService>((ref) {
  return const GeolocatorLocationServiceImpl();
});
