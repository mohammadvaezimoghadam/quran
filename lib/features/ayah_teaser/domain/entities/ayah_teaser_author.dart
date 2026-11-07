import 'package:flutter/foundation.dart';

/// Represents the author of an Ayah teaser post.
@immutable
class AyahTeaserAuthor {
  final int id;
  final String name;
  final String phone;
  final String? avatar;

  const AyahTeaserAuthor({
    required this.id,
    required this.name,
    required this.phone,
    this.avatar,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AyahTeaserAuthor &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'AyahTeaserAuthor(id: $id, name: $name)';
}

