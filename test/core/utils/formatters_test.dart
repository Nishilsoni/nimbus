import 'package:flutter_test/flutter_test.dart';
import 'package:nimbus/core/constants/app_strings.dart';
import 'package:nimbus/core/utils/country_flag.dart';
import 'package:nimbus/core/utils/date_formatter.dart';
import 'package:nimbus/core/utils/unit_formatter.dart';

void main() {
  group('DateFormatter.relative', () {
    final now = DateTime(2026, 9, 24, 12);

    String relative(Duration ago) =>
        DateFormatter.relative(now.subtract(ago), now: now);

    test('says "just now" under a minute', () {
      expect(relative(const Duration(seconds: 59)), AppStrings.justNow);
    });

    test('counts minutes under an hour', () {
      expect(relative(const Duration(minutes: 5)), '5 min ago');
    });

    test('counts hours under a day', () {
      expect(relative(const Duration(hours: 3, minutes: 40)), '3 h ago');
    });

    test('shows the date for anything older', () {
      expect(relative(const Duration(days: 2)), '22 Sep, 12:00 PM');
    });
  });

  group('UnitFormatter', () {
    test('rounds temperatures to whole degrees', () {
      expect(UnitFormatter.temperature(32.6), '33°');
      expect(UnitFormatter.temperature(-0.4), '0°');
      expect(UnitFormatter.temperature(-3.6), '-4°');
    });

    test('drops a trailing .0 but keeps real decimals', () {
      expect(UnitFormatter.precipitation(0), '0 mm');
      expect(UnitFormatter.precipitation(2.45), '2.5 mm');
      expect(UnitFormatter.uvIndex(7), '7');
      expect(UnitFormatter.uvIndex(7.4), '7.4');
      expect(UnitFormatter.uvIndex(null), AppStrings.notAvailable);
    });

    test('names WHO UV levels', () {
      expect(UnitFormatter.uvLevel(1), AppStrings.uvLow);
      expect(UnitFormatter.uvLevel(4.5), AppStrings.uvModerate);
      expect(UnitFormatter.uvLevel(7.4), AppStrings.uvHigh);
      expect(UnitFormatter.uvLevel(10), AppStrings.uvVeryHigh);
      expect(UnitFormatter.uvLevel(12), AppStrings.uvExtreme);
      expect(UnitFormatter.uvLevel(null), isNull);
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
}
