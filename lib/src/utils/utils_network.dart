import '../network/network.dart';
import 'utils.dart';

/// A network logger interceptor for Dio that logs requests, responses, and errors
/// in a structured format with curl command generation.
///
/// This class provides logging functionality by using the [DioLogger] package
/// to capture and display network activity, allowing developers to debug API calls
/// efficiently.
///
/// Example usage:
/// ```dart
/// final dio = Dio();
/// dio.interceptors.add(
///   InterceptorsWrapper(
///     onRequest: (options, handler) {
///       LoggerNetworkSettings.onRequest(options, handler, logRepository);
///     },
///     onResponse: (response, handler) {
///       LoggerNetworkSettings.onResponse(response, handler, logRepository);
///     },
///     onError: (error, handler) {
///       LoggerNetworkSettings.onError(error, handler, logRepository);
///     },
///   ),
/// );
/// ```
///
/// Each function logs network activity with specific color coding:
/// - **Requests (REQ)** → Logged in magenta.
/// - **Responses (RES)** → Logged in green.
/// - **Errors (ERR)** → Logged in red.
///
/// The log includes a generated cURL command for reproducing requests manually.
class LoggerNetworkSettings {
  /// Logs and processes an outgoing request.
  ///
  /// - Converts the request into a cURL command for debugging.
  /// - Logs the request details in magenta.
  /// - Passes the request to the next handler.
  static void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
    LogRepository logRepository,
  ) {
    final curlCommand = FormatLogger.generateCurlCommand(options);
    if (DioLogger.shouldLogNotifier.value) {
      LoggerLogsData.logMessage<RequestOptions>(
        options,
        AnsiColor.magenta,
        logRepository,
        curlCommand,
        name: "REQ",
      );
    }
    handler.next(options);
  }

  /// Logs and processes an incoming response.
  ///
  /// - Extracts the original request's cURL command.
  /// - Logs the response details in green.
  /// - Passes the response to the next handler.
  static void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
    LogRepository logRepository,
  ) {
    final curlCommand =
        FormatLogger.generateCurlCommand(response.requestOptions);
    if (DioLogger.shouldLogNotifier.value) {
      LoggerLogsData.logMessage<Response<dynamic>>(
        response,
        AnsiColor.green,
        logRepository,
        curlCommand,
        name: "RES",
      );
    }
    handler.next(response);
  }

  /// Logs and processes an error response.
  ///
  /// - Converts the failed request into a cURL command.
  /// - Logs the error details in red.
  /// - Rejects the error to the next handler.
  static void onError(
    DioException error,
    ErrorInterceptorHandler handler,
    LogRepository logRepository,
  ) {
    final curlCommand = FormatLogger.generateCurlCommand(error.requestOptions);
    if (DioLogger.shouldLogNotifier.value) {
      LoggerLogsData.logMessage<DioException>(
        error,
        AnsiColor.red,
        logRepository,
        curlCommand,
        name: "ERR",
      );
    }
    handler.reject(error);
  }

  static bool isSucces(
    LogRepositoryModel data,
  ) {
    final response = data.response;
    final isSuccess = [
      '200', // OK
      '201', // Created
      '202', // Accepted
      '203', // Non-Authoritative Information
      '204', // No Content
      '205', // Reset Content
      '206', // Partial Content
      '207', // Multi-Status (WebDAV)
      '208', // Already Reported (WebDAV)
      '226', // IM Used (RFC 3229)
    ].contains(response);

    return isSuccess;
  }

  static bool isError(
    LogRepositoryModel data,
  ) {
    final response = data.response;
    final isError = [
      // 4xx: Client Errors
      '400', // Bad Request
      '401', // Unauthorized
      '402', // Payment Required
      '403', // Forbidden
      '404', // Not Found
      '405', // Method Not Allowed
      '406', // Not Acceptable
      '407', // Proxy Authentication Required
      '408', // Request Timeout
      '409', // Conflict
      '410', // Gone
      '411', // Length Required
      '412', // Precondition Failed
      '413', // Payload Too Large
      '414', // URI Too Long
      '415', // Unsupported Media Type
      '416', // Range Not Satisfiable
      '417', // Expectation Failed
      '418', // I'm a teapot (RFC 2324)
      '421', // Misdirected Request
      '422', // Unprocessable Entity (WebDAV)
      '423', // Locked (WebDAV)
      '424', // Failed Dependency (WebDAV)
      '425', // Too Early (RFC 8470)
      '426', // Upgrade Required
      '428', // Precondition Required
      '429', // Too Many Requests
      '431', // Request Header Fields Too Large
      '451', // Unavailable For Legal Reasons

      // 5xx: Server Errors
      '500', // Internal Server Error
      '501', // Not Implemented
      '502', // Bad Gateway
      '503', // Service Unavailable
      '504', // Gateway Timeout
      '505', // HTTP Version Not Supported
      '506', // Variant Also Negotiates
      '507', // Insufficient Storage (WebDAV)
      '508', // Loop Detected (WebDAV)
      '510', // Not Extended
      '511', // Network Authentication Required
    ].contains(response);

    return isError;
  }
}
