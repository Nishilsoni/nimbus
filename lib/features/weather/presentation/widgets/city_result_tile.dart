import 'package:flutter/material.dart';
import 'package:nimbus/core/theme/app_colors.dart';
import 'package:nimbus/core/theme/app_text_styles.dart';
import 'package:nimbus/core/utils/country_flag.dart';
import 'package:nimbus/core/widgets/glass_card.dart';
import 'package:nimbus/features/weather/domain/entities/city.dart';

/// A tappable row in the search results, or the "current location" entry.
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
          ? const Icon(Icons.location_city_rounded)
          : Text(flag, style: const TextStyle(fontSize: 26)),
      onTap: onTap,
    );
  }

  final String title;
  final String? subtitle;
  final Widget? leading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Center(child: leading ?? const Icon(Icons.place_rounded)),
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
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
