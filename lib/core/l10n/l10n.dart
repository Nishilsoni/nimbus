import 'package:flutter/widgets.dart';
import 'package:nimbus/l10n/app_localizations.dart';

export 'package:nimbus/l10n/app_localizations.dart';

extension L10nContext on BuildContext {
  /// The translated strings for the current language.
  AppLocalizations get l10n => AppLocalizations.of(this);
}
