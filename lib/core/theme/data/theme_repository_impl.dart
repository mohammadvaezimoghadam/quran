import 'package:flutter/material.dart';

import '../../data/local/preferences/i_preferences_service.dart';
import '../../data/local/preferences/preferences_keys.dart';
import '../domain/i_theme_repository.dart';

class ThemeRepositoryImpl implements IThemeRepository {
  final IPreferencesService _preferencesService;

  ThemeRepositoryImpl(this._preferencesService);

  @override
  Future<ThemeMode> getThemeMode() async {
    final themeIndex = _preferencesService.getInt(PreferencesKeys.themeMode);
    if (themeIndex != null && themeIndex < ThemeMode.values.length) {
      return ThemeMode.values[themeIndex];
    }
    return ThemeMode.system;
  }

  @override
  Future<void> saveThemeMode(ThemeMode mode) async {
    await _preferencesService.setInt(PreferencesKeys.themeMode, mode.index);
  }
}
