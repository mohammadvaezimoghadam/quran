import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/moezzin.dart';

part 'moezzin_dto.freezed.dart';
part 'moezzin_dto.g.dart';

@freezed
abstract class MoezzinDto with _$MoezzinDto {
  const MoezzinDto._();

  const factory MoezzinDto({
    required String id,
    @JsonKey(name: 'name_fa') required String nameFa,
    @JsonKey(name: 'asset_path') required String assetPath,
    @JsonKey(name: 'download_url') required String downloadUrl,
  }) = _MoezzinDto;

  factory MoezzinDto.fromJson(Map<String, dynamic> json) =>
      _$MoezzinDtoFromJson(json);

  /// Converts this DTO to a Domain Entity
  Moezzin toEntity() {
    return Moezzin(
      id: id,
      nameFa: nameFa,
      assetPath: assetPath,
      downloadUrl: downloadUrl,
    );
  }
}
