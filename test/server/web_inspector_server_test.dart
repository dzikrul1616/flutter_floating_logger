import 'dart:async';
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
        final port = server.currentPort ?? 29993;

        final ws = await WebSocket.connect('ws://127.0.0.1:$port/ws');
        expect(ws.readyState, WebSocket.open);

        // Wait until server has accepted and added the client to _clients
        for (int i = 0; i < 50; i++) {
          if (server.clientsCount > 0) break;
          await Future.delayed(const Duration(milliseconds: 20));
        }

        final completer = Completer<void>();
        final receivedLogs = <Map<String, dynamic>>[];
        ws.listen((event) {
          final data = jsonDecode(event as String) as Map<String, dynamic>;
          receivedLogs.add(data);
          if (!completer.isCompleted) {
            completer.complete();
          }
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

        // Await incoming message with reasonable timeout for CI
        await completer.future.timeout(
          const Duration(seconds: 5),
          onTimeout: () {},
        );

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

    test('OPTIONS request returns OK with CORS headers', () async {
      await HttpOverrides.runWithHttpOverrides(() async {
        await server.start(port: 29997);
        final client = HttpClient();

        final req = await client.openUrl('OPTIONS', Uri.parse('http://127.0.0.1:29997/api/logs'));
        final res = await req.close();

        expect(res.statusCode, HttpStatus.ok);
        expect(res.headers.value('Access-Control-Allow-Origin'), '*');
        client.close();
      }, _AllowAllHttpOverrides());
    });

    test('Non-upgrade request to /ws returns 400 Bad Request', () async {
      await HttpOverrides.runWithHttpOverrides(() async {
        await server.start(port: 29998);
        final client = HttpClient();

        final req = await client.getUrl(Uri.parse('http://127.0.0.1:29998/ws'));
        final res = await req.close();

        expect(res.statusCode, HttpStatus.badRequest);
        client.close();
      }, _AllowAllHttpOverrides());
    });

    test('Request to unknown path returns 404 Not Found', () async {
      await HttpOverrides.runWithHttpOverrides(() async {
        await server.start(port: 29999);
        final client = HttpClient();

        final req = await client.getUrl(Uri.parse('http://127.0.0.1:29999/unknown_route'));
        final res = await req.close();

        expect(res.statusCode, HttpStatus.notFound);
        client.close();
      }, _AllowAllHttpOverrides());
    });

    test('Simulated internal error returns 500 Internal Server Error', () async {
      await HttpOverrides.runWithHttpOverrides(() async {
        await server.start(port: 30000);
        WebInspectorServer.simulateInternalError = true;
        final client = HttpClient();

        try {
          final req = await client.getUrl(Uri.parse('http://127.0.0.1:30000/api/logs'));
          final res = await req.close();
          expect(res.statusCode, HttpStatus.internalServerError);
        } finally {
          WebInspectorServer.simulateInternalError = false;
          client.close();
        }
      }, _AllowAllHttpOverrides());
    });

    test('Toggle starts the server when it is not running', () async {
      expect(server.isRunningNotifier.value, isFalse);
      final toggledOn = await server.toggle(port: 29988);
      expect(toggledOn, isTrue);
      expect(server.isRunningNotifier.value, isTrue);
      await server.stop();
    });

    test('Device info branches cover simulator and emulator combinations', () {
      // 1. iOS simulator with full env
      final iosInfo = server.getDeviceInfoForTesting(
        isIOS: true,
        isAndroid: false,
        envOverride: {
          'SIMULATOR_DEVICE_NAME': 'iPhone 15 Pro',
          'SIMULATOR_RUNTIME_VERSION': '17.4',
        },
        hostnameOverride: 'my-mac.local',
        osVersionOverride: 'Version 17.4',
      );
      expect(iosInfo['is_simulator'], isTrue);
      expect(iosInfo['device_name'], 'iPhone 15 Pro (Simulator)');
      expect(iosInfo['os_version'], 'iOS 17.4');

      // 2. iOS simulator with fallback name/version
      final iosFallback = server.getDeviceInfoForTesting(
        isIOS: true,
        isAndroid: false,
        envOverride: {
          'SIMULATOR_HOST_HOME': '/Users/someone',
        },
        hostnameOverride: 'some-host',
        osVersionOverride: '17.0',
      );
      expect(iosFallback['is_simulator'], isTrue);
      expect(iosFallback['device_name'], 'iPhone (Simulator)');
      expect(iosFallback['os_version'], 'iOS Simulator');

      // 3. iOS simulator detected by hostname containing 'mac' or ending with '.local'
      final iosByHost = server.getDeviceInfoForTesting(
        isIOS: true,
        isAndroid: false,
        envOverride: {},
        hostnameOverride: 'dzikrul-mac',
      );
      expect(iosByHost['is_simulator'], isTrue);

      // 4. Android emulator
      final androidInfo = server.getDeviceInfoForTesting(
        isIOS: false,
        isAndroid: true,
        envOverride: {},
        hostnameOverride: 'generic_x86_arm',
        osVersionOverride: '14.0',
      );
      expect(androidInfo['is_simulator'], isTrue);
      expect(androidInfo['device_name'], 'Android Emulator');
      expect(androidInfo['os_version'], 'Android 14.0');

      // 5. Android emulator matching 'emulator'
      final androidEmulator = server.getDeviceInfoForTesting(
        isIOS: false,
        isAndroid: true,
        envOverride: {},
        hostnameOverride: 'my-emulator',
        osVersionOverride: '13.0',
      );
      expect(androidEmulator['is_simulator'], isTrue);

      // 6. Regular device (non-simulator)
      final regularInfo = server.getDeviceInfoForTesting(
        isIOS: false,
        isAndroid: false,
        envOverride: {},
        hostnameOverride: 'real-device',
        osVersionOverride: '1.0',
      );
      expect(regularInfo['is_simulator'], isFalse);
      expect(regularInfo['device_name'], 'real-device');
    });
  });
}

