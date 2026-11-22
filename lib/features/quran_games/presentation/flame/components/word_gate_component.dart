import 'dart:math' as math;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../domain/models/hoopoe_game_models.dart';
import '../hoopoe_flight_game.dart';
import 'hoopoe_character_component.dart';

/// بلاک کارتونی، سه‌بعدی و پفکی شناور آیات قرآن (دروازه کلمه)
/// دارای افکت حجم سه‌بعدی (3D Bevel)، برق شیشه‌ای کارتونی، ابر شناور پایه،
/// خطوط کانتور بولد و تایپوگرافی دولایه برای خوانایی فوق‌العاده اعراب
class WordGateComponent extends PositionComponent
    with CollisionCallbacks, HasGameReference<HoopoeFlightGame> {
  final WordGateData gateData;
  final bool isTopGate;
  final double scrollSpeed;
  final SurahAtmosphere atmosphere;

  bool _isCollected = false;
  late final TextPainter _textPainter;
  late final TextPainter _textStrokePainter;

  double _animTime = 0.0;
  late final double _phase;

  WordGateComponent({
    required this.gateData,
    required this.isTopGate,
    required this.atmosphere,
    required Vector2 position,
    this.scrollSpeed = 165.0,
  }) : super(
          position: position,
          size: Vector2(146, 76),
          anchor: Anchor.center,
        ) {
    _phase = isTopGate ? 0.0 : math.pi * 0.75;
  }

  @override
  Future<void> onLoad() async {
    // محدوده برخورد دقیق با در نظر گرفتن عمق سه‌بعدی بلاک
    add(
      RectangleHitbox(
        size: Vector2(size.x * 0.90, size.y * 0.85),
        position: Vector2(size.x * 0.05, size.y * 0.08),
      ),
    );

    const double fontSize = 23.0;

    // ۱. لایه کانتور و خط دور تیره کلمه (برای ایجاد کنتراست کارتونی قوی)
    _textStrokePainter = TextPainter(
      text: TextSpan(
        text: gateData.word,
        style: TextStyle(
          fontFamily: 'Uthmanic',
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.8
            ..color = const Color(0xFF3E1800)
            ..strokeJoin = StrokeJoin.round,
        ),
      ),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
    )..layout(maxWidth: size.x - 28);

    // ۲. لایه اصلی و درخشان متن قرآنی با رنگ کرم-عاجی و سایه ملایم
    _textPainter = TextPainter(
      text: TextSpan(
        text: gateData.word,
        style: const TextStyle(
          fontFamily: 'Uthmanic',
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFFFDE7),
          shadows: [
            Shadow(
              color: Color(0x77000000),
              offset: Offset(0, 1.8),
              blurRadius: 3.0,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
    )..layout(maxWidth: size.x - 28);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x -= scrollSpeed * dt;
    _animTime += dt;

    if (position.x < -size.x) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (_isCollected) return;

    if (other is HoopoeCharacterComponent) {
      _isCollected = true;
      game.onGateCrossed(this, other);
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final width = size.x;
    final height = size.y;
    const cornerRadius = 22.0;
    const depth3D = 7.0; // ضخامت لایه سه‌بعدی زیرین

    // حرکت شناور موجی و چرخش ملایم کارتونی در هوا
    final bobY = math.sin(_animTime * 3.4 + _phase) * 4.2;
    final tilt = math.sin(_animTime * 2.0 + _phase) * 0.022;

    canvas.save();
    canvas.translate(width / 2, height / 2 + bobY);
    canvas.rotate(tilt);
    canvas.translate(-width / 2, -height / 2);

    // ۱. ابر سفید پفکی کارتونی زیر بلاک (پایه معلق در آسمان)
    _drawCartoonCloudBase(canvas, width, height);

    // ۲. هاله درخشش پیرامونی (Glow)
    final glowPaint = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: 0.32)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);
    final glowRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(3, 3, width - 6, height - depth3D),
      const Radius.circular(cornerRadius),
    );
    canvas.drawRRect(glowRRect, glowPaint);

    // ۳. لایه عمق و حجم سه‌بعدی زیرین (3D Extrusion Shadow)
    final baseRect = Rect.fromLTWH(0, depth3D, width, height - depth3D);
    final baseRRect = RRect.fromRectAndRadius(
      baseRect,
      const Radius.circular(cornerRadius),
    );
    final basePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF9E4A00), // قهوه‌ای کاراملی تیره
          Color(0xFF632C00), // سایه عمیق زیر بلاک
        ],
      ).createShader(baseRect);
    canvas.drawRRect(baseRRect, basePaint);

    final baseOutlinePaint = Paint()
      ..color = const Color(0xFF381700)
      ..strokeWidth = 3.6
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(baseRRect, baseOutlinePaint);

    // ۴. صفحه اصلی بلاک طلایی براق (Main Plaque Face)
    final faceRect = Rect.fromLTWH(0, 0, width, height - depth3D);
    final faceRRect = RRect.fromRectAndRadius(
      faceRect,
      const Radius.circular(cornerRadius),
    );
    final facePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFF59D), // زرد درخشان خورشیدی در بالا
          Color(0xFFFFD54F), // طلایی عسلی گرم
          Color(0xFFFFB300), // کهربایی براق
          Color(0xFFFFA000), // لبه کاراملی
        ],
        stops: [0.0, 0.30, 0.70, 1.0],
      ).createShader(faceRect);
    canvas.drawRRect(faceRRect, facePaint);

    // ۵. لبه برجسته روشن داخلی (Inner Bevel Chamfer)
    final innerBevelPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.85),
          Colors.white.withValues(alpha: 0.12),
        ],
      ).createShader(faceRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final innerBevelRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(2.2, 2.2, width - 4.4, height - depth3D - 4.4),
      const Radius.circular(cornerRadius - 2.0),
    );
    canvas.drawRRect(innerBevelRRect, innerBevelPaint);

    // ۶. برق شیشه‌ای/روغنی کارتونی روی نیمه بالایی (Top Gloss Sheen)
    final glossPath = Path();
    final glossRect = Rect.fromLTWH(6, 4, width - 12, (height - depth3D) * 0.40);
    glossPath.addRRect(
      RRect.fromRectAndCorners(
        glossRect,
        topLeft: const Radius.circular(cornerRadius - 4),
        topRight: const Radius.circular(cornerRadius - 4),
        bottomLeft: const Radius.circular(24),
        bottomRight: const Radius.circular(24),
      ),
    );
    final glossPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.60),
          Colors.white.withValues(alpha: 0.06),
        ],
      ).createShader(glossRect);
    canvas.drawPath(glossPath, glossPaint);

    // ۷. خط دور ضخیم کارتونی دور صفحه اصلی
    final faceOutlinePaint = Paint()
      ..color = const Color(0xFF3E1800)
      ..strokeWidth = 3.6
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(faceRRect, faceOutlinePaint);

    // ۸. نگین‌ها و پیچ‌های طلایی تزئینی در ۴ گوشه بلاک
    _drawCartoonRivet(canvas, 14, 14);
    _drawCartoonRivet(canvas, width - 14, 14);
    _drawCartoonRivet(canvas, 14, height - depth3D - 14);
    _drawCartoonRivet(canvas, width - 14, height - depth3D - 14);

    // ۹. ستاره درخشان متحرک در گوشه بالا (Sparkle Glint)
    final sparklePulse = (math.sin(_animTime * 4.0 + _phase) + 1.0) / 2.0;
    final sparkleScale = 0.5 + sparklePulse * 0.65;
    _drawSparkleStar(canvas, width - 18, 12, sparkleScale, _animTime * 1.5);

    // ۱۰. متن دولایه کلمه قرآنی با خوانایی کامل اعراب
    final textOffset = Offset(
      (width - _textPainter.width) / 2,
      (height - depth3D - _textPainter.height) / 2 - 1.5,
    );
    _textStrokePainter.paint(canvas, textOffset);
    _textPainter.paint(canvas, textOffset);

    canvas.restore();
  }

  /// رسم ابر پفکی کارتونی زیر بلاک به سبک بازی‌های ماریو و پلتفرمر
  void _drawCartoonCloudBase(Canvas canvas, double width, double height) {
    final cloudShadowPaint = Paint()..color = const Color(0x38000000);
    final cloudBasePaint = Paint()..color = const Color(0xFFBBDEFB); // سایه آبی ملایم ابر
    final cloudWhitePaint = Paint()..color = Colors.white.withValues(alpha: 0.94);
    final cloudOutlinePaint = Paint()
      ..color = const Color(0xFF1E2846)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;

    // ۳ حباب پفکی ابر در امتداد لبه پایینی
    final List<Offset> puffs = [
      Offset(width * 0.22, height - 3),
      Offset(width * 0.50, height + 1),
      Offset(width * 0.78, height - 3),
    ];
    final List<double> radii = [13.0, 17.0, 13.0];

    // لایه سایه زیرین ابر
    for (int i = 0; i < puffs.length; i++) {
      canvas.drawCircle(puffs[i].translate(0, 3.5), radii[i], cloudShadowPaint);
    }
    // لایه عمق رنگی ابر
    for (int i = 0; i < puffs.length; i++) {
      canvas.drawCircle(puffs[i].translate(0, 1.8), radii[i], cloudBasePaint);
    }
    // لایه سفید و خط کانتور ابر
    for (int i = 0; i < puffs.length; i++) {
      canvas.drawCircle(puffs[i], radii[i], cloudWhitePaint);
      canvas.drawCircle(puffs[i], radii[i], cloudOutlinePaint);
    }
  }

  /// رسم پیچ / نگین طلایی کارتونی همراه با نقطه برق Specular
  void _drawCartoonRivet(Canvas canvas, double cx, double cy) {
    // سایه زیرین پیچ
    final darkBase = Paint()..color = const Color(0xFF331400);
    canvas.drawCircle(Offset(cx, cy + 1.2), 3.8, darkBase);

    // بدنه طلایی
    final goldBody = Paint()..color = const Color(0xFFFFEE58);
    canvas.drawCircle(Offset(cx, cy), 3.2, goldBody);

    // نقطه نور سفید
    final shineDot = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx - 1.0, cy - 1.0), 1.0, shineDot);
  }

  /// رسم ستاره درخشان ۴ پر کارتونی
  void _drawSparkleStar(
    Canvas canvas,
    double cx,
    double cy,
    double scale,
    double rotation,
  ) {
    if (scale <= 0.1) return;
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(rotation);
    canvas.scale(scale);

    final path = Path();
    const rOuter = 8.0;
    const rInner = 2.4;
    for (int i = 0; i < 4; i++) {
      final angle = i * math.pi / 2;
      final xOuter = math.cos(angle) * rOuter;
      final yOuter = math.sin(angle) * rOuter;
      final xInner = math.cos(angle + math.pi / 4) * rInner;
      final yInner = math.sin(angle + math.pi / 4) * rInner;
      if (i == 0) {
        path.moveTo(xOuter, yOuter);
      } else {
        path.lineTo(xOuter, yOuter);
      }
      path.lineTo(xInner, yInner);
    }
    path.close();

    final starPaint = Paint()..color = const Color(0xFFFFF9C4);
    canvas.drawPath(path, starPaint);
    final corePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset.zero, 2.2, corePaint);

    canvas.restore();
  }
}
