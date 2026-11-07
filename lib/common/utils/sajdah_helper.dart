/// Type of Sajdah for an Ayah in Islamic jurisprudence.
enum SajdahType {
  none,
  wajib,
  mustahabb,
}

/// Helper utility for identifying Sajdah (prostration) verses in the Holy Quran.
///
/// According to Islamic jurisprudence:
/// - Exactly 4 verses have an Obligatory (Wajib) Sajdah upon reciting or hearing.
/// - Exactly 11 verses have a Recommended (Mustahabb) Sajdah.
abstract final class SajdahHelper {
  static const Map<String, SajdahType> _sajdahMap = {
    // 4 Wajib (Obligatory) Sajdahs
    '32:15': SajdahType.wajib, // Surah As-Sajdah
    '41:38': SajdahType.wajib, // Surah Fussilat
    '53:62': SajdahType.wajib, // Surah An-Najm
    '96:19': SajdahType.wajib, // Surah Al-Alaq

    // 11 Mustahabb (Recommended) Sajdahs
    '7:206': SajdahType.mustahabb, // Surah Al-A'raf
    '13:15': SajdahType.mustahabb, // Surah Ar-Ra'd
    '16:50': SajdahType.mustahabb, // Surah An-Nahl
    '17:109': SajdahType.mustahabb, // Surah Al-Isra
    '19:58': SajdahType.mustahabb, // Surah Maryam
    '22:18': SajdahType.mustahabb, // Surah Al-Hajj
    '22:77': SajdahType.mustahabb, // Surah Al-Hajj
    '25:60': SajdahType.mustahabb, // Surah Al-Furqan
    '27:26': SajdahType.mustahabb, // Surah An-Naml
    '38:24': SajdahType.mustahabb, // Surah Sad
    '84:21': SajdahType.mustahabb, // Surah Al-Inshiqaq
  };

  /// Returns the [SajdahType] for the given [surahId] and [ayahNumber].
  static SajdahType getSajdahType(int surahId, int ayahNumber) {
    return _sajdahMap['$surahId:$ayahNumber'] ?? SajdahType.none;
  }

  /// Returns true if this verse has any form of Sajdah (Wajib or Mustahabb).
  static bool hasSajdah(int surahId, int ayahNumber) {
    return _sajdahMap.containsKey('$surahId:$ayahNumber');
  }

  /// Returns true if this verse has an Obligatory (Wajib) Sajdah.
  static bool isWajib(int surahId, int ayahNumber) {
    return _sajdahMap['$surahId:$ayahNumber'] == SajdahType.wajib;
  }
}

