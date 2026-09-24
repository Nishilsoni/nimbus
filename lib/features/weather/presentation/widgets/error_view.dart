import 'package:flutter/material.dart';
import 'package:nimbus/core/constants/app_strings.dart';
import 'package:nimbus/core/error/failures.dart';
import 'package:nimbus/core/widgets/status_message.dart';
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
    return StatusMessage(
      visual: StatusIcon(failure.icon),
      title: failure.title,
      message: failure.message,
      actions: [
        FilledButton(onPressed: onAction, child: Text(failure.actionLabel)),
        OutlinedButton(
          onPressed: onSearch,
          child: const Text(AppStrings.searchCity),
        ),
      ],
    );
  }
}
