// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'continue_reading_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ContinueReadingState _$ContinueReadingStateFromJson(
  Map<String, dynamic> json,
) => _ContinueReadingState(
  surahId: (json['surahId'] as num).toInt(),
  surahName: json['surahName'] as String,
  ayahNumber: (json['ayahNumber'] as num).toInt(),
  totalAyahs: (json['totalAyahs'] as num).toInt(),
);

Map<String, dynamic> _$ContinueReadingStateToJson(
  _ContinueReadingState instance,
) => <String, dynamic>{
  'surahId': instance.surahId,
  'surahName': instance.surahName,
  'ayahNumber': instance.ayahNumber,
  'totalAyahs': instance.totalAyahs,
};
