import 'package:flutter/material.dart';

import 'package:nimbus/core/theme/app_colors.dart';

abstract final class AppTextStyles {
  static const _shadow = [
    Shadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 2)),
  ];

  static const temperatureHero = TextStyle(
    fontSize: 104,
    fontWeight: FontWeight.w200,
    height: 1,
    letterSpacing: -4,
    color: AppColors.textPrimary,
    shadows: _shadow,
  );

  static const cityTitle = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    shadows: _shadow,
  );

  static const conditionLabel = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    shadows: _shadow,
  );

  static const headline = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const body = TextStyle(
    fontSize: 15,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  static const bodyStrong = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const caption = TextStyle(
    fontSize: 13,
    color: AppColors.textSecondary,
  );

  static const tileLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.1,
    color: AppColors.textMuted,
  );

  static const tileValue = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const wordmark = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w300,
    letterSpacing: 10,
    color: AppColors.textPrimary,
  );
}
