import 'package:freezed_annotation/freezed_annotation.dart';

part 'city_entity.freezed.dart';
part 'city_entity.g.dart';

/// Represents a city location for Prayer Times calculation
@freezed
abstract class CityEntity with _$CityEntity {
  const factory CityEntity({
    required String id,
    required String namePersian,
    required String nameEnglish,
    required String province,
    required double latitude,
    required double longitude,
    @Default(false) bool isDefault,
    @Default(false) bool isGpsLocation,
  }) = _CityEntity;

  factory CityEntity.fromJson(Map<String, dynamic> json) =>
      _$CityEntityFromJson(json);
}

