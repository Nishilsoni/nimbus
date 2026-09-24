import 'package:flutter_test/flutter_test.dart';
import 'package:nimbus/features/weather/data/mappers/wmo_code_mapper.dart';
import 'package:nimbus/features/weather/domain/entities/weather_condition.dart';

void main() {
  const expectations = {
    0: WeatherCondition.clear,
    1: WeatherCondition.partlyCloudy,
    2: WeatherCondition.partlyCloudy,
    3: WeatherCondition.cloudy,
    45: WeatherCondition.fog,
    48: WeatherCondition.fog,
    51: WeatherCondition.drizzle,
    57: WeatherCondition.drizzle,
    61: WeatherCondition.rain,
    67: WeatherCondition.rain,
    80: WeatherCondition.rain,
    82: WeatherCondition.rain,
    71: WeatherCondition.snow,
    77: WeatherCondition.snow,
    86: WeatherCondition.snow,
    95: WeatherCondition.thunderstorm,
    99: WeatherCondition.thunderstorm,
  };

  expectations.forEach((code, condition) {
    test('maps WMO code $code to ${condition.name}', () {
      expect(WmoCodeMapper.toCondition(code), condition);
    });
  });

  test('maps codes outside the WMO table to unknown', () {
    expect(WmoCodeMapper.toCondition(4), WeatherCondition.unknown);
    expect(WmoCodeMapper.toCondition(-1), WeatherCondition.unknown);
    expect(WmoCodeMapper.toCondition(100), WeatherCondition.unknown);
  });
}
