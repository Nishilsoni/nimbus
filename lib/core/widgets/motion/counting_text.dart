import 'package:flutter/material.dart';

/// Shows a number that rolls smoothly to each new [value] instead of
/// jumping, e.g. the temperature after a refresh.
///
/// On first build it counts up from [from].
class CountingText extends StatelessWidget {
  const CountingText({
    super.key,
    required this.value,
    required this.format,
    this.from = 0,
    this.style,
    this.duration = const Duration(milliseconds: 1100),
  });

  final double value;
  final String Function(double value) format;
  final double from;
  final TextStyle? style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: from, end: value),
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : duration,
      curve: Curves.easeOutCubic,
      builder: (context, animated, _) => Text(format(animated), style: style),
    );
  }
}
