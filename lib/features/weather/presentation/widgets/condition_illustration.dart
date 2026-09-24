import 'package:flutter/material.dart';
import 'package:nimbus/features/weather/domain/entities/weather_condition.dart';
import 'package:nimbus/features/weather/presentation/widgets/sky_scene_painter.dart';

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
            painter: SkyScenePainter(
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
