import 'package:flutter/material.dart';

import 'package:quran/common/extensions/context_extension.dart';

/// Shared inherited pulse provider for minimal Apple-grade Khatm skeletons.
class KhatmSkeletonScope extends StatefulWidget {
  final Widget child;

  const KhatmSkeletonScope({super.key, required this.child});

  static double opacityOf(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<_KhatmSkeletonPulse>()
            ?.opacity ??
        0.7;
  }

  @override
  State<KhatmSkeletonScope> createState() => _KhatmSkeletonScopeState();
}

class _KhatmSkeletonScopeState extends State<KhatmSkeletonScope>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1050),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.42, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        return _KhatmSkeletonPulse(
          opacity: _pulse.value,
          child: child!,
        );
      },
      child: widget.child,
    );
  }
}

class _KhatmSkeletonPulse extends InheritedWidget {
  final double opacity;

  const _KhatmSkeletonPulse({
    required this.opacity,
    required super.child,
  });

  @override
  bool updateShouldNotify(_KhatmSkeletonPulse oldWidget) {
    return opacity != oldWidget.opacity;
  }
}

/// Pulsing rounded rectangle / circle block aligned with the Sacred Serenity theme.
class KhatmSkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;
  final bool isCircle;

  const KhatmSkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 6,
    this.isCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final pulse = KhatmSkeletonScope.opacityOf(context);
    final baseAlpha = isDark ? 0.09 : 0.065;
    final color = (isDark ? Colors.white : Colors.black).withValues(
      alpha: baseAlpha * pulse,
    );

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Pulsing hollow donut ring placeholder matching Khatm donut progress charts.
class KhatmSkeletonRing extends StatelessWidget {
  final double size;
  final double strokeWidth;

  const KhatmSkeletonRing({
    super.key,
    required this.size,
    this.strokeWidth = 9.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final pulse = KhatmSkeletonScope.opacityOf(context);
    final baseAlpha = isDark ? 0.11 : 0.08;
    final ringColor = (isDark ? Colors.white : Colors.black).withValues(
      alpha: baseAlpha * pulse,
    );

    final innerSize = (size - strokeWidth * 2).clamp(0.0, double.infinity);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: ringColor,
          width: strokeWidth,
        ),
      ),
      child: Center(
        child: innerSize >= 48
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  KhatmSkeletonBox(
                    width: size * 0.34,
                    height: (innerSize * 0.16).clamp(8.0, 22.0),
                    borderRadius: 6,
                  ),
                  SizedBox(height: (innerSize * 0.05).clamp(3.0, 6.0)),
                  KhatmSkeletonBox(
                    width: size * 0.26,
                    height: (innerSize * 0.09).clamp(5.0, 11.0),
                    borderRadius: 4,
                  ),
                ],
              )
            : KhatmSkeletonBox(
                width: (size * 0.34).clamp(6.0, innerSize * 0.7),
                height: (innerSize * 0.24).clamp(4.0, 8.0),
                borderRadius: 4,
              ),
      ),
    );
  }
}
