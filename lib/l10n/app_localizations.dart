import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('gu'),
    Locale('hi'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Nimbus'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Weather, clearly.'**
  String get appTagline;

  /// No description provided for @searchCity.
  ///
  /// In en, this message translates to:
  /// **'Search city'**
  String get searchCity;

  /// No description provided for @useMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get useMyLocation;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @refreshing.
  ///
  /// In en, this message translates to:
  /// **'Refreshing…'**
  String get refreshing;

  /// No description provided for @loadingWeather.
  ///
  /// In en, this message translates to:
  /// **'Loading weather'**
  String get loadingWeather;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Nimbus'**
  String get welcomeTitle;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Search for a city or use your location to see the current weather.'**
  String get welcomeMessage;

  /// No description provided for @feelsLike.
  ///
  /// In en, this message translates to:
  /// **'Feels like'**
  String get feelsLike;

  /// No description provided for @humidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get humidity;

  /// No description provided for @wind.
  ///
  /// In en, this message translates to:
  /// **'Wind'**
  String get wind;

  /// No description provided for @precipitation.
  ///
  /// In en, this message translates to:
  /// **'Precipitation'**
  String get precipitation;

  /// No description provided for @uvIndex.
  ///
  /// In en, this message translates to:
  /// **'UV index'**
  String get uvIndex;

  /// No description provided for @pressure.
  ///
  /// In en, this message translates to:
  /// **'Pressure'**
  String get pressure;

  /// No description provided for @sunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get sunrise;

  /// No description provided for @sunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get sunset;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get notAvailable;

  /// No description provided for @highLow.
  ///
  /// In en, this message translates to:
  /// **'H {high}  ·  L {low}'**
  String highLow(String high, String low);

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated {time}'**
  String lastUpdated(String time);

  /// No description provided for @updated.
  ///
  /// In en, this message translates to:
  /// **'Updated {time}'**
  String updated(String time);

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min ago'**
  String minutesAgo(int minutes);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours} h ago'**
  String hoursAgo(int hours);

  /// No description provided for @uvLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get uvLow;

  /// No description provided for @uvModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get uvModerate;

  /// No description provided for @uvHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get uvHigh;

  /// No description provided for @uvVeryHigh.
  ///
  /// In en, this message translates to:
  /// **'Very high'**
  String get uvVeryHigh;

  /// No description provided for @uvExtreme.
  ///
  /// In en, this message translates to:
  /// **'Extreme'**
  String get uvExtreme;

  /// No description provided for @conditionClear.
  ///
  /// In en, this message translates to:
  /// **'Clear sky'**
  String get conditionClear;

  /// No description provided for @conditionPartlyCloudy.
  ///
  /// In en, this message translates to:
  /// **'Partly cloudy'**
  String get conditionPartlyCloudy;

  /// No description provided for @conditionCloudy.
  ///
  /// In en, this message translates to:
  /// **'Cloudy'**
  String get conditionCloudy;

  /// No description provided for @conditionFog.
  ///
  /// In en, this message translates to:
  /// **'Foggy'**
  String get conditionFog;

  /// No description provided for @conditionDrizzle.
  ///
  /// In en, this message translates to:
  /// **'Drizzle'**
  String get conditionDrizzle;

  /// No description provided for @conditionRain.
  ///
  /// In en, this message translates to:
  /// **'Rain'**
  String get conditionRain;

  /// No description provided for @conditionSnow.
  ///
  /// In en, this message translates to:
  /// **'Snow'**
  String get conditionSnow;

  /// No description provided for @conditionThunderstorm.
  ///
  /// In en, this message translates to:
  /// **'Thunderstorm'**
  String get conditionThunderstorm;

  /// No description provided for @conditionUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get conditionUnknown;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for a city'**
  String get searchHint;

  /// No description provided for @searchIdleMessage.
  ///
  /// In en, this message translates to:
  /// **'Type at least 2 letters to search.'**
  String get searchIdleMessage;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearSearch;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current location'**
  String get currentLocation;

  /// No description provided for @currentLocationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use GPS to find weather near you'**
  String get currentLocationSubtitle;

  /// No description provided for @myLocation.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get myLocation;

  /// No description provided for @yourPlaces.
  ///
  /// In en, this message translates to:
  /// **'Your places'**
  String get yourPlaces;

  /// No description provided for @removePlace.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}'**
  String removePlace(String name);

  /// No description provided for @placeIndicator.
  ///
  /// In en, this message translates to:
  /// **'Place {index} of {count}'**
  String placeIndicator(int index, int count);

  /// No description provided for @hourlyForecastTitle.
  ///
  /// In en, this message translates to:
  /// **'Next 24 hours'**
  String get hourlyForecastTitle;

  /// No description provided for @dailyForecastTitle.
  ///
  /// In en, this message translates to:
  /// **'7-day forecast'**
  String get dailyForecastTitle;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @themeAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get themeAutomatic;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeAutomaticHint.
  ///
  /// In en, this message translates to:
  /// **'Auto is light by day and dark by night at the city on screen.'**
  String get themeAutomaticHint;

  /// No description provided for @settingsTemperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get settingsTemperature;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @noInternetTitle.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetTitle;

  /// No description provided for @noInternetMessage.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get noInternetMessage;

  /// No description provided for @timeoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Request timed out'**
  String get timeoutTitle;

  /// No description provided for @timeoutMessage.
  ///
  /// In en, this message translates to:
  /// **'The weather service is taking too long to respond. Please try again.'**
  String get timeoutMessage;

  /// No description provided for @rateLimitTitle.
  ///
  /// In en, this message translates to:
  /// **'Too many requests'**
  String get rateLimitTitle;

  /// No description provided for @rateLimitMessage.
  ///
  /// In en, this message translates to:
  /// **'The weather service is busy right now. Wait a moment and try again.'**
  String get rateLimitMessage;

  /// No description provided for @cityNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'No city found'**
  String get cityNotFoundTitle;

  /// No description provided for @cityNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t find “{query}”. Check the spelling or try a nearby city.'**
  String cityNotFoundMessage(String query);

  /// No description provided for @serverTitle.
  ///
  /// In en, this message translates to:
  /// **'Weather service unavailable'**
  String get serverTitle;

  /// No description provided for @serverMessage.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on the server. Please try again later.'**
  String get serverMessage;

  /// No description provided for @locationDisabledTitle.
  ///
  /// In en, this message translates to:
  /// **'Location is turned off'**
  String get locationDisabledTitle;

  /// No description provided for @locationDisabledMessage.
  ///
  /// In en, this message translates to:
  /// **'Turn on location services to see the weather where you are.'**
  String get locationDisabledMessage;

  /// No description provided for @locationDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Location permission needed'**
  String get locationDeniedTitle;

  /// No description provided for @locationDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'Allow location access to see the weather where you are.'**
  String get locationDeniedMessage;

  /// No description provided for @locationBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Location access blocked'**
  String get locationBlockedTitle;

  /// No description provided for @locationBlockedMessage.
  ///
  /// In en, this message translates to:
  /// **'Enable location access for Nimbus in your device settings.'**
  String get locationBlockedMessage;

  /// No description provided for @locationUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t find your location'**
  String get locationUnavailableTitle;

  /// No description provided for @locationUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t get a GPS fix. Try again or search for a city instead.'**
  String get locationUnavailableMessage;

  /// No description provided for @unknownTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get unknownTitle;

  /// No description provided for @unknownMessage.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get unknownMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'gu', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
