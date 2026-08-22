import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../../../common/utils/arabic_text_helper.dart';

/// Standalone interactive 360-Degree Circular Color Wheel Picker widget for customizing
/// Quranic Tashkeel (Arabic diacritics & harakat) colors with zero scroll interference,
/// throttled parent updates for 120fps smooth dragging, and real-time live preview.
class InlineTashkeelColorPicker extends StatefulWidget {
  final String initialColorHex;
  final Color accentColor;
  final Color textPrimary;
  final Color textSecondary;
  final ColorScheme colorScheme;
  final ValueChanged<String> onColorChanged;
  final VoidCallback onClose;

  const InlineTashkeelColorPicker({
    super.key,
    required this.initialColorHex,
    required this.accentColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.colorScheme,
    required this.onColorChanged,
    required this.onClose,
  });

  @override
  State<InlineTashkeelColorPicker> createState() =>
      _InlineTashkeelColorPickerState();
}

class _InlineTashkeelColorPickerState extends State<InlineTashkeelColorPicker> {
  double _hue = 0.0;
  double _saturation = 1.0;
  double _value = 1.0;
  Timer? _throttleTimer;

  @override
  void initState() {
    super.initState();
    _updateHsvFromHex(widget.initialColorHex);
  }

  @override
  void didUpdateWidget(InlineTashkeelColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialColorHex != widget.initialColorHex) {
      _updateHsvFromHex(widget.initialColorHex);
    }
  }

  @override
  void dispose() {
    _throttleTimer?.cancel();
    super.dispose();
  }

  void _updateHsvFromHex(String hex) {
    final color =
        ArabicTextHelper.parseHexColor(hex) ?? const Color(0xFFFF4444);
    final hsv = HSVColor.fromColor(color);
    _hue = hsv.hue;
    _saturation = hsv.saturation;
    _value = hsv.value.clamp(0.1, 1.0);
  }

  Color get _currentCustomColor {
    return HSVColor.fromAHSV(1.0, _hue, _saturation, _value).toColor();
  }

  String _colorToHex(Color color) {
    final argb = color.toARGB32();
    final rgb = argb & 0xFFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  /// Throttled parent notification to prevent UI stutter during rapid dragging
  void _notifyColorChangeThrottled() {
    if (_throttleTimer?.isActive ?? false) return;
    _throttleTimer = Timer(const Duration(milliseconds: 35), () {
      if (mounted) {
        final hex = _colorToHex(_currentCustomColor);
        widget.onColorChanged(hex);
      }
    });
  }

  void _notifyColorChangeImmediate() {
    _throttleTimer?.cancel();
    final hex = _colorToHex(_currentCustomColor);
    widget.onColorChanged(hex);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: widget.colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Right Corner (RTL): Circular Color Wheel & Brightness Slider
              Column(
                children: [
                  _buildColorWheel(110.0),
                  const SizedBox(height: 10),
                  // Brightness Slider underneath wheel
                  SizedBox(
                    width: 110.0,
                    child: Row(
                      children: [
                        Icon(
                          Icons.brightness_6_outlined,
                          size: 14,
                          color: widget.textSecondary,
                        ),
                        Expanded(
                          child: SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 3,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 10,
                              ),
                              activeTrackColor: widget.accentColor,
                              inactiveTrackColor: widget.colorScheme.outline
                                  .withValues(alpha: 0.2),
                              thumbColor: widget.accentColor,
                            ),
                            child: Slider(
                              value: _value,
                              min: 0.1,
                              max: 1.0,
                              onChanged: (val) {
                                setState(() {
                                  _value = val;
                                });
                                _notifyColorChangeThrottled();
                              },
                              onChangeEnd: (_) {
                                _notifyColorChangeImmediate();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 14),

              // Opposite Corner (Left Side): Close Button & Large Live Ayah Preview Snippet
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Close Button
                    GestureDetector(
                      onTap: widget.onClose,
                      behavior: HitTestBehavior.opaque,
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: widget.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Live Ayah Preview Text
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: RichText(
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          text: TextSpan(
                            style: TextStyle(
                              fontFamily: 'Vazirmatn',
                              fontSize: 16,
                              height: 1.6,
                              color: widget.textPrimary,
                            ),
                            children: ArabicTextHelper.buildColoredSpans(
                              text: 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                              baseStyle: TextStyle(
                                fontFamily: 'Vazirmatn',
                                fontSize: 16,
                                height: 1.6,
                                color: widget.textPrimary,
                              ),
                              baseColor: widget.textPrimary,
                              harakatColor: _currentCustomColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorWheel(double size) {
    final radius = size / 2;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) {
        _handleWheelTouch(details.localPosition, radius);
        _notifyColorChangeImmediate();
      },
      onPanDown: (details) {
        _handleWheelTouch(details.localPosition, radius);
        _notifyColorChangeThrottled();
      },
      onPanStart: (details) {
        _handleWheelTouch(details.localPosition, radius);
        _notifyColorChangeThrottled();
      },
      onPanUpdate: (details) {
        _handleWheelTouch(details.localPosition, radius);
        _notifyColorChangeThrottled();
      },
      onPanEnd: (_) {
        _notifyColorChangeImmediate();
      },
      child: CustomPaint(
        size: Size(size, size),
        painter: _ColorWheelPainter(
          hue: _hue,
          saturation: _saturation,
          value: _value,
          currentColor: _currentCustomColor,
        ),
      ),
    );
  }

  void _handleWheelTouch(Offset position, double radius) {
    final center = Offset(radius, radius);
    final dx = position.dx - center.dx;
    final dy = position.dy - center.dy;

    final angle = math.atan2(dy, dx);
    double hue = (angle * 180 / math.pi) % 360;
    if (hue < 0) hue += 360;

    final distance = math.sqrt(dx * dx + dy * dy);
    final saturation = (distance / radius).clamp(0.0, 1.0);

    setState(() {
      _hue = hue;
      _saturation = saturation;
    });
  }
}

/// Custom painter to render the 360-degree Color Wheel with indicator knob
class _ColorWheelPainter extends CustomPainter {
  final double hue;
  final double saturation;
  final double value;
  final Color currentColor;

  _ColorWheelPainter({
    required this.hue,
    required this.saturation,
    required this.value,
    required this.currentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(radius, radius);
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 1. Hue 360° Sweep Gradient
    final sweepGradient = SweepGradient(
      colors: List.generate(361, (index) {
        return HSVColor.fromAHSV(1.0, index.toDouble(), 1.0, value).toColor();
      }),
    );
    final wheelPaint = Paint()..shader = sweepGradient.createShader(rect);
    canvas.drawCircle(center, radius, wheelPaint);

    // 2. Saturation Radial Gradient (White at center to transparent at edge)
    final radialGradient = RadialGradient(
      colors: [
        HSVColor.fromAHSV(1.0, 0.0, 0.0, value).toColor(),
        HSVColor.fromAHSV(0.0, 0.0, 0.0, value).toColor(),
      ],
    );
    final satPaint = Paint()..shader = radialGradient.createShader(rect);
    canvas.drawCircle(center, radius, satPaint);

    // 3. Indicator knob circle (Original sleek size)
    final angleRad = hue * math.pi / 180;
    final dist = saturation * radius;
    final knobCenter = Offset(
      center.dx + dist * math.cos(angleRad),
      center.dy + dist * math.sin(angleRad),
    );

    final knobPaint = Paint()
      ..color = currentColor
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final shadowPaint = Paint()
      ..color = Colors.black38
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawCircle(knobCenter, 9, shadowPaint);
    canvas.drawCircle(knobCenter, 8, knobPaint);
    canvas.drawCircle(knobCenter, 8, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _ColorWheelPainter oldDelegate) {
    return oldDelegate.hue != hue ||
        oldDelegate.saturation != saturation ||
        oldDelegate.value != value;
  }
}
