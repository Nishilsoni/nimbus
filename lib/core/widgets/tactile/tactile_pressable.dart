import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nimbus/core/widgets/tactile/tactile_surface.dart';

/// A [TactileSurface] that sinks into the background while it's pressed.
///
/// Press feedback is physical rather than an ink ripple: the surface
/// animates from raised to pressed in, shrinks slightly, and gives a light
/// haptic tick.
class TactilePressable extends StatefulWidget {
  const TactilePressable({
    super.key,
    required this.child,
    required this.onPressed,
    this.radius = 24,
    this.circle = false,
    this.distance = 6,
    this.padding = EdgeInsets.zero,
    this.color,
    this.isActive = false,
  });

  final Widget child;

  /// `null` disables the control.
  final VoidCallback? onPressed;
  final double radius;
  final bool circle;
  final double distance;
  final EdgeInsetsGeometry padding;
  final Color? color;

  /// Holds the surface pressed in, e.g. while the action it started runs.
  final bool isActive;

  @override
  State<TactilePressable> createState() => _TactilePressableState();
}

class _TactilePressableState extends State<TactilePressable> {
  /// A quick tap would otherwise release before the press is visible.
  static const _minimumPress = Duration(milliseconds: 110);

  bool _isPressed = false;
  Timer? _releaseTimer;

  bool get _isEnabled => widget.onPressed != null;

  @override
  void dispose() {
    _releaseTimer?.cancel();
    super.dispose();
  }

  void _press() {
    _releaseTimer?.cancel();
    setState(() => _isPressed = true);
  }

  void _release() {
    _releaseTimer?.cancel();
    _releaseTimer = Timer(_minimumPress, () {
      if (mounted) setState(() => _isPressed = false);
    });
  }

  void _handleTap() {
    unawaited(HapticFeedback.selectionClick());
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isSunken = _isPressed || widget.isActive;
    final depth = isSunken ? -0.8 : (_isEnabled ? 1.0 : 0.35);

    return Semantics(
      button: true,
      enabled: _isEnabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _isEnabled ? (_) => _press() : null,
        onTapUp: _isEnabled ? (_) => _release() : null,
        onTapCancel: _isEnabled ? _release : null,
        onTap: _isEnabled ? _handleTap : null,
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : 1,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: _isEnabled || widget.isActive ? 1 : 0.5,
            duration: const Duration(milliseconds: 200),
            child: TactileSurface(
              depth: depth,
              radius: widget.radius,
              circle: widget.circle,
              distance: widget.distance,
              padding: widget.padding,
              color: widget.color,
              duration: const Duration(milliseconds: 160),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
