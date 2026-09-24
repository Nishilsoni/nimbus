// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Nimbus';

  @override
  String get appTagline => 'Weather, clearly.';

  @override
  String get searchCity => 'Search city';

  @override
  String get useMyLocation => 'Use my location';

  @override
  String get refresh => 'Refresh';

  @override
  String get refreshing => 'Refreshing…';

  @override
  String get loadingWeather => 'Loading weather';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get welcomeTitle => 'Welcome to Nimbus';

  @override
  String get welcomeMessage =>
      'Search for a city or use your location to see the current weather.';

  @override
  String get feelsLike => 'Feels like';

  @override
  String get humidity => 'Humidity';

  @override
  String get wind => 'Wind';

  @override
  String get precipitation => 'Precipitation';

  @override
  String get uvIndex => 'UV index';

  @override
  String get pressure => 'Pressure';

  @override
  String get sunrise => 'Sunrise';

  @override
  String get sunset => 'Sunset';

  @override
  String get notAvailable => '—';

  @override
  String highLow(String high, String low) {
    return 'H $high  ·  L $low';
  }

  @override
  String lastUpdated(String time) {
    return 'Last updated $time';
  }

  @override
  String updated(String time) {
    return 'Updated $time';
  }

  @override
  String get justNow => 'just now';

  @override
  String minutesAgo(int minutes) {
    return '$minutes min ago';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours h ago';
  }

  @override
  String get uvLow => 'Low';

  @override
  String get uvModerate => 'Moderate';

  @override
  String get uvHigh => 'High';

  @override
  String get uvVeryHigh => 'Very high';

  @override
  String get uvExtreme => 'Extreme';

  @override
  String get conditionClear => 'Clear sky';

  @override
  String get conditionPartlyCloudy => 'Partly cloudy';

  @override
  String get conditionCloudy => 'Cloudy';

  @override
  String get conditionFog => 'Foggy';

  @override
  String get conditionDrizzle => 'Drizzle';

  @override
  String get conditionRain => 'Rain';

  @override
  String get conditionSnow => 'Snow';

  @override
  String get conditionThunderstorm => 'Thunderstorm';

  @override
  String get conditionUnknown => 'Unknown';

  @override
  String get searchHint => 'Search for a city';

  @override
  String get searchIdleMessage => 'Type at least 2 letters to search.';

  @override
  String get clearSearch => 'Clear';

  @override
  String get currentLocation => 'Current location';

  @override
  String get currentLocationSubtitle => 'Use GPS to find weather near you';

  @override
  String get myLocation => 'My location';

  @override
  String get yourPlaces => 'Your places';

  @override
  String removePlace(String name) {
    return 'Remove $name';
  }

  @override
  String placeIndicator(int index, int count) {
    return 'Place $index of $count';
  }

  @override
  String get hourlyForecastTitle => 'Next 24 hours';

  @override
  String get dailyForecastTitle => '7-day forecast';

  @override
  String get now => 'Now';

  @override
  String get today => 'Today';

  @override
  String get settings => 'Settings';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeAutomatic => 'Auto';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeAutomaticHint =>
      'Auto is light by day and dark by night at the city on screen.';

  @override
  String get settingsTemperature => 'Temperature';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get tryAgain => 'Try again';

  @override
  String get openSettings => 'Open settings';

  @override
  String get noInternetTitle => 'No internet connection';

  @override
  String get noInternetMessage => 'Check your connection and try again.';

  @override
  String get timeoutTitle => 'Request timed out';

  @override
  String get timeoutMessage =>
      'The weather service is taking too long to respond. Please try again.';

  @override
  String get rateLimitTitle => 'Too many requests';

  @override
  String get rateLimitMessage =>
      'The weather service is busy right now. Wait a moment and try again.';

  @override
  String get cityNotFoundTitle => 'No city found';

  @override
  String cityNotFoundMessage(String query) {
    return 'We couldn’t find “$query”. Check the spelling or try a nearby city.';
  }

  @override
  String get serverTitle => 'Weather service unavailable';

  @override
  String get serverMessage =>
      'Something went wrong on the server. Please try again later.';

  @override
  String get locationDisabledTitle => 'Location is turned off';

  @override
  String get locationDisabledMessage =>
      'Turn on location services to see the weather where you are.';

  @override
  String get locationDeniedTitle => 'Location permission needed';

  @override
  String get locationDeniedMessage =>
      'Allow location access to see the weather where you are.';

  @override
  String get locationBlockedTitle => 'Location access blocked';

  @override
  String get locationBlockedMessage =>
      'Enable location access for Nimbus in your device settings.';

  @override
  String get locationUnavailableTitle => 'Couldn’t find your location';

  @override
  String get locationUnavailableMessage =>
      'We couldn’t get a GPS fix. Try again or search for a city instead.';

  @override
  String get unknownTitle => 'Something went wrong';

  @override
  String get unknownMessage =>
      'An unexpected error occurred. Please try again.';
}
