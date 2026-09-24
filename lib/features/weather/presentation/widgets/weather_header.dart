import 'package:flutter/material.dart';
import 'package:nimbus/core/constants/app_strings.dart';
import 'package:nimbus/core/theme/app_text_styles.dart';
import 'package:nimbus/core/theme/surface_palette.dart';
import 'package:nimbus/core/widgets/motion/smooth_switcher.dart';
import 'package:nimbus/core/widgets/relative_time_text.dart';
import 'package:nimbus/core/widgets/tactile/tactile_button.dart';
import 'package:nimbus/features/appearance/presentation/widgets/appearance_button.dart';
import 'package:nimbus/features/weather/domain/entities/city.dart';
import 'package:nimbus/features/weather/presentation/widgets/search_hero.dart';

/// City name, freshness, and the screen's actions.
class WeatherHeader extends StatelessWidget {
  const WeatherHeader({
    super.key,
    required this.city,
    required this.fetchedAt,
    required this.isRefreshing,
    required this.onSearch,
    required this.onUseLocation,
    required this.onRefresh,
  });

  final City? city;
  final DateTime? fetchedAt;
  final bool isRefreshing;
  final VoidCallback onSearch;
  final VoidCallback onUseLocation;

  /// `null` hides the refresh button (nothing to refresh yet).
  final VoidCallback? onRefresh;

  // Compact enough that four buttons leave room for the city name.
  static const _buttonSize = 42.0;
  static const _buttonGap = 12.0;

  @override
  Widget build(BuildContext context) {
    final onRefresh = this.onRefresh;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 18, 8),
      child: Row(
        children: [
          Expanded(
            child: _Title(city: city, fetchedAt: fetchedAt),
          ),
          const SizedBox(width: 10),
          const AppearanceButton(size: _buttonSize),
          const SizedBox(width: _buttonGap),
          TactileIconButton(
            icon: Icons.my_location_rounded,
            tooltip: AppStrings.useMyLocation,
            onPressed: onUseLocation,
            size: _buttonSize,
          ),
          const SizedBox(width: _buttonGap),
          SearchHero(
            child: TactileIconButton(
              icon: Icons.search_rounded,
              tooltip: AppStrings.searchCity,
              onPressed: onSearch,
              size: _buttonSize,
            ),
          ),
          // Slides in once there's something to refresh.
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: onRefresh == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(left: _buttonGap),
                    child: TactileIconButton(
                      icon: Icons.refresh_rounded,
                      tooltip: isRefreshing
                          ? AppStrings.refreshing
                          : AppStrings.refresh,
                      // Pressed in and spinning while busy; disabled so
                      // repeated taps can't queue duplicate requests.
                      isBusy: isRefreshing,
                      onPressed: onRefresh,
                      size: _buttonSize,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.city, required this.fetchedAt});

  final City? city;
  final DateTime? fetchedAt;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final city = this.city;
    final fetchedAt = this.fetchedAt;
    final secondary = AppTextStyles.caption.copyWith(
      color: palette.textSecondary,
    );

    return SmoothSwitcher(
      alignment: Alignment.centerLeft,
      child: city == null
          ? const Align(
              key: ValueKey('app-name'),
              alignment: Alignment.centerLeft,
              child: Text(AppStrings.appName, style: AppTextStyles.headline),
            )
          : Column(
              key: ValueKey(city),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (city.isCurrentLocation) ...[
                      Icon(
                        Icons.near_me_rounded,
                        size: 18,
                        color: palette.accent,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Flexible(
                      child: Text(
                        city.name,
                        style: AppTextStyles.cityTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (city.subtitle.isNotEmpty)
                  Text(
                    city.subtitle,
                    style: secondary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (fetchedAt != null)
                  RelativeTimeText(
                    time: fetchedAt,
                    builder: AppStrings.updated,
                    style: secondary.copyWith(color: palette.textMuted),
                  ),
              ],
            ),
    );
  }
}
