import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/tafakor_user.dart';

part 'tafakor_user_dto.freezed.dart';
part 'tafakor_user_dto.g.dart';

Object? _readTelegramConnected(Map json, String key) {
  final bot = json['is_telegram_bot_connected'];
  if (bot is bool) return bot;
  final legacy = json['is_telegram_connected'];
  if (legacy is bool) return legacy;
  final otp = json['is_telegram_otp_connected'];
  if (otp is bool) return otp;
  return false;
}

Object? _readBaleConnected(Map json, String key) {
  final bot = json['is_bale_bot_connected'];
  if (bot is bool) return bot;
  final legacy = json['is_bale_connected'];
  if (legacy is bool) return legacy;
  final otp = json['is_bale_otp_connected'];
  if (otp is bool) return otp;
  return false;
}

Object? _readFirstName(Map json, String key) {
  return (json['first_name'] ?? json['firstName'])?.toString() ?? '';
}

Object? _readLastName(Map json, String key) {
  return (json['last_name'] ?? json['lastName'])?.toString() ?? '';
}

@freezed
abstract class TafakorUserDto with _$TafakorUserDto {
  const TafakorUserDto._();

  const factory TafakorUserDto({
    required String phone,
    @JsonKey(name: 'first_name', readValue: _readFirstName)
    @Default('')
    String firstName,
    @JsonKey(name: 'last_name', readValue: _readLastName)
    @Default('')
    String lastName,
    @JsonKey(readValue: _readTelegramConnected)
    @Default(false)
    bool isTelegramConnected,
    @JsonKey(readValue: _readBaleConnected)
    @Default(false)
    bool isBaleConnected,
  }) = _TafakorUserDto;

  factory TafakorUserDto.fromJson(Map<String, dynamic> json) =>
      _$TafakorUserDtoFromJson(json);

  String get fullName => '${firstName.trim()} ${lastName.trim()}'.trim();

  bool get hasFullName =>
      firstName.trim().isNotEmpty && lastName.trim().isNotEmpty;

  TafakorUser toDomain({String? token}) => TafakorUser(
        phone: phone,
        firstName: firstName,
        lastName: lastName,
        isTelegramConnected: isTelegramConnected,
        isBaleConnected: isBaleConnected,
        token: token,
      );
}
