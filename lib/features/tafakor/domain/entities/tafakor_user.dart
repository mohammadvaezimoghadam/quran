import 'package:freezed_annotation/freezed_annotation.dart';

part 'tafakor_user.freezed.dart';

@freezed
abstract class TafakorUser with _$TafakorUser {
  const TafakorUser._();

  const factory TafakorUser({
    required String phone,
    @Default('') String firstName,
    @Default('') String lastName,
    @Default(false) bool isTelegramConnected,
    @Default(false) bool isBaleConnected,
    String? token,
  }) = _TafakorUser;

  String get fullName => '${firstName.trim()} ${lastName.trim()}'.trim();

  bool get hasFullName =>
      firstName.trim().isNotEmpty && lastName.trim().isNotEmpty;
}
