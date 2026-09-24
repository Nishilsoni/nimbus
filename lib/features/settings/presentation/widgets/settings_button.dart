import 'package:flutter/material.dart';
import 'package:nimbus/core/l10n/l10n.dart';
import 'package:nimbus/core/widgets/tactile/tactile_button.dart';
import 'package:nimbus/features/settings/presentation/widgets/settings_sheet.dart';

/// Opens the settings sheet: theme, temperature unit and language.
class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key, this.size = 46});

  final double size;

  @override
  Widget build(BuildContext context) {
    return TactileIconButton(
      icon: Icons.tune_rounded,
      tooltip: context.l10n.settings,
      onPressed: () => showSettingsSheet(context),
      size: size,
    );
  }
}
