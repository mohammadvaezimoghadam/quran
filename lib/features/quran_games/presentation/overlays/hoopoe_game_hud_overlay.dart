import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/hoopoe_game_controller.dart';

class HoopoeGameHudOverlay extends ConsumerWidget {
  final VoidCallback onPause;
  final VoidCallback onExit;

  const HoopoeGameHudOverlay({
    super.key,
    required this.onPause,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(hoopoeGameControllerProvider);
    final controller = ref.read(hoopoeGameControllerProvider.notifier);
    final currentAyah = controller.currentAyah;
    final stage = controller.currentStage;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Top Navigation Bar: Exit, Stage Title, Feathers, Pause
              Row(
                children: [
                  // Exit / Back
                  _buildIconButton(
                    icon: CupertinoIcons.xmark,
                    onTap: onExit,
                  ),
                  const SizedBox(width: 8.0),

                  // Stage & Ayah Title Pill
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 8.0,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF101935).withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(
                              color: const Color(0xFFFFD54F).withValues(alpha: 0.35),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'سوره ${stage.name}',
                                style: const TextStyle(
                                  fontFamily: 'IRANSans',
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 6.0),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6.0,
                                  vertical: 2.0,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD54F).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Text(
                                  'آیه ${currentAyah.ayahNumber}',
                                  style: const TextStyle(
                                    fontFamily: 'IRANSans',
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFFFE082),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8.0),

                  // Feathers / Lives (۳ پر هدهد)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (index) {
                      final hasFeather = index < state.feathers;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: Icon(
                          CupertinoIcons.sparkles,
                          size: 18.0,
                          color: hasFeather
                              ? const Color(0xFFFFD54F)
                              : Colors.white.withValues(alpha: 0.25),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(width: 8.0),

                  // Pause Button
                  _buildIconButton(
                    icon: CupertinoIcons.pause_fill,
                    onTap: onPause,
                  ),
                ],
              ),

              const SizedBox(height: 12.0),

              // 2. Interactive Ayah Word Sequence Tracker (بلاک‌های کارتونی سه‌بعدی کلمات آیه)
              ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C1328).withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(
                        color: const Color(0xFFFFD54F).withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 16.0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              CupertinoIcons.book_fill,
                              size: 12.0,
                              color: Color(0xFFFFD54F),
                            ),
                            const SizedBox(width: 5.0),
                            Text(
                              'کلمات آیه به ترتیب پرواز',
                              style: TextStyle(
                                fontFamily: 'IRANSans',
                                fontSize: 11.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 7.0,
                          runSpacing: 7.0,
                          children: List.generate(currentAyah.words.length, (idx) {
                            return _buildCartoonWordTile(
                              word: currentAyah.words[idx],
                              isPassed: idx < state.wordIndex,
                              isTarget: idx == state.wordIndex,
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // 3. Bottom Bar: Score, Combo, Guidance Toast
              ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF090E20).withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Score & Combo
                        Row(
                          children: [
                            const Icon(
                              CupertinoIcons.star_fill,
                              color: Color(0xFFFFD54F),
                              size: 16.0,
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              '${state.score}',
                              style: const TextStyle(
                                fontFamily: 'IRANSans',
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (state.combo > 1) ...[
                              const SizedBox(width: 8.0),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6.0,
                                  vertical: 2.0,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF7043).withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(6.0),
                                ),
                                child: Text(
                                  'x${state.combo}',
                                  style: const TextStyle(
                                    fontFamily: 'IRANSans',
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFFAB91),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),

                        // Guidance Status Text
                        Flexible(
                          child: Text(
                            state.statusMessage,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontFamily: 'IRANSans',
                              fontSize: 12.0,
                              color: Color(0xFFB0BEC5),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF101935).withValues(alpha: 0.75),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 0.8,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(icon, color: Colors.white, size: 18.0),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// بلاک کارتونی سه‌بعدی کلمات در هدر بالای بازی
  Widget _buildCartoonWordTile({
    required String word,
    required bool isPassed,
    required bool isTarget,
  }) {
    if (isTarget) {
      // ۱. کلمه فعال جاری: تایل طلایی کارتونی سه‌بعدی و چشمک‌زن
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFB26A00), // سایه حجم سه‌بعدی زیر تایل
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD54F).withValues(alpha: 0.5),
              blurRadius: 10.0,
              spreadRadius: 1.0,
            ),
          ],
        ),
        padding: const EdgeInsets.only(bottom: 3.5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFF9C4), // زرد خیلی روشن خورشیدی
                Color(0xFFFFD54F), // طلایی عسلی
                Color(0xFFFFB300), // کهربایی
              ],
            ),
            borderRadius: BorderRadius.circular(11.0),
            border: Border.all(
              color: const Color(0xFF4E2600), // خط کانتور کارتونی
              width: 1.6,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CupertinoIcons.sparkles,
                size: 13.0,
                color: Color(0xFF4E2600),
              ),
              const SizedBox(width: 4.0),
              Text(
                word,
                style: const TextStyle(
                  fontFamily: 'Uthmanic',
                  fontSize: 16.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E1500),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (isPassed) {
      // ۲. کلمات عبور کرده موفق: تایل زمردی کارتونی سه‌بعدی با تیک تایید
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1B5E20), // لایه حجم سه‌بعدی زیرین
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: const EdgeInsets.only(bottom: 3.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 3.5),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF81C784),
                Color(0xFF43A047),
                Color(0xFF2E7D32),
              ],
            ),
            borderRadius: BorderRadius.circular(11.0),
            border: Border.all(
              color: const Color(0xFF0F3813),
              width: 1.4,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CupertinoIcons.checkmark_alt,
                size: 13.0,
                color: Colors.white,
              ),
              const SizedBox(width: 3.0),
              Text(
                word,
                style: const TextStyle(
                  fontFamily: 'Uthmanic',
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Color(0x66000000),
                      offset: Offset(0, 1.0),
                      blurRadius: 2.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // ۳. کلمات بعدی آیه: تایل ابری ملایم کارتونی
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF111A33),
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: const EdgeInsets.only(bottom: 2.5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
          decoration: BoxDecoration(
            color: const Color(0xFF1F2B4D).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(11.0),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1.0,
            ),
          ),
          child: Text(
            word,
            style: TextStyle(
              fontFamily: 'Uthmanic',
              fontSize: 15.0,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
        ),
      );
    }
  }
}
