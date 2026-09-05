import 'dart:convert';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'adhan_alarm_dto.freezed.dart';
part 'adhan_alarm_dto.g.dart';

/// Data Transfer Object for passing adhan alarm data to the native Android layer.
@freezed
abstract class AdhanAlarmDto with _$AdhanAlarmDto {
  const AdhanAlarmDto._();

  const factory AdhanAlarmDto({
    /// Unique identifier for the alarm (e.g., hash of date and prayer type)
    required int id,

    /// The name of the prayer in Persian (e.g., 'صبح', 'ظهر')
    required String prayerName,

    /// The exact time the alarm should fire, in milliseconds since epoch
    required int epochMillis,

    /// The asset identifier for the moezzin's audio file (e.g., 'ghalvash') (Fallback)
    required String moezzinAsset,

    /// The absolute local file path of the downloaded moezzin mp3
    String? moezzinFilePath,

    @Default(100) int volumeLevel,
    @Default(true) bool vibrate,
    @Default(true) bool playInSilentMode,
    @Default(false) bool ascendingVolume,
    @Default(true) bool wakeScreen,
  }) = _AdhanAlarmDto;

  factory AdhanAlarmDto.fromJson(Map<String, dynamic> json) =>
      _$AdhanAlarmDtoFromJson(json);

  /// Helper to convert a list of DTOs to a JSON string array 
  /// expected by the Kotlin AdhanAlarmScheduler.
  static String listToJson(List<AdhanAlarmDto> alarms) {
    final List<Map<String, dynamic>> mapList =
        alarms.map((a) => a.toJson()).toList();
    return jsonEncode(mapList);
  }
}
