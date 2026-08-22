import 'package:freezed_annotation/freezed_annotation.dart';

part 'recitation_style_entity.freezed.dart';

@freezed
abstract class RecitationStyleEntity with _$RecitationStyleEntity {
  const factory RecitationStyleEntity({
    required int id,
    required String name,
    required String englishName,
  }) = _RecitationStyleEntity;
}
