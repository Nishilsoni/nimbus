import 'dart:async';

import 'package:flutter/material.dart';

import 'package:nimbus/core/utils/date_formatter.dart';

/// Text such as "Updated 5 min ago" that keeps itself current.
///
/// The ticking clock is purely local UI state, so a `setState` timer is
/// the right tool here rather than app-level state management.
class RelativeTimeText extends StatefulWidget {
  const RelativeTimeText({
    super.key,
    required this.time,
    required this.builder,
    this.style,
  });

  final DateTime time;

  /// Wraps the relative phrase, e.g. `(ago) => 'Updated $ago'`.
  final String Function(String relative) builder;
  final TextStyle? style;

  @override
  State<RelativeTimeText> createState() => _RelativeTimeTextState();
}

class _RelativeTimeTextState extends State<RelativeTimeText> {
  late final Timer _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(
      const Duration(seconds: 30),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      widget.builder(DateFormatter.relative(widget.time)),
      style: widget.style,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
