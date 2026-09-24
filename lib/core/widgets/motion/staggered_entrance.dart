import 'dart:async';

import 'package:flutter/material.dart';

/// Fades and floats [child] into place the first time it's built, delayed
/// by its [index] so a group of items cascades in one after another.
///
/// Give the group a new key (e.g. per city) to play the cascade again.
class StaggeredEntrance extends StatefulWidget {
  const StaggeredEntrance({
    super.key,
    required this.index,
    required this.child,
    this.step = const Duration(milliseconds: 65),
  });

  /// Position in the cascade; 0 enters first.
  final int index;
  final Widget child;

  /// Delay between consecutive items.
  final Duration step;

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 560),
  );

  late final Animation<double> _progress = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  Timer? _delay;
  bool _hasStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasStarted) return;
    _hasStarted = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      _delay = Timer(widget.step * widget.index, _controller.forward);
    }
  }

  @override
  void dispose() {
    _delay?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _progress,
      child: AnimatedBuilder(
        animation: _progress,
        builder: (context, child) {
          final remaining = 1 - _progress.value;
          return Transform.translate(
            offset: Offset(0, 28 * remaining),
            child: Transform.scale(scale: 1 - 0.04 * remaining, child: child),
          );
        },
        child: widget.child,
      ),
    );
  }
}
