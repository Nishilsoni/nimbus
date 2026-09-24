import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:nimbus/core/widgets/sky_shapes.dart';

/// The Nimbus mark, a sun rising behind a drifting cloud, animated by
/// [progress] (0 → 1).
///
/// Built from the same [SkyShapes] as the weather illustrations, so the
/// splash already speaks the app's visual language.
class AnimatedLogo extends StatelessWidget {
  const AnimatedLogo({super.key, required this.progress, this.size = 180});

  final Animation<double> progress;
  final double size;

  /// Where the sun ends up inside the logo. The splash uses it as the origin
  /// of the circular reveal into the weather screen.
  static const sunAlignment = Alignment(0.28, -0.30);

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _LogoPainter(progress)),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  _LogoPainter(this.progress) : super(repaint: progress);

  final Animation<double> progress;

  static const _sunRise = Interval(0, 0.55, curve: Curves.easeOutBack);
  static const _cloudDrift = Interval(0.30, 0.80, curve: Curves.easeOutCubic);

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value;
    final s = size.shortestSide;
    final sunIn = _sunRise.transform(t);
    final cloudIn = _cloudDrift.transform(t);

    final sunTarget = AnimatedLogo.sunAlignment.alongSize(size);
    _withOpacity(canvas, sunIn, () {
      SkyShapes.sun(
        canvas,
        sunTarget + Offset(0, (1 - sunIn) * s * 0.35),
        s * 0.20,
        rayRotation: t * math.pi / 2,
      );
    });

    final cloudTarget = size.center(Offset(-s * 0.06, s * 0.12));
    _withOpacity(canvas, cloudIn, () {
      SkyShapes.cloud(
        canvas,
        cloudTarget - Offset((1 - cloudIn) * s * 0.45, 0),
        s * 0.72,
      );
    });
  }

  void _withOpacity(Canvas canvas, double opacity, VoidCallback draw) {
    final alpha = opacity.clamp(0.0, 1.0);
    if (alpha == 0) return;
    canvas.saveLayer(null, Paint()..color = Color.fromRGBO(0, 0, 0, alpha));
    draw();
    canvas.restore();
  }

  @override
  bool shouldRepaint(_LogoPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
