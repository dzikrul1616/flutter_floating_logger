import 'package:floating_logger/floating_logger.dart';
import 'package:floating_logger/src/network/network.dart' show LogRepository;
import '../utils/utils_network.dart' show LoggerNetworkSettings;

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
      options.extra['start_time'] = DateTime.now().millisecondsSinceEpoch;
      await NetworkSimulator.instance.simulate(options);
      LoggerNetworkSettings.onRequest(
        options,
        handler,
        _effectiveLogRepository,
      );
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
