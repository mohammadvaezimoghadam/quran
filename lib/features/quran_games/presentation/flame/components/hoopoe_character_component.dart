import 'dart:math' as math;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// وضعیت ریل‌تایم کاراکتر جهت اتصال به ران‌تایم Rive
class PlayerVisualState {
  final double x;
  final double y;
  final double angle;
  final bool isHurt;
  final bool isCelebrating;

  const PlayerVisualState({
    required this.x,
    required this.y,
    required this.angle,
    required this.isHurt,
    required this.isCelebrating,
  });
}

/// کامپوننت فیزیک، برخوردها و ردیابی موقعیت کاراکتر در Flame
/// بدون استفاده از Canvas دستی برای پرنده؛ رندر پرنده کاملاً به Rive سپرده شده است.
class HoopoeCharacterComponent extends PositionComponent
    with CollisionCallbacks, HasGameReference {
  double velocityY = 0.0;
  static const double gravity = 560.0;
  static const double flapStrength = -290.0;
  static const double maxFallSpeed = 460.0;

  double _celebrateTimer = 0.0;
  double _hurtTimer = 0.0;
  final List<_TrailParticle> _trail = [];

  late final ValueNotifier<PlayerVisualState> visualNotifier;

  HoopoeCharacterComponent({required Vector2 position})
      : super(
          position: position,
          size: Vector2(78, 54),
          anchor: Anchor.center,
        ) {
    visualNotifier = ValueNotifier<PlayerVisualState>(
      PlayerVisualState(
        x: position.x,
        y: position.y,
        angle: 0.0,
        isHurt: false,
        isCelebrating: false,
      ),
    );
  }

  @override
  Future<void> onLoad() async {
    // Collision Hitbox centered on bird core
    add(
      CircleHitbox(
        radius: 24,
        position: Vector2(26, 14),
      ),
    );
  }

  void flap() {
    velocityY = flapStrength;
  }

  void celebrate() {
    _celebrateTimer = 0.65;
  }

  void hurt() {
    _hurtTimer = 0.5;
    velocityY = -90.0;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_celebrateTimer > 0) {
      _celebrateTimer -= dt;
      angle += dt * (math.pi * 2 / 0.65);
    } else {
      velocityY += gravity * dt;
      if (velocityY > maxFallSpeed) velocityY = maxFallSpeed;
      position.y += velocityY * dt;

      // Restrain within playable bounds
      final maxY = game.size.y - 60;
      const minY = 90.0;
      if (position.y > maxY) {
        position.y = maxY;
        velocityY = 0;
      }
      if (position.y < minY) {
        position.y = minY;
        velocityY = 0;
      }

      // Smooth flight banking tilt
      final targetAngle = (velocityY / maxFallSpeed).clamp(-0.4, 0.42);
      angle += (targetAngle - angle) * 0.16;
    }

    if (_hurtTimer > 0) {
      _hurtTimer -= dt;
    }

    // Stardust trail
    _trail.add(_TrailParticle(
      offset: Offset(position.x - 34, position.y + 4),
      lifetime: 0.45,
    ));
    for (int i = _trail.length - 1; i >= 0; i--) {
      _trail[i].lifetime -= dt;
      if (_trail[i].lifetime <= 0) {
        _trail.removeAt(i);
      }
    }

    // به‌روزرسانی ریل‌تایم وضعیت ویژوال برای رندر انیمیشن Rive
    visualNotifier.value = PlayerVisualState(
      x: position.x,
      y: position.y,
      angle: angle,
      isHurt: _hurtTimer > 0,
      isCelebrating: _celebrateTimer > 0,
    );
  }

  @override
  void render(Canvas canvas) {
    // رندر ردپای نورانی ستاره‌ای پشت پرنده (Stardust Trail)
    for (final p in _trail) {
      final alpha = (p.lifetime / 0.45).clamp(0.0, 1.0);
      final r = 1.2 + (1.0 - alpha) * 2.8;
      final pPaint = Paint()
        ..color = const Color(0xFFFFD54F).withValues(alpha: alpha * 0.65)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(p.offset.dx - position.x + size.x / 2, p.offset.dy - position.y + size.y / 2),
        r,
        pPaint,
      );
    }

    // هاله آسمانی ملایم اطراف کاراکتر
    final isHurt = _hurtTimer > 0;
    final haloPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFE082).withValues(alpha: isHurt ? 0.08 : 0.35),
          const Color(0xFF81D4FA).withValues(alpha: isHurt ? 0.0 : 0.12),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: const Offset(38, 27), radius: 46));
    canvas.drawCircle(const Offset(38, 27), 46, haloPaint);
  }

  @override
  void onRemove() {
    visualNotifier.dispose();
    super.onRemove();
  }
}

class _TrailParticle {
  final Offset offset;
  double lifetime;

  _TrailParticle({
    required this.offset,
    required this.lifetime,
  });
}
