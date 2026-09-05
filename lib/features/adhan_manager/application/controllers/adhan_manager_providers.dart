import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/local/preferences/preferences_service_provider.dart';
import '../../domain/repositories/adhan_settings_repository.dart';
import '../../domain/repositories/i_adhan_moezzin_repository.dart';
import '../../domain/services/i_adhan_storage_service.dart';
import '../../infrastructure/datasources/adhan_local_data_source.dart';
import '../../infrastructure/repositories/adhan_moezzin_repository.dart';
import '../../infrastructure/repositories/adhan_settings_repository_impl.dart';
import '../../infrastructure/services/adhan_storage_service_impl.dart';
import '../../domain/entities/moezzin.dart';

/// Riverpod provider for AdhanSettingsRepository
final adhanSettingsRepositoryProvider = Provider<AdhanSettingsRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesInstanceProvider);
  return AdhanSettingsRepositoryImpl(prefs);
});

/// Riverpod provider for AdhanMoezzinRepository
final adhanMoezzinRepositoryProvider = Provider<IAdhanMoezzinRepository>((ref) {
  final localDataSource = ref.watch(adhanLocalDataSourceProvider);
  return AdhanMoezzinRepository(localDataSource);
});

/// Riverpod provider for AdhanStorageService
final adhanStorageServiceProvider = Provider<IAdhanStorageService>((ref) {
  return AdhanStorageServiceImpl();
});

/// FutureProvider to load available moezzins for the UI
final availableMoezzinsProvider = FutureProvider<List<Moezzin>>((ref) async {
  return ref.watch(adhanMoezzinRepositoryProvider).getAvailableMoezzins();
});
