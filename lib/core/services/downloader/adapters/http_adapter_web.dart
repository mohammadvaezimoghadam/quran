import 'package:dio/dio.dart';

void configureHttpClientAdapter(Dio dio) {
  // On Web, Dio uses its default BrowserHttpClientAdapter which utilizes browser fetch/XHR.
  // SSL certificates and keep-alive are managed natively by the host browser.
}
