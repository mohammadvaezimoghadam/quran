import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/tafakor_paginated_posts.dart';
import 'tafakor_post_dto.dart';

part 'tafakor_paginated_posts_dto.freezed.dart';
part 'tafakor_paginated_posts_dto.g.dart';

@freezed
abstract class TafakorPaginatedPostsDto with _$TafakorPaginatedPostsDto {
  const TafakorPaginatedPostsDto._();

  const factory TafakorPaginatedPostsDto({
    required int count,
    String? next,
    String? previous,
    @Default([]) List<TafakorPostDto> results,
  }) = _TafakorPaginatedPostsDto;

  factory TafakorPaginatedPostsDto.fromJson(Map<String, dynamic> json) =>
      _$TafakorPaginatedPostsDtoFromJson(json);

  TafakorPaginatedPosts toDomain() => TafakorPaginatedPosts(
        count: count,
        next: next,
        previous: previous,
        results: results.map((dto) => dto.toDomain()).toList(),
      );
}
