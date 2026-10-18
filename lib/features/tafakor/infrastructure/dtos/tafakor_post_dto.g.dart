// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tafakor_post_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TafakorPostDto _$TafakorPostDtoFromJson(Map<String, dynamic> json) =>
    _TafakorPostDto(
      id: (json['id'] as num).toInt(),
      topicId: (json['topic'] as num).toInt(),
      authorId: (json['author'] as num).toInt(),
      authorPhone: json['author_phone'] as String? ?? '',
      authorName: json['author_name'] as String? ?? '',
      authorAvatar: json['author_avatar'] as String?,
      content: json['content'] as String? ?? '',
      mediaType: json['media_type'] as String?,
      mediaFile: json['media_file'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      reactionsSummary:
          (json['reactions_summary'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      userReaction: json['user_reaction'] as String?,
      commentsCount: (json['comments_count'] as num?)?.toInt() ?? 0,
      publishedPlatforms:
          (json['published_platforms'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$TafakorPostDtoToJson(_TafakorPostDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'topic': instance.topicId,
      'author': instance.authorId,
      'author_phone': instance.authorPhone,
      'author_name': instance.authorName,
      'author_avatar': instance.authorAvatar,
      'content': instance.content,
      'media_type': instance.mediaType,
      'media_file': instance.mediaFile,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'reactions_summary': instance.reactionsSummary,
      'user_reaction': instance.userReaction,
      'comments_count': instance.commentsCount,
      'published_platforms': instance.publishedPlatforms,
    };
