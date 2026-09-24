import 'package:flutter/material.dart';
import 'package:nimbus/core/constants/app_strings.dart';
import 'package:nimbus/core/utils/date_formatter.dart';
import 'package:nimbus/core/utils/unit_formatter.dart';
import 'package:nimbus/features/weather/domain/entities/weather.dart';
import 'package:nimbus/features/weather/presentation/widgets/detail_tile.dart';

/// All secondary measurements as a two-column grid of [DetailTile]s.
class WeatherDetailsGrid extends StatelessWidget {
  const WeatherDetailsGrid({super.key, required this.weather});

  final Weather weather;

  static const _spacing = 12.0;

  List<DetailTile> _tiles() {
    final sunrise = weather.sunrise;
    final sunset = weather.sunset;
    return [
      DetailTile(
        icon: Icons.thermostat_rounded,
        label: AppStrings.feelsLike,
        value: UnitFormatter.temperature(weather.feelsLike),
      ),
      DetailTile(
        icon: Icons.water_drop_rounded,
        label: AppStrings.humidity,
        value: UnitFormatter.percent(weather.humidity),
      ),
      DetailTile(
        icon: Icons.air_rounded,
        label: AppStrings.wind,
        value: UnitFormatter.windSpeed(weather.windSpeed),
      ),
      DetailTile(
        icon: Icons.umbrella_rounded,
        label: AppStrings.precipitation,
        value: UnitFormatter.precipitation(weather.precipitation),
      ),
      DetailTile(
        icon: Icons.wb_sunny_rounded,
        label: AppStrings.uvIndex,
        value: UnitFormatter.uvIndex(weather.uvIndex),
        caption: UnitFormatter.uvLevel(weather.uvIndex),
      ),
      DetailTile(
        icon: Icons.speed_rounded,
        label: AppStrings.pressure,
        value: UnitFormatter.pressure(weather.pressure),
      ),
      DetailTile(
        icon: Icons.wb_twilight_rounded,
        label: AppStrings.sunrise,
        value: sunrise == null
            ? AppStrings.notAvailable
            : DateFormatter.time(sunrise),
      ),
      DetailTile(
        icon: Icons.nights_stay_rounded,
        label: AppStrings.sunset,
        value: sunset == null
            ? AppStrings.notAvailable
            : DateFormatter.time(sunset),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tiles = _tiles();
    return Column(
      children: [
        for (var i = 0; i < tiles.length; i += 2)
          Padding(
            padding: EdgeInsets.only(
              bottom: i + 2 < tiles.length ? _spacing : 0,
            ),
            // Keeps both tiles in a row the same height, even when only one
            // has a caption.
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: tiles[i]),
                  const SizedBox(width: _spacing),
                  Expanded(
                    child: i + 1 < tiles.length
                        ? tiles[i + 1]
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
