import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/hoopoe_game_controller.dart';

class HoopoeGameVictoryOverlay extends ConsumerWidget {
  final bool isVictory;
  final VoidCallback onNextOrRetry;
  final VoidCallback onExit;

  const HoopoeGameVictoryOverlay({
    super.key,
    required this.isVictory,
    required this.onNextOrRetry,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(hoopoeGameControllerProvider);
    final controller = ref.read(hoopoeGameControllerProvider.notifier);
    final stage = controller.currentStage;

    final primaryColor = isVictory ? const Color(0xFFFFD54F) : const Color(0xFFFF7043);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Stack(
        children: [
          // Blur Backdrop
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              color: const Color(0xFF060914).withValues(alpha: 0.82),
            ),
          ),

          Center(
            child: Container(
              width: 320,
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
              decoration: BoxDecoration(
                color: const Color(0xFF101935).withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(24.0),
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.45),
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Badge Icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      isVictory ? CupertinoIcons.sparkles : CupertinoIcons.refresh,
                      color: primaryColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    isVictory ? 'ماشاءالله! تبریک' : 'فرصت‌ها به پایان رسید',
                    style: const TextStyle(
                      fontFamily: 'IRANSans',
                      fontSize: 19.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    isVictory
                        ? 'سوره مبارکه ${stage.name} را کامل کردید'
                        : 'کمی تمرین بیشتر و دوباره پرواز کنید!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'IRANSans',
                      fontSize: 13.0,
                      color: Color(0xFFB0BEC5),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Score & Stats Container
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat(
                          label: 'امتیاز کل',
                          value: '${state.score}',
                          color: const Color(0xFFFFD54F),
                        ),
                        Container(
                          width: 1,
                          height: 28,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                        _buildStat(
                          label: 'بیشترین کامبو',
                          value: 'x${state.combo > 1 ? state.combo : 1}',
                          color: const Color(0xFF81D4FA),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Main Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: const Color(0xFF101935),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                      ),
                      onPressed: onNextOrRetry,
                      child: Text(
                        isVictory ? 'مرحله بعد' : 'تلاش دوباره',
                        style: const TextStyle(
                          fontFamily: 'IRANSans',
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Exit Button
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white70,
                      ),
                      onPressed: onExit,
                      child: const Text(
                        'بازگشت به منوی بازی‌ها',
                        style: TextStyle(
                          fontFamily: 'IRANSans',
                          fontSize: 13.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'IRANSans',
            fontSize: 17.0,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'IRANSans',
            fontSize: 11.5,
            color: Color(0xFF90A4AE),
          ),
        ),
      ],
    );
  }
}

