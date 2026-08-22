import 'package:flutter/material.dart';

/// Extension on [num] to easily construct vertical and horizontal [SizedBox] spacers in UI layout.
extension NumSpacingExtension on num {
  /// Creates a vertical spacer [SizedBox] with height equal to this number.
  /// Example: `16.vSpace`
  SizedBox get vSpace => SizedBox(height: toDouble());

  /// Creates a horizontal spacer [SizedBox] with width equal to this number.
  /// Example: `12.hSpace`
  SizedBox get hSpace => SizedBox(width: toDouble());

  /// Alternative descriptive getter for vertical spacing.
  /// Example: `16.heightBox`
  SizedBox get heightBox => SizedBox(height: toDouble());

  /// Alternative descriptive getter for horizontal spacing.
  /// Example: `12.widthBox`
  SizedBox get widthBox => SizedBox(width: toDouble());
}
