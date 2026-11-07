import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/data/remote/tafakor_api_client.dart';
import '../dtos/tafakor_auth_response_dto.dart';
import '../dtos/tafakor_user_dto.dart';

final tafakorRemoteDataSourceProvider = Provider<TafakorRemoteDataSource>((ref) {
  final client = ref.watch(tafakorApiClientProvider);
  return TafakorRemoteDataSource(client);
});

class TafakorRemoteDataSource {
  final TafakorApiClient _client;

  /// Holds the latest debug OTP returned from the server for easy testing
  static String? lastDebugOtp;

  TafakorRemoteDataSource(this._client);

  Future<bool> requestOtp(String phone) async {
    final response = await _client.requestOtp({'phone': phone});
    final data = response.data;
    if (data is Map && data['otp'] != null) {
      final code = data['otp'].toString();
      lastDebugOtp = code;
      debugPrint('''

╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║               🔑🔑🔑 TAFAKOR OTP CODE 🔑🔑🔑                ║
║                                                              ║
║   📱 Phone:   $phone                                    ║
║   👑 CODE:    >>>  $code  <<<                                ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
''');
    } else {
      lastDebugOtp = null;
    }
    return response.response.statusCode == 200;
  }

  Future<TafakorAuthResponseDto> verifyOtp(String phone, String otp) async {
    final response = await _client.verifyOtp({
      'phone': phone,
      'otp': otp,
    });
    final data = response.data as Map<String, dynamic>;
    return TafakorAuthResponseDto.fromJson(data);
  }

  Future<TafakorUserDto> getProfile() async {
    final response = await _client.getProfile();
    final data = response.data as Map<String, dynamic>;
    return TafakorUserDto.fromJson(data);
  }
}
