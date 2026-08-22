import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/preferences/preferences_service_provider.dart';
import '../data/theme_repository_impl.dart';
import '../domain/i_theme_repository.dart';

final themeRepositoryProvider = Provider<IThemeRepository>((ref) {
  final preferencesService = ref.watch(preferencesServiceProvider);
  return ThemeRepositoryImpl(preferencesService);
});

final themeControllerProvider =
    NotifierProvider<ThemeController, ThemeMode>(ThemeController.new);

class ThemeController extends Notifier<ThemeMode> {
  late final IThemeRepository _repository;

  @override
  ThemeMode build() {
    _repository = ref.watch(themeRepositoryProvider);
    _loadTheme();
    return ThemeMode.system;
  }

  Future<void> _loadTheme() async {
    state = await _repository.getThemeMode();
  }

  Future<void> toggleTheme(ThemeMode mode) async {
    state = mode;
    await _repository.saveThemeMode(mode);
  }
}
