import 'package:flutter/material.dart';
import 'package:nimbus/core/theme/surface_palette.dart';

/// A shape moulded from the background: raised, flat or pressed in.
///
/// [depth] runs from 1 (raised: shadows outside) through 0 (flat) to -1
/// (pressed in: shadows inside). Changing it animates smoothly, which is
/// what makes buttons feel physical when pressed.
class TactileSurface extends StatelessWidget {
  const TactileSurface({
    super.key,
    this.child,
    this.depth = 1,
    this.radius = 24,
    this.circle = false,
    this.distance = 6,
    this.padding = EdgeInsets.zero,
    this.color,
    this.duration = const Duration(milliseconds: 220),
  });

  final Widget? child;
  final double depth;
  final double radius;

  /// Draws a circle (ignoring [radius]); give it a square child.
  final bool circle;

  /// How far the shadows fall. Larger surfaces look better with more.
  final double distance;
  final EdgeInsetsGeometry padding;

  /// Fill colour; defaults to the palette's base so the surface blends in.
  final Color? color;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return TweenAnimationBuilder<double>(
      tween: Tween(end: depth),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedDepth, child) => CustomPaint(
        painter: _SurfacePainter(
          palette: palette,
          depth: animatedDepth,
          radius: radius,
          circle: circle,
          distance: distance,
          color: color ?? palette.base,
        ),
        child: child,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _SurfacePainter extends CustomPainter {
  const _SurfacePainter({
    required this.palette,
    required this.depth,
    required this.radius,
    required this.circle,
    required this.distance,
    required this.color,
  });

  final SurfacePalette palette;
  final double depth;
  final double radius;
  final bool circle;
  final double distance;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final shape = RRect.fromRectAndRadius(
      rect,
      Radius.circular(circle ? size.shortestSide / 2 : radius),
    );
    final raised = depth.clamp(0.0, 1.0);
    final pressed = (-depth).clamp(0.0, 1.0);
    final blur = MaskFilter.blur(
      BlurStyle.normal,
      Shadow.convertRadiusToSigma(distance * 2),
    );

    // Raised: light falls from the top-left, so the highlight sits up and
    // left of the shape and the shade down and right.
    if (raised > 0.01) {
      final offset = Offset(distance, distance) * raised;
      canvas
        ..drawRRect(
          shape.shift(-offset),
          Paint()
            ..color = _fade(palette.highlight, raised)
            ..maskFilter = blur,
        )
        ..drawRRect(
          shape.shift(offset),
          Paint()
            ..color = _fade(palette.shade, raised)
            ..maskFilter = blur,
        );
    }

    canvas.drawRRect(shape, Paint()..color = color);

    // Pressed: the rim blocks the light, so the inner top-left edge falls
    // into shade and the inner bottom-right edge catches the light. Each
    // inner shadow is a blurred frame around the shape, clipped to it.
    if (pressed > 0.01) {
      final frame = Path.combine(
        PathOperation.difference,
        Path()..addRect(rect.inflate(distance * 3)),
        Path()..addRRect(shape),
      );
      final offset = Offset(distance, distance) * 0.7 * pressed;
      canvas
        ..save()
        ..clipRRect(shape)
        ..drawPath(
          frame.shift(offset),
          Paint()
            ..color = _fade(palette.shade, pressed)
            ..maskFilter = blur,
        )
        ..drawPath(
          frame.shift(-offset),
          Paint()
            ..color = _fade(palette.highlight, pressed * 0.8)
            ..maskFilter = blur,
        )
        ..restore();
    }
  }

  Color _fade(Color color, double factor) =>
      color.withValues(alpha: color.a * factor);

  @override
  bool shouldRepaint(_SurfacePainter old) =>
      old.depth != depth ||
      old.palette != palette ||
      old.radius != radius ||
      old.circle != circle ||
      old.distance != distance ||
      old.color != color;
}
