/// Typed accessors for decoded JSON.
///
/// Every `require*` method throws a [FormatException] naming the offending
/// key, so a changed API shows up as one clear error instead of a random
/// `TypeError` somewhere in a model.
extension JsonReader on Map<String, dynamic> {
  T require<T>(String key) {
    final value = this[key];
    if (value is T) return value;
    throw FormatException('Expected "$key" to be $T, got ${value.runtimeType}');
  }

  double requireDouble(String key) => require<num>(key).toDouble();

  int requireInt(String key) => require<num>(key).toInt();

  String requireString(String key) => require<String>(key);

  Map<String, dynamic> requireMap(String key) =>
      require<Map<String, dynamic>>(key);

  DateTime requireDateTime(String key) => DateTime.parse(requireString(key));

  double? optionalDouble(String key) => (this[key] as num?)?.toDouble();

  int? optionalInt(String key) => (this[key] as num?)?.toInt();

  String? optionalString(String key) {
    final value = this[key];
    return value is String && value.isNotEmpty ? value : null;
  }

  /// A column of values, e.g. `hourly.temperature_2m`. Entries may be null
  /// where the API has no data.
  List<T?> listOf<T>(String key) {
    final list = require<List<dynamic>>(key);
    return [
      for (final (index, value) in list.indexed)
        if (value == null)
          null
        else if (value is T)
          value
        else
          throw FormatException(
            'Expected "$key[$index]" to be $T, got ${value.runtimeType}',
          ),
    ];
  }

  /// Open-Meteo returns daily values as arrays, one entry per day.
  /// We only request today, so read the first element.
  T? firstOf<T>(String key) {
    final list = require<List<dynamic>>(key);
    if (list.isEmpty) return null;
    final value = list.first;
    if (value == null) return null;
    if (value is T) return value;
    throw FormatException(
      'Expected "$key[0]" to be $T, got ${value.runtimeType}',
    );
  }
}
