import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/data/local/preferences/preferences_service_provider.dart';
import '../../../../core/data/local/preferences/i_preferences_service.dart';
import '../../../../core/data/local/hive/hive_service_provider.dart';

abstract class ITranslationLocalDataSource {
  Future<void> saveTranslation(String translationId, Map<String, String> ayahs);
  Future<void> deleteTranslation(String translationId);
  String? getAyahTranslation(String translationId, int surahNumber, int ayahNumber);
  List<String> getDownloadedTranslationIds();
  
  Future<void> setActiveTranslation(String translationId);
  String? getActiveTranslation();
}

class TranslationLocalDataSource implements ITranslationLocalDataSource {
  static const String boxName = 'translationsBox';
  static const String activeTranslationKey = 'active_translation_id';
  
  final IPreferencesService _prefs;
  final Box _box;

  TranslationLocalDataSource(this._prefs, this._box);

  @override
  Future<void> saveTranslation(String translationId, Map<String, String> ayahs) async {
    await _box.put(translationId, ayahs);
  }

  @override
  Future<void> deleteTranslation(String translationId) async {
    await _box.delete(translationId);
  }

  @override
  String? getAyahTranslation(String translationId, int surahNumber, int ayahNumber) {
    final translationMap = _box.get(translationId);
    if (translationMap == null) return null;
    
    // Hive stores nested maps as Map<dynamic, dynamic>
    final map = Map<String, dynamic>.from(translationMap as Map);
    return map['${surahNumber}_$ayahNumber']?.toString();
  }

  @override
  List<String> getDownloadedTranslationIds() {
    return _box.keys.map((k) => k.toString()).toList();
  }

  @override
  Future<void> setActiveTranslation(String translationId) async {
    await _prefs.setString(activeTranslationKey, translationId);
  }

  @override
  String? getActiveTranslation() {
    return _prefs.getString(activeTranslationKey);
  }
}

final translationLocalDataSourceProvider = Provider<ITranslationLocalDataSource>((ref) {
  final prefs = ref.watch(preferencesServiceProvider);
  final hiveService = ref.watch(hiveServiceProvider);
  
  // Note: Ensure Hive.openBox(TranslationLocalDataSource.boxName) was called in main()
  final box = hiveService.getBox(TranslationLocalDataSource.boxName);
  
  return TranslationLocalDataSource(prefs, box);
});
