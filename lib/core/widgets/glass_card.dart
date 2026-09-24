import 'package:flutter/material.dart';

import 'package:nimbus/core/theme/app_colors.dart';

/// The translucent rounded surface used for every card in the app.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.fillColor = AppColors.glassFill,
    this.borderColor = AppColors.glassBorder,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color fillColor;
  final Color borderColor;
  final VoidCallback? onTap;

  static const _radius = BorderRadius.all(Radius.circular(20));

  @override
  Widget build(BuildContext context) {
    return Material(
      color: fillColor,
      shape: RoundedRectangleBorder(
        borderRadius: _radius,
        side: BorderSide(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
