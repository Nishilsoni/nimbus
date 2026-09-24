import 'package:flutter/material.dart';
import 'package:nimbus/core/theme/surface_palette.dart';
import 'package:nimbus/core/widgets/tactile/tactile_surface.dart';

/// Morphs the header's round search button into the search field (and
/// back) when the search screen opens and closes.
///
/// During the flight a plain surface stretches between the two shapes and
/// sinks from raised (button) to pressed in (field). The real text field
/// isn't flown, which avoids two copies of it sharing a controller.
class SearchHero extends StatelessWidget {
  const SearchHero({super.key, required this.child});

  final Widget child;

  static const _tag = 'city-search';

  @override
  Widget build(BuildContext context) {
    return Hero(tag: _tag, flightShuttleBuilder: _buildShuttle, child: child);
  }

  static Widget _buildShuttle(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection direction,
    BuildContext fromContext,
    BuildContext toContext,
  ) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => TactileSurface(
        depth: 1 - 2 * animation.value,
        radius: 23,
        duration: Duration.zero,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(
              Icons.search_rounded,
              size: 21,
              color: context.palette.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
