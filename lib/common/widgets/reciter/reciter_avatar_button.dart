import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_cached_network_image.dart';
import '../../../core/services/audio/audio_player_state.dart';
import '../../../features/quran_reader/application/controllers/quran_audio_controller.dart';
import 'reciter_selection_bottom_sheet.dart';

/// Reusable circular button displaying reciter avatar with a slow rotating ambient glow ring.
class ReciterAvatarButton extends ConsumerStatefulWidget {
  final double radius;
  final bool showLabel;

  const ReciterAvatarButton({
    super.key,
    this.radius = 24,
    this.showLabel = true,
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
    final selectedReciter = audioState.selectedReciter;
    final reciterName = selectedReciter?.name ?? '';
    final imageUrl = selectedReciter?.imageUrl;


    // Start or stop rotation animation based on audio status
    if (isPlaying && !_animController.isAnimating) {
      _animController.repeat();
    } else if (!isPlaying && _animController.isAnimating) {
      _animController.stop();
    }

    final avatarSize = widget.radius * 2;

    return Tooltip(
      message: 'انتخاب قاری (${reciterName.isEmpty ? 'پیش‌فرض' : reciterName})',
      child: GestureDetector(
        onTap: () {
          ReciterSelectionBottomSheet.show(context);
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
                  ],
                ),
              ),

              // 3. Small "قاریان" label badge on the top-left corner
              if (widget.showLabel)
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
                    child: const Text(
                      'قاریان',
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
