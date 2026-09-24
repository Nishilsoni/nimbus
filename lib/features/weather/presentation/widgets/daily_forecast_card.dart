import 'package:flutter/material.dart';
import 'package:nimbus/core/l10n/l10n.dart';
import 'package:nimbus/core/theme/app_text_styles.dart';
import 'package:nimbus/core/theme/surface_palette.dart';
import 'package:nimbus/core/utils/date_formatter.dart';
import 'package:nimbus/core/utils/unit_formatter.dart';
import 'package:nimbus/core/widgets/motion/staggered_entrance.dart';
import 'package:nimbus/core/widgets/tactile/tactile_surface.dart';
import 'package:nimbus/core/widgets/unit_scope.dart';
import 'package:nimbus/features/weather/domain/entities/forecast.dart';
import 'package:nimbus/features/weather/presentation/utils/condition_visuals.dart';
import 'package:nimbus/features/weather/presentation/widgets/card_title.dart';
import 'package:nimbus/features/weather/presentation/widgets/condition_icon.dart';

/// Seven days, each with its low-to-high range drawn on a bar that shares
/// one scale across the week, so warmer and cooler days stand out.
class DailyForecastCard extends StatelessWidget {
  const DailyForecastCard({
    super.key,
    required this.days,
    required this.currentTemperature,
  });

  final List<DailyForecast> days;

  /// Marked on today's bar.
  final double currentTemperature;

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) return const SizedBox.shrink();

    final weekLow = days.map((d) => d.low).reduce((a, b) => a < b ? a : b);
    final weekHigh = days.map((d) => d.high).reduce((a, b) => a > b ? a : b);

    return TactileSurface(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          CardTitle(
            icon: Icons.calendar_month_rounded,
            text: context.l10n.dailyForecastTitle,
          ),
          const SizedBox(height: 4),
          for (final (index, day) in days.indexed)
            StaggeredEntrance(
              index: index,
              step: const Duration(milliseconds: 45),
              child: _DayRow(
                day: day,
                isToday: index == 0,
                weekLow: weekLow,
                weekHigh: weekHigh,
                currentTemperature: index == 0 ? currentTemperature : null,
              ),
            ),
        ],
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.day,
    required this.isToday,
    required this.weekLow,
    required this.weekHigh,
    required this.currentTemperature,
  });

  final DailyForecast day;
  final bool isToday;
  final double weekLow;
  final double weekHigh;
  final double? currentTemperature;

  static const _minimumChanceShown = 20;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final unit = UnitScope.of(context);
    final scaler = MediaQuery.textScalerOf(context);
    final numberWidth = scaler.scale(38);
    final chance = day.precipitationChance ?? 0;
    final dayName = isToday
        ? l10n.today
        : DateFormatter.weekday(day.date, l10n.localeName);
    final low = UnitFormatter.temperature(day.low, unit);
    final high = UnitFormatter.temperature(day.high, unit);

    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            SizedBox(
              width: scaler.scale(62),
              child: Text(
                dayName,
                style: AppTextStyles.bodyStrong,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Semantics(
              label: day.condition.label(l10n),
              child: ConditionIcon(condition: day.condition, isDay: true),
            ),
            SizedBox(
              width: scaler.scale(42),
              child: chance >= _minimumChanceShown
                  ? Text(
                      '$chance%',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(
                        color: palette.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : null,
            ),
            SizedBox(
              width: numberWidth,
              child: Text(
                low,
                textAlign: TextAlign.right,
                style: AppTextStyles.bodyStrong.copyWith(
                  color: palette.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _RangeBar(
                weekLow: weekLow,
                weekHigh: weekHigh,
                low: day.low,
                high: day.high,
                current: currentTemperature,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: numberWidth,
              child: Text(high, style: AppTextStyles.bodyStrong),
            ),
          ],
        ),
      ),
    );
  }
}

/// A groove spanning the week's range with this day's range filled in,
/// coloured from cool to warm. The fill grows into place.
class _RangeBar extends StatelessWidget {
  const _RangeBar({
    required this.weekLow,
    required this.weekHigh,
    required this.low,
    required this.high,
    this.current,
  });

  final double weekLow;
  final double weekHigh;
  final double low;
  final double high;
  final double? current;

  static const _height = 8.0;

  @override
  Widget build(BuildContext context) {
    final span = weekHigh - weekLow;
    double position(double value) =>
        span == 0 ? 0.5 : ((value - weekLow) / span).clamp(0.0, 1.0);
    final start = position(low);
    final end = position(high);
    final current = this.current;

    return SizedBox(
      height: _height,
      child: TactileSurface(
        depth: -1,
        radius: _height / 2,
        distance: 2,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, grow, _) => CustomPaint(
            painter: _RangePainter(
              start: start,
              // Grows out from the day's low end.
              end: start + (end - start) * grow,
              lowColor: _temperatureColor(low),
              highColor: _temperatureColor(high),
              marker: current == null ? null : position(current),
              markerColor: context.palette.textPrimary,
              markerOpacity: grow,
            ),
          ),
        ),
      ),
    );
  }

  /// Icy blue through teal and yellow to orange and red, by °C.
  static Color _temperatureColor(double celsius) {
    const stops = [
      (-10.0, Color(0xFF7FB2FF)),
      (5.0, Color(0xFF63C7E6)),
      (15.0, Color(0xFF6ED3A8)),
      (22.0, Color(0xFFF2C94C)),
      (30.0, Color(0xFFF59E42)),
      (40.0, Color(0xFFEF5B4C)),
    ];
    if (celsius <= stops.first.$1) return stops.first.$2;
    for (var i = 1; i < stops.length; i++) {
      final (upper, upperColor) = stops[i];
      if (celsius <= upper) {
        final (lower, lowerColor) = stops[i - 1];
        return Color.lerp(
          lowerColor,
          upperColor,
          (celsius - lower) / (upper - lower),
        )!;
      }
    }
    return stops.last.$2;
  }
}

class _RangePainter extends CustomPainter {
  const _RangePainter({
    required this.start,
    required this.end,
    required this.lowColor,
    required this.highColor,
    required this.marker,
    required this.markerColor,
    required this.markerOpacity,
  });

  final double start;
  final double end;
  final Color lowColor;
  final Color highColor;
  final double? marker;
  final Color markerColor;
  final double markerOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(size.height / 2);
    // Always at least a dot wide, even when low and high are equal.
    final left = start * size.width;
    final right = (end * size.width).clamp(left + size.height, size.width);
    final fill = Rect.fromLTRB(left, 0, right, size.height);
    canvas.drawRRect(
      RRect.fromRectAndRadius(fill, radius),
      Paint()
        ..shader = LinearGradient(
          colors: [lowColor, highColor],
        ).createShader(fill),
    );

    final marker = this.marker;
    if (marker != null) {
      final centre = Offset(marker * size.width, size.height / 2);
      canvas
        ..drawCircle(
          centre,
          size.height * 0.75,
          Paint()..color = Colors.white.withValues(alpha: markerOpacity),
        )
        ..drawCircle(
          centre,
          size.height * 0.75,
          Paint()
            ..color = markerColor.withValues(alpha: 0.35 * markerOpacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
    }
  }

  @override
  bool shouldRepaint(_RangePainter old) =>
      old.start != start ||
      old.end != end ||
      old.lowColor != lowColor ||
      old.highColor != highColor ||
      old.marker != marker ||
      old.markerColor != markerColor ||
      old.markerOpacity != markerOpacity;
}
