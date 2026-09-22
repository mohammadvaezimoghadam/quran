export 'http_adapter_stub.dart'
    if (dart.library.io) 'http_adapter_io.dart'
    if (dart.library.js_interop) 'http_adapter_web.dart';
