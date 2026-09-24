import 'package:nimbus/features/settings/domain/app_settings.dart';

/// Remembers the user's settings between launches.
abstract interface class SettingsRepository {
  /// The saved settings, or the defaults if none were saved.
  AppSettings load();

  Future<void> save(AppSettings settings);
}
