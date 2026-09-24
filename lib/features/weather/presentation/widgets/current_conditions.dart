import 'package:flutter/material.dart';
import 'package:nimbus/core/constants/app_strings.dart';
import 'package:nimbus/core/theme/app_colors.dart';
import 'package:nimbus/core/theme/app_text_styles.dart';
import 'package:nimbus/core/theme/surface_palette.dart';
import 'package:nimbus/core/utils/unit_formatter.dart';
import 'package:nimbus/core/widgets/motion/counting_text.dart';
import 'package:nimbus/core/widgets/motion/smooth_switcher.dart';
import 'package:nimbus/core/widgets/motion/staggered_entrance.dart';
import 'package:nimbus/core/widgets/tactile/tactile_surface.dart';
import 'package:nimbus/features/weather/domain/entities/weather.dart';
import 'package:nimbus/features/weather/presentation/utils/condition_visuals.dart';
import 'package:nimbus/features/weather/presentation/widgets/condition_illustration.dart';

/// The hero block: the illustration set into a dial, the temperature
/// rolling to its value, the condition and today's range.
class CurrentConditions extends StatelessWidget {
  const CurrentConditions({super.key, required this.weather});

  final Weather weather;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final high = UnitFormatter.temperature(weather.highTemperature);
    final low = UnitFormatter.temperature(weather.lowTemperature);

    return Semantics(
      container: true,
      label:
          '${UnitFormatter.temperature(weather.temperature)}, '
          '${weather.condition.label}, ${AppStrings.highLow(high, low)}',
      child: ExcludeSemantics(
        child: Column(
          children: [
            StaggeredEntrance(
              index: 0,
              child: _Dial(
                isNight: !weather.isDay,
                child: SmoothSwitcher(
                  duration: const Duration(milliseconds: 600),
                  child: ConditionIllustration(
                    key: ValueKey((weather.condition, weather.isDay)),
                    condition: weather.condition,
                    isDay: weather.isDay,
                    size: 168,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            StaggeredEntrance(
              index: 1,
              child: CountingText(
                value: weather.temperature,
                format: UnitFormatter.temperature,
                style: AppTextStyles.temperatureHero,
              ),
            ),
            const SizedBox(height: 6),
            StaggeredEntrance(
              index: 2,
              child: SmoothSwitcher(
                child: Text(
                  weather.condition.label,
                  key: ValueKey(weather.condition),
                  style: AppTextStyles.conditionLabel,
                ),
              ),
            ),
            const SizedBox(height: 14),
            StaggeredEntrance(
              index: 3,
              child: TactileSurface(
                depth: -0.8,
                radius: 20,
                distance: 4,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                child: Text(
                  AppStrings.highLow(high, low),
                  style: AppTextStyles.bodyStrong.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A raised disc with a round well carved into it.
///
/// At night the well fills with a deep night sky, so the moon and stars
/// stay visible even on the light surface.
class _Dial extends StatelessWidget {
  const _Dial({required this.isNight, required this.child});

  final bool isNight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final nightWell = Color.lerp(
      palette.base,
      AppColors.nightSky,
      palette.isDark ? 0.45 : 0.9,
    );

    return TactileSurface(
      circle: true,
      distance: 14,
      child: SizedBox.square(
        dimension: 236,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: TactileSurface(
            circle: true,
            depth: -0.7,
            distance: 8,
            color: isNight ? nightWell : null,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
