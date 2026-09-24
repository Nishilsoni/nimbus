import 'package:flutter/material.dart';

/// Spins [child] continuously, e.g. a refresh icon while refreshing.
/// Holds still when the system asks for reduced motion.
class Spinning extends StatefulWidget {
  const Spinning({super.key, required this.child});

  final Widget child;

  @override
  State<Spinning> createState() => _SpinningState();
}

class _SpinningState extends State<Spinning>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _rotation.stop();
    } else if (!_rotation.isAnimating) {
      _rotation.repeat();
    }
  }

  @override
  void dispose() {
    _rotation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(turns: _rotation, child: widget.child);
  }
}
