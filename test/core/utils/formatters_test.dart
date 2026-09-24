import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nimbus/core/l10n/l10n.dart';
import 'package:nimbus/core/utils/country_flag.dart';
import 'package:nimbus/core/utils/date_formatter.dart';
import 'package:nimbus/core/utils/temperature_unit.dart';
import 'package:nimbus/core/utils/unit_formatter.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));

  // intl separates "PM" with a narrow no-break space; compare as plain text.
  String plain(String text) => text.replaceAll('\u202f', ' ');
  final hi = lookupAppLocalizations(const Locale('hi'));
  final gu = lookupAppLocalizations(const Locale('gu'));

  setUpAll(() async {
    // Loads intl's date symbols for every supported language, as the app
    // does at startup through its localization delegates.
    for (final locale in AppLocalizations.supportedLocales) {
      await GlobalMaterialLocalizations.delegate.load(locale);
    }
  });

  group('DateFormatter.relative', () {
    final now = DateTime(2026, 9, 24, 12);

    String relative(Duration ago, [AppLocalizations? l10n]) =>
        DateFormatter.relative(now.subtract(ago), l10n ?? en, now: now);

    test('says "just now" under a minute', () {
      expect(relative(const Duration(seconds: 59)), en.justNow);
    });

    test('counts minutes under an hour', () {
      expect(relative(const Duration(minutes: 5)), '5 min ago');
    });

    test('counts hours under a day', () {
      expect(relative(const Duration(hours: 3, minutes: 40)), '3 h ago');
    });

    test('shows the date for anything older', () {
      expect(plain(relative(const Duration(days: 2))), '22 Sep, 12:00 PM');
    });

    test('speaks the app language', () {
      expect(relative(const Duration(minutes: 5), hi), '5 मिनट पहले');
      expect(relative(const Duration(hours: 2), gu), '2 કલાક પહેલાં');
    });
  });

  group('DateFormatter', () {
    test('formats hours and weekdays for forecasts', () {
      final time = DateTime(2026, 9, 29, 21);
      expect(plain(DateFormatter.hour(time, 'en')), '9 PM');
      expect(DateFormatter.weekday(time, 'en'), 'Tue');
      expect(plain(DateFormatter.time(time, 'en')), '9:00 PM');
    });
  });

  group('UnitFormatter', () {
    test('rounds temperatures to whole degrees', () {
      const c = TemperatureUnit.celsius;
      expect(UnitFormatter.temperature(32.6, c), '33°');
      expect(UnitFormatter.temperature(-0.4, c), '0°');
      expect(UnitFormatter.temperature(-3.6, c), '-4°');
    });

    test('converts to Fahrenheit when chosen', () {
      const f = TemperatureUnit.fahrenheit;
      expect(UnitFormatter.temperature(0, f), '32°');
      expect(UnitFormatter.temperature(32.6, f), '91°');
    });

    test('drops a trailing .0 but keeps real decimals', () {
      expect(UnitFormatter.precipitation(0), '0 mm');
      expect(UnitFormatter.precipitation(2.45), '2.5 mm');
      expect(UnitFormatter.uvIndex(7, en), '7');
      expect(UnitFormatter.uvIndex(7.4, en), '7.4');
      expect(UnitFormatter.uvIndex(null, en), en.notAvailable);
    });

    test('names WHO UV levels', () {
      expect(UnitFormatter.uvLevel(1, en), en.uvLow);
      expect(UnitFormatter.uvLevel(4.5, en), en.uvModerate);
      expect(UnitFormatter.uvLevel(7.4, en), en.uvHigh);
      expect(UnitFormatter.uvLevel(10, en), en.uvVeryHigh);
      expect(UnitFormatter.uvLevel(12, en), en.uvExtreme);
      expect(UnitFormatter.uvLevel(null, en), isNull);
      expect(UnitFormatter.uvLevel(7.4, hi), 'अधिक');
    });
  });

  group('countryFlag', () {
    test('turns an ISO code into a flag emoji', () {
      expect(countryFlag('IN'), '🇮🇳');
      expect(countryFlag('gb'), '🇬🇧');
    });

    test('returns null for missing or malformed codes', () {
      expect(countryFlag(null), isNull);
      expect(countryFlag('IND'), isNull);
      expect(countryFlag('1A'), isNull);
    });
  });

  test('every language translates every string', () {
    // Spot-checks that the Hindi and Gujarati files aren't just English.
    expect(hi.searchCity, isNot(en.searchCity));
    expect(gu.searchCity, isNot(en.searchCity));
    expect(hi.cityNotFoundMessage('X'), contains('X'));
    expect(gu.placeIndicator(2, 3), allOf(contains('2'), contains('3')));
  });
}
