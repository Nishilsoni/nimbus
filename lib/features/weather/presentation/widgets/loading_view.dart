import 'package:flutter/material.dart';
import 'package:nimbus/core/constants/app_strings.dart';
import 'package:nimbus/core/widgets/skeleton.dart';

/// A skeleton with the same layout as [WeatherContent], so the real data
/// fades in where the placeholders were instead of jumping into place.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppStrings.loadingWeather,
      child: const SkeletonPulse(
        child: Column(
          children: [
            SizedBox(height: 20),
            SkeletonBox(width: 160, height: 160, radius: 80),
            SizedBox(height: 28),
            SkeletonBox(width: 150, height: 84, radius: 20),
            SizedBox(height: 14),
            SkeletonBox(width: 120, height: 22),
            SizedBox(height: 10),
            SkeletonBox(width: 110, height: 16),
            SizedBox(height: 40),
            _SkeletonRow(),
            SizedBox(height: 12),
            _SkeletonRow(),
            SizedBox(height: 12),
            _SkeletonRow(),
          ],
        ),
      ),
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: SkeletonBox(height: 92, radius: 20)),
        SizedBox(width: 12),
        Expanded(child: SkeletonBox(height: 92, radius: 20)),
      ],
    );
  }
}
