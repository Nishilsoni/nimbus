import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nimbus/core/theme/surface_palette.dart';

abstract final class AppTheme {
  /// Builds the whole Material theme from a surface palette, so one
  /// palette change restyles (and animates) everything.
  static ThemeData fromPalette(SurfacePalette palette) {
    final brightness = palette.isDark ? Brightness.dark : Brightness.light;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: palette.accent,
      brightness: brightness,
      primary: palette.accent,
      onPrimary: palette.onAccent,
      surface: palette.base,
      onSurface: palette.textPrimary,
    );
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
    );

    return baseTheme.copyWith(
      scaffoldBackgroundColor: palette.base,
      canvasColor: palette.base,
      extensions: [palette],
      // Depth, not ink ripples, is the press feedback in this design.
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      textTheme: baseTheme.textTheme.apply(
        bodyColor: palette.textPrimary,
        displayColor: palette.textPrimary,
      ),
      iconTheme: IconThemeData(color: palette.textPrimary),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: palette.accent,
        linearTrackColor: Colors.transparent,
        refreshBackgroundColor: palette.base,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: palette.accent,
        selectionColor: palette.accent.withValues(alpha: 0.3),
        selectionHandleColor: palette.accent,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: palette.textPrimary,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: TextStyle(color: palette.base, fontSize: 12),
      ),
    );
  }

  /// Status and navigation bar icons that stay readable on [palette].
  static SystemUiOverlayStyle overlayStyleFor(SurfacePalette palette) {
    final iconBrightness = palette.isDark ? Brightness.light : Brightness.dark;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: iconBrightness,
      // iOS names the bar's background brightness, the opposite of icons.
      statusBarBrightness: palette.isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: iconBrightness,
    );
  }
}
