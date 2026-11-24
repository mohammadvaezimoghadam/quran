// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tafakor_user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TafakorUserDto _$TafakorUserDtoFromJson(Map<String, dynamic> json) =>
    _TafakorUserDto(
      phone: json['phone'] as String,
      firstName: _readFirstName(json, 'first_name') as String? ?? '',
      lastName: _readLastName(json, 'last_name') as String? ?? '',
      isTelegramConnected:
          _readTelegramConnected(json, 'isTelegramConnected') as bool? ?? false,
      isBaleConnected:
          _readBaleConnected(json, 'isBaleConnected') as bool? ?? false,
    );

Map<String, dynamic> _$TafakorUserDtoToJson(_TafakorUserDto instance) =>
    <String, dynamic>{
      'phone': instance.phone,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'isTelegramConnected': instance.isTelegramConnected,
      'isBaleConnected': instance.isBaleConnected,
    };
