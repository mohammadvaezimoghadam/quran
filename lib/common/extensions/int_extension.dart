extension IntPersianHelper on int {
  /// Converts English digits in an integer to Persian digits.
  String toPersianDigit() {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    
    String text = toString();
    for (int i = 0; i < english.length; i++) {
      text = text.replaceAll(english[i], persian[i]);
    }
    return text;
  }
}
