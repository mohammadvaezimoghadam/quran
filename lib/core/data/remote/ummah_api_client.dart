import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';

import '../../../common/constants/app_constants.dart';
import 'network_service.dart';

part 'ummah_api_client.g.dart';

@RestApi()
abstract class UmmahApiClient {
  factory UmmahApiClient(Dio dio, {String? baseUrl}) = _UmmahApiClient;
}

final ummahApiClientProvider = Provider<UmmahApiClient>((ref) {
  final dio = ref.watch(networkServiceProvider);
  return UmmahApiClient(dio, baseUrl: AppConstants.ummahApiBaseUrl);
});
