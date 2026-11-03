import 'package:flutter/material.dart';

import 'responsive_breakpoints.dart';

/// A convenience widget that renders different layouts based on
/// the current screen width.
///
/// Supports lazy [mobileBuilder] and [desktopBuilder] to prevent duplicate
/// widget instantiation and avoid duplicate GlobalKeys in the tree.
///
/// Usage:
/// ```dart
/// ResponsiveLayout(
///   mobileBuilder: (context) => MobileHomeScreen(),
///   desktopBuilder: (context) => DesktopHomeScreen(),
/// )
/// ```
class ResponsiveLayout extends StatelessWidget {
  /// Widget rendered on mobile-sized screens (< 768px).
  final Widget? mobile;

  /// Widget rendered on desktop/web/tablet-landscape screens (>= 768px).
  final Widget? desktop;

  /// Lazy builder for mobile screens. Only evaluated when on mobile.
  final WidgetBuilder? mobileBuilder;

  /// Lazy builder for desktop screens. Only evaluated when on desktop.
  final WidgetBuilder? desktopBuilder;

  const ResponsiveLayout({
    super.key,
    this.mobile,
    this.desktop,
    this.mobileBuilder,
    this.desktopBuilder,
  }) : assert(
          (mobile != null || mobileBuilder != null) &&
              (desktop != null || desktopBuilder != null),
          'Either mobile/desktop widgets or mobileBuilder/desktopBuilder must be provided',
        );

  @override
  Widget build(BuildContext context) {
    final isDesktop =
        MediaQuery.sizeOf(context).width >= ResponsiveBreakpoints.desktop;
    if (isDesktop) {
      return desktopBuilder != null ? desktopBuilder!(context) : desktop!;
    }
    return mobileBuilder != null ? mobileBuilder!(context) : mobile!;
  }
}
