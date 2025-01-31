import 'dart:convert';
import 'package:floating_logger/floating_logger.dart';

/// A helper class to format logs, specifically for generating curl commands
/// and parsing JSON objects into a more readable format.
class FormatLogger {
  /// Generates a curl command from a `RequestOptions` object.
  /// This is used to build a `curl` command that can be used for debugging
  /// or logging the HTTP request.
  ///
  /// [options] is the `RequestOptions` object containing request details.
  ///
  /// Returns the curl command as a string.
  static String generateCurlCommand(RequestOptions options) {
    final buffer = StringBuffer();

    // Writing the HTTP method and URL to the curl command
    buffer.write('curl -X ${options.method} ');

    // Adding headers related to the request to the curl command
    options.headers.forEach((key, value) {
      buffer.write('-H "$key: $value" ');
    });

    // If there is data in the request, include it in the curl command
    if (options.data != null) {
      buffer.write('-d \'${options.data}\' ');
    }

    // Adding the request URL to the curl command
    buffer.write('"${options.uri.toString()}"');

    return buffer.toString();
  }

  /// Parses an object into a structured JSON format with indentation.
  /// If the object is a Map or List, it will be parsed directly.
  /// If the object is a String containing valid JSON, it will be decoded and parsed.
  ///
  /// [object] can be a Map, List, or a String containing JSON.
  ///
  /// Returns a formatted JSON string with indentation.
  static String parseJson(dynamic object) {
    try {
      // If the object is a Map or List, convert it to formatted JSON
      if (object is Map || object is List) {
        return const JsonEncoder.withIndent('  ').convert(object);
      } else if (object is String) {
        // If the object is a string, try to decode the JSON from the string
        final dynamic json = jsonDecode(object);
        return const JsonEncoder.withIndent('  ').convert(json);
      }
      // If the object is not a Map, List, or String, return its string representation
      return object.toString();
    } catch (e) {
      // If decoding fails, return the object's string representation
      return object.toString();
    }
  }
}
