import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/extensions/context_extension.dart';
import '../../../../common/extensions/int_extension.dart';
import '../../../../common/extensions/size_extension.dart';
import '../../../../common/widgets/app_modal_header.dart';
import '../../../../common/widgets/app_segmented_tab_bar.dart';
import '../../../../core/services/audio/ambient_sound/ambient_sound_controller.dart';
import '../../../../core/services/audio/ambient_sound/ambient_sound_state.dart';
import '../../../../core/services/audio/ambient_sound/ambient_sound_track.dart';
import '../../../../core/services/audio/echo/echo_controller.dart';
import '../../../../core/services/audio/echo/echo_preset.dart';
import '../../../../core/services/audio/echo/echo_state.dart';
import '../../../../core/theme/app_typography.dart';

/// Unified bottom sheet for Audio Ambience (Ambient Background Music)
/// and Sound Effects / Reverb (Echo, Mosque, Shrine, Vintage Radio).
class AudioAmbianceBottomSheet extends ConsumerStatefulWidget {
  final int initialTab;

  const AudioAmbianceBottomSheet({
    super.key,
    this.initialTab = 0,
  });

  static Future<void> show(BuildContext context, {int initialTab = 0}) {
    HapticFeedback.lightImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AudioAmbianceBottomSheet(initialTab: initialTab),
    );
  }

  @override
  ConsumerState<AudioAmbianceBottomSheet> createState() =>
      _AudioAmbianceBottomSheetState();
}

class _AudioAmbianceBottomSheetState
    extends ConsumerState<AudioAmbianceBottomSheet> {
  late int _selectedTab;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDark;
    final colorScheme = context.colorScheme;

    final ambientState = ref.watch(ambientSoundControllerProvider);
    final ambientController = ref.read(ambientSoundControllerProvider.notifier);

    final echoState = ref.watch(echoControllerProvider);
    final echoController = ref.read(echoControllerProvider.notifier);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        decoration: BoxDecoration(
          color: colors.dialogSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Standard Apple-grade header matching all other dialogs
              AppModalHeader(
                showDragHandle: true,
                title: 'فضاسازی و جلوه‌های صوتی',
                onClose: () => Navigator.of(context).pop(),
                bottomSpacing: 6.0,
              ),

              // Tab Switcher
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: AppSegmentedTabBar(
                  items: const [
                    AppSegmentedTabItem(
                      title: 'نغمه پس‌زمینه',
                    ),
                    AppSegmentedTabItem(
                      title: 'طنین و افکت صوتی',
                    ),
                  ],
                  selectedIndex: _selectedTab,
                  onTabSelected: (index) {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedTab = index);
                  },
                ),
              ),
              10.vSpace,

              // Scrollable Content
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 2,
                    bottom: MediaQuery.paddingOf(context).bottom + 16,
                  ),
                  child: _selectedTab == 0
                      ? _buildAmbientTab(
                          context: context,
                          isDark: isDark,
                          colorScheme: colorScheme,
                          state: ambientState,
                          controller: ambientController,
                        )
                      : _buildEffectsTab(
                          context: context,
                          isDark: isDark,
                          colorScheme: colorScheme,
                          state: echoState,
                          controller: echoController,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── TAB 1: AMBIENT SOUND (نغمه پس‌زمینه) ───────────────────────────
  Widget _buildAmbientTab({
    required BuildContext context,
    required bool isDark,
    required ColorScheme colorScheme,
    required AmbientSoundState state,
    required AmbientSoundController controller,
  }) {
    final volumePercent = (state.volume * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Activation Switch Card
        _buildCard(
          context: context,
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
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    2.vSpace,
                    Text(
                      'موزیک آرام زیر صوت قاری',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11.5,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Transform.scale(
                scale: 0.75,
                child: Switch(
                  value: state.isEnabled,
                  activeTrackColor: colorScheme.primary,
                  activeThumbColor: Colors.white,
                  onChanged: (value) {
                    HapticFeedback.selectionClick();
                    controller.setEnabled(value);
                  },
                ),
              ),
            ],
          ),
        ),
        10.vSpace,

        // 2. Volume Slider Card (Visible when enabled)
        AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: state.isEnabled ? 1.0 : 0.45,
          child: IgnorePointer(
            ignoring: !state.isEnabled,
            child: _buildCard(
              context: context,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'میزان صدای نغمه',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
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
                  4.vSpace,
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3.5,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 6.5),
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 14),
                      activeTrackColor: colorScheme.primary,
                      inactiveTrackColor: isDark ? Colors.white12 : Colors.black12,
                      thumbColor: colorScheme.primary,
                    ),
                    child: Slider(
                      value: state.volume,
                      min: 0.05,
                      max: 0.80,
                      divisions: 15,
                      onChanged: (val) => controller.setVolume(val),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        14.vSpace,

        // 3. Track Grid (2 columns, borderless, text directly on image)
        Text(
          'انتخاب نغمه آرامش:',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        10.vSpace,

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.75,
          ),
          itemCount: AmbientSoundTrack.defaultTracks.length,
          itemBuilder: (context, index) {
            final track = AmbientSoundTrack.defaultTracks[index];
            final isSelected = state.selectedTrack.id == track.id;
            return _buildItemCard(
              isDark: isDark,
              isSelected: isSelected,
              colorScheme: colorScheme,
              imageAsset: track.imageAsset,
              title: track.title,
              onTap: () {
                HapticFeedback.selectionClick();
                controller.selectTrack(track);
              },
            );
          },
        ),
      ],
    );
  }

  // ─── TAB 2: ACOUSTICS & EFFECTS (طنین و افکت صوتی) ───────────────────
  Widget _buildEffectsTab({
    required BuildContext context,
    required bool isDark,
    required ColorScheme colorScheme,
    required EchoState state,
    required EchoController controller,
  }) {
    final intensityPercent = (state.intensity * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Activation Switch Card
        _buildCard(
          context: context,
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
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    2.vSpace,
                    Text(
                      'شبیه‌سازی آکوستیک حرم، مسجد یا رادیو قدیمی',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11.5,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Transform.scale(
                scale: 0.75,
                child: Switch(
                  value: state.isEnabled,
                  activeTrackColor: colorScheme.primary,
                  activeThumbColor: Colors.white,
                  onChanged: (value) {
                    HapticFeedback.selectionClick();
                    controller.setEnabled(value);
                  },
                ),
              ),
            ],
          ),
        ),
        10.vSpace,

        // 2. Intensity Slider Card
        AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: state.isEnabled ? 1.0 : 0.45,
          child: IgnorePointer(
            ignoring: !state.isEnabled,
            child: _buildCard(
              context: context,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        state.preset.isRadio
                            ? 'شدت افکت'
                            : 'شدت طنین و بازتاب',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
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
                  4.vSpace,
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3.5,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 6.5),
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 14),
                      activeTrackColor: colorScheme.primary,
                      inactiveTrackColor: isDark ? Colors.white12 : Colors.black12,
                      thumbColor: colorScheme.primary,
                    ),
                    child: Slider(
                      value: state.intensity,
                      min: 0.1,
                      max: 1.0,
                      divisions: 18,
                      onChanged: (val) => controller.setIntensity(val),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        14.vSpace,

        // 3. Preset Grid (2 columns, borderless, text directly on image)
        Text(
          'انتخاب فضا و طنین:',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        10.vSpace,

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.75,
          ),
          itemCount: EchoPreset.values.length,
          itemBuilder: (context, index) {
            final preset = EchoPreset.values[index];
            final isSelected = state.preset == preset;
            return _buildItemCard(
              isDark: isDark,
              isSelected: isSelected,
              colorScheme: colorScheme,
              imageAsset: preset.imageAsset,
              title: preset.title,
              onTap: () {
                HapticFeedback.selectionClick();
                controller.setPreset(preset);
              },
            );
          },
        ),
      ],
    );
  }

  // ─── REUSABLE UI HELPERS ─────────────────────────────────────────────
  Widget _buildCard({
    required BuildContext context,
    required Widget child,
  }) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.cardBorder,
          width: 1,
        ),
      ),
      child: child,
    );
  }

  /// Artwork card with image background, subtle scrim, overlaid bold title,
  /// selection checkmark badge, and absolutely NO borders.
  Widget _buildItemCard({
    required bool isDark,
    required bool isSelected,
    required ColorScheme colorScheme,
    required String imageAsset,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Full artwork background image
            Image.asset(
              imageAsset,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: isDark ? Colors.white12 : Colors.black12,
              ),
            ),

            // 2. Bottom-only gradient scrim behind the text
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.45, 1.0],
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: isDark ? 0.75 : 0.60),
                  ],
                ),
              ),
            ),

            // 3. Selection tint overlay (No border!)
            if (isSelected)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.20),
                ),
              ),

            // 4. Overlaid content: Checkmark badge at top-start, Title at bottom
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top: Checkmark circle badge when active
                  Align(
                    alignment: AlignmentDirectional.topStart,
                    child: isSelected
                        ? Container(
                            padding: const EdgeInsets.all(3.5),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 13,
                              color: Colors.white,
                            ),
                          )
                        : const SizedBox(height: 20),
                  ),

                  // Bottom: Title text on image (no caption/description)
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black87,
                          offset: Offset(0, 1),
                          blurRadius: 3,
                        ),
                      ],
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
