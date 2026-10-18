import 'package:freezed_annotation/freezed_annotation.dart';
import 'tafakor_post.dart';

part 'tafakor_paginated_posts.freezed.dart';

@freezed
abstract class TafakorPaginatedPosts with _$TafakorPaginatedPosts {
  const factory TafakorPaginatedPosts({
    required int count,
    String? next,
    String? previous,
    required List<TafakorPost> results,
  }) = _TafakorPaginatedPosts;
}
