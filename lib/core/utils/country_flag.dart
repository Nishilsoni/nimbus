/// Turns an ISO 3166-1 alpha-2 code ("IN") into its flag emoji ("🇮🇳").
///
/// Flag emoji are pairs of "regional indicator" symbols, one per letter,
/// which start at U+1F1E6 for "A".
String? countryFlag(String? countryCode) {
  if (countryCode == null || countryCode.length != 2) return null;
  const regionalIndicatorA = 0x1F1E6;
  final letters = countryCode.toUpperCase().codeUnits;
  if (letters.any((unit) => unit < 0x41 || unit > 0x5A)) return null;
  return String.fromCharCodes(
    letters.map((unit) => regionalIndicatorA + unit - 0x41),
  );
}
