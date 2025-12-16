import 'package:dio/io.dart' show IOHttpClientAdapter;
import 'package:floating_logger/floating_logger.dart';
import 'package:floating_logger/src/network/network_model.dart';
import '../utils/utils_network.dart';
import 'package:flutter/foundation.dart' as foundation; // For kIsWeb
import 'dart:io';

/// A custom Dio instance with integrated logging functionality.
///
/// This class extends [DioMixin] and implements [Dio] to provide a singleton
/// Dio instance that includes network request logging using [DioLogger].
///
/// It logs HTTP requests, responses, and errors while allowing further customization.
///
/// Usage:
/// ```dart
/// final dio = DioLogger.instance;
/// dio.get('https://api.example.com');
/// ```
class DioLogger with DioMixin implements Dio {
  /// The log repository used to store and manage logs.
  final LogRepository logRepository;

  /// Private constructor to initialize DioLogger with custom configurations.
  ///
  /// - Sets default request options such as `contentType`, `connectTimeout`, and `receiveTimeout`.
  /// - Adds custom interceptors for logging requests, responses, and errors.
  /// - Uses [IOHttpClientAdapter] for HTTP request handling.
  DioLogger._(this.logRepository) {
    // Set default request options for all HTTP requests.
    options = BaseOptions(
      contentType:
          'application/json; charset=utf-8', // Define content type as JSON with UTF-8 encoding.
      connectTimeout: const Duration(
          milliseconds: 50000), // Set connection timeout to 50 seconds.
      receiveTimeout: const Duration(
          milliseconds: 30000), // Set response receiving timeout to 30 seconds.
    );

    // Set the HTTP client adapter using the helper method
    httpClientAdapter = createAdapter(isWeb: foundation.kIsWeb);

    // Add default interceptors
    addDefaultInterceptors();

    // Add Dio's built-in logging interceptor (disabled to avoid duplicate logs).
    interceptors.add(
      LogInterceptor(
        error: false, // Disable error logging.
        request: false, // Disable request logging.
        requestHeader: false, // Disable request header logging.
        responseHeader: false, // Disable response header logging.
        responseBody: false, // Disable response body logging.
        requestBody: false, // Disable request body logging.
      ),
    );
  }

  /// A private log repository instance to manage logs globally.
  static final LogRepository _logRepository = LogRepository();

  /// A singleton instance of [DioLogger].
  ///
  /// This ensures that only one instance of DioLogger is used throughout the application.
  static final DioLogger _instance = DioLogger._(_logRepository);

  /// Returns the singleton instance of [DioLogger].
  static DioLogger get instance => _instance;

  static final ValueNotifier<bool> shouldLogNotifier =
      ValueNotifier<bool>(true);

  /// Provides access to the log repository instance.
  LogRepository get logs => _logRepository;

  // Add a custom interceptor to log request, response, and error details.
  void addDefaultInterceptors() {
    interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) => LoggerNetworkSettings.onRequest(
          options,
          handler,
          logRepository,
        ),
        onResponse: (response, handler) => LoggerNetworkSettings.onResponse(
          response,
          handler,
          logRepository,
        ),
        onError: (error, handler) => LoggerNetworkSettings.onError(
          error,
          handler,
          logRepository,
        ),
      ),
    );
  }

  /// Method to add custom interceptors
  void addInterceptor(Interceptor interceptor) {
    interceptors.add(interceptor);
  }

  void addListInterceptor(List<Interceptor> interceptorsList) {
    for (var interceptor in interceptorsList) {
      interceptors.add(interceptor);
    }
  }

  /// Creates and returns the appropriate HttpClientAdapter based on the platform.
  ///
  /// - [isWeb]: If true, returns the default [HttpClientAdapter] (for web).
  /// - If false, returns [IOHttpClientAdapter] with SSL verification disabled.
  @foundation.visibleForTesting
  static HttpClientAdapter createAdapter({bool isWeb = foundation.kIsWeb}) {
    if (isWeb) {
      // Web-specific adapter (ensure this is used for Web)
      return HttpClientAdapter();
    } else {
      // For non-web platforms like mobile, use IOHttpClientAdapter with SSL bypass
      return IOHttpClientAdapter()
        ..createHttpClient = () {
          final client = HttpClient();
          client.badCertificateCallback = (cert, host, port) => true;
          return client;
        };
    }
  }
}
