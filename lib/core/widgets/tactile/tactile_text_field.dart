import 'package:flutter/material.dart';
import 'package:nimbus/core/theme/app_text_styles.dart';
import 'package:nimbus/core/theme/surface_palette.dart';
import 'package:nimbus/core/widgets/tactile/tactile_surface.dart';

/// A text field carved into the surface.
class TactileTextField extends StatelessWidget {
  const TactileTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.clearTooltip,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// Shows a clear button while there's text.
  final VoidCallback? onClear;
  final String? clearTooltip;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final onClear = this.onClear;

    return TactileSurface(
      depth: -1,
      radius: 22,
      distance: 5,
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        autocorrect: false,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.search,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        style: AppTextStyles.bodyStrong.copyWith(color: palette.textPrimary),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.body.copyWith(color: palette.textMuted),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          prefixIcon: Icon(Icons.search_rounded, color: palette.textSecondary),
          // Rebuilds only the clear button as the text changes.
          suffixIcon: onClear == null
              ? null
              : ValueListenableBuilder(
                  valueListenable: controller,
                  builder: (context, value, _) => AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: value.text.isEmpty
                        ? const SizedBox.shrink()
                        : IconButton(
                            tooltip: clearTooltip,
                            icon: Icon(
                              Icons.close_rounded,
                              color: palette.textSecondary,
                            ),
                            onPressed: onClear,
                          ),
                  ),
                ),
        ),
      ),
    );
  }
}
