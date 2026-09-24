import 'package:flutter/material.dart';
import 'package:nimbus/core/layout/breakpoints.dart';
import 'package:nimbus/core/widgets/motion/staggered_entrance.dart';
import 'package:nimbus/features/weather/domain/entities/weather_report.dart';
import 'package:nimbus/features/weather/presentation/widgets/current_conditions.dart';
import 'package:nimbus/features/weather/presentation/widgets/daily_forecast_card.dart';
import 'package:nimbus/features/weather/presentation/widgets/hourly_forecast_card.dart';
import 'package:nimbus/features/weather/presentation/widgets/weather_details_grid.dart';

/// The success view: everything we know about the weather at a place.
///
/// One column on phones. From [Breakpoints.twoPane] (phones on their side,
/// foldables, tablets) the hero sits on the left and the forecasts and
/// details on the right, so nothing is stretched or pushed off screen.
///
/// Parts cascade in when a place first appears. Refreshing doesn't replay
/// the cascade; values roll and cross-fade in place.
class WeatherContent extends StatelessWidget {
  const WeatherContent({super.key, required this.report});

  final WeatherReport report;

  static const _gap = 22.0;

  @override
  Widget build(BuildContext context) {
    final weather = report.weather;
    final hero = CurrentConditions(weather: weather);
    // Continue the cascade after the hero's four parts.
    List<Widget> details({required int firstIndex}) => [
      StaggeredEntrance(
        index: firstIndex,
        child: HourlyForecastCard(hours: weather.hourly),
      ),
      const SizedBox(height: _gap),
      StaggeredEntrance(
        index: firstIndex + 1,
        child: DailyForecastCard(
          days: weather.daily,
          currentTemperature: weather.temperature,
        ),
      ),
      const SizedBox(height: _gap),
      WeatherDetailsGrid(weather: weather, firstEntranceIndex: firstIndex + 2),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < Breakpoints.twoPane) {
          return Column(
            children: [
              const SizedBox(height: 16),
              hero,
              const SizedBox(height: 32),
              ...details(firstIndex: 4),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: hero,
              ),
            ),
            const SizedBox(width: 28),
            Expanded(flex: 6, child: Column(children: details(firstIndex: 2))),
          ],
        );
      },
    );
  }
}
