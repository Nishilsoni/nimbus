import 'package:flutter/material.dart';
import 'package:nimbus/core/constants/app_strings.dart';
import 'package:nimbus/core/error/failures.dart';
import 'package:nimbus/core/theme/app_text_styles.dart';
import 'package:nimbus/core/theme/surface_palette.dart';
import 'package:nimbus/core/widgets/relative_time_text.dart';
import 'package:nimbus/core/widgets/tactile/tactile_button.dart';
import 'package:nimbus/core/widgets/tactile/tactile_surface.dart';
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
    final palette = context.palette;
    return Semantics(
      liveRegion: true,
      child: TactileSurface(
        radius: 22,
        padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
        child: Row(
          children: [
            TactileSurface(
              circle: true,
              depth: -1,
              distance: 4,
              child: SizedBox.square(
                dimension: 40,
                child: Icon(failure.icon, size: 20, color: palette.warning),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(failure.title, style: AppTextStyles.bodyStrong),
                  RelativeTimeText(
                    time: lastUpdated,
                    builder: AppStrings.lastUpdated,
                    style: AppTextStyles.caption.copyWith(
                      color: palette.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TactileButton(
              label: failure.actionLabel,
              onPressed: onAction,
              isCompact: true,
            ),
            const SizedBox(width: 10),
            TactileIconButton(
              icon: Icons.close_rounded,
              tooltip: AppStrings.dismiss,
              onPressed: onDismiss,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }
}
