import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nimbus/core/error/exceptions.dart';
import 'package:nimbus/core/network/api_client.dart';
import 'package:nimbus/core/network/network_info.dart';

class _FakeNetworkInfo implements NetworkInfo {
  bool connected = true;

  @override
  Future<bool> get isConnected async => connected;
}

void main() {
  final uri = Uri.https('example.com', '/data');
  late _FakeNetworkInfo networkInfo;

  setUp(() => networkInfo = _FakeNetworkInfo());

  ApiClient clientReturning(
    Future<http.Response> Function(http.Request) handler, {
    Duration timeout = const Duration(seconds: 1),
  }) => ApiClient(
    httpClient: MockClient(handler),
    networkInfo: networkInfo,
    timeout: timeout,
  );

  test('returns decoded JSON for a 200 response', () async {
    final client = clientReturning((_) async => http.Response('{"a": 1}', 200));

    expect(await client.getJson(uri), {'a': 1});
  });

  test('decodes UTF-8 even when the charset header is missing', () async {
    final client = clientReturning(
      (_) async => http.Response.bytes(utf8.encode('{"name": "Zürich"}'), 200),
    );

    expect(await client.getJson(uri), {'name': 'Zürich'});
  });

  test(
    'throws NoInternetException without calling the server when offline',
    () async {
      var called = false;
      networkInfo.connected = false;
      final client = clientReturning((_) async {
        called = true;
        return http.Response('{}', 200);
      });

      await expectLater(
        client.getJson(uri),
        throwsA(isA<NoInternetException>()),
      );
      expect(called, isFalse);
    },
  );

  test('maps socket errors to NoInternetException', () async {
    final client = clientReturning(
      (_) async => throw const SocketException('Failed host lookup'),
    );

    await expectLater(client.getJson(uri), throwsA(isA<NoInternetException>()));
  });

  test('maps client errors to NoInternetException', () async {
    final client = clientReturning(
      (_) async => throw http.ClientException('Connection closed'),
    );

    await expectLater(client.getJson(uri), throwsA(isA<NoInternetException>()));
  });

  test('throws RequestTimeoutException when the server is too slow', () async {
    final client = clientReturning(
      (_) => Completer<http.Response>().future,
      timeout: const Duration(milliseconds: 10),
    );

    await expectLater(
      client.getJson(uri),
      throwsA(isA<RequestTimeoutException>()),
    );
  });

  test('throws RateLimitException for HTTP 429', () async {
    final client = clientReturning((_) async => http.Response('', 429));

    await expectLater(client.getJson(uri), throwsA(isA<RateLimitException>()));
  });

  test('throws ServerException with the API reason for other errors', () async {
    final client = clientReturning(
      (_) async =>
          http.Response('{"error": true, "reason": "Bad latitude"}', 400),
    );

    await expectLater(
      client.getJson(uri),
      throwsA(
        isA<ServerException>()
            .having((e) => e.statusCode, 'statusCode', 400)
            .having((e) => e.reason, 'reason', 'Bad latitude'),
      ),
    );
  });

  test('throws ServerException for a 5xx with a non-JSON body', () async {
    final client = clientReturning((_) async => http.Response('<html>', 503));

    await expectLater(
      client.getJson(uri),
      throwsA(isA<ServerException>().having((e) => e.statusCode, 'code', 503)),
    );
  });

  test(
    'throws ParsingException when a 200 body is not a JSON object',
    () async {
      final client = clientReturning((_) async => http.Response('[1, 2]', 200));

      await expectLater(client.getJson(uri), throwsA(isA<ParsingException>()));
    },
  );
}
