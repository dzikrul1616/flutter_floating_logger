import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:floating_logger/floating_logger.dart';

/// Realtime local web server that allows inspecting API logs in a desktop browser.
///
/// Uses standard `dart:io` [HttpServer] and [WebSocketTransformer] for zero dependencies.
class WebInspectorServer {
  static final WebInspectorServer _instance = WebInspectorServer._internal();

  /// Singleton instance of [WebInspectorServer].
  static WebInspectorServer get instance => _instance;

  WebInspectorServer._internal();

  HttpServer? _server;
  final Set<WebSocket> _clients = {};

  /// Current port the server is listening on.
  int? currentPort;

  /// Detected local IPv4 address (e.g., `192.168.1.50`).
  String? currentIp;

  /// Notifier for server running state.
  final ValueNotifier<bool> isRunningNotifier = ValueNotifier<bool>(false);

  @visibleForTesting
  static Future<bool> Function({int port, int maxAttempts})? mockStart;

  @visibleForTesting
  static Future<void> Function()? mockStop;

  @visibleForTesting
  static bool simulateInternalError = false;

  /// Default port used for Web Inspector (21616 avoids common port conflicts).
  static const int defaultPort = 21616;

  /// Returns the full HTTP URL of the inspector if running (e.g. `http://192.168.1.50:21616`).
  String? get serverUrl {
    if (!isRunningNotifier.value || currentPort == null) return null;
    final host = currentIp ?? 'localhost';
    return 'http://$host:$currentPort';
  }

  /// Finds the local IPv4 address of the device using standard `dart:io`.
  static Future<String?> getLocalIpAddress() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );
      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          if (!addr.isLoopback && !addr.address.startsWith('127.')) {
            return addr.address;
          }
        }
      }
    } catch (_) {}
    return null;
  }

  /// Starts the Web Inspector HTTP & WebSocket server.
  ///
  /// - [port]: The starting port (default: `21616`).
  /// - [maxAttempts]: Number of consecutive ports to try if [port] is busy.
  Future<bool> start({int port = defaultPort, int maxAttempts = 10}) async {
    if (mockStart != null) {
      final res = await mockStart!(port: port, maxAttempts: maxAttempts);
      isRunningNotifier.value = res;
      if (res) {
        currentPort = port;
        currentIp = '127.0.0.1';
      }
      return res;
    }

    if (isRunningNotifier.value) return true;

    HttpServer? boundServer;
    int attemptPort = port;

    for (int i = 0; i < maxAttempts; i++) {
      try {
        boundServer = await HttpServer.bind(InternetAddress.anyIPv4, attemptPort);
        break;
      } on SocketException {
        attemptPort++;
      } catch (_) {
        break;
      }
    }

    if (boundServer == null) return false;

    boundServer.idleTimeout = null;
    _server = boundServer;
    currentPort = attemptPort;
    currentIp = await getLocalIpAddress() ?? 'localhost';
    isRunningNotifier.value = true;

    // Listen to log changes and broadcast via WebSocket
    DioLogger.instance.logs.logsNotifier.addListener(_onLogsChanged);

    _listen(boundServer);
    return true;
  }

  /// Stops the Web Inspector server and disconnects active clients.
  Future<void> stop() async {
    if (mockStop != null) {
      await mockStop!();
      isRunningNotifier.value = false;
      currentPort = null;
      return;
    }

    DioLogger.instance.logs.logsNotifier.removeListener(_onLogsChanged);

    for (final client in _clients.toList()) {
      try {
        await client.close();
      } catch (_) {}
    }
    _clients.clear();

    await _server?.close(force: true);
    _server = null;
    currentPort = null;
    isRunningNotifier.value = false;
  }

  /// Toggles the server state on or off.
  Future<bool> toggle({int port = defaultPort}) async {
    if (isRunningNotifier.value) {
      await stop();
      return false;
    } else {
      return await start(port: port);
    }
  }

  void _onLogsChanged() {
    final logs = DioLogger.instance.logs.logsNotifier.value;
    if (logs.isNotEmpty && _clients.isNotEmpty) {
      final newest = logs.first;
      final jsonStr = jsonEncode(newest.toJson());
      for (final client in _clients.toList()) {
        try {
          client.add(jsonStr);
        } catch (_) {}
      }
    }
  }

  void _listen(HttpServer server) {
    server.listen(
      (HttpRequest request) async {
        try {
          // Enable CORS
          request.response.headers.add('Access-Control-Allow-Origin', '*');
          request.response.headers
              .add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
          request.response.headers.add('Access-Control-Allow-Headers', '*');

          if (request.method == 'OPTIONS') {
            request.response.statusCode = HttpStatus.ok;
            await request.response.close();
            return;
          }

          final path = request.uri.path;

          if (simulateInternalError) {
            throw Exception('Simulated Internal Error');
          }

          if (path == '/ws') {
            if (WebSocketTransformer.isUpgradeRequest(request)) {
              final socket = await WebSocketTransformer.upgrade(request);
              _clients.add(socket);
              socket.listen(
                null,
                onDone: () => _clients.remove(socket),
              );
            } else {
              request.response.statusCode = HttpStatus.badRequest;
              await request.response.close();
            }
          } else if (path == '/api/logs') {
            request.response.headers.contentType = ContentType.json;
            final logs = DioLogger.instance.logs.logsNotifier.value
                .map((e) => e.toJson())
                .toList();
            request.response.write(jsonEncode(logs));
            await request.response.close();
          } else if (path == '/api/device-info') {
            request.response.headers.contentType = ContentType.json;
            request.response.write(jsonEncode(_getDeviceInfo()));
            await request.response.close();
          } else if (path == '/' || path == '/index.html') {
            request.response.headers.contentType = ContentType.html;
            request.response.write(kWebInspectorHtml);
            await request.response.close();
          } else {
            request.response.statusCode = HttpStatus.notFound;
            await request.response.close();
          }
        } catch (_) {
          try {
            request.response.statusCode = HttpStatus.internalServerError;
            await request.response.close();
          } catch (_) {}
        }
      },
    );
  }

  Map<String, dynamic> _getDeviceInfo({
    bool? isIOS,
    bool? isAndroid,
    Map<String, String>? envOverride,
    String? hostnameOverride,
    String? osVersionOverride,
  }) {
    final env = envOverride ?? Platform.environment;
    final isIOSVal = isIOS ?? Platform.isIOS;
    final isAndroidVal = isAndroid ?? Platform.isAndroid;
    final localHostname = hostnameOverride ?? Platform.localHostname;
    final rawOsVersion = osVersionOverride ?? Platform.operatingSystemVersion;

    final isIosSimulator = isIOSVal &&
        (env.containsKey('SIMULATOR_DEVICE_NAME') ||
            env.containsKey('SIMULATOR_MODEL_IDENTIFIER') ||
            env.containsKey('SIMULATOR_HOST_HOME') ||
            localHostname.endsWith('.local') ||
            localHostname.toLowerCase().contains('mac'));

    final isAndroidEmulator = isAndroidVal &&
        (localHostname.toLowerCase().contains('generic') ||
            localHostname.toLowerCase().contains('emulator'));

    String deviceName = localHostname;
    String osVersion = rawOsVersion;

    if (isIosSimulator) {
      if (env.containsKey('SIMULATOR_DEVICE_NAME') &&
          env['SIMULATOR_DEVICE_NAME']!.isNotEmpty) {
        deviceName = '${env['SIMULATOR_DEVICE_NAME']} (Simulator)';
      } else {
        deviceName = 'iPhone (Simulator)';
      }

      if (env.containsKey('SIMULATOR_RUNTIME_VERSION') &&
          env['SIMULATOR_RUNTIME_VERSION']!.isNotEmpty) {
        osVersion = 'iOS ${env['SIMULATOR_RUNTIME_VERSION']}';
      } else {
        osVersion = 'iOS Simulator';
      }
    } else if (isAndroidEmulator) {
      deviceName = 'Android Emulator';
      osVersion = 'Android $rawOsVersion';
    }

    return {
      'platform': Platform.operatingSystem,
      'is_simulator': isIosSimulator || isAndroidEmulator,
      'device_name': deviceName,
      'os_version': osVersion,
      'raw_os_version': rawOsVersion,
      'hostname': localHostname,
      'processors': Platform.numberOfProcessors,
      'dart_version': Platform.version.split(' ').first,
      'locale': Platform.localeName,
    };
  }

  @visibleForTesting
  Map<String, dynamic> getDeviceInfoForTesting({
    bool? isIOS,
    bool? isAndroid,
    Map<String, String>? envOverride,
    String? hostnameOverride,
    String? osVersionOverride,
  }) =>
      _getDeviceInfo(
        isIOS: isIOS,
        isAndroid: isAndroid,
        envOverride: envOverride,
        hostnameOverride: hostnameOverride,
        osVersionOverride: osVersionOverride,
      );
}
