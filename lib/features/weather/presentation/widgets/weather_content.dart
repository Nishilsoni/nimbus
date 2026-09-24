import 'package:flutter/material.dart';
import 'package:nimbus/features/weather/domain/entities/weather_report.dart';
import 'package:nimbus/features/weather/presentation/widgets/current_conditions.dart';
import 'package:nimbus/features/weather/presentation/widgets/weather_details_grid.dart';

/// The success view: everything we know about the weather right now.
///
/// Its parts cascade in when a city first appears. Refreshing the same city
/// doesn't replay the cascade; values roll and cross-fade in place.
class WeatherContent extends StatelessWidget {
  const WeatherContent({super.key, required this.report});

  final WeatherReport report;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        CurrentConditions(weather: report.weather),
        const SizedBox(height: 36),
        // Continues the cascade after the hero's four parts.
        WeatherDetailsGrid(weather: report.weather, firstEntranceIndex: 4),
      ],
    );
  }
}
