import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:nimbus/core/theme/app_colors.dart';

/// Drawing primitives for sky elements.
///
/// Shared by the splash logo and the weather illustrations so the whole app
/// uses one visual language. Every method draws in absolute canvas
/// coordinates; callers decide positions and sizes.
abstract final class SkyShapes {
  static void sun(
    Canvas canvas,
    Offset center,
    double radius, {
    double rayRotation = 0,
  }) {
    final glowRect = Rect.fromCircle(center: center, radius: radius * 2.1);
    canvas.drawCircle(
      center,
      radius * 2.1,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.sunGlow.withValues(alpha: 0.55),
            AppColors.sunGlow.withValues(alpha: 0),
          ],
        ).createShader(glowRect),
    );

    final rayPaint = Paint()
      ..color = AppColors.sunCore
      ..strokeWidth = radius * 0.13
      ..strokeCap = StrokeCap.round;
    const rayCount = 8;
    for (var i = 0; i < rayCount; i++) {
      final angle = rayRotation + i * 2 * math.pi / rayCount;
      final direction = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(
        center + direction * radius * 1.32,
        center + direction * radius * 1.62,
        rayPaint,
      );
    }

    final coreRect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.sunCore, AppColors.sunEdge],
        ).createShader(coreRect),
    );
  }

  static void moon(Canvas canvas, Offset center, double radius) {
    final glowRect = Rect.fromCircle(center: center, radius: radius * 2);
    canvas.drawCircle(
      center,
      radius * 2,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.moonGlow.withValues(alpha: 0.35),
            AppColors.moonGlow.withValues(alpha: 0),
          ],
        ).createShader(glowRect),
    );

    final disc = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    final bite = Path()
      ..addOval(
        Rect.fromCircle(
          center: center + Offset(radius * 0.48, -radius * 0.32),
          radius: radius * 0.82,
        ),
      );
    canvas.drawPath(
      Path.combine(PathOperation.difference, disc, bite),
      Paint()..color = AppColors.moon,
    );
  }

  /// A four-point twinkle star.
  static void star(Canvas canvas, Offset center, double size, double opacity) {
    final paint = Paint()
      ..color = AppColors.star.withValues(alpha: opacity.clamp(0, 1));
    final path = Path()
      ..moveTo(center.dx, center.dy - size)
      ..quadraticBezierTo(center.dx, center.dy, center.dx + size, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + size)
      ..quadraticBezierTo(center.dx, center.dy, center.dx - size, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - size)
      ..close();
    canvas.drawPath(path, paint);
  }

  /// A cloud [width] wide (about 0.6 × width tall) centred on [center].
  static void cloud(
    Canvas canvas,
    Offset center,
    double width, {
    Color color = AppColors.cloudLight,
  }) {
    // The shape is designed on a unit grid: three puffs sitting on a
    // rounded base. The visible cloud spans x 0.10–0.92 and y 0.04–0.54.
    final unit = width / 0.82;
    final origin = center - Offset(unit * 0.51, unit * 0.29);
    Offset at(double x, double y) => origin + Offset(x * unit, y * unit);

    final path = Path()
      ..addOval(Rect.fromCircle(center: at(0.28, 0.36), radius: unit * 0.17))
      ..addOval(Rect.fromCircle(center: at(0.52, 0.27), radius: unit * 0.23))
      ..addOval(Rect.fromCircle(center: at(0.76, 0.38), radius: unit * 0.15))
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromPoints(at(0.10, 0.30), at(0.92, 0.54)),
          Radius.circular(unit * 0.12),
        ),
      );

    canvas.drawPath(
      path.shift(Offset(0, unit * 0.04)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.18)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, unit * 0.05),
    );

    final bounds = path.getBounds();
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color, Color.lerp(color, Colors.black, 0.12)!],
        ).createShader(bounds),
    );
  }

  /// A slanted raindrop streak starting at [top].
  static void raindrop(
    Canvas canvas,
    Offset top,
    double length,
    double opacity,
  ) {
    canvas.drawLine(
      top,
      top + Offset(-length * 0.28, length),
      Paint()
        ..color = AppColors.raindrop.withValues(alpha: opacity.clamp(0, 1))
        ..strokeWidth = length * 0.16
        ..strokeCap = StrokeCap.round,
    );
  }

  static void snowflake(
    Canvas canvas,
    Offset center,
    double radius,
    double opacity,
  ) {
    final alpha = opacity.clamp(0.0, 1.0);
    // A soft shadow keeps white flakes visible on light surfaces.
    canvas
      ..drawCircle(
        center + Offset(0, radius * 0.3),
        radius,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.18 * alpha)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.6),
      )
      ..drawCircle(
        center,
        radius,
        Paint()..color = AppColors.snowflake.withValues(alpha: alpha),
      );
  }

  /// A lightning bolt [height] tall hanging from [top].
  static void lightning(
    Canvas canvas,
    Offset top,
    double height,
    double opacity,
  ) {
    final w = height * 0.5;
    final path = Path()
      ..moveTo(top.dx + w * 0.10, top.dy)
      ..lineTo(top.dx - w * 0.30, top.dy + height * 0.55)
      ..lineTo(top.dx + w * 0.02, top.dy + height * 0.55)
      ..lineTo(top.dx - w * 0.20, top.dy + height)
      ..lineTo(top.dx + w * 0.38, top.dy + height * 0.40)
      ..lineTo(top.dx + w * 0.06, top.dy + height * 0.40)
      ..lineTo(top.dx + w * 0.34, top.dy)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.lightning.withValues(alpha: opacity.clamp(0, 1)),
    );
  }

  /// A soft horizontal band of mist.
  static void fogBand(
    Canvas canvas,
    Offset center,
    double width,
    double opacity,
  ) {
    canvas.drawLine(
      center - Offset(width / 2, 0),
      center + Offset(width / 2, 0),
      Paint()
        ..color = AppColors.fog.withValues(alpha: opacity.clamp(0, 1))
        ..strokeWidth = width * 0.07
        ..strokeCap = StrokeCap.round,
    );
  }
}
