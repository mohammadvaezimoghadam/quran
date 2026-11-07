import 'package:flutter/foundation.dart';
import 'ayah_teaser_author.dart';
import 'ayah_teaser_topic.dart';

/// Represents a single latest community note for a specific Ayah.
@immutable
class AyahTeaserItem {
  final int ayah;
  final int postId;
  final AyahTeaserTopic topic;
  final AyahTeaserAuthor author;
  final String content;
  final String contentPreview;
  final String mediaType;
  final String? mediaUrl;
  final DateTime? createdAt;

  const AyahTeaserItem({
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AyahTeaserItem &&
          runtimeType == other.runtimeType &&
          postId == other.postId &&
          ayah == other.ayah;

  @override
  int get hashCode => postId.hashCode ^ ayah.hashCode;

  @override
  String toString() =>
      'AyahTeaserItem(ayah: $ayah, post: $postId, author: ${author.name})';
}

