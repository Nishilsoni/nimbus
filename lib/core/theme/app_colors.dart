import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand
  static const brandNavy = Color(0xFF0B1E3F);
  static const brandBlue = Color(0xFF2F6BFF);
  static const brandGradient = [
    Color(0xFF0B1E3F),
    Color(0xFF16336B),
    Color(0xFF2F5AA8),
  ];

  // Sky elements
  static const sunCore = Color(0xFFFFD54F);
  static const sunEdge = Color(0xFFFF9F43);
  static const sunGlow = Color(0xFFFFE08A);
  static const moon = Color(0xFFF3F0D7);
  static const moonGlow = Color(0xFFDCE6FF);
  static const star = Color(0xFFFFFFFF);
  static const cloudLight = Color(0xFFF7F9FC);
  static const cloudMid = Color(0xFFD5DEEA);
  static const cloudDark = Color(0xFF8793A6);
  static const cloudStorm = Color(0xFF5E6A7E);
  static const raindrop = Color(0xFF9FD0FF);
  static const snowflake = Color(0xFFFFFFFF);
  static const lightning = Color(0xFFFFE45C);
  static const fog = Color(0xFFE3E8EE);

  // Text & surfaces on top of the sky gradients
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xCCFFFFFF);
  static const textMuted = Color(0x99FFFFFF);
  static const glassFill = Color(0x1FFFFFFF);
  static const glassBorder = Color(0x26FFFFFF);
  static const skeleton = Color(0x33FFFFFF);
  static const warningFill = Color(0x33FFB74D);
  static const warningBorder = Color(0x66FFB74D);
}
