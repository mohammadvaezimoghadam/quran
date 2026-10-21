import 'package:flutter/cupertino.dart';

/// Available echo / reverb presets for Quran recitation playback.
enum EchoPreset {
  /// Large Hall / Dome reverb (طنین معنوی حرم مطهر)
  shrine(
    id: 'shrine',
    title: 'طنین حرم مطهر',
    description: 'طنین عمیق و باشکوه صحن‌های حرم',
    icon: CupertinoIcons.sparkles,
    imageAsset: 'assets/images/effect_shrine.jpg',
    nativePresetId: 5,
    tap1DelayMs: 160,
    tap1VolumeFactor: 0.38,
    tap2DelayMs: 320,
    tap2VolumeFactor: 0.18,
  ),

  /// Medium Hall reverb (فضای آکوستیک مسجد)
  mosque(
    id: 'mosque',
    title: 'طنین مسجد',
    description: 'طنین متوازن و دل‌نشین محراب مسجد',
    icon: CupertinoIcons.building_2_fill,
    imageAsset: 'assets/images/effect_mosque.jpg',
    nativePresetId: 4,
    tap1DelayMs: 130,
    tap1VolumeFactor: 0.32,
    tap2DelayMs: 260,
    tap2VolumeFactor: 0.14,
  ),

  /// Plate / Studio Reverb (اکوی استودیویی تلاوت)
  studio(
    id: 'studio',
    title: 'اکوی استودیویی',
    description: 'طنین شفاف و باکیفیت استودیو',
    icon: CupertinoIcons.waveform,
    imageAsset: 'assets/images/effect_studio.jpg',
    nativePresetId: 6,
    tap1DelayMs: 95,
    tap1VolumeFactor: 0.28,
    tap2DelayMs: 0,
    tap2VolumeFactor: 0.0,
  ),

  /// Small Room / Intimate Reverb (خلوت و ملایم)
  room(
    id: 'room',
    title: 'طنین ملایم',
    description: 'طنین خلوت و کوتاه برای تمرکز',
    icon: CupertinoIcons.home,
    imageAsset: 'assets/images/effect_room.jpg',
    nativePresetId: 2,
    tap1DelayMs: 65,
    tap1VolumeFactor: 0.20,
    tap2DelayMs: 0,
    tap2VolumeFactor: 0.0,
  ),

  /// Vintage AM Radio effect (رادیو قدیمی / نوستالژی)
  radio(
    id: 'radio',
    title: 'رادیو قدیمی (نوستالژی)',
    description: 'صدای فیلترشده و گرم رادیو لامپی',
    icon: CupertinoIcons.antenna_radiowaves_left_right,
    imageAsset: 'assets/images/effect_radio.jpg',
    nativePresetId: 0,
    tap1DelayMs: 0,
    tap1VolumeFactor: 0.0,
    tap2DelayMs: 0,
    tap2VolumeFactor: 0.0,
  );

  bool get isRadio => this == EchoPreset.radio;

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final String imageAsset;
  final int nativePresetId;
  final int tap1DelayMs;
  final double tap1VolumeFactor;
  final int tap2DelayMs;
  final double tap2VolumeFactor;

  bool get hasSecondTap => tap2DelayMs > 0 && tap2VolumeFactor > 0.0;

  const EchoPreset({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.imageAsset,
    required this.nativePresetId,
    required this.tap1DelayMs,
    required this.tap1VolumeFactor,
    required this.tap2DelayMs,
    required this.tap2VolumeFactor,
  });

  static EchoPreset fromId(String? id) {
    if (id == null) return EchoPreset.shrine;
    return EchoPreset.values.firstWhere(
      (e) => e.id == id,
      orElse: () => EchoPreset.shrine,
    );
  }
}
