import 'package:flutter/services.dart';

import '../extensions/string_extension.dart';

/// Input formatter that allows digits (English, Arabic, or Persian) and
/// converts them immediately to Persian digits (`۰-۹`).
class PersianNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final converted = newValue.text.toPersianDigit();
    final baseOffset = newValue.selection.baseOffset.clamp(0, converted.length);
    final extentOffset = newValue.selection.extentOffset.clamp(
      0,
      converted.length,
    );
    return TextEditingValue(
      text: converted,
      selection: TextSelection(
        baseOffset: baseOffset,
        extentOffset: extentOffset,
      ),
    );
  }
}
