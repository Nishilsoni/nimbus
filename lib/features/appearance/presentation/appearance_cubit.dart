import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nimbus/features/appearance/domain/appearance_mode.dart';
import 'package:nimbus/features/appearance/domain/appearance_repository.dart';

class AppearanceCubit extends Cubit<AppearanceMode> {
  AppearanceCubit(this._repository) : super(_repository.load());

  final AppearanceRepository _repository;

  /// The header toggle: automatic → light → dark → automatic.
  Future<void> cycle() => select(state.next);

  /// Applies [mode] at once, then saves it for the next launch.
  Future<void> select(AppearanceMode mode) async {
    if (mode == state) return;
    emit(mode);
    await _repository.save(mode);
  }
}

extension AppearanceThemeMode on AppearanceMode {
  /// The theme to show. In automatic mode it follows day or night at the
  /// city on screen ([isDay]), or the device setting while that's unknown.
  ThemeMode toThemeMode({required bool? isDay}) => switch (this) {
    AppearanceMode.light => ThemeMode.light,
    AppearanceMode.dark => ThemeMode.dark,
    AppearanceMode.automatic => switch (isDay) {
      null => ThemeMode.system,
      true => ThemeMode.light,
      false => ThemeMode.dark,
    },
  };
}
