import 'package:flutter/material.dart';
import 'package:nimbus/core/constants/app_strings.dart';
import 'package:nimbus/core/theme/app_text_styles.dart';
import 'package:nimbus/core/widgets/relative_time_text.dart';
import 'package:nimbus/features/weather/domain/entities/city.dart';

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

  @override
  Widget build(BuildContext context) {
    final onRefresh = this.onRefresh;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 8, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _Title(city: city, fetchedAt: fetchedAt),
          ),
          IconButton(
            tooltip: AppStrings.useMyLocation,
            icon: const Icon(Icons.my_location_rounded),
            onPressed: onUseLocation,
          ),
          IconButton(
            tooltip: AppStrings.searchCity,
            icon: const Icon(Icons.search_rounded),
            onPressed: onSearch,
          ),
          if (onRefresh != null)
            _RefreshButton(isRefreshing: isRefreshing, onPressed: onRefresh),
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
    final city = this.city;
    final fetchedAt = this.fetchedAt;
    if (city == null) {
      return const Padding(
        padding: EdgeInsets.only(top: 8),
        child: Text(AppStrings.appName, style: AppTextStyles.headline),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.topLeft,
        children: [...previous, ?current],
      ),
      child: Column(
        key: ValueKey(city),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (city.isCurrentLocation) ...[
                const Icon(Icons.near_me_rounded, size: 18),
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
              style: AppTextStyles.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          if (fetchedAt != null)
            RelativeTimeText(
              time: fetchedAt,
              builder: AppStrings.updated,
              style: AppTextStyles.caption,
            ),
        ],
      ),
    );
  }
}

class _RefreshButton extends StatelessWidget {
  const _RefreshButton({required this.isRefreshing, required this.onPressed});

  final bool isRefreshing;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: isRefreshing ? AppStrings.refreshing : AppStrings.refresh,
      // Disabled while busy so repeated taps can't queue duplicate requests.
      onPressed: isRefreshing ? null : onPressed,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: isRefreshing
            ? const SizedBox.square(
                key: ValueKey('spinner'),
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2.2),
              )
            : const Icon(Icons.refresh_rounded, key: ValueKey('icon')),
      ),
    );
  }
}
