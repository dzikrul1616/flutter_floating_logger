import 'package:floating_logger/src/network/network.dart';
import 'package:floating_logger/src/utils/utils.dart';
import '../test.dart';

void utilsNetwork() {
  group('Utils Network', () {
    late MockLogRepository mockLogRepository;

    setUp(() {
      mockLogRepository = MockLogRepository();
    });

    test('onRequest should log request details and call next', () {
      final options = RequestOptions(
        method: 'GET',
        path: 'https://example.com',
      );
      final handler = MockRequestInterceptorHandler();

      LoggerNetworkSettings.onRequest(options, handler, mockLogRepository);

      verify(mockLogRepository.addLog(any)).called(1);
      verify(handler.next(options)).called(1);
    });

    test('onResponse should log response details and call next', () {
      final options = RequestOptions(
        method: 'POST',
        path: 'https://example.com',
      );
      final response = Response<dynamic>(
        requestOptions: options,
        statusCode: 200,
        data: '{}',
      );
      final handler = MockResponseInterceptorHandler();

      LoggerNetworkSettings.onResponse(response, handler, mockLogRepository);

      verify(mockLogRepository.addLog(any)).called(1);
      verify(handler.next(response)).called(1);
    });

    test('onError should log error details and call reject', () {
      final options = RequestOptions(
        method: 'PUT',
        path: 'https://example.com',
      );
      final dioError = DioException(
        requestOptions: options,
        message: 'Error occurred',
      );
      final handler = MockErrorInterceptorHandler();

      LoggerNetworkSettings.onError(dioError, handler, mockLogRepository);

      verify(mockLogRepository.addLog(any)).called(1);
      verify(handler.reject(dioError)).called(1);
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
