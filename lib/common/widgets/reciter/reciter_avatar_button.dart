import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_cached_network_image.dart';
import '../../../core/services/audio/audio_player_state.dart';
import '../../../features/quran_reader/application/controllers/quran_audio_controller.dart';
import '../../../features/quran_reader/domain/enums/audio_playback_mode.dart';
import '../../../features/quran_reader/domain/enums/current_track_type.dart';
import '../../../features/subscription/application/vip_subscription_controller.dart';
import '../../../features/subscription/domain/policy/audio_vip_policy.dart';
import 'reciter_selection_bottom_sheet.dart';

/// Reusable circular button displaying reciter avatar with a slow rotating ambient glow ring.
class ReciterAvatarButton extends ConsumerStatefulWidget {
  final double radius;
  final bool showLabel;
  final bool isPlayButton;
  final VoidCallback? onTap;

  const ReciterAvatarButton({
    super.key,
    this.radius = 24,
    this.showLabel = true,
    this.isPlayButton = false,
    this.onTap,
  });

  @override
  ConsumerState<ReciterAvatarButton> createState() => _ReciterAvatarButtonState();
}

class _ReciterAvatarButtonState extends ConsumerState<ReciterAvatarButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final audioState = ref.watch(quranAudioControllerProvider);
    final isPlaying = audioState.status == AudioStatus.playing;
    final isLoading = audioState.status == AudioStatus.loading;
    final isSessionActive = audioState.status != AudioStatus.stopped && audioState.status != AudioStatus.initial;
    final currentTrackType = audioState.currentTrackType;
    final playbackMode = audioState.playbackMode;

    // Determine whether current active (or configured) track is translation
    final isTranslationTrack = isSessionActive
        ? (currentTrackType == CurrentTrackType.translation)
        : (playbackMode == AudioPlaybackMode.onlyTranslation || playbackMode == AudioPlaybackMode.translationThenQuran);

    // Show the correct reciter based on what's currently playing or configured
    final displayReciter = isTranslationTrack
        ? audioState.selectedTranslationReciter
        : audioState.selectedReciter;
    final reciterName = displayReciter?.name ?? '';
    final imageUrl = displayReciter?.imageUrl;


    // Start or stop rotation animation based on audio status
    if (isPlaying && !_animController.isAnimating) {
      _animController.repeat();
    } else if (!isPlaying && _animController.isAnimating) {
      _animController.stop();
    }

    // Check subscription & reciter access
    final hasVip = ref.watch(hasVipAccessProvider);
    final isParhizgar = displayReciter == null ||
        AudioVipPolicy.isDefaultReciter(displayReciter.identifier);

    final avatarSize = widget.radius * 2;

    final String tooltipMessage;
    if (widget.isPlayButton) {
      if (isPlaying) {
        tooltipMessage = 'توقف پخش';
      } else if (isSessionActive) {
        tooltipMessage = isTranslationTrack ? 'ادامه پخش ترجمه' : 'ادامه تلاوت';
      } else {
        tooltipMessage = isTranslationTrack ? 'پخش ترجمه' : 'پخش تلاوت';
      }
    } else {
      final defaultName = isTranslationTrack ? 'مترجم گویا' : 'استاد پرهیزگار';
      final nameStr = reciterName.isEmpty ? defaultName : reciterName;
      final roleTitle = isTranslationTrack ? 'گوینده ترجمه' : 'قاری';
      if (hasVip || (isParhizgar && !isTranslationTrack)) {
        tooltipMessage = 'انتخاب $roleTitle ($nameStr)';
      } else {
        tooltipMessage = 'انتخاب $roleTitle ($nameStr - نیازمند اشتراک)';
      }
    }

    return Tooltip(
      message: tooltipMessage,
      child: GestureDetector(
        onTap: widget.onTap ?? () {
          ReciterSelectionBottomSheet.show(
            context,
            isTranslationMode: isTranslationTrack,
          );
        },
        child: SizedBox(
          width: avatarSize + 8,
          height: avatarSize + 8,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Main Avatar
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                  border: Border.all(
                    color: isPlaying
                        ? colorScheme.primary.withValues(alpha: 0.30)
                        : colorScheme.primary.withValues(alpha: 0.12),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isPlaying
                          ? colorScheme.primary.withValues(alpha: 0.22)
                          : Colors.black.withValues(alpha: 0.08),
                      blurRadius: isPlaying ? 14 : 6,
                      spreadRadius: isPlaying ? 2 : 0,
                      offset: const Offset(0, 2),
                    ),
                    if (isPlaying)
                      BoxShadow(
                        color: colorScheme.tertiary.withValues(alpha: 0.12),
                        blurRadius: 18,
                        spreadRadius: 3,
                        offset: const Offset(0, 0),
                      ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 1. Slow Rotating Ambient Gradient Ring (Active when playing)
                    if (isPlaying)
                      RotationTransition(
                        turns: _animController,
                        child: Container(
                          width: avatarSize,
                          height: avatarSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: SweepGradient(
                              colors: [
                                colorScheme.primary.withValues(alpha: 0.45),
                                colorScheme.tertiary.withValues(alpha: 0.30),
                                colorScheme.primary.withValues(alpha: 0.08),
                                colorScheme.primary.withValues(alpha: 0.45),
                              ],
                              stops: const [0.0, 0.35, 0.7, 1.0],
                            ),
                          ),
                        ),
                      ),

                    // 2. Fixed Upright Avatar Photo
                    AppCachedNetworkImage.circle(
                      imageUrl: imageUrl,
                      size: avatarSize,
                      fallbackIcon: CupertinoIcons.person_fill,
                      backgroundColor: isPlaying
                          ? colorScheme.primary
                          : colorScheme.surfaceContainerHigh,
                    ),

                    // 3. Play/Pause/Loading Overlay Icon (When isPlayButton is true)
                    if (widget.isPlayButton) ...[
                      Container(
                        width: avatarSize,
                        height: avatarSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.38),
                        ),
                      ),
                      if (isLoading)
                        SizedBox(
                          width: avatarSize * 0.38,
                          height: avatarSize * 0.38,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      else
                        Icon(
                          isPlaying ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
                          color: Colors.white,
                          size: avatarSize * 0.45,
                        ),
                    ],
                  ],
                ),
              ),

              // 4. Small "قاریان" label badge on the top-left corner (Only when not play button)
              if (widget.showLabel && !widget.isPlayButton)
                Positioned(
                  top: -2,
                  left: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.35),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      isTranslationTrack ? 'گویندگان' : 'قاریان',
                      style: const TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),

              // 5. VIP Status Badges (Only shown when user has NO VIP, not in play button mode, and not free default)
              if (!hasVip && !widget.isPlayButton && !isParhizgar && !isTranslationTrack) ...[
                Positioned(
                    top: -3,
                    right: -3,
                    child: Container(
                      padding: const EdgeInsets.all(3.5),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F766E), Color(0xFF005C55)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.lock_rounded,
                        color: Colors.white,
                        size: 13,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

