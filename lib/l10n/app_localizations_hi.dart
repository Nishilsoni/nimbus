// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'Nimbus';

  @override
  String get appTagline => 'मौसम, साफ़-साफ़।';

  @override
  String get searchCity => 'शहर खोजें';

  @override
  String get useMyLocation => 'मेरा स्थान';

  @override
  String get refresh => 'रीफ़्रेश करें';

  @override
  String get refreshing => 'रीफ़्रेश हो रहा है…';

  @override
  String get loadingWeather => 'मौसम लोड हो रहा है';

  @override
  String get dismiss => 'बंद करें';

  @override
  String get welcomeTitle => 'Nimbus में आपका स्वागत है';

  @override
  String get welcomeMessage =>
      'मौजूदा मौसम देखने के लिए कोई शहर खोजें या अपने स्थान का उपयोग करें।';

  @override
  String get feelsLike => 'महसूस होता है';

  @override
  String get humidity => 'नमी';

  @override
  String get wind => 'हवा';

  @override
  String get precipitation => 'वर्षा';

  @override
  String get uvIndex => 'यूवी सूचकांक';

  @override
  String get pressure => 'दबाव';

  @override
  String get sunrise => 'सूर्योदय';

  @override
  String get sunset => 'सूर्यास्त';

  @override
  String get notAvailable => '—';

  @override
  String highLow(String high, String low) {
    return 'उच्च $high  ·  निम्न $low';
  }

  @override
  String lastUpdated(String time) {
    return 'अंतिम अपडेट $time';
  }

  @override
  String updated(String time) {
    return 'अपडेट: $time';
  }

  @override
  String get justNow => 'अभी-अभी';

  @override
  String minutesAgo(int minutes) {
    return '$minutes मिनट पहले';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours घंटे पहले';
  }

  @override
  String get uvLow => 'कम';

  @override
  String get uvModerate => 'मध्यम';

  @override
  String get uvHigh => 'अधिक';

  @override
  String get uvVeryHigh => 'बहुत अधिक';

  @override
  String get uvExtreme => 'अत्यधिक';

  @override
  String get conditionClear => 'साफ़ आसमान';

  @override
  String get conditionPartlyCloudy => 'आंशिक रूप से बादल';

  @override
  String get conditionCloudy => 'बादल छाए';

  @override
  String get conditionFog => 'कोहरा';

  @override
  String get conditionDrizzle => 'बूंदाबांदी';

  @override
  String get conditionRain => 'बारिश';

  @override
  String get conditionSnow => 'बर्फ़बारी';

  @override
  String get conditionThunderstorm => 'आंधी-तूफ़ान';

  @override
  String get conditionUnknown => 'अज्ञात';

  @override
  String get searchHint => 'कोई शहर खोजें';

  @override
  String get searchIdleMessage => 'खोजने के लिए कम से कम 2 अक्षर लिखें।';

  @override
  String get clearSearch => 'साफ़ करें';

  @override
  String get currentLocation => 'वर्तमान स्थान';

  @override
  String get currentLocationSubtitle =>
      'पास का मौसम जानने के लिए GPS का उपयोग करें';

  @override
  String get myLocation => 'मेरा स्थान';

  @override
  String get yourPlaces => 'आपके स्थान';

  @override
  String removePlace(String name) {
    return '$name हटाएँ';
  }

  @override
  String placeIndicator(int index, int count) {
    return '$count में से स्थान $index';
  }

  @override
  String get hourlyForecastTitle => 'अगले 24 घंटे';

  @override
  String get dailyForecastTitle => '7 दिन का पूर्वानुमान';

  @override
  String get now => 'अभी';

  @override
  String get today => 'आज';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get settingsTheme => 'थीम';

  @override
  String get themeAutomatic => 'ऑटो';

  @override
  String get themeLight => 'हल्की';

  @override
  String get themeDark => 'गहरी';

  @override
  String get themeAutomaticHint =>
      'ऑटो में स्क्रीन पर दिख रहे शहर में दिन को हल्की और रात को गहरी थीम रहती है।';

  @override
  String get settingsTemperature => 'तापमान';

  @override
  String get settingsLanguage => 'भाषा';

  @override
  String get languageSystem => 'सिस्टम';

  @override
  String get tryAgain => 'फिर से कोशिश करें';

  @override
  String get openSettings => 'सेटिंग्स खोलें';

  @override
  String get noInternetTitle => 'इंटरनेट कनेक्शन नहीं है';

  @override
  String get noInternetMessage => 'अपना कनेक्शन जाँचें और फिर से कोशिश करें।';

  @override
  String get timeoutTitle => 'अनुरोध का समय समाप्त';

  @override
  String get timeoutMessage =>
      'मौसम सेवा जवाब देने में बहुत समय ले रही है। कृपया फिर से कोशिश करें।';

  @override
  String get rateLimitTitle => 'बहुत ज़्यादा अनुरोध';

  @override
  String get rateLimitMessage =>
      'मौसम सेवा अभी व्यस्त है। थोड़ी देर रुककर फिर से कोशिश करें।';

  @override
  String get cityNotFoundTitle => 'कोई शहर नहीं मिला';

  @override
  String cityNotFoundMessage(String query) {
    return 'हमें “$query” नहीं मिला। वर्तनी जाँचें या पास का कोई शहर आज़माएँ।';
  }

  @override
  String get serverTitle => 'मौसम सेवा उपलब्ध नहीं है';

  @override
  String get serverMessage =>
      'सर्वर पर कुछ गड़बड़ हो गई। कृपया बाद में फिर से कोशिश करें।';

  @override
  String get locationDisabledTitle => 'लोकेशन बंद है';

  @override
  String get locationDisabledMessage =>
      'अपने स्थान का मौसम देखने के लिए लोकेशन सेवाएँ चालू करें।';

  @override
  String get locationDeniedTitle => 'लोकेशन की अनुमति चाहिए';

  @override
  String get locationDeniedMessage =>
      'अपने स्थान का मौसम देखने के लिए लोकेशन की अनुमति दें।';

  @override
  String get locationBlockedTitle => 'लोकेशन की अनुमति बंद है';

  @override
  String get locationBlockedMessage =>
      'डिवाइस की सेटिंग्स में Nimbus के लिए लोकेशन की अनुमति चालू करें।';

  @override
  String get locationUnavailableTitle => 'आपका स्थान नहीं मिल सका';

  @override
  String get locationUnavailableMessage =>
      'GPS से स्थान नहीं मिल पाया। फिर से कोशिश करें या कोई शहर खोजें।';

  @override
  String get unknownTitle => 'कुछ गड़बड़ हो गई';

  @override
  String get unknownMessage => 'एक अनचाही त्रुटि हुई। कृपया फिर से कोशिश करें।';
}
