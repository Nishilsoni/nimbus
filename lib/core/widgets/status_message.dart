import 'package:flutter/material.dart';

import 'package:nimbus/core/theme/app_text_styles.dart';

/// A centred visual, title, message and optional buttons. The common layout
/// behind empty states, error states and search feedback.
class StatusMessage extends StatelessWidget {
  const StatusMessage({
    super.key,
    required this.visual,
    required this.title,
    required this.message,
    this.actions = const [],
  });

  final Widget visual;
  final String title;
  final String message;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          visual,
          const SizedBox(height: 24),
          Text(
            title,
            style: AppTextStyles.headline,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(message, style: AppTextStyles.body, textAlign: TextAlign.center),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 28),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: actions,
            ),
          ],
        ],
      ),
    );
  }
}

/// A large icon on a soft circular backdrop, for use as a [StatusMessage]
/// visual.
class StatusIcon extends StatelessWidget {
  const StatusIcon(this.icon, {super.key});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0x1FFFFFFF),
      ),
      child: Icon(icon, size: 44),
    );
  }
}
