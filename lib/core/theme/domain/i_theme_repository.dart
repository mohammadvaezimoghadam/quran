import 'package:flutter/material.dart';

abstract interface class IThemeRepository {
  Future<ThemeMode> getThemeMode();
  Future<void> saveThemeMode(ThemeMode mode);
}
