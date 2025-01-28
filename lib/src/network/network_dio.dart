import 'dart:convert';
import 'dart:developer';
import 'package:dio/io.dart';
import 'package:floating_logger/floating_logger.dart';

class DioLogger with DioMixin implements Dio {
  final LogRepository logRepository;

  DioLogger._(this.logRepository) {
    options = BaseOptions(
      contentType: 'application/json; charset=utf-8',
      connectTimeout: const Duration(milliseconds: 50000),
      receiveTimeout: const Duration(milliseconds: 30000),
    );

    interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final curlCommand = _generateCurlCommand(options);
          logRepository.addLog(LogRepositoryModel(
            type: "Request",
            path: options.path,
            responseData: "",
            data: options.data?.toString() ?? "",
            response: options.method,
            queryparameter: options.queryParameters.toString(),
            message: "",
            curl: curlCommand,
          ));
          handler.next(options);
        },
        onResponse: (response, handler) async {
          final curlCommand = _generateCurlCommand(response.requestOptions);
          logRepository.addLog(LogRepositoryModel(
            type: "Response",
            path: response.requestOptions.path,
            responseData: response.data?.toString() ?? "",
            data: "",
            response: response.statusCode?.toString() ?? "Unknown",
            queryparameter: "",
            message: response.statusMessage,
            curl: curlCommand,
          ));
          handler.next(response);
        },
        onError: (error, handler) async {
          final curlCommand = _generateCurlCommand(error.requestOptions);
          logRepository.addLog(LogRepositoryModel(
            type: "Error",
            path: error.requestOptions.path,
            responseData:
                error.response?.data?.toString() ?? "No Response Data",
            data: error.message ?? "No Error Message",
            response: error.response?.statusCode?.toString() ?? "Unknown",
            queryparameter: "",
            message: error.response!.statusMessage,
            curl: curlCommand,
          ));
          handler.next(error);
          handler.reject(error);
        },
      ),
    );

    interceptors.add(
      LogInterceptor(
        responseBody: true,
        requestBody: true,
        logPrint: (object) {
          try {
            final dynamic json = jsonDecode(object.toString());
            final String prettyJson =
                const JsonEncoder.withIndent('  ').convert(json);
            log(prettyJson);
          } catch (e) {
            log(object.toString());
          }
        },
      ),
    );

    httpClientAdapter = IOHttpClientAdapter();
  }

  static final LogRepository _logRepository = LogRepository();
  static final DioLogger _instance = DioLogger._(_logRepository);

  static DioLogger get instance => _instance;

  LogRepository get logs => _logRepository;

  String _generateCurlCommand(RequestOptions options) {
    final buffer = StringBuffer();

    buffer.write('curl -X ${options.method} ');

    options.headers.forEach((key, value) {
      buffer.write('-H "$key: $value" ');
    });

    if (options.data != null) {
      buffer.write('-d \'${options.data}\' ');
    }

    buffer.write('"${options.uri.toString()}"');

    return buffer.toString();
  }
}
