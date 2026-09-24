import 'package:flutter/material.dart';
import 'package:nimbus/core/constants/app_strings.dart';
import 'package:nimbus/core/widgets/status_message.dart';
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
    return StatusMessage(
      visual: const ConditionIllustration(
        condition: WeatherCondition.partlyCloudy,
        isDay: true,
        size: 170,
      ),
      title: AppStrings.welcomeTitle,
      message: AppStrings.welcomeMessage,
      actions: [
        FilledButton.icon(
          onPressed: onSearch,
          icon: const Icon(Icons.search_rounded),
          label: const Text(AppStrings.searchCity),
        ),
        OutlinedButton.icon(
          onPressed: onUseLocation,
          icon: const Icon(Icons.my_location_rounded),
          label: const Text(AppStrings.useMyLocation),
        ),
      ],
    );
  }
}
