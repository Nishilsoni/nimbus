import 'package:flutter/material.dart';
import 'package:nimbus/core/constants/app_strings.dart';
import 'package:nimbus/core/theme/app_text_styles.dart';
import 'package:nimbus/core/utils/unit_formatter.dart';
import 'package:nimbus/features/weather/domain/entities/weather.dart';
import 'package:nimbus/features/weather/presentation/utils/condition_visuals.dart';
import 'package:nimbus/features/weather/presentation/widgets/condition_illustration.dart';

/// The hero block: illustration, temperature, condition, and today's range.
class CurrentConditions extends StatelessWidget {
  const CurrentConditions({super.key, required this.weather});

  final Weather weather;

  @override
  Widget build(BuildContext context) {
    final high = UnitFormatter.temperature(weather.highTemperature);
    final low = UnitFormatter.temperature(weather.lowTemperature);

    return Semantics(
      container: true,
      label:
          '${UnitFormatter.temperature(weather.temperature)}, '
          '${weather.condition.label}',
      child: Column(
        children: [
          ConditionIllustration(
            condition: weather.condition,
            isDay: weather.isDay,
          ),
          ExcludeSemantics(
            child: Text(
              UnitFormatter.temperature(weather.temperature),
              style: AppTextStyles.temperatureHero,
            ),
          ),
          const SizedBox(height: 4),
          ExcludeSemantics(
            child: Text(
              weather.condition.label,
              style: AppTextStyles.conditionLabel,
            ),
          ),
          const SizedBox(height: 6),
          Text(AppStrings.highLow(high, low), style: AppTextStyles.body),
        ],
      ),
    );
  }
}
