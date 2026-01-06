import 'dart:io' show SocketException;

import 'package:floating_logger/floating_logger.dart';

class CustomError {
  static String mapDioErrorToMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionError:
        return 'Connection error. Please try again.';

      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please try again.';

      case DioExceptionType.sendTimeout:
        return 'Request timeout while sending data.';

      case DioExceptionType.receiveTimeout:
        return 'Server took too long to respond.';

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        return 'Server error ($statusCode). Please try again later.';

      case DioExceptionType.cancel:
        return 'Request was cancelled.';

      case DioExceptionType.unknown:
        if (e.error is SocketException) {
          return 'No internet connection. Please check your network.';
        }
        return 'Unexpected network error occurred.';

      default:
        return 'Something went wrong.';
    }
  }
}
