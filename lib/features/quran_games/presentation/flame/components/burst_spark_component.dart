import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class BurstSparkComponent extends PositionComponent {
  final int count;
  final Color color;
  final List<_SparkParticle> _sparks = [];
  double _lifetime = 0.55;

  BurstSparkComponent({
    required Vector2 position,
    this.count = 14,
    this.color = const Color(0xFFFFD54F),
  }) : super(position: position, size: Vector2.zero(), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    final rand = math.Random();
    for (int i = 0; i < count; i++) {
      final angle = rand.nextDouble() * math.pi * 2;
      final speed = 80.0 + rand.nextDouble() * 160.0;
      _sparks.add(
        _SparkParticle(
          velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
          position: Offset.zero,
          size: 2.0 + rand.nextDouble() * 3.5,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _lifetime -= dt;
    if (_lifetime <= 0) {
      removeFromParent();
      return;
    }

    for (final s in _sparks) {
      s.position += s.velocity * dt;
      s.velocity = Offset(s.velocity.dx * 0.95, s.velocity.dy * 0.95);
    }
  }

  @override
  void render(Canvas canvas) {
    final alpha = (_lifetime / 0.55).clamp(0.0, 1.0);
    final paint = Paint()
      ..color = color.withValues(alpha: alpha)
      ..style = PaintingStyle.fill;

    for (final s in _sparks) {
      canvas.drawCircle(s.position, s.size * alpha, paint);
    }
  }
}

class _SparkParticle {
  Offset velocity;
  Offset position;
  final double size;

  _SparkParticle({
    required this.velocity,
    required this.position,
    required this.size,
  });
}

