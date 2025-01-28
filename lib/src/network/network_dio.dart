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
          final curlCommand = FormatLogger.generateCurlCommand(options);
          LoggerLogsData.logMessage<RequestOptions>(
            options,
            AnsiColor.magenta,
            curlCommand,
            name: "REQ",
          );
          logRepository.addLog(
            LogRepositoryModel(
              type: "Request",
              path: options.path,
              responseData: "",
              data: FormatLogger.parseJson(options.data),
              response: options.method,
              header: FormatLogger.parseJson(options.headers),
              queryparameter: FormatLogger.parseJson(options.queryParameters),
              message: "",
              curl: curlCommand,
            ),
          );
          handler.next(options);
        },
        onResponse: (response, handler) async {
          final curlCommand =
              FormatLogger.generateCurlCommand(response.requestOptions);
          LoggerLogsData.logMessage<Response<dynamic>>(
            response,
            AnsiColor.green,
            curlCommand,
            name: "RES",
          );
          logRepository.addLog(LogRepositoryModel(
            type: "Response",
            path: response.requestOptions.path,
            responseData: FormatLogger.parseJson(response.data),
            data: "",
            response: response.statusCode?.toString() ?? "Unknown",
            queryparameter: "",
            header: FormatLogger.parseJson(response.headers),
            message: response.statusMessage,
            curl: curlCommand,
          ));
          handler.next(response);
        },
        onError: (error, handler) async {
          final curlCommand =
              FormatLogger.generateCurlCommand(error.requestOptions);
          LoggerLogsData.logMessage<DioException>(
            error,
            AnsiColor.red,
            curlCommand,
            name: "ERR",
          );
          logRepository.addLog(LogRepositoryModel(
            type: "Error",
            path: error.requestOptions.path,
            responseData: FormatLogger.parseJson(error.response?.data),
            data: error.message ?? "No Error Message",
            response: error.response?.statusCode?.toString() ?? "Unknown",
            queryparameter: "",
            header: FormatLogger.parseJson(error.requestOptions.headers),
            message: error.response!.statusMessage,
            curl: curlCommand,
          ));
          handler.reject(error);
        },
      ),
    );

    interceptors.add(
      LogInterceptor(
        error: false,
        request: false,
        requestHeader: false,
        responseHeader: false,
        responseBody: false,
        requestBody: false,
      ),
    );

    httpClientAdapter = IOHttpClientAdapter();
  }

  static final LogRepository _logRepository = LogRepository();
  static final DioLogger _instance = DioLogger._(_logRepository);

  static DioLogger get instance => _instance;

  LogRepository get logs => _logRepository;
}
