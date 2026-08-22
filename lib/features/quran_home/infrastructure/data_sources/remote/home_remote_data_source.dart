import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../../common/constants/api_endpoints.dart';
import '../../../../../common/constants/app_constants.dart';
import '../../../../../core/data/remote/network_service.dart';
import '../../../../surah_list/infrastructure/dtos/al_quran_response_dto.dart';
import '../../dtos/ayah_dto.dart';

part 'home_remote_data_source.g.dart';

final homeRemoteDataSourceProvider = Provider<HomeRemoteDataSource>((ref) {
  final dio = ref.watch(networkServiceProvider);
  return HomeRemoteDataSource(dio, baseUrl: AppConstants.alQuranCloudBaseUrl);
});

/// Remote Data Source for Home feature API calls using Retrofit
@RestApi()
abstract class HomeRemoteDataSource {
  factory HomeRemoteDataSource(Dio dio, {String? baseUrl}) = _HomeRemoteDataSource;

  /// Fetches an Ayah with Arabic text, Persian translation, and reciter audio
  @GET(ApiEndpoints.ayahEditions)
  Future<AlQuranResponseDto<List<AyahDto>>> getAyahEditions(
    @Path('number') int ayahNumber,
  );
}
