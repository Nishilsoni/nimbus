import 'package:flutter/material.dart';
import 'package:nimbus/core/l10n/l10n.dart';
import 'package:nimbus/core/layout/breakpoints.dart';
import 'package:nimbus/core/theme/app_text_styles.dart';
import 'package:nimbus/core/theme/surface_palette.dart';
import 'package:nimbus/core/widgets/motion/smooth_switcher.dart';
import 'package:nimbus/core/widgets/relative_time_text.dart';
import 'package:nimbus/core/widgets/tactile/tactile_button.dart';
import 'package:nimbus/features/settings/presentation/widgets/settings_button.dart';
import 'package:nimbus/features/weather/domain/entities/city.dart';
import 'package:nimbus/features/weather/presentation/widgets/search_hero.dart';

/// Place name, freshness, and the screen's actions.
class WeatherHeader extends StatelessWidget {
  const WeatherHeader({
    super.key,
    required this.city,
    required this.fetchedAt,
    required this.isRefreshing,
    required this.onSearch,
    required this.onUseLocation,
    required this.onRefresh,
    this.placeholderTitle,
    this.showsLocationIcon = false,
  });

  final City? city;
  final DateTime? fetchedAt;
  final bool isRefreshing;
  final VoidCallback onSearch;
  final VoidCallback onUseLocation;

  /// `null` hides the refresh button (nothing to refresh yet).
  final VoidCallback? onRefresh;

  /// Shown while [city] is unknown, e.g. "My location" before a GPS fix.
  final String? placeholderTitle;

  /// Marks the title as the device's location.
  final bool showsLocationIcon;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final onRefresh = this.onRefresh;
    final isNarrow =
        MediaQuery.sizeOf(context).width < Breakpoints.narrowHeader;
    // Compact enough that four buttons leave room for the place name.
    final buttonSize = isNarrow ? 38.0 : 42.0;
    final gap = isNarrow ? 9.0 : 12.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(isNarrow ? 18 : 24, 12, 18, 8),
      child: Row(
        children: [
          Expanded(
            child: _Title(
              city: city,
              fetchedAt: fetchedAt,
              placeholder: placeholderTitle ?? l10n.appName,
              showsLocationIcon: showsLocationIcon,
            ),
          ),
          SizedBox(width: gap),
          SettingsButton(size: buttonSize),
          SizedBox(width: gap),
          TactileIconButton(
            icon: Icons.my_location_rounded,
            tooltip: l10n.useMyLocation,
            onPressed: onUseLocation,
            size: buttonSize,
          ),
          SizedBox(width: gap),
          SearchHero(
            child: TactileIconButton(
              icon: Icons.search_rounded,
              tooltip: l10n.searchCity,
              onPressed: onSearch,
              size: buttonSize,
            ),
          ),
          // Slides in once there's something to refresh.
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: onRefresh == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: EdgeInsets.only(left: gap),
                    child: TactileIconButton(
                      icon: Icons.refresh_rounded,
                      tooltip: isRefreshing ? l10n.refreshing : l10n.refresh,
                      // Pressed in and spinning while busy; disabled so
                      // repeated taps can't queue duplicate requests.
                      isBusy: isRefreshing,
                      onPressed: onRefresh,
                      size: buttonSize,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({
    required this.city,
    required this.fetchedAt,
    required this.placeholder,
    required this.showsLocationIcon,
  });

  final City? city;
  final DateTime? fetchedAt;
  final String placeholder;
  final bool showsLocationIcon;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final city = this.city;
    final fetchedAt = this.fetchedAt;
    final secondary = AppTextStyles.caption.copyWith(
      color: palette.textSecondary,
    );

    return SmoothSwitcher(
      alignment: Alignment.centerLeft,
      child: Column(
        key: ValueKey(city ?? placeholder),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (showsLocationIcon) ...[
                Icon(Icons.near_me_rounded, size: 18, color: palette.accent),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  city?.name ?? placeholder,
                  style: AppTextStyles.cityTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (city != null && city.subtitle.isNotEmpty)
            Text(
              city.subtitle,
              style: secondary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          if (fetchedAt != null)
            RelativeTimeText(
              time: fetchedAt,
              builder: l10n.updated,
              style: secondary.copyWith(color: palette.textMuted),
            ),
        ],
      ),
    );
  }
}
