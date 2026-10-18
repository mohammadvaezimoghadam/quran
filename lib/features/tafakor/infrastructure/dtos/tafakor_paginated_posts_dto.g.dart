// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tafakor_paginated_posts_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TafakorPaginatedPostsDto _$TafakorPaginatedPostsDtoFromJson(
  Map<String, dynamic> json,
) => _TafakorPaginatedPostsDto(
  count: (json['count'] as num).toInt(),
  next: json['next'] as String?,
  previous: json['previous'] as String?,
  results:
      (json['results'] as List<dynamic>?)
          ?.map((e) => TafakorPostDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$TafakorPaginatedPostsDtoToJson(
  _TafakorPaginatedPostsDto instance,
) => <String, dynamic>{
  'count': instance.count,
  'next': instance.next,
  'previous': instance.previous,
  'results': instance.results,
};
