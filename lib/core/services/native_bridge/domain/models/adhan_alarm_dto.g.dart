// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adhan_alarm_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AdhanAlarmDto _$AdhanAlarmDtoFromJson(Map<String, dynamic> json) =>
    _AdhanAlarmDto(
      id: (json['id'] as num).toInt(),
      prayerName: json['prayerName'] as String,
      epochMillis: (json['epochMillis'] as num).toInt(),
      moezzinAsset: json['moezzinAsset'] as String,
      moezzinFilePath: json['moezzinFilePath'] as String?,
      volumeLevel: (json['volumeLevel'] as num?)?.toInt() ?? 100,
      vibrate: json['vibrate'] as bool? ?? true,
      playInSilentMode: json['playInSilentMode'] as bool? ?? true,
      ascendingVolume: json['ascendingVolume'] as bool? ?? false,
      wakeScreen: json['wakeScreen'] as bool? ?? true,
    );

Map<String, dynamic> _$AdhanAlarmDtoToJson(_AdhanAlarmDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'prayerName': instance.prayerName,
      'epochMillis': instance.epochMillis,
      'moezzinAsset': instance.moezzinAsset,
      'moezzinFilePath': instance.moezzinFilePath,
      'volumeLevel': instance.volumeLevel,
      'vibrate': instance.vibrate,
      'playInSilentMode': instance.playInSilentMode,
      'ascendingVolume': instance.ascendingVolume,
      'wakeScreen': instance.wakeScreen,
    };
