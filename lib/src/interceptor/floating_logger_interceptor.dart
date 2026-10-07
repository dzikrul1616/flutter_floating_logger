import 'package:floating_logger/floating_logger.dart';
import 'package:floating_logger/src/network/network.dart' show LogRepository;
import '../utils/utils.dart';

/// A Dio interceptor that logs requests, responses, and errors using [DioLogger].
///
/// This interceptor can be added to any Dio instance to enable floating logger functionality
/// without using the [DioLogger] wrapper class.
///
/// Example usage:
/// ```dart
/// final dio = Dio();
/// dio.interceptors.add(FloatingLoggerInterceptor());
/// ```
class FloatingLoggerInterceptor extends InterceptorsWrapper {
  final LogRepository? _logRepository;

  FloatingLoggerInterceptor({LogRepository? logRepository})
      : _logRepository = logRepository;

  LogRepository get _effectiveLogRepository =>
      _logRepository ?? DioLogger.instance.logs;

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final isSim = NetworkSimulator.instance.simulationNotifier.value !=
          NetworkSimulation.normal;

      options.extra['start_time'] = DateTime.now().millisecondsSinceEpoch;
      if (isSim) {
        options.extra['is_simulation'] = true;
      }

      // 1. Log outgoing request so it's always recorded
      final curlCommand = FormatLogger.generateCurlCommand(options);
      if (DioLogger.shouldLogNotifier.value) {
        LoggerLogsData.logMessage<RequestOptions>(
          options,
          AnsiColor.magenta,
          _effectiveLogRepository,
          curlCommand,
          name: "REQ",
          isSimulation: isSim,
        );
      }

      void logSimError(DioException dioErr) {
        if (DioLogger.shouldLogNotifier.value) {
          int? duration;
          if (options.extra['start_time'] != null) {
            final startTime = options.extra['start_time'] as int;
            duration = DateTime.now().millisecondsSinceEpoch - startTime;
          }

          LoggerLogsData.logMessage<DioException>(
            dioErr,
            AnsiColor.red,
            _effectiveLogRepository,
            curlCommand,
            name: "ERR",
            duration: duration,
            isSimulation: true,
          );
        }
      }

      // 2. Perform network simulation (which can delay or throw simulated exceptions)
      try {
        await NetworkSimulator.instance.simulate(options);
        handler.next(options);
      } on DioException catch (e) {
        logSimError(e);
        handler.reject(e);
      } catch (e) {
        final dioErr = DioException(requestOptions: options, error: e);
        logSimError(dioErr);
        handler.reject(dioErr);
      }
    } on DioException catch (e) {
      handler.reject(e);
    } catch (e) {
      handler.reject(DioException(requestOptions: options, error: e));
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    LoggerNetworkSettings.onResponse(
      response,
      handler,
      _effectiveLogRepository,
    );
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    LoggerNetworkSettings.onError(
      err,
      handler,
      _effectiveLogRepository,
    );
  }
}
