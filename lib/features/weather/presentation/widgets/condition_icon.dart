import 'package:flutter/material.dart';
import 'package:nimbus/features/weather/domain/entities/weather_condition.dart';
import 'package:nimbus/features/weather/presentation/widgets/sky_scene_painter.dart';

/// A small, still version of the condition illustration, for forecast rows
/// where dozens of animated scenes would be distracting and wasteful.
class ConditionIcon extends StatelessWidget {
  const ConditionIcon({
    super.key,
    required this.condition,
    required this.isDay,
    this.size = 28,
  });

  final WeatherCondition condition;
  final bool isDay;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: SizedBox.square(
          dimension: size,
          child: CustomPaint(
            painter: SkyScenePainter(
              condition: condition,
              isDay: isDay,
              // A moment where rain and snow are mid-fall.
              loop: const AlwaysStoppedAnimation(0.3),
            ),
          ),
        ),
      ),
    );
  }
}
