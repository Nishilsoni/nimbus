import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:nimbus/core/constants/api_constants.dart';
import 'package:nimbus/core/error/exceptions.dart';
import 'package:nimbus/core/network/network_info.dart';
import 'package:nimbus/core/utils/json_reader.dart';

/// The single gateway for HTTP calls.
///
/// It turns every transport problem into an [AppException], so data sources
/// only deal with successful JSON and never with sockets or status codes.
class ApiClient {
  ApiClient({
    required http.Client httpClient,
    required NetworkInfo networkInfo,
    this.timeout = ApiConstants.requestTimeout,
  }) : _httpClient = httpClient,
       _networkInfo = networkInfo;

  final http.Client _httpClient;
  final NetworkInfo _networkInfo;
  final Duration timeout;

  Future<Map<String, dynamic>> getJson(Uri uri) async {
    if (!await _networkInfo.isConnected) throw const NoInternetException();

    final http.Response response;
    try {
      response = await _httpClient.get(uri).timeout(timeout);
    } on TimeoutException {
      throw const RequestTimeoutException();
    } on http.ClientException {
      throw const NoInternetException();
    } on IOException {
      throw const NoInternetException();
    }

    if (response.statusCode == HttpStatus.tooManyRequests) {
      throw const RateLimitException();
    }

    final body = _decode(response);
    final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
    if (!isSuccess) {
      throw ServerException(
        response.statusCode,
        reason: body?.optionalString('reason'),
      );
    }
    if (body == null) {
      throw const ParsingException('Response body is not a JSON object');
    }
    return body;
  }

  /// Decodes the body as UTF-8. `response.body` would fall back to Latin-1
  /// when the charset header is missing and mangle names like "Zürich".
  Map<String, dynamic>? _decode(http.Response response) {
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      return decoded is Map<String, dynamic> ? decoded : null;
    } on FormatException {
      return null;
    }
  }
}
