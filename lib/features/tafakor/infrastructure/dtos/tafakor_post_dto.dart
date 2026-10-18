import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/tafakor_post.dart';

part 'tafakor_post_dto.freezed.dart';
part 'tafakor_post_dto.g.dart';

@freezed
abstract class TafakorPostDto with _$TafakorPostDto {
  const TafakorPostDto._();

  const factory TafakorPostDto({
    required int id,
    @JsonKey(name: 'topic') required int topicId,
    @JsonKey(name: 'author') required int authorId,
    @JsonKey(name: 'author_phone') @Default('') String authorPhone,
    @JsonKey(name: 'author_name') @Default('') String authorName,
    @JsonKey(name: 'author_avatar') String? authorAvatar,
    @Default('') String content,
    @JsonKey(name: 'media_type') String? mediaType,
    @JsonKey(name: 'media_file') String? mediaFile,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    @JsonKey(name: 'reactions_summary') @Default({}) Map<String, int> reactionsSummary,
    @JsonKey(name: 'user_reaction') String? userReaction,
    @JsonKey(name: 'comments_count') @Default(0) int commentsCount,
    @JsonKey(name: 'published_platforms') @Default([]) List<String> publishedPlatforms,
  }) = _TafakorPostDto;

  factory TafakorPostDto.fromJson(Map<String, dynamic> json) =>
      _$TafakorPostDtoFromJson(json);

  TafakorPost toDomain() => TafakorPost(
        id: id,
        topicId: topicId,
        authorId: authorId,
        authorPhone: authorPhone,
        authorName: authorName,
        authorAvatar: authorAvatar,
        content: content,
        mediaType: mediaType,
        mediaFile: mediaFile,
        createdAt: createdAt,
        updatedAt: updatedAt,
        reactionsSummary: reactionsSummary,
        userReaction: userReaction,
        commentsCount: commentsCount,
        publishedPlatforms: publishedPlatforms,
      );
}
