import 'package:flutter/material.dart';
import 'package:nimbus/features/weather/domain/entities/weather_report.dart';
import 'package:nimbus/features/weather/presentation/widgets/current_conditions.dart';
import 'package:nimbus/features/weather/presentation/widgets/weather_details_grid.dart';

/// The success view: everything we know about the weather right now.
class WeatherContent extends StatelessWidget {
  const WeatherContent({super.key, required this.report});

  final WeatherReport report;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CurrentConditions(weather: report.weather),
        const SizedBox(height: 32),
        WeatherDetailsGrid(weather: report.weather),
      ],
    );
  }
}
