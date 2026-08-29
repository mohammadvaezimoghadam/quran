/// Enum representing audio playback modes for Quran Reader.
enum AudioPlaybackMode {
  /// 1. Play Quran Arabic recitation only.
  onlyQuran,

  /// 2. Play Audio Translation only.
  onlyTranslation,

  /// 3. Play Quran Arabic recitation first, then Audio Translation.
  quranThenTranslation,

  /// 4. Play Audio Translation first, then Quran Arabic recitation.
  translationThenQuran,
}

extension AudioPlaybackModeX on AudioPlaybackMode {
  String get title {
    switch (this) {
      case AudioPlaybackMode.onlyQuran:
        return 'فقط تلاوت قرآن';
      case AudioPlaybackMode.onlyTranslation:
        return 'فقط ترجمه گویا';
      case AudioPlaybackMode.quranThenTranslation:
        return 'اول تلاوت، سپس ترجمه';
      case AudioPlaybackMode.translationThenQuran:
        return 'اول ترجمه، سپس تلاوت';
    }
  }

  bool get includesQuran =>
      this == AudioPlaybackMode.onlyQuran ||
      this == AudioPlaybackMode.quranThenTranslation ||
      this == AudioPlaybackMode.translationThenQuran;

  bool get includesTranslation =>
      this == AudioPlaybackMode.onlyTranslation ||
      this == AudioPlaybackMode.quranThenTranslation ||
      this == AudioPlaybackMode.translationThenQuran;
}
