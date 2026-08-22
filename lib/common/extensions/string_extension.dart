extension StringSearchNormalizeExtension on String {
  /// Removes text inside brackets [...] and cleans up resulting multiple spaces.
  /// Used primarily for cleaning up translator explanations from Quran translations.
  String removeTranslatorExplanations() {
    String cleanText = replaceAll(RegExp(r'\[.*?\]'), '');
    return cleanText.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Normalizes Arabic and Persian text for flexible search matching.
  /// Removes Tashkeel (harakat), unifies Arabic letter variants (ي/ى->ی, ك->ک, أ/إ/آ/ٱ->ا, ة->ه, ؤ->و, ئ->ی),
  /// converts Arabic/Persian digits to standard digits, and lowercases text.
  String normalizeForSearch() {
    if (isEmpty) return '';

    String text = this;

    // 1. Remove Tashkeel (diacritics / harakat) & Quranic stop marks
    text = text.replaceAll(
      RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06DC\u06DF-\u06E8\u06EA-\u06ED]'),
      '',
    );

    // 2. Unify Arabic character variants to Persian/Standard equivalents
    text = text
        .replaceAll(RegExp(r'[يى]'), 'ی')
        .replaceAll('ك', 'ک')
        .replaceAll(RegExp(r'[أإآٱ]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ی');

    // 3. Convert Arabic and Persian digits to standard ASCII digits
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const persianDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    for (int i = 0; i < 10; i++) {
      text = text.replaceAll(arabicDigits[i], i.toString());
      text = text.replaceAll(persianDigits[i], i.toString());
    }

    return text.toLowerCase().trim();
  }
}
