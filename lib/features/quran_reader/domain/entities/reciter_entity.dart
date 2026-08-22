import 'package:freezed_annotation/freezed_annotation.dart';

part 'reciter_entity.freezed.dart';

@freezed
abstract class ReciterEntity with _$ReciterEntity {
  const factory ReciterEntity({
    required int id,
    required String identifier,
    required String name,
    required String englishName,
    required String arabicName,
    required String subfolder,
    required String bitrate,
    required int styleId,
    String? styleName,
    String? imageUrl,
  }) = _ReciterEntity;
}
