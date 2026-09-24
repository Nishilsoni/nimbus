import 'package:flutter/material.dart';
import 'package:nimbus/core/constants/app_strings.dart';
import 'package:nimbus/core/error/failures.dart';
import 'package:nimbus/core/theme/app_colors.dart';
import 'package:nimbus/core/theme/app_text_styles.dart';
import 'package:nimbus/core/widgets/glass_card.dart';
import 'package:nimbus/core/widgets/relative_time_text.dart';
import 'package:nimbus/features/weather/presentation/utils/failure_display.dart';

/// Explains that the latest request failed and the weather below is the
/// last good data, with how old it is and a way to fix the problem.
class RefreshStatusBanner extends StatelessWidget {
  const RefreshStatusBanner({
    super.key,
    required this.failure,
    required this.lastUpdated,
    required this.onAction,
    required this.onDismiss,
  });

  final Failure failure;
  final DateTime lastUpdated;
  final VoidCallback onAction;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: GlassCard(
        fillColor: AppColors.warningFill,
        borderColor: AppColors.warningBorder,
        padding: const EdgeInsets.fromLTRB(16, 10, 4, 10),
        child: Row(
          children: [
            Icon(failure.icon, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(failure.title, style: AppTextStyles.bodyStrong),
                  RelativeTimeText(
                    time: lastUpdated,
                    builder: AppStrings.lastUpdated,
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            TextButton(onPressed: onAction, child: Text(failure.actionLabel)),
            IconButton(
              tooltip: AppStrings.dismiss,
              icon: const Icon(Icons.close_rounded, size: 20),
              onPressed: onDismiss,
            ),
          ],
        ),
      ),
    );
  }
}
