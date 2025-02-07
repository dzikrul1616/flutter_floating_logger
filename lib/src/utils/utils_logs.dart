import 'utils.dart';
import 'dart:developer';
import 'package:floating_logger/src/network/network_model.dart';

/// Class for handling logging of information related to Dio requests, responses, and exceptions.
class LoggerLogsData {
  // Helper method to retrieve the HTTP method
  /// Extracts the HTTP method (e.g., GET, POST) from the given data.
  /// Supports `RequestOptions`, `Response`, and `DioException` types.
  static String getMethod<T>(T data) {
    if (data is RequestOptions) return data.method;
    if (data is Response<dynamic>) return data.requestOptions.method;
    if (data is DioException) return data.requestOptions.method;
    return data.toString(); // Fallback for unsupported data types
  }

  // Helper method to retrieve the status code
  /// Retrieves the HTTP status code from the given data.
  /// Supports `Response` and `DioException`. Returns "Request" for `RequestOptions`.
  static String? getStatusCode<T>(T data) {
    if (data is Response<dynamic>) return data.statusCode.toString();
    if (data is DioException) {
      return data.response?.statusCode == null
          ? "Could not get status"
          : data.response?.statusCode.toString();
    }
    return 'REQUEST'; // Default for RequestOptions
  }

  // Helper method to retrieve the URL
  /// Retrieves the request URL from the given data.
  /// Supports `RequestOptions`, `Response`, and `DioException`.
  static String getUrl<T>(T data) {
    if (data is RequestOptions) return data.uri.toString();
    if (data is Response<dynamic>) return data.realUri.toString();
    if (data is DioException) return data.requestOptions.path;
    return data.toString(); // Fallback for unsupported data types
  }

  // Helper method to retrieve request or response data
  /// Retrieves the payload or response body from the given data.
  /// Supports `RequestOptions`, `Response`, and `DioException`.
  static dynamic _getData<T>(T data) {
    if (data is RequestOptions) return data.data;
    if (data is Response<dynamic>) return data.data;
    if (data is DioException) return data.response?.data;
    return data; // Fallback for unsupported data types
  }

  // Helper method to retrieve headers
  /// Extracts headers from the given data.
  /// Supports `RequestOptions`, `Response`, and `DioException`.
  static dynamic _getHeaders<T>(T data) {
    if (data is RequestOptions) return data.headers;
    if (data is Response<dynamic>) {
      return _filterHeaders(data.requestOptions.headers);
    }
    if (data is DioException) {
      return _filterHeaders(data.requestOptions.headers);
    }
    return data; // Fallback for unsupported data types
  }

  static Map<String, dynamic> _filterHeaders(Map<String, dynamic> headers) {
    final hiddenKeys = {
      'authorization',
      'cookie',
      'set-cookie',
      'x-powered-by'
    };
    return headers
      ..removeWhere((key, value) => hiddenKeys.contains(key.toLowerCase()));
  }

  // Helper method to retrieve queryparameter
  /// Extracts queryparameter from the given data.
  /// Supports `RequestOptions`, `Response`, and `DioException`.
  static dynamic _getParam<T>(T data) {
    if (data is RequestOptions) return data.queryParameters;
    if (data is Response<dynamic>) return data.requestOptions.queryParameters;
    if (data is DioException) return data.requestOptions.queryParameters;
    return data; // Fallback for unsupported data types
  }

  // Message method to retrieve headers
  /// Extracts message response from the given data.
  /// Supports `RequestOptions`, `Response`, and `DioException`.
  static String getMessage<T>(T data) {
    if (data is RequestOptions) return "";
    if (data is Response<dynamic>) return data.statusMessage.toString();
    if (data is DioException) return data.message ?? "-";
    return data.toString(); // Fallback for unsupported data types
  }

  // Main log function
  /// Logs detailed information about the given data, including HTTP method, URL, status code, data, headers, and a curl command.
  ///
  /// - [color]: String representing the log color (e.g., for terminal styling).
  /// - [curlCommand]: A string representation of the curl command for the request.
  /// - [name]: Logger name used in the log entry (default is "Log").
  static void logMessage<T>(
    T data,
    String color,
    LogRepository logRepository,
    String curlCommand, {
    String name = "Log",
  }) {
    // Extract individual log components from the data
    final method = getMethod(data);
    final statusCode = getStatusCode(data);
    final url = getUrl(data);
    final dataText = _getData(data);
    final headers = _getHeaders(data);
    final param = _getParam(data);
    final message = getMessage(data);

    // Construct the log message
    final logMessage = "${color}Method  :${AnsiColor.reset} $method\n"
        "${color}Url     :${AnsiColor.reset} $url\n"
        "${color}Status  :${AnsiColor.reset} $statusCode \n"
        "${color}Message :${AnsiColor.reset} ${message.isEmpty ? '-' : message}\n"
        "${color}Param   :\n${AnsiColor.reset}${FormatLogger.parseJson(param)}\n"
        "${color}Data    :\n${AnsiColor.reset}${FormatLogger.parseJson(dataText)}\n"
        "${color}Headers :\n${AnsiColor.reset}${FormatLogger.parseJson(headers)}\n"
        "${color}Curl    :${AnsiColor.reset} $curlCommand";

    // Log the message using Dart's `log` function
    log(
      logMessage,
      name: name,
    );

    // Save the request or response message on state before show in ui
    logRepository.addLog(
      LogRepositoryModel(
        type: name == "RES"
            ? "RESPONSE"
            : name == "REQ"
                ? "REQUEST"
                : "ERROR",
        method: method,
        path: url,
        responseData: FormatLogger.parseJson(dataText),
        data: FormatLogger.parseJson(dataText),
        response: statusCode,
        queryparameter: FormatLogger.parseJson(param),
        header: FormatLogger.parseJson(headers),
        message: message,
        curl: curlCommand,
      ),
    );
  }
}
