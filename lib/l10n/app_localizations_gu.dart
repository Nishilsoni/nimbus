// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Gujarati (`gu`).
class AppLocalizationsGu extends AppLocalizations {
  AppLocalizationsGu([String locale = 'gu']) : super(locale);

  @override
  String get appName => 'Nimbus';

  @override
  String get appTagline => 'હવામાન, સ્પષ્ટ રીતે.';

  @override
  String get searchCity => 'શહેર શોધો';

  @override
  String get useMyLocation => 'મારું સ્થાન';

  @override
  String get refresh => 'રિફ્રેશ કરો';

  @override
  String get refreshing => 'રિફ્રેશ થઈ રહ્યું છે…';

  @override
  String get loadingWeather => 'હવામાન લોડ થઈ રહ્યું છે';

  @override
  String get dismiss => 'બંધ કરો';

  @override
  String get welcomeTitle => 'Nimbus માં આપનું સ્વાગત છે';

  @override
  String get welcomeMessage =>
      'હાલનું હવામાન જોવા માટે કોઈ શહેર શોધો અથવા તમારા સ્થાનનો ઉપયોગ કરો.';

  @override
  String get feelsLike => 'અનુભવાય છે';

  @override
  String get humidity => 'ભેજ';

  @override
  String get wind => 'પવન';

  @override
  String get precipitation => 'વરસાદ';

  @override
  String get uvIndex => 'યુવી સૂચકાંક';

  @override
  String get pressure => 'દબાણ';

  @override
  String get sunrise => 'સૂર્યોદય';

  @override
  String get sunset => 'સૂર્યાસ્ત';

  @override
  String get notAvailable => '—';

  @override
  String highLow(String high, String low) {
    return 'મહત્તમ $high  ·  લઘુત્તમ $low';
  }

  @override
  String lastUpdated(String time) {
    return 'છેલ્લે અપડેટ $time';
  }

  @override
  String updated(String time) {
    return 'અપડેટ: $time';
  }

  @override
  String get justNow => 'હમણાં જ';

  @override
  String minutesAgo(int minutes) {
    return '$minutes મિનિટ પહેલાં';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours કલાક પહેલાં';
  }

  @override
  String get uvLow => 'ઓછું';

  @override
  String get uvModerate => 'મધ્યમ';

  @override
  String get uvHigh => 'વધુ';

  @override
  String get uvVeryHigh => 'ખૂબ વધુ';

  @override
  String get uvExtreme => 'અતિશય';

  @override
  String get conditionClear => 'સ્વચ્છ આકાશ';

  @override
  String get conditionPartlyCloudy => 'આંશિક વાદળછાયું';

  @override
  String get conditionCloudy => 'વાદળછાયું';

  @override
  String get conditionFog => 'ધુમ્મસ';

  @override
  String get conditionDrizzle => 'ઝરમર';

  @override
  String get conditionRain => 'વરસાદ';

  @override
  String get conditionSnow => 'હિમવર્ષા';

  @override
  String get conditionThunderstorm => 'વાવાઝોડું';

  @override
  String get conditionUnknown => 'અજ્ઞાત';

  @override
  String get searchHint => 'કોઈ શહેર શોધો';

  @override
  String get searchIdleMessage => 'શોધવા માટે ઓછામાં ઓછા 2 અક્ષર લખો.';

  @override
  String get clearSearch => 'સાફ કરો';

  @override
  String get currentLocation => 'હાલનું સ્થાન';

  @override
  String get currentLocationSubtitle => 'નજીકનું હવામાન જાણવા GPS નો ઉપયોગ કરો';

  @override
  String get myLocation => 'મારું સ્થાન';

  @override
  String get yourPlaces => 'તમારાં સ્થળો';

  @override
  String removePlace(String name) {
    return '$name દૂર કરો';
  }

  @override
  String placeIndicator(int index, int count) {
    return '$count માંથી સ્થળ $index';
  }

  @override
  String get hourlyForecastTitle => 'આગામી 24 કલાક';

  @override
  String get dailyForecastTitle => '7 દિવસની આગાહી';

  @override
  String get now => 'હમણાં';

  @override
  String get today => 'આજે';

  @override
  String get settings => 'સેટિંગ્સ';

  @override
  String get settingsTheme => 'થીમ';

  @override
  String get themeAutomatic => 'ઓટો';

  @override
  String get themeLight => 'લાઇટ';

  @override
  String get themeDark => 'ડાર્ક';

  @override
  String get themeAutomaticHint =>
      'ઓટોમાં સ્ક્રીન પરના શહેરમાં દિવસે લાઇટ અને રાત્રે ડાર્ક થીમ રહે છે.';

  @override
  String get settingsTemperature => 'તાપમાન';

  @override
  String get settingsLanguage => 'ભાષા';

  @override
  String get languageSystem => 'સિસ્ટમ';

  @override
  String get tryAgain => 'ફરી પ્રયાસ કરો';

  @override
  String get openSettings => 'સેટિંગ્સ ખોલો';

  @override
  String get noInternetTitle => 'ઇન્ટરનેટ કનેક્શન નથી';

  @override
  String get noInternetMessage => 'તમારું કનેક્શન તપાસો અને ફરી પ્રયાસ કરો.';

  @override
  String get timeoutTitle => 'વિનંતીનો સમય પૂરો થયો';

  @override
  String get timeoutMessage =>
      'હવામાન સેવા જવાબ આપવામાં બહુ સમય લઈ રહી છે. કૃપા કરીને ફરી પ્રયાસ કરો.';

  @override
  String get rateLimitTitle => 'ઘણી બધી વિનંતીઓ';

  @override
  String get rateLimitMessage =>
      'હવામાન સેવા હમણાં વ્યસ્ત છે. થોડી વાર રાહ જોઈને ફરી પ્રયાસ કરો.';

  @override
  String get cityNotFoundTitle => 'કોઈ શહેર મળ્યું નહીં';

  @override
  String cityNotFoundMessage(String query) {
    return 'અમને “$query” મળ્યું નહીં. જોડણી તપાસો અથવા નજીકનું શહેર અજમાવો.';
  }

  @override
  String get serverTitle => 'હવામાન સેવા ઉપલબ્ધ નથી';

  @override
  String get serverMessage =>
      'સર્વર પર કંઈક ખોટું થયું. કૃપા કરીને પછીથી ફરી પ્રયાસ કરો.';

  @override
  String get locationDisabledTitle => 'લોકેશન બંધ છે';

  @override
  String get locationDisabledMessage =>
      'તમારા સ્થાનનું હવામાન જોવા લોકેશન સેવાઓ ચાલુ કરો.';

  @override
  String get locationDeniedTitle => 'લોકેશનની પરવાનગી જરૂરી છે';

  @override
  String get locationDeniedMessage =>
      'તમારા સ્થાનનું હવામાન જોવા લોકેશનની પરવાનગી આપો.';

  @override
  String get locationBlockedTitle => 'લોકેશનની પરવાનગી બંધ છે';

  @override
  String get locationBlockedMessage =>
      'ડિવાઇસ સેટિંગ્સમાં Nimbus માટે લોકેશનની પરવાનગી ચાલુ કરો.';

  @override
  String get locationUnavailableTitle => 'તમારું સ્થાન મળ્યું નહીં';

  @override
  String get locationUnavailableMessage =>
      'GPS થી સ્થાન મળી શક્યું નહીં. ફરી પ્રયાસ કરો અથવા કોઈ શહેર શોધો.';

  @override
  String get unknownTitle => 'કંઈક ખોટું થયું';

  @override
  String get unknownMessage => 'અણધારી ભૂલ આવી. કૃપા કરીને ફરી પ્રયાસ કરો.';
}
