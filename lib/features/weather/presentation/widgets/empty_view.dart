import 'package:flutter/material.dart';
import 'package:nimbus/core/l10n/l10n.dart';
import 'package:nimbus/core/widgets/status_message.dart';
import 'package:nimbus/core/widgets/tactile/tactile_button.dart';
import 'package:nimbus/core/widgets/tactile/tactile_surface.dart';
import 'package:nimbus/features/weather/domain/entities/weather_condition.dart';
import 'package:nimbus/features/weather/presentation/widgets/condition_illustration.dart';

/// First launch: no city chosen and nothing cached yet.
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.onSearch,
    required this.onUseLocation,
  });

  final VoidCallback onSearch;
  final VoidCallback onUseLocation;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return StatusMessage(
      visual: const TactileSurface(
        circle: true,
        distance: 12,
        child: SizedBox.square(
          dimension: 190,
          child: Center(
            child: ConditionIllustration(
              condition: WeatherCondition.partlyCloudy,
              isDay: true,
              size: 150,
            ),
          ),
        ),
      ),
      title: l10n.welcomeTitle,
      message: l10n.welcomeMessage,
      actions: [
        TactileButton(
          label: l10n.searchCity,
          icon: Icons.search_rounded,
          onPressed: onSearch,
          isPrimary: true,
        ),
        TactileButton(
          label: l10n.useMyLocation,
          icon: Icons.my_location_rounded,
          onPressed: onUseLocation,
        ),
      ],
    );
  }
}
