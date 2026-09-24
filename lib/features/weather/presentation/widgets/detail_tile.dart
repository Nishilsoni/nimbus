import 'package:flutter/material.dart';
import 'package:nimbus/core/theme/app_colors.dart';
import 'package:nimbus/core/theme/app_text_styles.dart';
import 'package:nimbus/core/widgets/glass_card.dart';

/// One measurement, e.g. "HUMIDITY · 60%".
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
    final caption = this.caption;
    return MergeSemantics(
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label.toUpperCase(),
                    style: AppTextStyles.tileLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(value, style: AppTextStyles.tileValue),
            if (caption != null) Text(caption, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}
