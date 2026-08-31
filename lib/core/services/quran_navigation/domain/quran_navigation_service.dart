import 'entities/ayah_target.dart';

/// Abstract domain interface for Quran navigation and location resolution
abstract class IQuranNavigationService {
  /// Resolves (surahId, ayahNumber) for a given surah ID (1-114) and optional ayah number
  Future<AyahTarget?> getTargetBySurah(int surahId, {int ayahNumber = 1});

  /// Resolves the starting (surahId, ayahNumber) for a given page number (1-604)
  Future<AyahTarget?> getTargetByPage(int page);

  /// Resolves the starting (surahId, ayahNumber) for a given juz number (1-30)
  Future<AyahTarget?> getTargetByJuz(int juz);

  /// Resolves the starting (surahId, ayahNumber) for a given hizb number (1-120)
  Future<AyahTarget?> getTargetByHizb(int hizb);
}
