import 'package:flutter/material.dart';
import 'package:nimbus/core/error/failures.dart';
import 'package:nimbus/core/l10n/l10n.dart';
import 'package:nimbus/core/theme/surface_palette.dart';
import 'package:nimbus/core/widgets/status_message.dart';
import 'package:nimbus/core/widgets/tactile/tactile_button.dart';
import 'package:nimbus/features/weather/presentation/utils/failure_display.dart';

/// Full-screen error, shown only when there is no data to fall back on.
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.failure,
    required this.onAction,
    required this.onSearch,
  });

  final Failure failure;
  final VoidCallback onAction;

  /// Searching is always a way out, e.g. when location access is blocked.
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return StatusMessage(
      visual: StatusIcon(failure.icon, color: context.palette.warning),
      title: failure.title(l10n),
      message: failure.message(l10n),
      actions: [
        TactileButton(
          label: failure.actionLabel(l10n),
          icon: failure.action == FailureAction.openSettings
              ? Icons.settings_rounded
              : Icons.refresh_rounded,
          onPressed: onAction,
          isPrimary: true,
        ),
        TactileButton(
          label: l10n.searchCity,
          icon: Icons.search_rounded,
          onPressed: onSearch,
        ),
      ],
    );
  }
}
