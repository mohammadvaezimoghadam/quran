/// Centralized API Endpoints Constants
abstract class ApiEndpoints {
  /// Surahs list endpoint
  static const String surahs = '/surah';

  /// Ayah with multiple editions endpoint (Uthmani text, Persian translation, Audio)
  static const String ayahEditions = '/ayah/{number}/editions/quran-uthmani,fa.makarem,ar.alafasy';
}
