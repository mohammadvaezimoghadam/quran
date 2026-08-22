extension StringTranslationHelper on String {
  /// Removes text inside brackets [...] and cleans up resulting multiple spaces.
  /// Used primarily for cleaning up translator explanations from Quran translations.
  String removeTranslatorExplanations() {
    String cleanText = replaceAll(RegExp(r'\[.*?\]'), '');
    return cleanText.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
