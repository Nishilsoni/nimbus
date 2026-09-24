import 'package:flutter/widgets.dart';

/// Width thresholds the layouts adapt at. They're applied to the space a
/// widget actually gets, so the same rules cover phones, landscape,
/// foldables and tablets.
abstract final class Breakpoints {
  /// From here the weather splits into two columns: the hero on one side,
  /// forecasts and details on the other. Phones in landscape qualify.
  static const twoPane = 720.0;

  /// From here the detail tiles sit four to a row instead of two.
  static const wideGrid = 560.0;

  /// Content never grows wider than this on large tablets.
  static const maxContentWidth = 1100.0;

  /// Forms and lists (search, settings, messages) stay readable.
  static const maxFormWidth = 640.0;

  /// Below this the header uses smaller buttons.
  static const narrowHeader = 380.0;
}

/// Gives [child] the full available width, up to [maxWidth], and centres
/// it horizontally when the screen is wider.
class MaxWidth extends StatelessWidget {
  const MaxWidth({
    super.key,
    required this.maxWidth,
    required this.child,
    this.alignment = Alignment.topCenter,
  });

  final double maxWidth;
  final Widget child;

  /// Where [child] sits when there's spare room.
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }
}
