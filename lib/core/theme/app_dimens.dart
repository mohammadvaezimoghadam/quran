import 'package:flutter/material.dart';

/// Sacred Serenity & Apple-grade 8-point Dimensions, Spacing, and Corner Radii System.
class AppDimens {
  // Page Margins & Grid Gutters
  static const double marginPage = 20.0;
  static const double gutterGrid = 16.0;
  static const double safeAreaBottom = 34.0;

  // 8-Point Grid Spacing Base Units
  static const double stackXxSm = 2.0;
  static const double stackXs = 4.0;
  static const double stackSm = 8.0;
  static const double stackSmMd = 12.0;
  static const double stackMd = 16.0;
  static const double stackLg = 24.0;
  static const double stackXl = 32.0;
  static const double stack2Xl = 40.0;
  static const double stack3Xl = 48.0;

  // Card Heights & Padding
  static const double cardBaseHeight = 176.0;
  static const double cardPaddingVertical = 12.0;
  static const double cardPaddingHorizontal = 16.0;

  // Corner Radii (BorderRadius)
  static const double radiusXs = 6.0;
  static const double radiusSm = 10.0;
  static const double radiusDefault = 16.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 24.0;
  static const double radiusXl = 32.0;
  static const double radiusFull = 999.0;

  // Pre-built BorderRadius Objects for UI Convenience
  static const BorderRadius borderRadiusXs = BorderRadius.all(Radius.circular(radiusXs));
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
  static const double iconXl = 40.0;
}
