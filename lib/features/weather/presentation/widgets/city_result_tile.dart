import 'package:flutter/material.dart';
import 'package:nimbus/core/theme/app_text_styles.dart';
import 'package:nimbus/core/theme/surface_palette.dart';
import 'package:nimbus/core/utils/country_flag.dart';
import 'package:nimbus/core/widgets/tactile/tactile_pressable.dart';
import 'package:nimbus/core/widgets/tactile/tactile_surface.dart';
import 'package:nimbus/features/weather/domain/entities/city.dart';

/// A pressable row in the search results, or the "current location" entry.
class CityResultTile extends StatelessWidget {
  const CityResultTile({
    super.key,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.leading,
  });

  /// A search result, led by the country's flag.
  factory CityResultTile.city({
    Key? key,
    required City city,
    required VoidCallback onTap,
  }) {
    final flag = countryFlag(city.countryCode);
    return CityResultTile(
      key: key,
      title: city.name,
      subtitle: city.subtitle.isEmpty ? null : city.subtitle,
      leading: flag == null
          ? null
          : Text(flag, style: const TextStyle(fontSize: 22)),
      onTap: onTap,
    );
  }

  final String title;
  final String? subtitle;

  /// Defaults to a city icon.
  final Widget? leading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final subtitle = this.subtitle;

    return TactilePressable(
      onPressed: onTap,
      radius: 22,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          TactileSurface(
            circle: true,
            depth: -1,
            distance: 4,
            child: SizedBox.square(
              dimension: 42,
              child: Center(
                child:
                    leading ??
                    Icon(Icons.location_city_rounded, color: palette.accent),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyStrong),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: palette.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: palette.textMuted),
        ],
      ),
    );
  }
}
