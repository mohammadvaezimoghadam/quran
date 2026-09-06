enum DownloadedItemType {
  quranAudio,
  audioTranslation,
  textTranslation,
}

class DownloadedItemEntity {
  final String id;
  final DownloadedItemType type;
  final String title;
  final String subtitle;
  final int? surahId;
  final int? reciterId;
  final String? translationId;
  final int sizeBytes;
  final String formattedSize;
  final DateTime? downloadedAt;

  const DownloadedItemEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    this.surahId,
    this.reciterId,
    this.translationId,
    required this.sizeBytes,
    required this.formattedSize,
    this.downloadedAt,
  });
}
