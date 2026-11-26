import 'package:flutter/material.dart';

/// Displays a single line of text that smoothly auto-scrolls (marquee) only
/// when the text overflows its available width.
///
/// Designed for compact RTL/LTR cards (names, campaign titles, slot labels):
/// - If the text fits within the constraints, renders a plain [Text] with zero
///   animation overhead or active tickers.
/// - If it overflows, pauses calmly at the beginning so the user can read the
///   start of the name, smoothly scrolls at a constant speed with a duplicate
///   copy separated by [gap], feather-fades clipped edges, and loops seamlessly.
/// - Respects [MediaQuery.disableAnimationsOf] and uses
///   [NeverScrollableScrollPhysics] + [IgnorePointer] so parent card taps and
///   outer horizontal lists are never intercepted.
class AutoScrollText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final TextDirection? textDirection;
  final double gap;
  final double velocityPxPerSecond;
  final Duration pauseDuration;
  final bool fadeEdges;

  const AutoScrollText(
    this.text, {
    super.key,
    this.style,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.gap = 32.0,
    this.velocityPxPerSecond = 32.0,
    this.pauseDuration = const Duration(milliseconds: 1300),
    this.fadeEdges = true,
  });

  @override
  State<AutoScrollText> createState() => _AutoScrollTextState();
}

class _AutoScrollTextState extends State<AutoScrollText>
    with SingleTickerProviderStateMixin {
  static final RegExp _rtlCharPattern = RegExp(
    r'[\u0591-\u07FF\u200F\u202B\u202E\uFB1D-\uFDFD\uFE70-\uFEFC]',
  );

  late final AnimationController _controller;
  late final ScrollController _scrollController;
  final ValueNotifier<bool> _hasScrolledFromStart = ValueNotifier<bool>(false);

  bool _shouldScroll = false;
  double _cycleDistance = 0.0;
  double _pauseFraction = 0.0;
  String? _measuredKey;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this)..addListener(_onTick);
    _scrollController = ScrollController();
  }

  @override
  void didUpdateWidget(covariant AutoScrollText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text ||
        oldWidget.style != widget.style ||
        oldWidget.gap != widget.gap ||
        oldWidget.velocityPxPerSecond != widget.velocityPxPerSecond ||
        oldWidget.pauseDuration != widget.pauseDuration ||
        oldWidget.textDirection != widget.textDirection) {
      _measuredKey = null;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTick);
    _controller.dispose();
    _scrollController.dispose();
    _hasScrolledFromStart.dispose();
    super.dispose();
  }

  void _onTick() {
    if (!_shouldScroll || _cycleDistance <= 0) return;

    final t = _controller.value;
    final double targetOffset;
    if (t <= _pauseFraction || _pauseFraction >= 1.0) {
      targetOffset = 0.0;
    } else {
      final progress = (t - _pauseFraction) / (1.0 - _pauseFraction);
      targetOffset = progress * _cycleDistance;
    }

    if (_scrollController.hasClients) {
      final maxExtent = _scrollController.position.maxScrollExtent;
      final clamped = targetOffset.clamp(0.0, maxExtent);
      if ((_scrollController.offset - clamped).abs() > 0.1) {
        _scrollController.jumpTo(clamped);
      }
    }

    final moved = targetOffset > 1.0;
    if (_hasScrolledFromStart.value != moved) {
      _hasScrolledFromStart.value = moved;
    }
  }

  TextDirection _resolveDirection(BuildContext context) {
    if (widget.textDirection != null) return widget.textDirection!;
    if (_rtlCharPattern.hasMatch(widget.text)) {
      return TextDirection.rtl;
    }
    return Directionality.of(context);
  }

  double _measureSingleLineWidth(
    BuildContext context,
    TextStyle resolvedStyle,
    TextDirection direction,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: widget.text, style: resolvedStyle),
      maxLines: 1,
      textDirection: direction,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return painter.width;
  }

  void _syncAnimation({
    required bool overflows,
    required double textWidth,
    required double maxWidth,
    required bool disableAnimations,
  }) {
    final nextShouldScroll = overflows && !disableAnimations && maxWidth > 0;
    final nextCycle = textWidth + widget.gap;

    if (!nextShouldScroll) {
      if (_shouldScroll || _controller.isAnimating) {
        _shouldScroll = false;
        _cycleDistance = 0.0;
        _controller.stop();
        _controller.value = 0.0;
        _hasScrolledFromStart.value = false;
        if (_scrollController.hasClients && _scrollController.offset != 0.0) {
          _scrollController.jumpTo(0.0);
        }
      }
      return;
    }

    final speed = widget.velocityPxPerSecond.clamp(10.0, 200.0);
    final scrollMs = ((nextCycle / speed) * 1000).round().clamp(1200, 30000);
    final pauseMs = widget.pauseDuration.inMilliseconds.clamp(0, 10000);
    final totalMs = pauseMs + scrollMs;
    final nextDuration = Duration(milliseconds: totalMs);
    final nextPauseFraction = totalMs > 0 ? (pauseMs / totalMs) : 0.0;

    final distanceChanged = (_cycleDistance - nextCycle).abs() > 0.5;
    if (_shouldScroll &&
        !distanceChanged &&
        _controller.duration == nextDuration &&
        _controller.isAnimating) {
      return;
    }

    _shouldScroll = true;
    _cycleDistance = nextCycle;
    _pauseFraction = nextPauseFraction;
    _controller.duration = nextDuration;
    _controller.reset();
    _hasScrolledFromStart.value = false;
    if (_scrollController.hasClients && _scrollController.offset != 0.0) {
      _scrollController.jumpTo(0.0);
    }
    _controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = DefaultTextStyle.of(context).style.merge(widget.style);
    final effectiveDirection = _resolveDirection(context);
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedWidth || constraints.maxWidth <= 0) {
          return Text(
            widget.text,
            style: resolvedStyle,
            textAlign: widget.textAlign,
            textDirection: effectiveDirection,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        }

        final maxWidth = constraints.maxWidth;
        final textWidth =
            _measureSingleLineWidth(context, resolvedStyle, effectiveDirection);
        // Tiny subpixel tolerance (0.5px) avoids unnecessary scrolling on exact fits.
        final overflows = textWidth > maxWidth + 0.5;

        final textScaler = MediaQuery.textScalerOf(context);
        final measureKey =
            '${widget.text}|${resolvedStyle.hashCode}|${maxWidth.toStringAsFixed(1)}|$effectiveDirection|$disableAnimations|${textScaler.hashCode}';
        if (_measuredKey != measureKey) {
          _measuredKey = measureKey;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _syncAnimation(
              overflows: overflows,
              textWidth: textWidth,
              maxWidth: maxWidth,
              disableAnimations: disableAnimations,
            );
          });
        }

        if (!overflows || disableAnimations) {
          return Text(
            widget.text,
            style: resolvedStyle,
            textAlign: widget.textAlign,
            textDirection: effectiveDirection,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        }

        final Widget marqueeScroller = SizedBox(
          width: maxWidth,
          child: IgnorePointer(
            child: Directionality(
              textDirection: effectiveDirection,
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.text,
                      style: resolvedStyle,
                      maxLines: 1,
                      softWrap: false,
                    ),
                    SizedBox(width: widget.gap),
                    Text(
                      widget.text,
                      style: resolvedStyle,
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        if (!widget.fadeEdges || maxWidth < 36) {
          return marqueeScroller;
        }

        final edgeRatio = (10.0 / maxWidth).clamp(0.03, 0.14);
        return ValueListenableBuilder<bool>(
          valueListenable: _hasScrolledFromStart,
          builder: (context, isMidScroll, child) {
            final isRtl = effectiveDirection == TextDirection.rtl;
            final double leftStart = isRtl ? 1.0 : (isMidScroll ? 1.0 : 0.0);
            final double rightEnd = isRtl ? (isMidScroll ? 1.0 : 0.0) : 1.0;

            return ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (bounds) {
                return LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    leftStart > 0 ? Colors.transparent : Colors.black,
                    Colors.black,
                    Colors.black,
                    rightEnd > 0 ? Colors.transparent : Colors.black,
                  ],
                  stops: [0.0, edgeRatio, 1.0 - edgeRatio, 1.0],
                ).createShader(bounds);
              },
              child: child,
            );
          },
          child: marqueeScroller,
        );
      },
    );
  }
}
