import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/extensions/context_extension.dart';
import '../../../../common/extensions/int_extension.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../core/services/audio/ambient_sound/ambient_sound_controller.dart';
import '../../../../core/services/audio/ambient_sound/ambient_sound_track.dart';
import '../../../../core/theme/app_typography.dart';
import 'audio_ambiance_bottom_sheet.dart';

/// Bottom sheet dialog allowing the user to configure background ambient sound
/// (toggle on/off, volume slider, track selection, and instant test playback).
class AmbientSoundBottomSheet extends ConsumerWidget {
  const AmbientSoundBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return AudioAmbianceBottomSheet.show(context, initialTab: 0);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDark;
    final colorScheme = context.colorScheme;
    final ambientState = ref.watch(ambientSoundControllerProvider);
    final controller = ref.read(ambientSoundControllerProvider.notifier);

    final volumePercent = (ambientState.volume * 100).round();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E22) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 14,
          bottom: MediaQuery.paddingOf(context).bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            16.vSpace,

            // Header Row: Title & Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        CupertinoIcons.music_note_2,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                    ),
                    10.hSpace,
                    Text(
                      'صدای آرامش‌بخش پس‌زمینه',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    CupertinoIcons.xmark,
                    size: 19,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
              ],
            ),
            14.vSpace,

            // 1. Activation Switch Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : const Color(0xFFF7F7F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFFE5E5EA),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'پخش همزمان با تلاوت قرآن',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        2.vSpace,
                        Text(
                          'موزیک آرام به صورت پیوسته زیر صوت قاری پخش می‌شود',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 11.5,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CupertinoSwitch(
                    value: ambientState.isEnabled,
                    activeTrackColor: colorScheme.primary,
                    onChanged: (value) {
                      HapticFeedback.selectionClick();
                      controller.setEnabled(value);
                    },
                  ),
                ],
              ),
            ),
            16.vSpace,

            // 2. Volume Slider Card (Only when enabled or previewing)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: ambientState.isEnabled ? 1.0 : 0.45,
              child: IgnorePointer(
                ignoring: !ambientState.isEnabled,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : const Color(0xFFF7F7F9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : const Color(0xFFE5E5EA),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.speaker_2,
                                size: 16,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                              6.hSpace,
                              Text(
                                'شدت صدای پس‌زمینه',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${volumePercent.toPersianDigit()}٪',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      8.vSpace,
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: colorScheme.primary,
                          inactiveTrackColor: isDark
                              ? Colors.white12
                              : const Color(0xFFE5E5EA),
                          thumbColor: colorScheme.primary,
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 7,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 14,
                          ),
                        ),
                        child: Slider(
                          value: ambientState.volume,
                          min: 0.02,
                          max: 0.60, // capped at 60% so it never drowns reciter
                          divisions: 29,
                          onChanged: (val) {
                            controller.setVolume(val);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            16.vSpace,

            // 3. Track Selection Label
            Text(
              'انتخاب نغمه آرامش:',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            10.vSpace,

            // Track List
            ...AmbientSoundTrack.defaultTracks.map((track) {
              final isSelected = ambientState.selectedTrack.id == track.id;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary.withValues(alpha: 0.08)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.03)
                          : const Color(0xFFF7F7F9)),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary.withValues(alpha: 0.45)
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : const Color(0xFFE5E5EA)),
                    width: isSelected ? 1.4 : 1.0,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    controller.selectTrack(track);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? CupertinoIcons.check_mark_circled_solid
                              : CupertinoIcons.circle,
                          size: 20,
                          color: isSelected
                              ? colorScheme.primary
                              : (isDark ? Colors.white30 : Colors.black26),
                        ),
                        12.hSpace,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                track.title,
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 13.5,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              if (track.description != null) ...[
                                2.vSpace,
                                Text(
                                  track.description!,
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 11,
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.black45,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            12.vSpace,

            // 4. Test / Preview Audio Button
            Center(
              child: TextButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  controller.previewToggle();
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFFF0F0F3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(
                  ambientState.isPlaying
                      ? CupertinoIcons.pause_fill
                      : CupertinoIcons.play_fill,
                  size: 15,
                  color: colorScheme.primary,
                ),
                label: Text(
                  ambientState.isPlaying
                      ? 'توقف پخش آزمایشی'
                      : 'تست و پخش آزمایشی نغمه',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
