import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/hoopoe_game_controller.dart';

class HoopoeGamePauseOverlay extends ConsumerWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  const HoopoeGamePauseOverlay({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(hoopoeGameControllerProvider);
    final controller = ref.read(hoopoeGameControllerProvider.notifier);
    final stage = controller.currentStage;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Stack(
        children: [
          // Darkened Blur Backdrop
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              color: const Color(0xFF060914).withValues(alpha: 0.75),
            ),
          ),

          Center(
            child: Container(
              width: 320,
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
              decoration: BoxDecoration(
                color: const Color(0xFF101935).withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(24.0),
                border: Border.all(
                  color: const Color(0xFFFFD54F).withValues(alpha: 0.35),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD54F).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFFD54F).withValues(alpha: 0.5),
                      ),
                    ),
                    child: const Icon(
                      CupertinoIcons.pause_fill,
                      color: Color(0xFFFFD54F),
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'بازی متوقف شد',
                    style: TextStyle(
                      fontFamily: 'IRANSans',
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'سوره ${stage.name}  |  امتیاز: ${state.score}',
                    style: const TextStyle(
                      fontFamily: 'IRANSans',
                      fontSize: 13.0,
                      color: Color(0xFFB0BEC5),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Resume Button
                  _buildButton(
                    label: 'ادامه پرواز',
                    icon: CupertinoIcons.play_fill,
                    isPrimary: true,
                    onTap: onResume,
                  ),
                  const SizedBox(height: 10),

                  // Restart Button
                  _buildButton(
                    label: 'شروع دوباره سوره',
                    icon: CupertinoIcons.arrow_clockwise,
                    isPrimary: false,
                    onTap: onRestart,
                  ),
                  const SizedBox(height: 10),

                  // Exit Button
                  _buildButton(
                    label: 'خروج به منوی بازی‌ها',
                    icon: CupertinoIcons.xmark,
                    isPrimary: false,
                    onTap: onExit,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? const Color(0xFFFFD54F)
              : Colors.white.withValues(alpha: 0.08),
          foregroundColor: isPrimary ? const Color(0xFF101935) : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.0),
            side: BorderSide(
              color: isPrimary
                  ? Colors.transparent
                  : Colors.white.withValues(alpha: 0.15),
            ),
          ),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'IRANSans',
                fontSize: 13.5,
                fontWeight: isPrimary ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

