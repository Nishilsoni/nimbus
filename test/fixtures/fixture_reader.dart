import 'dart:convert';
import 'dart:io';

/// Reads a JSON fixture captured from the real Open-Meteo API.
String fixture(String name) => File('test/fixtures/$name').readAsStringSync();

Map<String, dynamic> jsonFixture(String name) =>
    jsonDecode(fixture(name)) as Map<String, dynamic>;
