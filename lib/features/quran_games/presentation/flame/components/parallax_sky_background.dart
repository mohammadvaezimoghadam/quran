import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../domain/models/hoopoe_game_models.dart';

class ParallaxSkyBackground extends Component with HasGameReference {
  final SurahAtmosphere atmosphere;
  late final List<_Star> _stars;
  double _scrollOffset = 0.0;

  ParallaxSkyBackground({required this.atmosphere});

  @override
  Future<void> onLoad() async {
    final rand = math.Random(42);
    _stars = List.generate(70, (_) {
      return _Star(
        x: rand.nextDouble(),
        y: rand.nextDouble() * 0.75,
        radius: 0.8 + rand.nextDouble() * 1.8,
        twinkleSpeed: 1.5 + rand.nextDouble() * 3.0,
        phase: rand.nextDouble() * math.pi * 2,
        speedMultiplier: 0.2 + rand.nextDouble() * 0.5,
      );
    });
  }

  @override
  void update(double dt) {
    super.update(dt);
    _scrollOffset += dt * 50.0;
  }

  @override
  void render(Canvas canvas) {
    final size = game.size;

    // 1. Dynamic Atmosphere Sky Gradient
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: atmosphere.skyGradient,
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), skyPaint);

    // 2. Crescent Moon with Surah Tint
    final moonCenter = Offset(size.x * 0.82, size.y * 0.16);
    final moonRadius = size.x * 0.08;

    final moonGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          atmosphere.gateGlowColor.withValues(alpha: 0.35),
          atmosphere.gateGlowColor.withValues(alpha: 0.08),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: moonCenter, radius: moonRadius * 2.5));
    canvas.drawCircle(moonCenter, moonRadius * 2.5, moonGlow);

    final moonPath = Path()
      ..addArc(Rect.fromCircle(center: moonCenter, radius: moonRadius), 0, math.pi * 2);
    final cutoutCenter = moonCenter + const Offset(-12, -8);
    final cutoutPath = Path()
      ..addArc(Rect.fromCircle(center: cutoutCenter, radius: moonRadius * 0.95), 0, math.pi * 2);
    final crescentPath = Path.combine(PathOperation.difference, moonPath, cutoutPath);

    final crescentPaint = Paint()
      ..color = const Color(0xFFFFFDE7)
      ..style = PaintingStyle.fill;
    canvas.drawPath(crescentPath, crescentPaint);

    // 3. Twinkling Stars Layer with Surah Star Tint
    final now = DateTime.now().millisecondsSinceEpoch / 1000.0;
    for (final star in _stars) {
      final sx = ((star.x * size.x - _scrollOffset * star.speedMultiplier) % size.x + size.x) % size.x;
      final sy = star.y * size.y;
      final twinkle = 0.35 + 0.65 * ((math.sin(now * star.twinkleSpeed + star.phase) + 1) / 2);

      final starPaint = Paint()
        ..color = atmosphere.starColor.withValues(alpha: twinkle)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(sx, sy), star.radius, starPaint);
    }

    // 4. Parallax Dunes & Oriental Silhouettes
    _renderSilhouettes(canvas, size, _scrollOffset);
  }

  void _renderSilhouettes(Canvas canvas, Vector2 size, double offset) {
    final dunePaint = Paint()..color = atmosphere.duneColor.withValues(alpha: 0.7);
    final dunePath = Path();
    dunePath.moveTo(0, size.y);

    final duneStep = size.x / 4;
    final duneOffset = (offset * 0.3) % duneStep;
    for (double x = -duneStep; x <= size.x + duneStep; x += duneStep) {
      final px = x - duneOffset;
      final py = size.y * 0.82 + math.sin((x + offset * 0.3) * 0.005) * 35;
      dunePath.lineTo(px, py);
    }
    dunePath.lineTo(size.x, size.y);
    dunePath.close();
    canvas.drawPath(dunePath, dunePaint);

    // Foreground Horizon
    final forePaint = Paint()..color = atmosphere.duneColor;
    final forePath = Path();
    forePath.moveTo(0, size.y);
    forePath.lineTo(0, size.y * 0.93);
    forePath.quadraticBezierTo(size.x * 0.5, size.y * 0.90, size.x, size.y * 0.94);
    forePath.lineTo(size.x, size.y);
    forePath.close();
    canvas.drawPath(forePath, forePaint);
  }
}

class _Star {
  final double x;
  final double y;
  final double radius;
  final double twinkleSpeed;
  final double phase;
  final double speedMultiplier;

  _Star({
    required this.x,
    required this.y,
    required this.radius,
    required this.twinkleSpeed,
    required this.phase,
    required this.speedMultiplier,
  });
}
