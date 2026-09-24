import 'package:flutter/material.dart';

/// An [AnimatedSwitcher] that cross-fades with a slight rise and scale.
/// Used wherever content is swapped: values, views, list states.
///
/// Children must have distinct keys (or types) for the switch to animate.
class SmoothSwitcher extends StatelessWidget {
  const SmoothSwitcher({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 380),
    this.alignment = Alignment.center,
  });

  final Widget child;
  final Duration duration;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (current, previous) =>
          Stack(alignment: alignment, children: [...previous, ?current]),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween(begin: 0.96, end: 1.0).animate(animation),
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
      ),
      child: child,
    );
  }
}
