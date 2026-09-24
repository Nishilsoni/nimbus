import 'package:flutter/material.dart';
import 'package:nimbus/core/constants/app_strings.dart';
import 'package:nimbus/core/widgets/skeleton.dart';
import 'package:nimbus/core/widgets/tactile/tactile_surface.dart';

/// A skeleton with the same layout as [WeatherContent], so the real data
/// settles in where the placeholders were instead of jumping into place.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppStrings.loadingWeather,
      child: const SkeletonPulse(
        child: Column(
          children: [
            SizedBox(height: 16),
            TactileSurface(
              circle: true,
              distance: 14,
              child: SizedBox.square(
                dimension: 236,
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: SkeletonBox(height: 200, circle: true),
                ),
              ),
            ),
            SizedBox(height: 32),
            SkeletonBox(width: 150, height: 80, radius: 24),
            SizedBox(height: 16),
            SkeletonBox(width: 120, height: 22),
            SizedBox(height: 16),
            SkeletonBox(width: 150, height: 36, radius: 20),
            SizedBox(height: 40),
            _SkeletonRow(),
            SizedBox(height: 18),
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
        Expanded(child: SkeletonBox(height: 104, radius: 24)),
        SizedBox(width: 18),
        Expanded(child: SkeletonBox(height: 104, radius: 24)),
      ],
    );
  }
}
