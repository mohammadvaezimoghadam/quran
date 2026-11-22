import 'package:flutter/material.dart';

/// Clean domain model representing a game item in the Quran Games Hub.
@immutable
class QuranGameItem {
  final String id;
  final String title;
  final String category;
  final String description;
  final String? badge;
  final Color? badgeColor;
  final List<Color> gradientColors;
  final IconData icon;
  final bool isPlayable;
  final int? stars;
  final List<String> tags;

  const QuranGameItem({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    this.badge,
    this.badgeColor,
    required this.gradientColors,
    required this.icon,
    this.isPlayable = false,
    this.stars,
    this.tags = const [],
  });

  QuranGameItem copyWith({
    String? id,
    String? title,
    String? category,
    String? description,
    String? badge,
    Color? badgeColor,
    List<Color>? gradientColors,
    IconData? icon,
    bool? isPlayable,
    int? stars,
    List<String>? tags,
  }) {
    return QuranGameItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      badge: badge ?? this.badge,
      badgeColor: badgeColor ?? this.badgeColor,
      gradientColors: gradientColors ?? this.gradientColors,
      icon: icon ?? this.icon,
      isPlayable: isPlayable ?? this.isPlayable,
      stars: stars ?? this.stars,
      tags: tags ?? this.tags,
    );
  }
}

/// Represents a horizontal section of games in the hub (e.g. Featured, Lightweight, etc.)
@immutable
class QuranGameSection {
  final String title;
  final String? tag;
  final String actionText;
  final List<QuranGameItem> items;

  const QuranGameSection({
    required this.title,
    this.tag,
    this.actionText = 'بیشتر',
    required this.items,
  });
}
