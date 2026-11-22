import 'package:intl/intl.dart';

import 'string_extension.dart';

extension IntPersianHelper on int {
  /// Converts English digits in an integer to Persian digits.
  String toPersianDigit() {
    return toString().toPersianDigit();
  }

  /// Formats integer into 3-digit comma-separated groups with Persian digits (e.g. 149000 -> ۱۴۹٬۰۰۰).
  String toPersianFormatted() {
    final formatter = NumberFormat('#,###', 'fa');
    return formatter.format(this);
  }
}
