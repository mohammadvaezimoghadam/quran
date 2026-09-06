/// Request payload carrying Quranic context for AI analysis
class QuranAiRequest {
  final int surahId;
  final String surahName;
  final int ayahNumber;
  final String fullArabicText;
  final String? translationText;
  final String selectedText; // Could be a single word or full ayah
  final bool isWordAnalysis; // True if user highlighted specific words

  const QuranAiRequest({
    required this.surahId,
    required this.surahName,
    required this.ayahNumber,
    required this.fullArabicText,
    this.translationText,
    required this.selectedText,
    required this.isWordAnalysis,
  });

  /// Context header providing Quran coordinates for prompts
  String buildContextPrefix() {
    final buffer = StringBuffer();
    buffer.writeln('موقعیت قرآنی: سوره $surahName (شماره $surahId)، آیه $ayahNumber');
    buffer.writeln('متن عربی آیه: $fullArabicText');
    if (translationText != null && translationText!.isNotEmpty) {
      buffer.writeln('ترجمه آیه: $translationText');
    }
    if (isWordAnalysis && selectedText.trim() != fullArabicText.trim()) {
      buffer.writeln('واژه / عبارت مدنظر: «$selectedText»');
    }
    return buffer.toString();
  }

  /// Formulates the tailored prompt based on whether it's a specific word or whole verse
  String buildInitialPrompt() {
    final buffer = StringBuffer();
    buffer.write(buildContextPrefix());
    buffer.writeln();

    if (isWordAnalysis && selectedText.trim() != fullArabicText.trim()) {
      buffer.writeln('واژه / عبارت انتخاب‌شده توسط کاربر: «$selectedText»');
      buffer.writeln('لطفاً این واژه را به طور دقیق در بافت این آیه تحلیل کن:');
      buffer.writeln('۱. ریشه‌شناسی و معنای لغوی در ادبیات عرب');
      buffer.writeln('۲. چرا دقیقاً این واژه در این آیه به کار رفته و تفاوتش با واژگان مشابه چیست؟');
      buffer.writeln('۳. نکته تفسیری و معنایی مهم در این آیه');
      buffer.writeln('۴. پیام تدبری و کاربرد این واژه در زندگی روزمره امروز ما');
    } else {
      buffer.writeln('تحلیل تدبری کل آیه:');
      buffer.writeln('لطفاً یک تدبر و تفسیر جامع، روان، دلنشین و کاربردی برای این آیه ارائه بده:');
      buffer.writeln('۱. پیام و پیام‌آوری اصلی آیه');
      buffer.writeln('۲. شأن نزول یا کانتکست تاریخی (در صورت وجود)');
      buffer.writeln('۳. نکات ظریف و کلیدی آیات');
      buffer.writeln('۴. چگونه می‌توان این آیه را در سبک زندگی امروز پیاده کرد؟');
    }

    return buffer.toString();
  }
}
