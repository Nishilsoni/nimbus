import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nimbus/core/l10n/l10n.dart';
import 'package:nimbus/core/theme/app_text_styles.dart';
import 'package:nimbus/core/theme/surface_palette.dart';
import 'package:nimbus/core/utils/date_formatter.dart';
import 'package:nimbus/core/utils/unit_formatter.dart';
import 'package:nimbus/core/widgets/tactile/tactile_surface.dart';
import 'package:nimbus/core/widgets/unit_scope.dart';
import 'package:nimbus/features/weather/domain/entities/forecast.dart';
import 'package:nimbus/features/weather/presentation/utils/condition_visuals.dart';
import 'package:nimbus/features/weather/presentation/widgets/card_title.dart';
import 'package:nimbus/features/weather/presentation/widgets/condition_icon.dart';

/// The next 24 hours as a smooth temperature curve that draws itself in,
/// with each hour's condition and chance of rain. Scrolls sideways.
class HourlyForecastCard extends StatelessWidget {
  const HourlyForecastCard({super.key, required this.hours});

  final List<HourlyForecast> hours;

  /// Only chances worth noticing are shown, to keep the row calm.
  static const _minimumChanceShown = 20;

  @override
  Widget build(BuildContext context) {
    if (hours.isEmpty) return const SizedBox.shrink();

    final l10n = context.l10n;
    final palette = context.palette;
    final unit = UnitScope.of(context);
    final textScaler = MediaQuery.textScalerOf(context);
    final layout = _ChartLayout(textScaler);
    final temperatures = [
      for (final hour in hours)
        UnitFormatter.temperature(hour.temperature, unit),
    ];

    return TactileSurface(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardTitle(
            icon: Icons.schedule_rounded,
            text: l10n.hourlyForecastTitle,
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: layout.height,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                width: layout.columnWidth * hours.length,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: MediaQuery.disableAnimationsOf(context)
                            ? Duration.zero
                            : const Duration(milliseconds: 900),
                        curve: Curves.easeOutCubic,
                        builder: (context, progress, _) => CustomPaint(
                          painter: _TemperatureCurvePainter(
                            temperatures: [
                              for (final hour in hours) hour.temperature,
                            ],
                            labels: temperatures,
                            layout: layout,
                            progress: progress,
                            palette: palette,
                            labelStyle: AppTextStyles.caption.copyWith(
                              color: palette.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                            textScaler: textScaler,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        for (final (index, hour) in hours.indexed)
                          _HourColumn(
                            label: index == 0
                                ? l10n.now
                                : DateFormatter.hour(
                                    hour.time,
                                    l10n.localeName,
                                  ),
                            hour: hour,
                            temperature: temperatures[index],
                            layout: layout,
                            showsChance:
                                (hour.precipitationChance ?? 0) >=
                                _minimumChanceShown,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Vertical positions shared by the columns and the curve, scaled with the
/// user's text size so labels never collide.
class _ChartLayout {
  _ChartLayout(TextScaler scaler)
    : columnWidth = scaler.scale(58).clamp(58.0, 100.0),
      timeHeight = scaler.scale(18),
      labelRoom = scaler.scale(22),
      chanceHeight = scaler.scale(17);

  final double columnWidth;
  final double timeHeight;

  /// Space above the highest point for its temperature label.
  final double labelRoom;
  final double chanceHeight;

  static const curveBand = 52.0;
  static const iconSize = 28.0;

  double get curveTop => timeHeight + labelRoom;
  double get curveBottom => curveTop + curveBand;
  double get iconTop => curveBottom + 14;
  double get height => iconTop + iconSize + 4 + chanceHeight + 2;
}

class _HourColumn extends StatelessWidget {
  const _HourColumn({
    required this.label,
    required this.hour,
    required this.temperature,
    required this.layout,
    required this.showsChance,
  });

  final String label;
  final HourlyForecast hour;
  final String temperature;
  final _ChartLayout layout;
  final bool showsChance;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final chance = '${hour.precipitationChance ?? 0}%';

    return Semantics(
      label: [
        label,
        temperature,
        hour.condition.label(l10n),
        if (showsChance) chance,
      ].join(', '),
      child: ExcludeSemantics(
        child: SizedBox(
          width: layout.columnWidth,
          child: Column(
            children: [
              SizedBox(
                height: layout.timeHeight,
                child: Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: palette.textSecondary,
                  ),
                  maxLines: 1,
                ),
              ),
              SizedBox(height: layout.iconTop - layout.timeHeight),
              ConditionIcon(condition: hour.condition, isDay: hour.isDay),
              const SizedBox(height: 4),
              SizedBox(
                height: layout.chanceHeight,
                child: showsChance
                    ? Text(
                        chance,
                        style: AppTextStyles.caption.copyWith(
                          color: palette.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Draws the temperatures as a smooth curve with a soft fill beneath,
/// revealed from left to right as [progress] goes from 0 to 1.
class _TemperatureCurvePainter extends CustomPainter {
  _TemperatureCurvePainter({
    required this.temperatures,
    required this.labels,
    required this.layout,
    required this.progress,
    required this.palette,
    required this.labelStyle,
    required this.textScaler,
  });

  final List<double> temperatures;
  final List<String> labels;
  final _ChartLayout layout;
  final double progress;
  final SurfacePalette palette;
  final TextStyle labelStyle;
  final TextScaler textScaler;

  @override
  void paint(Canvas canvas, Size size) {
    final points = _points();
    if (points.isEmpty) return;

    canvas
      ..save()
      ..clipRect(Rect.fromLTWH(0, 0, size.width * progress, size.height));

    final curve = _smoothPath(points);
    final fill = Path.from(curve)
      ..lineTo(points.last.dx, layout.curveBottom + 10)
      ..lineTo(points.first.dx, layout.curveBottom + 10)
      ..close();
    canvas
      ..drawPath(
        fill,
        Paint()
          ..shader =
              LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  palette.accent.withValues(alpha: 0.28),
                  palette.accent.withValues(alpha: 0),
                ],
              ).createShader(
                Rect.fromLTRB(
                  0,
                  layout.curveTop,
                  size.width,
                  layout.curveBottom + 10,
                ),
              ),
      )
      ..drawPath(
        curve,
        Paint()
          ..color = palette.accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );

    for (final (index, point) in points.indexed) {
      final isNow = index == 0;
      canvas
        ..drawCircle(point, isNow ? 6 : 4, Paint()..color = palette.base)
        ..drawCircle(
          point,
          isNow ? 6 : 4,
          Paint()
            ..color = palette.accent
            ..style = PaintingStyle.stroke
            ..strokeWidth = isNow ? 3 : 2,
        );

      final label = TextPainter(
        text: TextSpan(text: labels[index], style: labelStyle),
        textDirection: TextDirection.ltr,
        textScaler: textScaler,
      )..layout();
      label.paint(canvas, point - Offset(label.width / 2, label.height + 8));
      label.dispose();
    }
    canvas.restore();
  }

  List<Offset> _points() {
    final low = temperatures.reduce((a, b) => a < b ? a : b);
    final high = temperatures.reduce((a, b) => a > b ? a : b);
    final span = high - low;
    return [
      for (final (index, temperature) in temperatures.indexed)
        Offset(
          (index + 0.5) * layout.columnWidth,
          // A flat day draws a flat line through the middle of the band.
          span == 0
              ? layout.curveTop + _ChartLayout.curveBand / 2
              : layout.curveBottom -
                    (temperature - low) / span * _ChartLayout.curveBand,
        ),
    ];
  }

  /// A Catmull-Rom spline through every point, converted to cubic Béziers,
  /// so the curve passes through each hour without sharp corners.
  Path _smoothPath(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final previous = points[i == 0 ? 0 : i - 1];
      final current = points[i];
      final next = points[i + 1];
      final afterNext = points[i + 2 < points.length ? i + 2 : i + 1];
      final control1 = current + (next - previous) / 6;
      final control2 = next - (afterNext - current) / 6;
      path.cubicTo(
        control1.dx,
        control1.dy,
        control2.dx,
        control2.dy,
        next.dx,
        next.dy,
      );
    }
    return path;
  }

  @override
  bool shouldRepaint(_TemperatureCurvePainter old) =>
      old.progress != progress ||
      old.palette != palette ||
      old.labelStyle != labelStyle ||
      old.textScaler != textScaler ||
      !listEquals(old.temperatures, temperatures) ||
      !listEquals(old.labels, labels);
}
