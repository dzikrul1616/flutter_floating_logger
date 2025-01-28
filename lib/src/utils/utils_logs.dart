import 'dart:developer';
import 'package:floating_logger/floating_logger.dart';

/// Class for handling logging of information related to Dio requests, responses, and exceptions.
class LoggerLogsData {
  // Helper method to retrieve the HTTP method
  /// Extracts the HTTP method (e.g., GET, POST) from the given data.
  /// Supports `RequestOptions`, `Response`, and `DioException` types.
  static String _getMethod<T>(T data) {
    if (data is RequestOptions) return data.method;
    if (data is Response<dynamic>) return data.requestOptions.method;
    if (data is DioException) return data.requestOptions.method;
    return data.toString(); // Fallback for unsupported data types
  }

  // Helper method to retrieve the status code
  /// Retrieves the HTTP status code from the given data.
  /// Supports `Response` and `DioException`. Returns "Request" for `RequestOptions`.
  static String? _getStatusCode<T>(T data) {
    if (data is Response<dynamic>) return data.statusCode.toString();
    if (data is DioException) return data.response?.statusCode.toString();
    return 'Request'; // Default for RequestOptions
  }

  // Helper method to retrieve the URL
  /// Retrieves the request URL from the given data.
  /// Supports `RequestOptions`, `Response`, and `DioException`.
  static String _getUrl<T>(T data) {
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
    if (data is Response<dynamic>) return data.headers;
    if (data is DioException) return data.requestOptions.headers;
    return data; // Fallback for unsupported data types
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
    String curlCommand, {
    String name = "Log",
  }) {
    // Extract individual log components from the data
    final method = _getMethod(data);
    final statusCode = _getStatusCode(data);
    final url = _getUrl(data);
    final dataText = _getData(data);
    final headers = _getHeaders(data);

    // Construct the log message
    final logMessage = "${color}Method  :${AnsiColor.reset} $method\n"
        "${color}Url     :${AnsiColor.reset} $url\n"
        "${color}Status  :${AnsiColor.reset} $statusCode\n"
        "${color}Data    :\n${AnsiColor.reset}${FormatLogger.parseJson(dataText)}\n"
        "${color}Headers :\n${AnsiColor.reset}${FormatLogger.parseJson(headers)}\n"
        "${color}Curl    :${AnsiColor.reset} $curlCommand";

    // Log the message using Dart's `log` function
    log(
      logMessage,
      name: name,
    );
  }
}
