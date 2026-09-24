import 'package:flutter/material.dart';
import 'package:nimbus/core/theme/app_colors.dart';

/// The colours of the soft surface the whole app is moulded from.
///
/// Every element has the same colour as the background and is separated
/// from it only by light: a [highlight] towards the light source (top-left)
/// and a [shade] away from it. Both are derived from [base], so any base
/// colour produces a consistent set.
///
/// Registered as a [ThemeExtension] so that when the theme changes (day to
/// night, sunny to rainy) every surface interpolates smoothly.
@immutable
class SurfacePalette extends ThemeExtension<SurfacePalette> {
  const SurfacePalette({
    required this.base,
    required this.highlight,
    required this.shade,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.onAccent,
    required this.warning,
    required this.isDark,
  });

  /// Daylight surface, faintly tinted towards [accent].
  factory SurfacePalette.light({Color accent = AppColors.brandLight}) {
    final base = Color.lerp(_lightNeutral, accent, _tintStrength)!;
    return SurfacePalette(
      base: base,
      highlight: Colors.white,
      shade: _shiftLightness(base, -0.17).withValues(alpha: 0.85),
      textPrimary: const Color(0xFF263247),
      textSecondary: const Color(0xFF56647B),
      textMuted: const Color(0xFF7D899C),
      accent: accent,
      onAccent: Colors.white,
      warning: const Color(0xFFC96F12),
      isDark: false,
    );
  }

  /// Night surface, faintly tinted towards [accent].
  factory SurfacePalette.dark({Color accent = AppColors.brandDark}) {
    final base = Color.lerp(_darkNeutral, accent, _tintStrength)!;
    return SurfacePalette(
      base: base,
      highlight: _shiftLightness(base, 0.07).withValues(alpha: 0.9),
      shade: _shiftLightness(base, -0.10).withValues(alpha: 0.95),
      textPrimary: const Color(0xFFE9EDF4),
      textSecondary: const Color(0xFFA6B1C3),
      textMuted: const Color(0xFF788396),
      accent: accent,
      onAccent: const Color(0xFF111522),
      warning: const Color(0xFFFFB86B),
      isDark: true,
    );
  }

  static const _lightNeutral = Color(0xFFE6EBF2);
  static const _darkNeutral = Color(0xFF252A33);

  /// How much the accent colours the surface: enough to set a mood, not
  /// enough to fight the content.
  static const _tintStrength = 0.06;

  final Color base;
  final Color highlight;
  final Color shade;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color accent;

  /// Text and icons drawn on an [accent]-filled surface.
  final Color onAccent;

  /// Icons that flag a problem, e.g. in the refresh-failed banner.
  final Color warning;
  final bool isDark;

  static Color _shiftLightness(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  @override
  SurfacePalette copyWith({
    Color? base,
    Color? highlight,
    Color? shade,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? accent,
    Color? onAccent,
    Color? warning,
    bool? isDark,
  }) {
    return SurfacePalette(
      base: base ?? this.base,
      highlight: highlight ?? this.highlight,
      shade: shade ?? this.shade,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      warning: warning ?? this.warning,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  SurfacePalette lerp(SurfacePalette? other, double t) {
    if (other == null) return this;
    return SurfacePalette(
      base: Color.lerp(base, other.base, t)!,
      highlight: Color.lerp(highlight, other.highlight, t)!,
      shade: Color.lerp(shade, other.shade, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}

extension SurfacePaletteContext on BuildContext {
  /// The current palette. Falls back to the light palette so widgets still
  /// render inside a bare `MaterialApp` (e.g. in widget tests).
  SurfacePalette get palette =>
      Theme.of(this).extension<SurfacePalette>() ?? _fallbackPalette;
}

final _fallbackPalette = SurfacePalette.light();
