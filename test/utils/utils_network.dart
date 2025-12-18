import 'package:floating_logger/src/network/network.dart';
import 'package:floating_logger/src/utils/utils.dart';
import '../test.dart';

void utilsNetwork() {
  group('Utils Network', () {
    late MockLogRepository mockLogRepository;

    setUp(() {
      mockLogRepository = MockLogRepository();
    });

    test('onRequest should log request details, set start_time, and call next',
        () {
      final options = RequestOptions(
        method: 'GET',
        path: 'https://example.com',
      );
      final handler = MockRequestInterceptorHandler();

      LoggerNetworkSettings.onRequest(options, handler, mockLogRepository);

      expect(options.extra.containsKey('start_time'), isTrue);
      verify(mockLogRepository.addLog(any)).called(1);
      verify(handler.next(options)).called(1);
    });

    test(
        'onResponse should log response details, calculate duration, and call next',
        () async {
      final options = RequestOptions(
        method: 'POST',
        path: 'https://example.com',
        extra: {'start_time': DateTime.now().millisecondsSinceEpoch - 100},
      );
      final response = Response<dynamic>(
        requestOptions: options,
        statusCode: 200,
        data: '{}',
      );
      final handler = MockResponseInterceptorHandler();

      // Add a small delay to ensure time difference
      await Future.delayed(const Duration(milliseconds: 10));

      LoggerNetworkSettings.onResponse(response, handler, mockLogRepository);

      final captured = verify(mockLogRepository.addLog(captureAny)).captured;
      final logModel = captured.first as LogRepositoryModel;
      expect(logModel.responseTime, greaterThanOrEqualTo(100));
      verify(handler.next(response)).called(1);
    });

    test(
        'onError should log error details, calculate duration, and call reject',
        () {
      final options = RequestOptions(
        method: 'PUT',
        path: 'https://example.com',
        extra: {'start_time': DateTime.now().millisecondsSinceEpoch - 50},
      );
      final dioError = DioException(
        requestOptions: options,
        message: 'Error occurred',
      );
      final handler = MockErrorInterceptorHandler();

      LoggerNetworkSettings.onError(dioError, handler, mockLogRepository);

      final captured = verify(mockLogRepository.addLog(captureAny)).captured;
      final logModel = captured.first as LogRepositoryModel;
      expect(logModel.responseTime, greaterThanOrEqualTo(50));
      verify(handler.next(dioError)).called(1);
    });

    test('should NOT log when shouldLogNotifier is false', () {
      DioLogger.shouldLogNotifier.value = false;

      final options = RequestOptions(path: 'https://example.com');
      final handler = MockRequestInterceptorHandler();
      LoggerNetworkSettings.onRequest(options, handler, mockLogRepository);

      verifyNever(mockLogRepository.addLog(any));
      verify(handler.next(options)).called(1);

      DioLogger.shouldLogNotifier.value = true;
    });

    test('isSucces should return true for 2xx status codes', () {
      final data = LogRepositoryModel(response: '200');
      expect(LoggerNetworkSettings.isSucces(data), isTrue);
    });

    test('isSucces should return false for non-2xx status codes', () {
      final data = LogRepositoryModel(response: '404');
      expect(LoggerNetworkSettings.isSucces(data), isFalse);
    });

    test('isError should return true for 4xx and 5xx status codes', () {
      final data = LogRepositoryModel(response: '500');
      expect(LoggerNetworkSettings.isError(data), isTrue);
    });

    test('isError should return false for 2xx status codes', () {
      final data = LogRepositoryModel(response: '200');
      expect(LoggerNetworkSettings.isError(data), isFalse);
    });
  });
}
