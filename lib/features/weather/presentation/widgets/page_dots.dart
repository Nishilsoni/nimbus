import 'package:flutter/material.dart';
import 'package:nimbus/core/l10n/l10n.dart';
import 'package:nimbus/core/theme/surface_palette.dart';
import 'package:nimbus/core/widgets/tactile/tactile_surface.dart';

/// Which page is showing, as dots in a raised pill. The active dot
/// stretches; the location page is marked with an arrow instead of a dot.
class PageDots extends StatelessWidget {
  const PageDots({
    super.key,
    required this.count,
    required this.index,
    required this.firstIsLocation,
  });

  final int count;
  final int index;
  final bool firstIsLocation;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      label: context.l10n.placeIndicator(index + 1, count),
      child: ExcludeSemantics(
        child: TactileSurface(
          radius: 16,
          distance: 4,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < count; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: i == 0 && firstIsLocation
                      ? AnimatedScale(
                          scale: i == index ? 1.15 : 0.85,
                          duration: const Duration(milliseconds: 250),
                          child: Icon(
                            Icons.near_me_rounded,
                            size: 11,
                            color: i == index
                                ? palette.accent
                                : palette.textMuted,
                          ),
                        )
                      : AnimatedContainer(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOutCubic,
                          width: i == index ? 18 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: i == index
                                ? palette.accent
                                : palette.textMuted.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
