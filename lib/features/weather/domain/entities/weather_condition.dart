/// The weather categories the app knows how to illustrate.
///
/// The domain doesn't care which API codes produce these; the data layer
/// maps provider-specific codes onto them.
enum WeatherCondition {
  clear,
  partlyCloudy,
  cloudy,
  fog,
  drizzle,
  rain,
  snow,
  thunderstorm,
  unknown,
}
