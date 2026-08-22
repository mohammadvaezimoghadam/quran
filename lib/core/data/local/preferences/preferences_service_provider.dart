import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'i_preferences_service.dart';
import 'preferences_service_impl.dart';

/// Provider for raw SharedPreferences instance, overridden in main.dart
final sharedPreferencesInstanceProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesInstanceProvider must be overridden in ProviderScope in main.dart',
  );
});

/// Central provider for IPreferencesService
final preferencesServiceProvider = Provider<IPreferencesService>((ref) {
  final prefs = ref.watch(sharedPreferencesInstanceProvider);
  return PreferencesServiceImpl(prefs);
});
