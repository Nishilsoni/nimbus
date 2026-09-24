import 'package:flutter/material.dart';

/// Type scale. Styles carry no colour: text inherits the palette's primary
/// colour from the theme (so it animates with it), and secondary text adds
/// `context.palette.textSecondary` where it's used.
abstract final class AppTextStyles {
  static const temperatureHero = TextStyle(
    fontSize: 96,
    fontWeight: FontWeight.w300,
    height: 1,
    letterSpacing: -3,
  );

  static const cityTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );

  static const conditionLabel = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const headline = TextStyle(fontSize: 22, fontWeight: FontWeight.w700);

  static const body = TextStyle(fontSize: 15, height: 1.4);

  static const bodyStrong = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  static const caption = TextStyle(fontSize: 13, height: 1.3);

  static const tileLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
  );

  static const tileValue = TextStyle(fontSize: 22, fontWeight: FontWeight.w600);

  static const wordmark = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w300,
    letterSpacing: 12,
  );
}
