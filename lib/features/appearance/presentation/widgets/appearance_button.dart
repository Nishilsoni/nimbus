import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nimbus/core/constants/app_strings.dart';
import 'package:nimbus/core/widgets/tactile/tactile_button.dart';
import 'package:nimbus/features/appearance/domain/appearance_mode.dart';
import 'package:nimbus/features/appearance/presentation/appearance_cubit.dart';

/// Cycles the appearance: automatic, light, dark. The icon shows the
/// current mode and the whole app glides to the new look.
class AppearanceButton extends StatelessWidget {
  const AppearanceButton({super.key, this.size = 46});

  final double size;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppearanceCubit, AppearanceMode>(
      builder: (context, mode) => TactileIconButton(
        icon: switch (mode) {
          AppearanceMode.automatic => Icons.brightness_auto_rounded,
          AppearanceMode.light => Icons.light_mode_rounded,
          AppearanceMode.dark => Icons.dark_mode_rounded,
        },
        tooltip: switch (mode) {
          AppearanceMode.automatic => AppStrings.appearanceAutomatic,
          AppearanceMode.light => AppStrings.appearanceLight,
          AppearanceMode.dark => AppStrings.appearanceDark,
        },
        onPressed: context.read<AppearanceCubit>().cycle,
        size: size,
      ),
    );
  }
}
