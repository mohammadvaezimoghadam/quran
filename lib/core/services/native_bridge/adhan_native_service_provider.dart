import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'domain/adhan_native_service.dart';
import 'infrastructure/method_channel_adhan_native_service.dart';

/// Provider for the [AdhanNativeService].
/// Provides a singleton instance of [MethodChannelAdhanNativeService] 
/// for communicating with the native Android layer.
final adhanNativeServiceProvider = Provider<AdhanNativeService>((ref) {
  return MethodChannelAdhanNativeService();
});
