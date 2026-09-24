import 'package:flutter/material.dart';
import 'package:nimbus/core/widgets/tactile/tactile_surface.dart';

/// An indeterminate progress line running in a groove carved into the
/// surface. Fades in and out without changing the layout.
class TactileProgressBar extends StatelessWidget {
  const TactileProgressBar({super.key, required this.isVisible});

  final bool isVisible;

  static const _height = 6.0;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isVisible ? 1 : 0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: SizedBox(
        height: _height,
        child: isVisible
            ? TactileSurface(
                depth: -1,
                radius: _height / 2,
                distance: 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(_height / 2),
                  child: const LinearProgressIndicator(minHeight: _height),
                ),
              )
            : null,
      ),
    );
  }
}
