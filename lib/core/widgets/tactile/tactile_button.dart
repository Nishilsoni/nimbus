import 'package:flutter/material.dart';
import 'package:nimbus/core/theme/app_text_styles.dart';
import 'package:nimbus/core/theme/surface_palette.dart';
import 'package:nimbus/core/widgets/motion/spinning.dart';
import 'package:nimbus/core/widgets/tactile/tactile_pressable.dart';

/// A pill-shaped button. [isPrimary] fills it with the accent colour so the
/// main action on a screen stands out from the soft surface.
class TactileButton extends StatelessWidget {
  const TactileButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isPrimary = false,
    this.isCompact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isPrimary;

  /// Smaller padding, for buttons inside cards.
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final foreground = isPrimary ? palette.onAccent : palette.textPrimary;
    final icon = this.icon;

    return TactilePressable(
      onPressed: onPressed,
      radius: 28,
      distance: isCompact ? 4 : 6,
      color: isPrimary ? palette.accent : null,
      padding: isCompact
          ? const EdgeInsets.symmetric(horizontal: 14, vertical: 9)
          : const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: isCompact ? 17 : 20,
              color: isPrimary ? foreground : palette.accent,
            ),
            SizedBox(width: isCompact ? 6 : 10),
          ],
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style:
                  (isCompact ? AppTextStyles.caption : AppTextStyles.bodyStrong)
                      .copyWith(color: foreground, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

/// A round icon button. While [isBusy] it stays pressed in and its icon
/// spins, so the button itself shows that its action is running.
class TactileIconButton extends StatelessWidget {
  const TactileIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.isBusy = false,
    this.size = 46,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool isBusy;
  final double size;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(
      icon,
      key: ValueKey(icon),
      size: size * 0.46,
      color: isBusy ? context.palette.accent : context.palette.textPrimary,
    );

    return Tooltip(
      message: tooltip,
      child: TactilePressable(
        circle: true,
        distance: size / 9,
        onPressed: isBusy ? null : onPressed,
        isActive: isBusy,
        child: SizedBox.square(
          dimension: size,
          child: Center(
            // A new icon turns and scales in rather than popping.
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOutBack,
              transitionBuilder: (child, animation) => RotationTransition(
                turns: Tween(begin: -0.25, end: 0.0).animate(animation),
                child: ScaleTransition(scale: animation, child: child),
              ),
              child: isBusy ? Spinning(child: iconWidget) : iconWidget,
            ),
          ),
        ),
      ),
    );
  }
}
