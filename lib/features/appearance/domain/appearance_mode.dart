/// How the app chooses between its light and dark looks.
enum AppearanceMode {
  /// Light by day and dark by night at the city on screen. Before any
  /// weather has loaded, follows the device's light/dark setting.
  automatic,
  light,
  dark;

  /// The next mode when the toggle is tapped: automatic → light → dark.
  AppearanceMode get next => values[(index + 1) % values.length];
}
