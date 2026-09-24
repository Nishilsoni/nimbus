import 'package:flutter/material.dart';
import 'package:nimbus/core/theme/app_text_styles.dart';
import 'package:nimbus/core/theme/surface_palette.dart';

/// The small caps heading at the top of a forecast card.
class CardTitle extends StatelessWidget {
  const CardTitle({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      children: [
        Icon(icon, size: 16, color: palette.accent),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text.toUpperCase(),
            style: AppTextStyles.tileLabel.copyWith(color: palette.textMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
