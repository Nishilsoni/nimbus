/// The unit temperatures are shown in. Data stays in Celsius everywhere;
/// conversion happens only when formatting, so switching units never needs
/// a new request.
enum TemperatureUnit {
  celsius('°C'),
  fahrenheit('°F');

  const TemperatureUnit(this.symbol);

  final String symbol;

  double fromCelsius(double celsius) => switch (this) {
    TemperatureUnit.celsius => celsius,
    TemperatureUnit.fahrenheit => celsius * 9 / 5 + 32,
  };
}
