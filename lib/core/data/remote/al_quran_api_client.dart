import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';

import '../../../common/constants/app_constants.dart';
import 'network_service.dart';

part 'al_quran_api_client.g.dart';

@RestApi()
abstract class AlQuranApiClient {
  factory AlQuranApiClient(Dio dio, {String? baseUrl}) = _AlQuranApiClient;
}

final alQuranApiClientProvider = Provider<AlQuranApiClient>((ref) {
  final dio = ref.watch(networkServiceProvider);
  return AlQuranApiClient(dio, baseUrl: AppConstants.alQuranCloudBaseUrl);
});

