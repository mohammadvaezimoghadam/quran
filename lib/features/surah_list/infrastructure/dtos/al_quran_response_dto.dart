import 'package:freezed_annotation/freezed_annotation.dart';

part 'al_quran_response_dto.freezed.dart';
part 'al_quran_response_dto.g.dart';

@Freezed(genericArgumentFactories: true)
abstract class AlQuranResponseDto<T> with _$AlQuranResponseDto<T> {
  const factory AlQuranResponseDto({
    required int code,
    required String status,
    required T data,
  }) = _AlQuranResponseDto<T>;

  factory AlQuranResponseDto.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$AlQuranResponseDtoFromJson(json, fromJsonT);
}
