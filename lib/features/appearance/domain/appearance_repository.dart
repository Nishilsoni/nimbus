import 'package:nimbus/features/appearance/domain/appearance_mode.dart';

/// Remembers the user's appearance choice between launches.
abstract interface class AppearanceRepository {
  /// The saved mode, or [AppearanceMode.automatic] if none was saved.
  AppearanceMode load();

  Future<void> save(AppearanceMode mode);
}
