// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'al_quran_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AlQuranResponseDto<T> _$AlQuranResponseDtoFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => _AlQuranResponseDto<T>(
  code: (json['code'] as num).toInt(),
  status: json['status'] as String,
  data: fromJsonT(json['data']),
);

Map<String, dynamic> _$AlQuranResponseDtoToJson<T>(
  _AlQuranResponseDto<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'code': instance.code,
  'status': instance.status,
  'data': toJsonT(instance.data),
};
