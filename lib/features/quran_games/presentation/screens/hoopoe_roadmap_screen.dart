import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/hoopoe_game_controller.dart';
import '../../domain/models/hoopoe_game_models.dart';
import '../widgets/stage_briefing_dialog.dart';
import 'hoopoe_flight_game_screen.dart';

class HoopoeRoadmapScreen extends ConsumerStatefulWidget {
  final VoidCallback onExitToHub;

  const HoopoeRoadmapScreen({
    super.key,
    required this.onExitToHub,
  });

  @override
  ConsumerState<HoopoeRoadmapScreen> createState() => _HoopoeRoadmapScreenState();
}

class _HoopoeRoadmapScreenState extends ConsumerState<HoopoeRoadmapScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  bool _isPlayingFlight = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isPlayingFlight) {
      return HoopoeFlightGameScreen(
        onExitToHub: () {
          setState(() {
            _isPlayingFlight = false;
          });
        },
      );
    }

    final state = ref.watch(hoopoeGameControllerProvider);
    final controller = ref.read(hoopoeGameControllerProvider.notifier);
    final stages = QuranGameStages.stages;
    final totalStars = controller.totalStarsEarned;
    final maxStars = controller.maxPossibleStars;
    final unlockedStage = state.unlockedUpToStage;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF070B18),
        body: Stack(
          children: [
            // 1. Celestial Starry Background & Desert Dunes Canvas
            const Positioned.fill(
              child: _RoadmapBackground(),
            ),

            // 2. Serpentine Winding Stages Path (Bottom to Top Scroll)
            CustomScrollView(
              reverse: true, // Stage 1 starts at bottom, scrolls up to summit!
              physics: const BouncingScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(
                  child: SizedBox(height: 110), // Space for top floating HUD
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: _SerpentinePathView(
                      stages: stages,
                      unlockedUpToStage: unlockedStage,
                      stageStars: state.stageStars,
                      pulseAnimation: _pulseController,
                      onStageTap: (stageIndex) {
                        if (stageIndex <= unlockedStage) {
                          controller.selectStage(stageIndex);
                          StageBriefingDialog.show(
                            context: context,
                            stage: stages[stageIndex],
                            earnedStars: state.stageStars[stageIndex] ?? 0,
                            onStartFlight: () {
                              setState(() {
                                _isPlayingFlight = true;
                              });
                            },
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('این مرحله قفل است؛ ابتدا مرحله قبل را کامل کنید.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 30),
                ),
              ],
            ),

            // 3. Floating Top Bar: Back, Title, Stars, Progress
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildTopBar(context, totalStars, maxStars, unlockedStage, stages.length),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    int totalStars,
    int maxStars,
    int unlockedIndex,
    int totalStages,
  ) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: EdgeInsets.fromLTRB(16, topPadding + 8, 16, 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0C1226).withValues(alpha: 0.85),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
                width: 0.8,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  // Back button
                  ClipOval(
                    child: Material(
                      color: Colors.white.withValues(alpha: 0.08),
                      child: InkWell(
                        onTap: widget.onExitToHub,
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(CupertinoIcons.back, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Title
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'نقشه آسمانی سوره‌ها',
                          style: TextStyle(
                            fontFamily: 'IRANSans',
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'مراحل پرواز هدهد در کلام وحی',
                          style: TextStyle(
                            fontFamily: 'IRANSans',
                            fontSize: 11.5,
                            color: Color(0xFF90A4AE),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Stars Counter Chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD54F).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFFFD54F).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          CupertinoIcons.star_fill,
                          color: Color(0xFFFFD54F),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$totalStars / $maxStars',
                          style: const TextStyle(
                            fontFamily: 'IRANSans',
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFE082),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Linear Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: ((unlockedIndex + 1) / totalStages).clamp(0.0, 1.0),
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                  minHeight: 5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Serpentine Winding Path with Stage Nodes
class _SerpentinePathView extends StatelessWidget {
  final List<SurahStage> stages;
  final int unlockedUpToStage;
  final Map<int, int> stageStars;
  final Animation<double> pulseAnimation;
  final ValueChanged<int> onStageTap;

  const _SerpentinePathView({
    required this.stages,
    required this.unlockedUpToStage,
    required this.stageStars,
    required this.pulseAnimation,
    required this.onStageTap,
  });

  @override
  Widget build(BuildContext context) {
    const double rowHeight = 135.0;

    return Stack(
      children: [
        // 1. Winding Road Canvas (Dotted golden path connecting waypoints)
        Positioned.fill(
          child: CustomPaint(
            painter: _WindingRoadPainter(stageCount: stages.length, rowHeight: rowHeight),
          ),
        ),

        // 2. Stage Nodes laid out along the S-curve
        Column(
          children: List.generate(stages.length, (idx) {
            final stage = stages[idx];
            final isUnlocked = idx <= unlockedUpToStage;
            final isCurrent = idx == unlockedUpToStage;
            final stars = stageStars[idx] ?? 0;

            // X-alignment oscillates: center -> left -> center -> right -> center
            final xAlign = (idx % 2 == 0) ? -0.55 : 0.55;

            return SizedBox(
              height: rowHeight,
              child: Align(
                alignment: Alignment(xAlign, 0.0),
                child: _StageNodeWidget(
                  stage: stage,
                  isUnlocked: isUnlocked,
                  isCurrent: isCurrent,
                  earnedStars: stars,
                  pulseAnimation: pulseAnimation,
                  onTap: () => onStageTap(idx),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// Individual Stage Node on the Winding Road
class _StageNodeWidget extends StatelessWidget {
  final SurahStage stage;
  final bool isUnlocked;
  final bool isCurrent;
  final int earnedStars;
  final Animation<double> pulseAnimation;
  final VoidCallback onTap;

  const _StageNodeWidget({
    required this.stage,
    required this.isUnlocked,
    required this.isCurrent,
    required this.earnedStars,
    required this.pulseAnimation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final atmosphere = stage.atmosphere;
    final primaryColor = isUnlocked ? atmosphere.gateGlowColor : const Color(0xFF455A64);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circular Stage Pedestal
          AnimatedBuilder(
            animation: pulseAnimation,
            builder: (ctx, child) {
              final pulseGlow = isCurrent ? 6.0 + pulseAnimation.value * 8.0 : 4.0;
              return Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isUnlocked
                        ? [
                            atmosphere.gateGlowColor,
                            atmosphere.gateBorderColor,
                          ]
                        : [
                            const Color(0xFF263238),
                            const Color(0xFF1B242A),
                          ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: isUnlocked ? 0.45 : 0.1),
                      blurRadius: pulseGlow,
                      spreadRadius: isCurrent ? 2 : 0,
                    ),
                  ],
                  border: Border.all(
                    color: isCurrent ? Colors.white : Colors.white.withValues(alpha: 0.35),
                    width: isCurrent ? 2.5 : 1.5,
                  ),
                ),
                child: Center(
                  child: isUnlocked
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${stage.stageNumber}',
                              style: TextStyle(
                                fontFamily: 'IRANSans',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isUnlocked ? const Color(0xFF0F1733) : Colors.white54,
                              ),
                            ),
                          ],
                        )
                      : const Icon(
                          CupertinoIcons.lock_fill,
                          color: Colors.white38,
                          size: 24,
                        ),
                ),
              );
            },
          ),
          const SizedBox(height: 6),

          // Surah Name Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1733).withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isUnlocked
                    ? atmosphere.gateGlowColor.withValues(alpha: 0.4)
                    : Colors.white12,
              ),
            ),
            child: Text(
              'سوره ${stage.name}',
              style: TextStyle(
                fontFamily: 'IRANSans',
                fontSize: 12,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                color: isUnlocked ? Colors.white : Colors.white38,
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Stars Row
          if (isUnlocked)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (idx) {
                final hasStar = idx < earnedStars;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.5),
                  child: Icon(
                    CupertinoIcons.star_fill,
                    size: 13,
                    color: hasStar ? const Color(0xFFFFD54F) : Colors.white24,
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }
}

/// Canvas Painter for the Winding Road (S-curve path)
class _WindingRoadPainter extends CustomPainter {
  final int stageCount;
  final double rowHeight;

  _WindingRoadPainter({required this.stageCount, required this.rowHeight});

  @override
  void paint(Canvas canvas, Size size) {
    if (stageCount < 2) return;

    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < stageCount; i++) {
      final y = (i + 0.5) * rowHeight;
      final x = (i % 2 == 0) ? size.width * 0.25 : size.width * 0.75;
      points.add(Offset(x, y));
    }

    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final cx = (p0.dx + p1.dx) / 2;
      final cy = (p0.dy + p1.dy) / 2;
      path.quadraticBezierTo(cx, p0.dy, cx, cy);
      path.quadraticBezierTo(cx, p1.dy, p1.dx, p1.dy);
    }

    // Outer glow path
    final glowPaint = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(path, glowPaint);

    // Inner dotted celestial path
    final pathPaint = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, pathPaint);
  }

  @override
  bool shouldRepaint(covariant _WindingRoadPainter oldDelegate) =>
      oldDelegate.stageCount != stageCount || oldDelegate.rowHeight != rowHeight;
}

class _RoadmapBackground extends StatelessWidget {
  const _RoadmapBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF04060C),
            Color(0xFF080E1E),
            Color(0xFF101932),
            Color(0xFF16203D),
          ],
        ),
      ),
    );
  }
}

