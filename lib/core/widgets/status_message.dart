import 'package:flutter/material.dart';
import 'package:nimbus/core/theme/app_text_styles.dart';
import 'package:nimbus/core/theme/surface_palette.dart';
import 'package:nimbus/core/widgets/motion/staggered_entrance.dart';
import 'package:nimbus/core/widgets/tactile/tactile_surface.dart';

/// A centred visual, title, message and optional buttons that cascade in.
/// The common layout behind empty states, error states and search feedback.
class StatusMessage extends StatelessWidget {
  const StatusMessage({
    super.key,
    required this.visual,
    required this.title,
    required this.message,
    this.actions = const [],
  });

  final Widget visual;
  final String title;
  final String message;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StaggeredEntrance(index: 0, child: visual),
          const SizedBox(height: 32),
          StaggeredEntrance(
            index: 1,
            child: Text(
              title,
              style: AppTextStyles.headline,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          StaggeredEntrance(
            index: 2,
            child: Text(
              message,
              style: AppTextStyles.body.copyWith(color: palette.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 32),
            StaggeredEntrance(
              index: 3,
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 16,
                children: actions,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A large icon sitting in a round well carved into the surface, for use
/// as a [StatusMessage] visual.
class StatusIcon extends StatelessWidget {
  const StatusIcon(this.icon, {super.key, this.color});

  final IconData icon;

  /// Defaults to the palette accent.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return TactileSurface(
      circle: true,
      distance: 10,
      child: SizedBox.square(
        dimension: 116,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: TactileSurface(
            circle: true,
            depth: -1,
            child: Center(
              child: Icon(
                icon,
                size: 40,
                color: color ?? context.palette.accent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
