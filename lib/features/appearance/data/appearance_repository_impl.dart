import 'package:nimbus/features/appearance/domain/appearance_mode.dart';
import 'package:nimbus/features/appearance/domain/appearance_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppearanceRepositoryImpl implements AppearanceRepository {
  const AppearanceRepositoryImpl(this._preferences);

  static const storageKey = 'appearance_mode';

  final SharedPreferences _preferences;

  /// Synchronous: preferences are already in memory at startup, so the
  /// first frame uses the right theme instead of flashing the wrong one.
  @override
  AppearanceMode load() {
    final saved = _preferences.getString(storageKey);
    return AppearanceMode.values.firstWhere(
      (mode) => mode.name == saved,
      orElse: () => AppearanceMode.automatic,
    );
  }

  @override
  Future<void> save(AppearanceMode mode) =>
      _preferences.setString(storageKey, mode.name);
}
