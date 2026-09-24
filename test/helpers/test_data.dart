import 'package:nimbus/features/weather/domain/entities/city.dart';
import 'package:nimbus/features/weather/domain/entities/forecast.dart';
import 'package:nimbus/features/weather/domain/entities/weather.dart';
import 'package:nimbus/features/weather/domain/entities/weather_condition.dart';
import 'package:nimbus/features/weather/domain/entities/weather_report.dart';

/// Shared sample data so tests read as behaviour, not setup.
abstract final class TestData {
  static const ahmedabad = City(
    id: 1279233,
    name: 'Ahmedabad',
    region: 'Gujarat',
    country: 'India',
    countryCode: 'IN',
    latitude: 23.02579,
    longitude: 72.58727,
  );

  static const london = City(
    id: 2643743,
    name: 'London',
    region: 'England',
    country: 'United Kingdom',
    countryCode: 'GB',
    latitude: 51.50853,
    longitude: -0.12574,
  );

  static const currentLocation = City(
    name: 'Navrangpura',
    region: 'Gujarat',
    country: 'India',
    countryCode: 'IN',
    latitude: 23.03,
    longitude: 72.56,
    isCurrentLocation: true,
  );

  static final hourly = [
    for (var hour = 0; hour < 24; hour++)
      HourlyForecast(
        time: DateTime(2026, 9, 24, 21).add(Duration(hours: hour)),
        temperature: 30 - (hour % 12) * 0.5,
        condition: hour.isEven
            ? WeatherCondition.clear
            : WeatherCondition.partlyCloudy,
        isDay: hour > 9 && hour < 21,
        precipitationChance: hour == 5 ? 40 : 0,
      ),
  ];

  static final daily = [
    for (var day = 0; day < 7; day++)
      DailyForecast(
        date: DateTime(2026, 9, 24 + day),
        condition: day == 2 ? WeatherCondition.rain : WeatherCondition.cloudy,
        high: 36.7 - day,
        low: 27.4 - day / 2,
        precipitationChance: day == 2 ? 70 : 0,
      ),
  ];

  static final weather = Weather(
    condition: WeatherCondition.clear,
    isDay: false,
    temperature: 32.6,
    feelsLike: 37.4,
    highTemperature: 36.7,
    lowTemperature: 27.4,
    humidity: 60,
    windSpeed: 8,
    precipitation: 0,
    pressure: 999.3,
    observedAt: DateTime(2026, 9, 24, 21),
    uvIndex: 7.4,
    sunrise: DateTime(2026, 9, 24, 6, 28),
    sunset: DateTime(2026, 9, 24, 18, 34),
    hourly: hourly,
    daily: daily,
  );

  static final fetchedAt = DateTime(2026, 9, 24, 21, 5);

  static WeatherReport report({City city = ahmedabad, DateTime? at}) =>
      WeatherReport(city: city, weather: weather, fetchedAt: at ?? fetchedAt);
}
