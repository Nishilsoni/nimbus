import 'package:flutter/material.dart';
import 'package:nimbus/core/theme/app_text_styles.dart';
import 'package:nimbus/core/theme/surface_palette.dart';
import 'package:nimbus/core/widgets/motion/smooth_switcher.dart';
import 'package:nimbus/core/widgets/tactile/tactile_surface.dart';

/// One measurement, e.g. "HUMIDITY · 60%", on a raised card. The value
/// cross-fades when a refresh changes it.
class DetailTile extends StatelessWidget {
  const DetailTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.caption,
  });

  final IconData icon;
  final String label;
  final String value;

  /// Extra context under the value, e.g. "High" for a UV index of 7.
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final caption = this.caption;

    return MergeSemantics(
      child: TactileSurface(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TactileSurface(
                  circle: true,
                  depth: -1,
                  distance: 3,
                  child: SizedBox.square(
                    dimension: 32,
                    child: Icon(icon, size: 16, color: palette.accent),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label.toUpperCase(),
                    style: AppTextStyles.tileLabel.copyWith(
                      color: palette.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SmoothSwitcher(
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                key: ValueKey(value),
                style: AppTextStyles.tileValue,
              ),
            ),
            if (caption != null)
              Text(
                caption,
                style: AppTextStyles.caption.copyWith(
                  color: palette.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
