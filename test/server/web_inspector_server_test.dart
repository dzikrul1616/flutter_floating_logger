import 'dart:convert';
import 'dart:io';
import 'package:floating_logger/floating_logger.dart';
import 'package:flutter_test/flutter_test.dart';

class _AllowAllHttpOverrides extends HttpOverrides {}

void main() {
  group('WebInspectorServer Tests', () {
    final server = WebInspectorServer.instance;

    setUp(() async {
      if (server.isRunningNotifier.value) {
        await server.stop();
      }
      DioLogger.instance.logs.clearLogs();
    });

    tearDown(() async {
      if (server.isRunningNotifier.value) {
        await server.stop();
      }
      DioLogger.instance.logs.clearLogs();
    });

    test('Server starts and stops cleanly', () async {
      expect(server.isRunningNotifier.value, isFalse);
      expect(server.serverUrl, isNull);

      final started = await server.start(port: 29990);
      expect(started, isTrue);
      expect(server.isRunningNotifier.value, isTrue);
      expect(server.currentPort, 29990);
      expect(server.serverUrl, contains('29990'));

      // Toggling should stop the server
      final toggledOff = await server.toggle(port: 29990);
      expect(toggledOff, isFalse);
      expect(server.isRunningNotifier.value, isFalse);
      expect(server.serverUrl, isNull);
    });

    test('GET / serves HTML Dashboard', () async {
      await HttpOverrides.runWithHttpOverrides(() async {
        await server.start(port: 29991);
        final client = HttpClient();

        final req = await client.getUrl(Uri.parse('http://127.0.0.1:29991/'));
        final res = await req.close();

        expect(res.statusCode, HttpStatus.ok);
        expect(res.headers.contentType?.mimeType, 'text/html');

        final body = await res.transform(utf8.decoder).join();
        expect(body, contains('Floating Logger'));
        expect(body, contains('Web Inspector'));
        expect(body, contains('<!DOCTYPE html>'));

        client.close();
      }, _AllowAllHttpOverrides());
    });

    test('GET /api/logs returns JSON log list', () async {
      await HttpOverrides.runWithHttpOverrides(() async {
        DioLogger.instance.logs.addLog(
          const LogRepositoryModel(
            method: 'GET',
            path: '/api/v1/test',
            type: 'RESPONSE',
            response: '200',
          ),
        );

        await server.start(port: 29992);
        final client = HttpClient();

        final req =
            await client.getUrl(Uri.parse('http://127.0.0.1:29992/api/logs'));
        final res = await req.close();

        expect(res.statusCode, HttpStatus.ok);
        expect(res.headers.contentType?.mimeType, 'application/json');

        final body = await res.transform(utf8.decoder).join();
        final list = jsonDecode(body) as List;
        expect(list.isNotEmpty, isTrue);
        expect(list.first['path'], '/api/v1/test');
        expect(list.first['response'], '200');

        client.close();
      }, _AllowAllHttpOverrides());
    });

    test('GET /api/device-info returns device platform info', () async {
      await HttpOverrides.runWithHttpOverrides(() async {
        await server.start(port: 29996);

        final client = HttpClient();
        final req =
            await client.getUrl(Uri.parse('http://127.0.0.1:29996/api/device-info'));
        final res = await req.close();

        expect(res.statusCode, HttpStatus.ok);
        expect(res.headers.contentType?.mimeType, 'application/json');

        final body = await res.transform(utf8.decoder).join();
        final info = jsonDecode(body) as Map<String, dynamic>;
        expect(info['platform'], isNotNull);
        expect(info['os_version'], isNotNull);

        client.close();
      }, _AllowAllHttpOverrides());
    });

    test('WebSocket /ws connects and receives live log broadcasts', () async {
      await HttpOverrides.runWithHttpOverrides(() async {
        await server.start(port: 29993);

        final ws = await WebSocket.connect('ws://127.0.0.1:29993/ws');
        expect(ws.readyState, WebSocket.open);

        final receivedLogs = <Map<String, dynamic>>[];
        ws.listen((event) {
          final data = jsonDecode(event as String) as Map<String, dynamic>;
          receivedLogs.add(data);
        });

        // Add a log to trigger broadcast
        DioLogger.instance.logs.addLog(
          const LogRepositoryModel(
            method: 'POST',
            path: '/api/v1/live_test',
            type: 'RESPONSE',
            response: '201',
          ),
        );

        // Give a moment for loopback WebSocket event
        await Future.delayed(const Duration(milliseconds: 100));

        expect(receivedLogs.length, 1);
        expect(receivedLogs.first['path'], '/api/v1/live_test');
        expect(receivedLogs.first['response'], '201');

        await ws.close();
      }, _AllowAllHttpOverrides());
    });

    test('Server automatically attempts next port if starting port is busy',
        () async {
      // Bind a dummy server on port 29994
      final busyServer =
          await HttpServer.bind(InternetAddress.anyIPv4, 29994);

      // WebInspectorServer should fallback to 29995
      final started = await server.start(port: 29994);
      expect(started, isTrue);
      expect(server.currentPort, 29995);

      await busyServer.close();
    });
  });
}
