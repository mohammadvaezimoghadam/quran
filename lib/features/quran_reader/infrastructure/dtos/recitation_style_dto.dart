import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/recitation_style_entity.dart';

part 'recitation_style_dto.freezed.dart';
part 'recitation_style_dto.g.dart';

@freezed
abstract class RecitationStyleDto with _$RecitationStyleDto {
  const RecitationStyleDto._();

  const factory RecitationStyleDto({
    required int id,
    required String name,
    @JsonKey(name: 'english_name') required String englishName,
  }) = _RecitationStyleDto;

  factory RecitationStyleDto.fromJson(Map<String, dynamic> json) => _$RecitationStyleDtoFromJson(json);

  factory RecitationStyleDto.fromSqlite(Map<String, dynamic> map) {
    return RecitationStyleDto(
      id: map['id'] as int,
      name: map['name'] as String,
      englishName: map['english_name'] as String,
    );
  }

  RecitationStyleEntity toDomain() {
    return RecitationStyleEntity(
      id: id,
      name: name,
      englishName: englishName,
    );
  }
}
