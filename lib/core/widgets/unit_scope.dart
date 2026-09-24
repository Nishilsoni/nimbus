import 'package:flutter/widgets.dart';
import 'package:nimbus/core/utils/temperature_unit.dart';

/// Makes the chosen [TemperatureUnit] available to every widget below it,
/// so widgets that format temperatures don't need to know where the setting
/// comes from.
class UnitScope extends InheritedWidget {
  const UnitScope({super.key, required this.unit, required super.child});

  final TemperatureUnit unit;

  /// Celsius when no scope is present (e.g. in isolated widget tests).
  static TemperatureUnit of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<UnitScope>()?.unit ??
      TemperatureUnit.celsius;

  @override
  bool updateShouldNotify(UnitScope oldWidget) => oldWidget.unit != unit;
}
