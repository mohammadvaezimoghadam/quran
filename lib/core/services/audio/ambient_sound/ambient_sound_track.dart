/// Model representing an ambient sound track (e.g. rain, calm melody, nature).
class AmbientSoundTrack {
  final String id;
  final String title;
  final String assetPath;
  final String imageAsset;
  final String? description;

  const AmbientSoundTrack({
    required this.id,
    required this.title,
    required this.assetPath,
    required this.imageAsset,
    this.description,
  });

  /// Pre-defined ambient sound options
  static const List<AmbientSoundTrack> defaultTracks = [
    AmbientSoundTrack(
      id: 'calm_melody',
      title: 'نوای آرامش',
      assetPath: 'assets/audio/ambient/calm_melody.mp3',
      imageAsset: 'assets/images/ambient_calm.jpg',
      description: 'نوای ملایم برای آرامش ذهن و تدبر',
    ),
    AmbientSoundTrack(
      id: 'rain',
      title: 'نم‌نم باران',
      assetPath: 'assets/audio/ambient/rain.mp3',
      imageAsset: 'assets/images/ambient_rain.jpg',
      description: 'صدای ملایم بارش باران',
    ),
    AmbientSoundTrack(
      id: 'nature',
      title: 'آواز آرام پرندگان',
      assetPath: 'assets/audio/ambient/serenity.mp3',
      imageAsset: 'assets/images/ambient_nature.jpg',
      description: 'صدای دل‌نشین پرندگان سحرگاهی در طبیعت',
    ),
    AmbientSoundTrack(
      id: 'serenity',
      title: 'نسیم آرامش',
      assetPath: 'assets/audio/ambient/nature.mp3',
      imageAsset: 'assets/images/ambient_serenity.jpg',
      description: 'نوای بی‌کلام معنوی و روح‌نواز',
    ),
    AmbientSoundTrack(
      id: 'deep_peace',
      title: 'آرامش درون',
      assetPath: 'assets/audio/ambient/deep_peace.mp3',
      imageAsset: 'assets/images/ambient_deep_peace.jpg',
      description: 'اتمسفر عمیق و لطیف برای تفکر',
    ),
    AmbientSoundTrack(
      id: 'heavenly_melody',
      title: 'نغمه ملکوت',
      assetPath: 'assets/audio/ambient/heavenly_melody.mp3',
      imageAsset: 'assets/images/ambient_heavenly.jpg',
      description: 'هارمونی دل‌نشین فضای معنوی',
    ),
  ];

  static AmbientSoundTrack fromId(String? id) {
    if (id == null) return defaultTracks.first;
    return defaultTracks.firstWhere(
      (t) => t.id == id,
      orElse: () => defaultTracks.first,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AmbientSoundTrack &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
