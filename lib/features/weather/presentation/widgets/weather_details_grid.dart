import 'package:flutter/material.dart';
import 'package:nimbus/core/l10n/l10n.dart';
import 'package:nimbus/core/layout/breakpoints.dart';
import 'package:nimbus/core/utils/date_formatter.dart';
import 'package:nimbus/core/utils/unit_formatter.dart';
import 'package:nimbus/core/widgets/motion/staggered_entrance.dart';
import 'package:nimbus/core/widgets/unit_scope.dart';
import 'package:nimbus/features/weather/domain/entities/weather.dart';
import 'package:nimbus/features/weather/presentation/widgets/detail_tile.dart';

/// All secondary measurements as a grid of [DetailTile]s: two per row on
/// phones, four when there's room.
class WeatherDetailsGrid extends StatelessWidget {
  const WeatherDetailsGrid({
    super.key,
    required this.weather,
    this.firstEntranceIndex = 0,
  });

  final Weather weather;

  /// Where the rows join the screen's entrance cascade.
  final int firstEntranceIndex;

  /// Soft shadows need room to breathe between cards.
  static const _spacing = 18.0;

  List<DetailTile> _tiles(BuildContext context) {
    final l10n = context.l10n;
    final unit = UnitScope.of(context);
    String time(DateTime? value) => value == null
        ? l10n.notAvailable
        : DateFormatter.time(value, l10n.localeName);

    return [
      DetailTile(
        icon: Icons.thermostat_rounded,
        label: l10n.feelsLike,
        value: UnitFormatter.temperature(weather.feelsLike, unit),
      ),
      DetailTile(
        icon: Icons.water_drop_rounded,
        label: l10n.humidity,
        value: UnitFormatter.percent(weather.humidity),
      ),
      DetailTile(
        icon: Icons.air_rounded,
        label: l10n.wind,
        value: UnitFormatter.windSpeed(weather.windSpeed),
      ),
      DetailTile(
        icon: Icons.umbrella_rounded,
        label: l10n.precipitation,
        value: UnitFormatter.precipitation(weather.precipitation),
      ),
      DetailTile(
        icon: Icons.wb_sunny_rounded,
        label: l10n.uvIndex,
        value: UnitFormatter.uvIndex(weather.uvIndex, l10n),
        caption: UnitFormatter.uvLevel(weather.uvIndex, l10n),
      ),
      DetailTile(
        icon: Icons.speed_rounded,
        label: l10n.pressure,
        value: UnitFormatter.pressure(weather.pressure),
      ),
      DetailTile(
        icon: Icons.wb_twilight_rounded,
        label: l10n.sunrise,
        value: time(weather.sunrise),
      ),
      DetailTile(
        icon: Icons.nights_stay_rounded,
        label: l10n.sunset,
        value: time(weather.sunset),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tiles = _tiles(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final perRow = constraints.maxWidth >= Breakpoints.wideGrid ? 4 : 2;
        final rows = [
          for (var i = 0; i < tiles.length; i += perRow)
            tiles.sublist(i, (i + perRow).clamp(0, tiles.length)),
        ];

        return Column(
          children: [
            for (final (index, row) in rows.indexed)
              Padding(
                padding: EdgeInsets.only(
                  bottom: index < rows.length - 1 ? _spacing : 0,
                ),
                child: StaggeredEntrance(
                  index: firstEntranceIndex + index,
                  // Keeps the tiles in a row the same height, even when
                  // only one has a caption.
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < perRow; i++) ...[
                          if (i > 0) const SizedBox(width: _spacing),
                          Expanded(
                            child: i < row.length
                                ? row[i]
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
