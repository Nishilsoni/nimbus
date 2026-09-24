import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:nimbus/core/theme/app_colors.dart';
import 'package:nimbus/core/widgets/sky_shapes.dart';
import 'package:nimbus/features/weather/domain/entities/weather_condition.dart';

/// An animated, hand-drawn scene for a [WeatherCondition]: drifting clouds,
/// falling rain or snow, a turning sun, a twinkling night sky.
///
/// Everything is painted in code, so there are no image assets to ship and
/// the scene scales crisply to any [size].
class ConditionIllustration extends StatefulWidget {
  const ConditionIllustration({
    super.key,
    required this.condition,
    required this.isDay,
    this.size = 200,
  });

  final WeatherCondition condition;
  final bool isDay;
  final double size;

  @override
  State<ConditionIllustration> createState() => _ConditionIllustrationState();
}

class _ConditionIllustrationState extends State<ConditionIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Respect the system "reduce motion" setting.
    if (MediaQuery.disableAnimationsOf(context)) {
      _loop.stop();
    } else if (!_loop.isAnimating) {
      _loop.repeat();
    }
  }

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: SizedBox.square(
          dimension: widget.size,
          child: CustomPaint(
            painter: _SkyScenePainter(
              condition: widget.condition,
              isDay: widget.isDay,
              loop: _loop,
            ),
          ),
        ),
      ),
    );
  }
}

class _SkyScenePainter extends CustomPainter {
  _SkyScenePainter({
    required this.condition,
    required this.isDay,
    required this.loop,
  }) : super(repaint: loop);

  final WeatherCondition condition;
  final bool isDay;

  /// 0 → 1, repeating. Every motion completes a whole number of cycles per
  /// loop so the animation never visibly jumps when it wraps.
  final Animation<double> loop;

  static const _tau = 2 * math.pi;

  @override
  void paint(Canvas canvas, Size size) {
    final t = loop.value;
    final s = size.shortestSide;
    final c = size.center(Offset.zero);
    final bob = math.sin(t * _tau) * s * 0.02;

    switch (condition) {
      case WeatherCondition.clear:
        if (!isDay) _stars(canvas, c, s, t);
        _sunOrMoon(canvas, c, s * (isDay ? 0.24 : 0.22), t);
      case WeatherCondition.partlyCloudy:
        _sunOrMoon(canvas, c + Offset(s * 0.14, -s * 0.12), s * 0.17, t);
        SkyShapes.cloud(
          canvas,
          c + Offset(-s * 0.06, s * 0.10 + bob),
          s * 0.70,
        );
      case WeatherCondition.cloudy || WeatherCondition.unknown:
        SkyShapes.cloud(
          canvas,
          c + Offset(s * 0.16, -s * 0.10 - bob * 0.6),
          s * 0.52,
          color: AppColors.cloudMid,
        );
        SkyShapes.cloud(
          canvas,
          c + Offset(-s * 0.06, s * 0.08 + bob),
          s * 0.72,
        );
      case WeatherCondition.fog:
        SkyShapes.cloud(
          canvas,
          c + Offset(0, -s * 0.10 + bob),
          s * 0.66,
          color: AppColors.cloudMid,
        );
        _fog(canvas, c, s, t);
      case WeatherCondition.drizzle:
        _rain(canvas, c, s, t, drops: 6, cyclesPerLoop: 2, length: s * 0.05);
        _cloudOverhead(canvas, c, s, bob, AppColors.cloudMid);
      case WeatherCondition.rain:
        _rain(canvas, c, s, t, drops: 10, cyclesPerLoop: 3, length: s * 0.08);
        _cloudOverhead(canvas, c, s, bob, AppColors.cloudDark);
      case WeatherCondition.snow:
        _snow(canvas, c, s, t);
        _cloudOverhead(canvas, c, s, bob, AppColors.cloudLight);
      case WeatherCondition.thunderstorm:
        _rain(canvas, c, s, t, drops: 8, cyclesPerLoop: 3, length: s * 0.08);
        _lightning(canvas, c, s, t);
        _cloudOverhead(canvas, c, s, bob, AppColors.cloudStorm);
    }
  }

  void _sunOrMoon(Canvas canvas, Offset center, double radius, double t) {
    if (isDay) {
      // The sun has 8 rays, so an eighth of a turn per loop is seamless.
      SkyShapes.sun(canvas, center, radius, rayRotation: t * _tau / 8);
    } else {
      SkyShapes.moon(canvas, center, radius);
    }
  }

  /// Precipitation is drawn first so it appears to fall from behind this.
  void _cloudOverhead(
    Canvas canvas,
    Offset c,
    double s,
    double bob,
    Color color,
  ) {
    SkyShapes.cloud(
      canvas,
      c + Offset(0, -s * 0.10 + bob),
      s * 0.74,
      color: color,
    );
  }

  static const _starPositions = [
    Offset(-0.34, -0.28),
    Offset(0.32, -0.34),
    Offset(0.38, 0.20),
    Offset(-0.38, 0.16),
    Offset(0.06, -0.44),
    Offset(-0.14, 0.40),
  ];

  void _stars(Canvas canvas, Offset c, double s, double t) {
    for (var i = 0; i < _starPositions.length; i++) {
      final twinkle = 0.5 + 0.5 * math.sin((t * 2 + i * 0.17) * _tau);
      SkyShapes.star(
        canvas,
        c + _starPositions[i] * s,
        s * (i.isEven ? 0.032 : 0.022),
        0.3 + 0.7 * twinkle,
      );
    }
  }

  void _rain(
    Canvas canvas,
    Offset c,
    double s,
    double t, {
    required int drops,
    required int cyclesPerLoop,
    required double length,
  }) {
    final left = c.dx - s * 0.26;
    final width = s * 0.50;
    final top = c.dy + s * 0.02;
    final fall = s * 0.40;
    for (var i = 0; i < drops; i++) {
      // The golden ratio spreads start times so drops never fall in sync.
      final phase = (t * cyclesPerLoop + i * 0.618) % 1;
      SkyShapes.raindrop(
        canvas,
        Offset(left + (i + 0.5) / drops * width, top + phase * fall),
        length,
        math.sin(phase * math.pi),
      );
    }
  }

  void _snow(Canvas canvas, Offset c, double s, double t) {
    const flakes = 8;
    final left = c.dx - s * 0.26;
    final width = s * 0.52;
    final top = c.dy + s * 0.02;
    final fall = s * 0.40;
    for (var i = 0; i < flakes; i++) {
      final phase = (t + i * 0.618) % 1;
      final sway = math.sin((phase * 2 + i * 0.3) * _tau) * s * 0.025;
      SkyShapes.snowflake(
        canvas,
        Offset(left + (i + 0.5) / flakes * width + sway, top + phase * fall),
        s * (0.016 + (i % 3) * 0.005),
        math.sin(phase * math.pi),
      );
    }
  }

  void _lightning(Canvas canvas, Offset c, double s, double t) {
    // Two quick flickers per loop.
    final flicker = (t > 0.50 && t < 0.53) || (t > 0.57 && t < 0.59);
    SkyShapes.lightning(
      canvas,
      c + Offset(s * 0.02, s * 0.06),
      s * 0.30,
      flicker ? 0.25 : 0.95,
    );
  }

  void _fog(Canvas canvas, Offset c, double s, double t) {
    const widths = [0.62, 0.50, 0.56];
    for (var i = 0; i < widths.length; i++) {
      final drift = math.sin((t + i / widths.length) * _tau) * s * 0.05;
      SkyShapes.fogBand(
        canvas,
        c + Offset(drift, s * (0.16 + i * 0.09)),
        s * widths[i],
        0.75,
      );
    }
  }

  @override
  bool shouldRepaint(_SkyScenePainter oldDelegate) =>
      oldDelegate.condition != condition ||
      oldDelegate.isDay != isDay ||
      oldDelegate.loop != loop;
}
