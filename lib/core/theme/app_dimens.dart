import 'package:flutter/material.dart';

/// Sacred Serenity Dimensions, Spacing, and Corner Radii System
/// Extracted directly from DESIGN.md
class AppDimens {
  // Page Margins & Grid Gutters
  static const double marginPage = 24.0;
  static const double gutterGrid = 16.0;
  static const double safeAreaBottom = 40.0;

  // Stack & Padding Spacing Base Units
  static const double stackXxSm = 2.0;
  static const double stackXs = 4.0;
  static const double stackSm = 8.0;
  static const double stackSmMd = 12.0;
  static const double stackMd = 16.0;
  static const double stackLg = 32.0;

  // Card Heights & Padding
  static const double cardBaseHeight = 176.0;
  static const double cardPaddingVertical = 12.0;

  // Corner Radii (BorderRadius)
  static const double radiusSm = 8.0;       // 0.5rem
  static const double radiusDefault = 16.0;  // 1rem
  static const double radiusMd = 24.0;       // 1.5rem
  static const double radiusLg = 32.0;       // 2rem
  static const double radiusXl = 48.0;       // 3rem
  static const double radiusFull = 9999.0;

  // Pre-built BorderRadius Objects for UI Convenience
  static const BorderRadius borderRadiusSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius borderRadiusDefault = BorderRadius.all(Radius.circular(radiusDefault));
  static const BorderRadius borderRadiusMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius borderRadiusLg = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius borderRadiusXl = BorderRadius.all(Radius.circular(radiusXl));
  static const BorderRadius borderRadiusFull = BorderRadius.all(Radius.circular(radiusFull));

  // Common Icon Sizes
  static const double iconXs = 16.0;
  static const double iconSm = 18.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
}
