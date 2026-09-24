import 'package:flutter/material.dart';
import 'package:nimbus/core/l10n/l10n.dart';
import 'package:nimbus/core/theme/app_colors.dart';
import 'package:nimbus/core/theme/app_text_styles.dart';
import 'package:nimbus/core/theme/surface_palette.dart';
import 'package:nimbus/core/utils/unit_formatter.dart';
import 'package:nimbus/core/widgets/motion/counting_text.dart';
import 'package:nimbus/core/widgets/motion/smooth_switcher.dart';
import 'package:nimbus/core/widgets/motion/staggered_entrance.dart';
import 'package:nimbus/core/widgets/tactile/tactile_surface.dart';
import 'package:nimbus/core/widgets/unit_scope.dart';
import 'package:nimbus/features/weather/domain/entities/weather.dart';
import 'package:nimbus/features/weather/presentation/utils/condition_visuals.dart';
import 'package:nimbus/features/weather/presentation/widgets/condition_illustration.dart';

/// The hero block: the illustration set into a dial, the temperature
/// rolling to its value, the condition and today's range.
///
/// Sizes follow the space available, so it fits a small phone, a phone on
/// its side and a tablet alike.
class CurrentConditions extends StatelessWidget {
  const CurrentConditions({super.key, required this.weather});

  final Weather weather;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final unit = UnitScope.of(context);
    final high = UnitFormatter.temperature(weather.highTemperature, unit);
    final low = UnitFormatter.temperature(weather.lowTemperature, unit);
    final screenHeight = MediaQuery.sizeOf(context).height;

    return LayoutBuilder(
      builder: (context, constraints) {
        // As wide as the space allows, but never so tall that a landscape
        // phone can't see the temperature below it.
        final dialSize = [
          constraints.maxWidth * 0.64,
          screenHeight * 0.42,
          280.0,
        ].reduce((a, b) => a < b ? a : b).clamp(150.0, 280.0);
        final heroStyle = AppTextStyles.temperatureHero.copyWith(
          fontSize: (dialSize * 0.42).clamp(64.0, 110.0),
        );

        return Semantics(
          container: true,
          label:
              '${UnitFormatter.temperature(weather.temperature, unit)}, '
              '${weather.condition.label(l10n)}, ${l10n.highLow(high, low)}',
          child: ExcludeSemantics(
            child: Column(
              children: [
                StaggeredEntrance(
                  index: 0,
                  child: _Dial(
                    size: dialSize,
                    isNight: !weather.isDay,
                    child: SmoothSwitcher(
                      duration: const Duration(milliseconds: 600),
                      child: ConditionIllustration(
                        key: ValueKey((weather.condition, weather.isDay)),
                        condition: weather.condition,
                        isDay: weather.isDay,
                        size: dialSize * 0.71,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                StaggeredEntrance(
                  index: 1,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: CountingText(
                      value: weather.temperature,
                      format: (celsius) =>
                          UnitFormatter.temperature(celsius, unit),
                      style: heroStyle,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                StaggeredEntrance(
                  index: 2,
                  child: SmoothSwitcher(
                    child: Text(
                      weather.condition.label(l10n),
                      key: ValueKey(weather.condition),
                      style: AppTextStyles.conditionLabel,
                      textAlign: TextAlign.center,
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
                      l10n.highLow(high, low),
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
      },
    );
  }
}

/// A raised disc with a round well carved into it.
///
/// At night the well fills with a deep night sky, so the moon and stars
/// stay visible even on the light surface.
class _Dial extends StatelessWidget {
  const _Dial({required this.size, required this.isNight, required this.child});

  final double size;
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
      distance: size / 17,
      child: SizedBox.square(
        dimension: size,
        child: Padding(
          padding: EdgeInsets.all(size * 0.076),
          child: TactileSurface(
            circle: true,
            depth: -0.7,
            distance: size / 30,
            color: isNight ? nightWell : null,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
