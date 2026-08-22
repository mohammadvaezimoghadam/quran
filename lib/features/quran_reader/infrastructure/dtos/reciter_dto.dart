import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/reciter_entity.dart';

part 'reciter_dto.freezed.dart';
part 'reciter_dto.g.dart';

@freezed
abstract class ReciterDto with _$ReciterDto {
  const ReciterDto._();

  const factory ReciterDto({
    required int id,
    required String identifier,
    required String name,
    @JsonKey(name: 'english_name') required String englishName,
    @JsonKey(name: 'arabic_name') required String arabicName,
    required String subfolder,
    required String bitrate,
    @JsonKey(name: 'style_id') required int styleId,
    @JsonKey(name: 'style_name') String? styleName,
    @JsonKey(name: 'image_url') String? imageUrl,
  }) = _ReciterDto;

  factory ReciterDto.fromJson(Map<String, dynamic> json) => _$ReciterDtoFromJson(json);

  factory ReciterDto.fromSqlite(Map<String, dynamic> map) {
    return ReciterDto(
      id: map['id'] as int,
      identifier: map['identifier'] as String,
      name: map['name'] as String,
      englishName: map['english_name'] as String,
      arabicName: map['arabic_name'] as String,
      subfolder: map['subfolder'] as String,
      bitrate: map['bitrate'] as String,
      styleId: map['style_id'] as int,
      styleName: map['style_name'] as String?,
      imageUrl: map['image_url'] as String?,
    );
  }

  ReciterEntity toDomain() {
    return ReciterEntity(
      id: id,
      identifier: identifier,
      name: name,
      englishName: englishName,
      arabicName: arabicName,
      subfolder: subfolder,
      bitrate: bitrate,
      styleId: styleId,
      styleName: styleName,
      imageUrl: imageUrl,
    );
  }
}
