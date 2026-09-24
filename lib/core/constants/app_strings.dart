/// Every user-facing string in one place, so copy stays consistent and is
/// easy to localise later.
abstract final class AppStrings {
  static const appName = 'Nimbus';
  static const appTagline = 'Weather, clearly.';

  // Weather screen
  static const searchCity = 'Search city';
  static const useMyLocation = 'Use my location';
  static const refresh = 'Refresh';
  static const refreshing = 'Refreshing…';
  static const loadingWeather = 'Loading weather';

  // Appearance
  static const appearanceAutomatic = 'Theme: automatic (day and night)';
  static const appearanceLight = 'Theme: light';
  static const appearanceDark = 'Theme: dark';
  static const dismiss = 'Dismiss';
  static const welcomeTitle = 'Welcome to Nimbus';
  static const welcomeMessage =
      'Search for a city or use your location to see the current weather.';
  static const feelsLike = 'Feels like';
  static const humidity = 'Humidity';
  static const wind = 'Wind';
  static const precipitation = 'Precipitation';
  static const uvIndex = 'UV index';
  static const pressure = 'Pressure';
  static const sunrise = 'Sunrise';
  static const sunset = 'Sunset';
  static const notAvailable = '—';

  static String highLow(String high, String low) => 'H $high  ·  L $low';
  static String feelsLikeValue(String value) => 'Feels like $value';
  static String lastUpdated(String relativeTime) =>
      'Last updated $relativeTime';

  // Relative time
  static const justNow = 'just now';
  static String minutesAgo(int minutes) => '$minutes min ago';
  static String hoursAgo(int hours) => '$hours h ago';
  static String updated(String relativeTime) => 'Updated $relativeTime';

  // UV index levels
  static const uvLow = 'Low';
  static const uvModerate = 'Moderate';
  static const uvHigh = 'High';
  static const uvVeryHigh = 'Very high';
  static const uvExtreme = 'Extreme';

  // Weather conditions
  static const conditionClear = 'Clear sky';
  static const conditionPartlyCloudy = 'Partly cloudy';
  static const conditionCloudy = 'Cloudy';
  static const conditionFog = 'Foggy';
  static const conditionDrizzle = 'Drizzle';
  static const conditionRain = 'Rain';
  static const conditionSnow = 'Snow';
  static const conditionThunderstorm = 'Thunderstorm';
  static const conditionUnknown = 'Unknown';

  // City search
  static const searchHint = 'Search for a city';
  static const searchIdleMessage = 'Type at least 2 letters to search.';
  static const clearSearch = 'Clear';
  static const currentLocation = 'Current location';
  static const currentLocationSubtitle = 'Use GPS to find weather near you';

  // Failures
  static const tryAgain = 'Try again';
  static const openSettings = 'Open settings';
  static const noInternetTitle = 'No internet connection';
  static const noInternetMessage = 'Check your connection and try again.';
  static const timeoutTitle = 'Request timed out';
  static const timeoutMessage =
      'The weather service is taking too long to respond. Please try again.';
  static const rateLimitTitle = 'Too many requests';
  static const rateLimitMessage =
      'The weather service is busy right now. Wait a moment and try again.';
  static const cityNotFoundTitle = 'No city found';
  static String cityNotFoundMessage(String query) =>
      'We couldn’t find “$query”. Check the spelling or try a nearby city.';
  static const serverTitle = 'Weather service unavailable';
  static const serverMessage =
      'Something went wrong on the server. Please try again later.';
  static const locationDisabledTitle = 'Location is turned off';
  static const locationDisabledMessage =
      'Turn on location services to see the weather where you are.';
  static const locationDeniedTitle = 'Location permission needed';
  static const locationDeniedMessage =
      'Allow location access to see the weather where you are.';
  static const locationBlockedTitle = 'Location access blocked';
  static const locationBlockedMessage =
      'Enable location access for Nimbus in your device settings.';
  static const locationUnavailableTitle = 'Couldn’t find your location';
  static const locationUnavailableMessage =
      'We couldn’t get a GPS fix. Try again or search for a city instead.';
  static const unknownTitle = 'Something went wrong';
  static const unknownMessage =
      'An unexpected error occurred. Please try again.';
}
