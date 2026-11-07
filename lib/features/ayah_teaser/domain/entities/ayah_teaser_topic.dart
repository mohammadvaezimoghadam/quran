import 'package:flutter/foundation.dart';

/// Represents the topic to which an Ayah teaser post belongs.
@immutable
class AyahTeaserTopic {
  final int id;
  final String name;

  const AyahTeaserTopic({
    required this.id,
    required this.name,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AyahTeaserTopic &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'AyahTeaserTopic(id: $id, name: $name)';
}

