import 'package:flutter/material.dart';

/// Fixed colours. Surface and text colours live in `SurfacePalette`, because
/// they change with the weather and time of day.
abstract final class AppColors {
  // Brand accent, tuned for contrast on light and on dark surfaces.
  static const brandLight = Color(0xFF3D6BE0);
  static const brandDark = Color(0xFF7FA2FF);

  // Sky elements, shared by the splash logo and the weather illustrations.
  static const sunCore = Color(0xFFFFD54F);
  static const sunEdge = Color(0xFFFF9F43);
  static const sunGlow = Color(0xFFFFE08A);
  static const moon = Color(0xFFF3F0D7);
  static const nightSky = Color(0xFF1C2640);
  static const moonGlow = Color(0xFFDCE6FF);
  static const star = Color(0xFFFFFFFF);
  static const cloudLight = Color(0xFFFFFFFF);
  static const cloudMid = Color(0xFFDCE3EE);
  static const cloudDark = Color(0xFF8F9BB0);
  static const cloudStorm = Color(0xFF626E84);
  static const raindrop = Color(0xFF4A9BEA);
  static const snowflake = Color(0xFFFFFFFF);
  static const lightning = Color(0xFFFFD23F);
  static const fog = Color(0xFF9AA7BA);
}
