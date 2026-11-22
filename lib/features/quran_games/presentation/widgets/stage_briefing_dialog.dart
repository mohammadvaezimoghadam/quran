import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../domain/models/hoopoe_game_models.dart';
import 'hoopoe_rive_widget.dart';

/// دیالوگ آماده‌سازی و شروع پرواز هر مرحله با کاراکتر متحرک Rive
class StageBriefingDialog extends StatelessWidget {
  final SurahStage stage;
  final int earnedStars;
  final VoidCallback onStartFlight;

  const StageBriefingDialog({
    super.key,
    required this.stage,
    required this.earnedStars,
    required this.onStartFlight,
  });

  static Future<void> show({
    required BuildContext context,
    required SurahStage stage,
    required int earnedStars,
    required VoidCallback onStartFlight,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StageBriefingDialog(
        stage: stage,
        earnedStars: earnedStars,
        onStartFlight: () {
          Navigator.of(ctx).pop();
          onStartFlight();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final atmosphere = stage.atmosphere;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32.0)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  atmosphere.skyGradient.first.withValues(alpha: 0.95),
                  atmosphere.skyGradient.last.withValues(alpha: 0.98),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32.0)),
              border: Border.all(
                color: atmosphere.gateGlowColor.withValues(alpha: 0.35),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 32,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top drag handle
                Center(
                  child: Container(
                    width: 44,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // ۱. کاراکتر زنده و متحرک Rive هدهد (بدون کانواس یا کاستوم پینتر)
                const Center(
                  child: HoopoeRiveWidget(size: 145),
                ),
                const SizedBox(height: 10),

                // Surah Name Title
                Center(
                  child: Text(
                    'مرحله ${stage.stageNumber}: سوره ${stage.name}',
                    style: const TextStyle(
                      fontFamily: 'IRANSans',
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                // Atmosphere Subtitle
                Center(
                  child: Text(
                    atmosphere.subtitle,
                    style: TextStyle(
                      fontFamily: 'IRANSans',
                      fontSize: 12.5,
                      color: atmosphere.gateGlowColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Stars display (ستاره‌های به دست آمده)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    final isEarned = index < earnedStars;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Icon(
                        isEarned
                            ? CupertinoIcons.star_fill
                            : CupertinoIcons.star,
                        color: isEarned
                            ? const Color(0xFFFFD54F)
                            : Colors.white24,
                        size: 24,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),

                // Information Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildPill('تعداد آیات', '${stage.ayahs.length} آیه'),
                          Container(width: 1, height: 24, color: Colors.white12),
                          _buildPill('فرصت پرواز', '۳ پر (جان)'),
                          Container(width: 1, height: 24, color: Colors.white12),
                          _buildPill('پاداش مرحله', '+۱۰۰۰ امتیاز'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        stage.virtueDescription,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'IRANSans',
                          fontSize: 11.5,
                          color: Color(0xFFCFD8DC),
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Action Buttons
                // ۱. دکمه اصلی: شروع پرواز
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: atmosphere.gateGlowColor,
                      foregroundColor: const Color(0xFF0F1733),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                    onPressed: onStartFlight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(CupertinoIcons.play_arrow_solid, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'شروع پرواز سوره ${stage.name}',
                          style: const TextStyle(
                            fontFamily: 'IRANSans',
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // ۲. دکمه فرعی: مرور آیات این مرحله
                SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 1.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                    ),
                    onPressed: () => _showAyahPreviewSheet(context),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.book, size: 16, color: Colors.white70),
                        SizedBox(width: 6),
                        Text(
                          'مرور آیات و آمادگی قبل پرواز',
                          style: TextStyle(
                            fontFamily: 'IRANSans',
                            fontSize: 13.0,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPill(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'IRANSans',
            fontSize: 13.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'IRANSans',
            fontSize: 10.5,
            color: Color(0xFF90A4AE),
          ),
        ),
      ],
    );
  }

  void _showAyahPreviewSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            decoration: BoxDecoration(
              color: const Color(0xFF0E1424),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'آیات سوره ${stage.name}',
                  style: const TextStyle(
                    fontFamily: 'IRANSans',
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                ...stage.ayahs.map((ayah) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF070B16),
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Container(
                        padding: const EdgeInsets.all(14.0),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              Color(0xFF1E294B),
                              Color(0xFF131B32),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: const Color(0xFFFFD54F).withValues(alpha: 0.35),
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                    vertical: 2.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFD54F).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Text(
                                    'آیه ${ayah.ayahNumber}',
                                    style: const TextStyle(
                                      fontFamily: 'IRANSans',
                                      fontSize: 11.0,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFFE082),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              ayah.fullText,
                              style: const TextStyle(
                                fontFamily: 'Uthmanic',
                                fontSize: 19.0,
                                height: 1.6,
                                color: Color(0xFFFFF9C4),
                              ),
                            ),
                            const SizedBox(height: 6.0),
                            Text(
                              ayah.translation,
                              style: const TextStyle(
                                fontFamily: 'IRANSans',
                                fontSize: 12.0,
                                color: Color(0xFFCFD8DC),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
