import 'package:floating_logger/src/utils/utils.dart';
import 'package:floating_logger/src/network/network_model.dart';
import '../test.dart';

void utilsLogs() {
  group('Utils Logs', () {
    late MockLogRepository mockLogRepository;
    const String curlCommand =
        'curl -X POST -H "Content-Type: application/json" -d \'{"name": "John"}\' "https://example.com"';

    setUp(() {
      mockLogRepository = MockLogRepository();
    });

    test('should correctly extract method from RequestOptions', () {
      final options = RequestOptions(
        method: 'POST',
        path: 'https://example.com',
        headers: {},
        data: '{"name": "John"}',
      );

      final method = LoggerLogsData.getMethod(options);

      expect(method, 'POST');
    });

    test('should correctly extract method from Response', () {
      final options = RequestOptions(
        method: 'GET',
        path: 'https://example.com',
        headers: {},
        data: null,
      );
      final response = Response<dynamic>(
        requestOptions: options,
        data: '{"name": "John"}',
        statusCode: 200,
      );

      final method = LoggerLogsData.getMethod(response);

      expect(method, 'GET');
    });

    test('should correctly extract method from DioException', () {
      final options = RequestOptions(
        method: 'PUT',
        path: 'https://example.com',
        headers: {},
        data: '{"name": "John"}',
      );
      final dioException = DioException(
        requestOptions: options,
        message: 'Error occurred',
      );

      final method = LoggerLogsData.getMethod(dioException);

      expect(method, 'PUT');
    });

    test('should correctly extract method unsuported', () {
      final response = "GET";

      final method = LoggerLogsData.getMethod<String>(response);
      final url = LoggerLogsData.getUrl<String>(response);
      final message = LoggerLogsData.getMessage<String>(response);

      expect(method, 'GET');
      expect(url, 'GET');
      expect(message, 'GET');
    });

    test('should correctly extract status code from Response', () {
      final response = Response<dynamic>(
        requestOptions: RequestOptions(
          method: 'GET',
          path: 'https://example.com',
        ),
        statusCode: 200,
        data: '{"name": "John"}',
      );

      final statusCode = LoggerLogsData.getStatusCode(response);

      expect(statusCode, '200');
    });

    test('should correctly extract status code from DioException', () {
      final response = Response<dynamic>(
        requestOptions: RequestOptions(
          method: 'GET',
          path: 'https://example.com',
        ),
        statusCode: 500,
        data: '{"error": "Internal Server Error"}',
      );
      final dioException = DioException(
        requestOptions:
            RequestOptions(method: 'GET', path: 'https://example.com'),
        response: response,
        message: 'Error occurred',
      );

      final statusCode = LoggerLogsData.getStatusCode(dioException);

      expect(statusCode, '500');
    });

    test('logMessage should log data and call addLog', () {
      final options = RequestOptions(
        method: 'POST',
        path: 'https://example.com',
        headers: {'Content-Type': 'application/json'},
        data: '{"name": "John"}',
      );

      // Call logMessage
      LoggerLogsData.logMessage(
        options,
        AnsiColor.red,
        mockLogRepository,
        curlCommand,
      );

      // Check if the logRepository.addLog is called
      verify(mockLogRepository.addLog(any)).called(1);
    });

    test('should correctly parse FormData in logMessage', () async {
      final formData = FormData.fromMap({
        'name': 'John',
        'file': MultipartFile.fromString('file content', filename: 'test.txt'),
      });

      final options = RequestOptions(
        method: 'POST',
        path: 'https://example.com/upload',
        data: formData,
      );

      LoggerLogsData.logMessage(
        options,
        AnsiColor.green,
        mockLogRepository,
        curlCommand,
      );

      final captured = verify(mockLogRepository.addLog(captureAny)).captured;
      final logModel = captured.first as LogRepositoryModel;

      final parsedData = logModel.data as String;
      expect(parsedData.contains('"name": "John"'), isTrue);
      expect(parsedData.contains('"filename": "test.txt"'), isTrue);
      // We expect length to be present. length of 'file content' is 12 bytes.
      expect(parsedData.contains('"length": 12'), isTrue);
    });

    test('should correctly parse FormData with multiple fields having same key',
        () async {
      final formData = FormData.fromMap({
        'tags': ['flutter', 'dart', 'logger'],
      });

      // Manually add fields to ensure duplicate keys are tested
      formData.fields.add(MapEntry('tags', 'awesome'));

      final options = RequestOptions(
        method: 'POST',
        path: 'https://example.com/tags',
        data: formData,
      );

      LoggerLogsData.logMessage(
        options,
        AnsiColor.green,
        mockLogRepository,
        curlCommand,
      );

      final captured = verify(mockLogRepository.addLog(captureAny)).captured;
      final logModel = captured.first as LogRepositoryModel;
      final parsedData = logModel.data as String;

      expect(parsedData.contains('"tags"'), isTrue);
      expect(parsedData.contains('"flutter"'), isTrue);
      expect(parsedData.contains('"dart"'), isTrue);
      expect(parsedData.contains('"logger"'), isTrue);
      expect(parsedData.contains('"awesome"'), isTrue);
    });
  });
}
