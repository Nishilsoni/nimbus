import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A page transition that reveals the new page through a circle growing
/// from [center] (in global coordinates) until it covers the screen.
class CircularRevealRoute<T> extends PageRouteBuilder<T> {
  CircularRevealRoute({required Widget page, required this.center})
    : super(
        transitionDuration: const Duration(milliseconds: 900),
        pageBuilder: (context, animation, secondaryAnimation) => page,
      );

  final Offset center;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOutCubic,
    );
    return AnimatedBuilder(
      animation: curved,
      builder: (context, child) => ClipPath(
        clipper: _CircleClipper(center: center, fraction: curved.value),
        child: child,
      ),
      child: child,
    );
  }
}

class _CircleClipper extends CustomClipper<Path> {
  const _CircleClipper({required this.center, required this.fraction});

  final Offset center;
  final double fraction;

  @override
  Path getClip(Size size) {
    // Distance to the farthest corner, so the circle covers everything.
    final maxRadius = [
      Offset.zero,
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ].map((corner) => (corner - center).distance).reduce(math.max);

    return Path()
      ..addOval(Rect.fromCircle(center: center, radius: maxRadius * fraction));
  }

  @override
  bool shouldReclip(_CircleClipper oldClipper) =>
      oldClipper.fraction != fraction || oldClipper.center != center;
}
