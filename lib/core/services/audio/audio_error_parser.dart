abstract class AudioErrorParser {
  /// Converts technical audio exceptions and HTTP errors into clear Persian messages.
  static String parseError(dynamic error) {
    if (error == null) return 'خطای غیرمنتظره در پخش صوت';
    
    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains('404') || errorStr.contains('not found')) {
      return 'صوت این آیه برای این قاری در سرور یافت نشد. لطفاً قاری دیگری انتخاب نمایید.';
    } else if (errorStr.contains('timeout') || errorStr.contains('timed out')) {
      return 'سرور صوت پاسخ نمی‌دهد. لطفاً اتصال اینترنت خود را بررسی کرده و مجدداً تلاش کنید.';
    } else if (errorStr.contains('socketexception') ||
        errorStr.contains('connection') ||
        errorStr.contains('network') ||
        errorStr.contains('failed to connect') ||
        errorStr.contains('timed out') ||
        errorStr.contains('handshakeexception')) {
      return 'اتصال اینترنت برقرار نمی‌باشد. لطفاً اینترنت خود را بررسی کنید.';
    } else if (errorStr.contains('interrupted') || errorStr.contains('abort')) {
      return 'در حال بارگذاری صوت جدید...';
    } else if (errorStr.contains('format') || errorStr.contains('codec')) {
      return 'فرمت این فایل صوتی قابل پخش نمی‌باشد.';
    }

    return 'خطا در پخش فایل صوتی. لطفاً مجدداً تلاش کنید.';
  }
}
