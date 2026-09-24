import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nimbus/core/l10n/l10n.dart';
import 'package:nimbus/core/layout/breakpoints.dart';
import 'package:nimbus/core/theme/app_text_styles.dart';
import 'package:nimbus/core/theme/app_theme.dart';
import 'package:nimbus/core/theme/surface_palette.dart';
import 'package:nimbus/core/utils/temperature_unit.dart';
import 'package:nimbus/core/widgets/motion/staggered_entrance.dart';
import 'package:nimbus/core/widgets/tactile/tactile_segmented.dart';
import 'package:nimbus/core/widgets/tactile/tactile_surface.dart';
import 'package:nimbus/features/settings/domain/app_settings.dart';
import 'package:nimbus/features/settings/presentation/languages.dart';
import 'package:nimbus/features/settings/presentation/settings_cubit.dart';

/// Opens the settings as a bottom sheet. Every change applies live, so the
/// app restyles or retranslates behind the sheet as you choose.
Future<void> showSettingsSheet(BuildContext context) {
  final currentPalette = context.palette;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    constraints: const BoxConstraints(maxWidth: Breakpoints.maxFormWidth),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (_) => SettingsSheet(
      accent: currentPalette.accent,
      initialIsDark: currentPalette.isDark,
    ),
  );
}

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({
    super.key,
    required this.accent,
    required this.initialIsDark,
  });

  final Color accent;
  final bool initialIsDark;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<SettingsCubit>();

    return BlocBuilder<SettingsCubit, AppSettings>(
      builder: (context, settings) {
        final isDark = switch (settings.appearance) {
          AppearanceMode.dark => true,
          AppearanceMode.light => false,
          AppearanceMode.automatic => initialIsDark,
        };
        final palette = isDark
            ? SurfacePalette.dark(accent: accent)
            : SurfacePalette.light(accent: accent);

        return AnimatedTheme(
          data: AppTheme.fromPalette(palette),
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOutCubic,
          child: Material(
            color: palette.base,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            clipBehavior: Clip.antiAlias,
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: TactileSurface(
                        depth: -1,
                        radius: 3,
                        distance: 2,
                        child: SizedBox(width: 44, height: 6),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(l10n.settings, style: AppTextStyles.headline),
                    const SizedBox(height: 24),
                    _Section(
                      index: 0,
                      label: l10n.settingsTheme,
                      footnote: l10n.themeAutomaticHint,
                      child: TactileSegmented(
                        segments: [
                          Segment(
                            AppearanceMode.automatic,
                            l10n.themeAutomatic,
                          ),
                          Segment(AppearanceMode.light, l10n.themeLight),
                          Segment(AppearanceMode.dark, l10n.themeDark),
                        ],
                        selected: settings.appearance,
                        onChanged: cubit.setAppearance,
                      ),
                    ),
                    _Section(
                      index: 1,
                      label: l10n.settingsTemperature,
                      child: TactileSegmented(
                        segments: [
                          for (final unit in TemperatureUnit.values)
                            Segment(unit, unit.symbol),
                        ],
                        selected: settings.temperatureUnit,
                        onChanged: cubit.setTemperatureUnit,
                      ),
                    ),
                    _Section(
                      index: 2,
                      label: l10n.settingsLanguage,
                      child: TactileSegmented<String?>(
                        segments: [
                          Segment(null, l10n.languageSystem),
                          for (final MapEntry(key: code, value: name)
                              in supportedLanguages.entries)
                            Segment(code, name),
                        ],
                        selected: settings.languageCode,
                        onChanged: cubit.setLanguage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.index,
    required this.label,
    required this.child,
    this.footnote,
  });

  final int index;
  final String label;
  final Widget child;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final footnote = this.footnote;
    return StaggeredEntrance(
      index: index,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: AppTextStyles.tileLabel.copyWith(color: palette.textMuted),
            ),
            const SizedBox(height: 10),
            child,
            if (footnote != null) ...[
              const SizedBox(height: 8),
              Text(
                footnote,
                style: AppTextStyles.caption.copyWith(
                  color: palette.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
