import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nimbus/core/theme/app_text_styles.dart';
import 'package:nimbus/core/theme/surface_palette.dart';
import 'package:nimbus/core/widgets/tactile/tactile_surface.dart';

/// One choice in a [TactileSegmented] control.
class Segment<T> {
  const Segment(this.value, this.label);

  final T value;
  final String label;
}

/// A row of choices in a groove, with a raised thumb that slides to the
/// selected one.
class TactileSegmented<T> extends StatelessWidget {
  const TactileSegmented({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
  });

  final List<Segment<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final selectedIndex = segments.indexWhere((s) => s.value == selected);

    return TactileSurface(
      depth: -1,
      radius: 18,
      distance: 4,
      padding: const EdgeInsets.all(5),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth = constraints.maxWidth / segments.length;
          return Stack(
            children: [
              if (selectedIndex != -1)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutCubic,
                  left: selectedIndex * segmentWidth,
                  width: segmentWidth,
                  top: 0,
                  bottom: 0,
                  child: const TactileSurface(radius: 14, distance: 3),
                ),
              Row(
                children: [
                  for (final (index, segment) in segments.indexed)
                    Expanded(
                      child: Semantics(
                        button: true,
                        selected: index == selectedIndex,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            if (segment.value == selected) return;
                            unawaited(HapticFeedback.selectionClick());
                            onChanged(segment.value);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 11,
                            ),
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 220),
                              style: AppTextStyles.bodyStrong.copyWith(
                                color: index == selectedIndex
                                    ? palette.accent
                                    : palette.textSecondary,
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(segment.label, maxLines: 1),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
