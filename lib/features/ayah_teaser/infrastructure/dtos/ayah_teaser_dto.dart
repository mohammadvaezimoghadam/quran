import '../../domain/entities/ayah_teaser_author.dart';
import '../../domain/entities/ayah_teaser_item.dart';
import '../../domain/entities/ayah_teaser_topic.dart';
import '../../domain/entities/surah_teasers_result.dart';

class AyahTeaserAuthorDto {
  final int id;
  final String name;
  final String phone;
  final String? avatar;

  const AyahTeaserAuthorDto({
    required this.id,
    required this.name,
    required this.phone,
    this.avatar,
  });

  factory AyahTeaserAuthorDto.fromJson(Map<String, dynamic> json) {
    return AyahTeaserAuthorDto(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString().trim() ?? '',
      phone: json['phone']?.toString().trim() ?? '',
      avatar: json['avatar']?.toString(),
    );
  }

  AyahTeaserAuthor toDomain() => AyahTeaserAuthor(
        id: id,
        name: name.isNotEmpty ? name : (phone.isNotEmpty ? phone : 'کاربر تفکر'),
        phone: phone,
        avatar: avatar,
      );
}

class AyahTeaserTopicDto {
  final int id;
  final String name;

  const AyahTeaserTopicDto({
    required this.id,
    required this.name,
  });

  factory AyahTeaserTopicDto.fromJson(Map<String, dynamic> json) {
    return AyahTeaserTopicDto(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString().trim() ?? '',
    );
  }

  AyahTeaserTopic toDomain() => AyahTeaserTopic(
        id: id,
        name: name,
      );
}

class AyahTeaserItemDto {
  final int ayah;
  final int postId;
  final AyahTeaserTopicDto topic;
  final AyahTeaserAuthorDto author;
  final String content;
  final String contentPreview;
  final String mediaType;
  final String? mediaUrl;
  final DateTime? createdAt;

  const AyahTeaserItemDto({
    required this.ayah,
    required this.postId,
    required this.topic,
    required this.author,
    required this.content,
    required this.contentPreview,
    required this.mediaType,
    this.mediaUrl,
    this.createdAt,
  });

  factory AyahTeaserItemDto.fromJson(Map<String, dynamic> json) {
    final rawTopic = json['topic'] is Map<String, dynamic>
        ? json['topic'] as Map<String, dynamic>
        : (json['topic'] is Map ? Map<String, dynamic>.from(json['topic'] as Map) : <String, dynamic>{});

    final rawAuthor = json['author'] is Map<String, dynamic>
        ? json['author'] as Map<String, dynamic>
        : (json['author'] is Map ? Map<String, dynamic>.from(json['author'] as Map) : <String, dynamic>{});

    final rawCreatedAt = json['created_at']?.toString();
    DateTime? parsedDate;
    if (rawCreatedAt != null && rawCreatedAt.isNotEmpty) {
      parsedDate = DateTime.tryParse(rawCreatedAt);
    }

    return AyahTeaserItemDto(
      ayah: json['ayah'] is int
          ? json['ayah'] as int
          : int.tryParse(json['ayah']?.toString() ?? '') ?? 0,
      postId: json['post_id'] is int
          ? json['post_id'] as int
          : int.tryParse(json['post_id']?.toString() ?? '') ?? 0,
      topic: AyahTeaserTopicDto.fromJson(rawTopic),
      author: AyahTeaserAuthorDto.fromJson(rawAuthor),
      content: json['content']?.toString() ?? '',
      contentPreview: json['content_preview']?.toString() ?? '',
      mediaType: json['media_type']?.toString() ?? 'text',
      mediaUrl: json['media_url']?.toString(),
      createdAt: parsedDate,
    );
  }

  AyahTeaserItem toDomain() => AyahTeaserItem(
        ayah: ayah,
        postId: postId,
        topic: topic.toDomain(),
        author: author.toDomain(),
        content: content,
        contentPreview: contentPreview.isNotEmpty ? contentPreview : content,
        mediaType: mediaType,
        mediaUrl: mediaUrl,
        createdAt: createdAt,
      );
}

class SurahTeasersDto {
  final int surah;
  final int totalAyahsWithPosts;
  final List<AyahTeaserItemDto> items;

  const SurahTeasersDto({
    required this.surah,
    required this.totalAyahsWithPosts,
    required this.items,
  });

  factory SurahTeasersDto.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final List<AyahTeaserItemDto> parsedItems = [];

    if (rawItems is List) {
      for (final raw in rawItems) {
        if (raw is Map<String, dynamic>) {
          parsedItems.add(AyahTeaserItemDto.fromJson(raw));
        } else if (raw is Map) {
          parsedItems.add(AyahTeaserItemDto.fromJson(Map<String, dynamic>.from(raw)));
        }
      }
    }

    return SurahTeasersDto(
      surah: json['surah'] is int
          ? json['surah'] as int
          : int.tryParse(json['surah']?.toString() ?? '') ?? 0,
      totalAyahsWithPosts: json['total_ayahs_with_posts'] is int
          ? json['total_ayahs_with_posts'] as int
          : parsedItems.length,
      items: parsedItems,
    );
  }

  SurahTeasersResult toDomain() => SurahTeasersResult(
        surah: surah,
        totalAyahsWithPosts: totalAyahsWithPosts,
        items: items.map((e) => e.toDomain()).toList(),
      );
}

