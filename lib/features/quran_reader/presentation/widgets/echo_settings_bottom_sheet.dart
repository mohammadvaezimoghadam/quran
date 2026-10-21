import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/extensions/context_extension.dart';
import '../../../../common/extensions/int_extension.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../core/services/audio/echo/echo_controller.dart';
import '../../../../core/services/audio/echo/echo_preset.dart';
import '../../../../core/theme/app_typography.dart';
import 'audio_ambiance_bottom_sheet.dart';

/// Bottom sheet allowing user to configure Echo and Reverb acoustic effects
/// on the Quran recitation playback.
class EchoSettingsBottomSheet extends ConsumerWidget {
  const EchoSettingsBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return AudioAmbianceBottomSheet.show(context, initialTab: 1);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDark;
    final colorScheme = context.colorScheme;
    final echoState = ref.watch(echoControllerProvider);
    final controller = ref.read(echoControllerProvider.notifier);

    final intensityPercent = (echoState.intensity * 100).round();

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
                        echoState.preset.isRadio
                            ? CupertinoIcons.antenna_radiowaves_left_right
                            : CupertinoIcons.sparkles,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                    ),
                    10.hSpace,
                    Text(
                      'جلوه‌های صوتی و طنین تلاوت',
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
                          'طنین و جلوه صوتی قاری',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        2.vSpace,
                        Text(
                          'شبیه‌سازی آکوستیک صحن حرم، مساجد یا رادیو قدیمی',
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
                    value: echoState.isEnabled,
                    activeTrackColor: colorScheme.primary,
                    onChanged: (val) {
                      HapticFeedback.selectionClick();
                      controller.toggleEcho();
                    },
                  ),
                ],
              ),
            ),
            16.vSpace,

            // Section Label
            Text(
              'انتخاب حالت و فضای طنین',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            10.vSpace,

            // 2. Presets Grid / List
            ...EchoPreset.values.map((preset) {
              final isSelected = echoState.preset == preset;
              final isEnabled = echoState.isEnabled;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    if (!isEnabled) {
                      controller.setEnabled(true);
                    }
                    controller.setPreset(preset);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary.withValues(
                              alpha: isDark ? 0.16 : 0.08,
                            )
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.03)
                              : const Color(0xFFFAFAFC)),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : const Color(0xFFE5E5EA)),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primary.withValues(alpha: 0.2)
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.black.withValues(alpha: 0.05)),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            preset.icon,
                            size: 19,
                            color: isSelected
                                ? colorScheme.primary
                                : (isDark ? Colors.white70 : Colors.black54),
                          ),
                        ),
                        12.hSpace,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                preset.title,
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 13.5,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? colorScheme.primary
                                      : colorScheme.onSurface,
                                ),
                              ),
                              2.vSpace,
                              Text(
                                preset.description,
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 11,
                                  color: isDark ? Colors.white54 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            CupertinoIcons.checkmark_circle_fill,
                            size: 20,
                            color: colorScheme.primary,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            10.vSpace,

            // 3. Intensity Slider (Visible when enabled)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: echoState.isEnabled ? 1.0 : 0.45,
              child: IgnorePointer(
                ignoring: !echoState.isEnabled,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                CupertinoIcons.dial_fill,
                                size: 16,
                                color: colorScheme.primary,
                              ),
                              6.hSpace,
                              Text(
                                echoState.preset.isRadio
                                    ? 'شدت افکت'
                                    : 'شدت طنین و بازتاب',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${intensityPercent.toPersianDigit()}٪',
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
                      CupertinoSlider(
                        value: echoState.intensity,
                        min: 0.1,
                        max: 1.0,
                        divisions: 18,
                        activeColor: colorScheme.primary,
                        onChanged: (val) {
                          controller.setIntensity(val);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            14.vSpace,

            // Info hint card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.info_circle,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  8.hSpace,
                  Expanded(
                    child: Text(
                      'این افکت با پردازش پژواک تأخیری دولایه (Dual-Tap Delay)، طنین معنوی و اکوی تلاوت صحن‌های متبرکه را روی صوت قاری اعمال می‌کند.',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 10.5,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
