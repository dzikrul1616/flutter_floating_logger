import 'package:floating_logger/src/network/network.dart';
import 'package:floating_logger/src/utils/utils.dart';
import '../test.dart';

void networkDio() {
  group('Network Dio', () {
    late DioLogger dioLogger;
    late MockInterceptor mockInterceptor;
    late MockInterceptor mockInterceptor2;
    late DioLogger dio;
    late MockDioLogger mockDio;
    late LogRepository logRepository;
    late MockLogRepository mockLogRepository;
    late MockRequestOptions mockRequestOptions;
    late MockResponse mockResponse;
    late MockDioException mockDioException;
    late MockRequestInterceptorHandler mockRequestHandler;
    late MockResponseInterceptorHandler mockResponseHandler;
    late MockErrorInterceptorHandler mockErrorHandler;
    setUp(() {
      dioLogger = DioLogger.instance;
      mockDio = MockDioLogger();
      mockLogRepository = MockLogRepository();
      mockRequestOptions = MockRequestOptions();
      mockResponse = MockResponse();
      logRepository = LogRepository();
      mockDioException = MockDioException();
      mockInterceptor = MockInterceptor();
      mockInterceptor2 = MockInterceptor();
      mockRequestHandler = MockRequestInterceptorHandler();
      mockResponseHandler = MockResponseInterceptorHandler();
      mockErrorHandler = MockErrorInterceptorHandler();
      when(mockDio.options).thenReturn(BaseOptions(
        connectTimeout: Duration(milliseconds: 50000),
        receiveTimeout: Duration(milliseconds: 30000),
        contentType: 'application/json; charset=utf-8',
      ));

      when(mockDio.logs).thenReturn(mockLogRepository);

      final mockLogsNotifier = ValueNotifier<List<LogRepositoryModel>>([]);
      when(mockLogRepository.logsNotifier).thenReturn(mockLogsNotifier);

      when(mockDio.get('https://jsonplaceholder.typicode.com/posts/1'))
          .thenAnswer((_) async => Response(
                statusCode: 200,
                data: {
                  "userId": 1,
                  "id": 1,
                  "title":
                      "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
                  "body":
                      "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto"
                },
                requestOptions: RequestOptions(
                  path: 'https://jsonplaceholder.typicode.com/posts/1',
                ),
              ));

      dio = mockDio;
    });

    test('DioLogger singleton', () {
      final dio1 = DioLogger.instance;
      final dio2 = DioLogger.instance;

      expect(dio1, equals(dio2));
    });

    test('DioLogger default options', () {
      expect(dio.options.connectTimeout, Duration(milliseconds: 50000));
      expect(dio.options.receiveTimeout, Duration(milliseconds: 30000));
      expect(dio.options.contentType, 'application/json; charset=utf-8');
    });

    test('DioLogger errors', () async {
      try {
        await dio.get('https://jsonplaceholder.typicode.com/404');
      } catch (e) {
        final logs = dio.logs.logsNotifier.value;
        expect(logs.isNotEmpty, true);
        expect(logs.last.message, contains('404'));
      }
    });

    test('LogRepository should store logs and reflect changes in length',
        () async {
      final initialLogsCount = dio.logs.logsNotifier.value.length;

      await dio.get('https://jsonplaceholder.typicode.com/posts/1');

      final newLog = LogRepositoryModel(
          message: 'GET https://jsonplaceholder.typicode.com/posts/1');

      dio.logs.logsNotifier.value.add(newLog);

      dio.logs.logsNotifier.notifyListeners();
      expect(dio.logs.logsNotifier.value.length, greaterThan(initialLogsCount));
    });

    test('onRequest should call LoggerNetworkSettings.onRequest', () {
      when(mockRequestOptions.method).thenReturn('GET');
      when(mockRequestOptions.path).thenReturn('/api/test');
      when(mockRequestHandler.next(mockRequestOptions)).thenReturn(null);

      LoggerNetworkSettings.onRequest(
        mockRequestOptions,
        mockRequestHandler,
        mockLogRepository,
      );

      verify(mockLogRepository.addLog(any)).called(1);
      verify(mockRequestHandler.next(mockRequestOptions)).called(1);
    });

    test('onResponse should call LoggerNetworkSettings.onResponse', () {
      when(mockResponse.requestOptions).thenReturn(mockRequestOptions);
      when(mockResponseHandler.next(mockResponse)).thenReturn(null);

      LoggerNetworkSettings.onResponse(
        mockResponse,
        mockResponseHandler,
        mockLogRepository,
      );

      verify(mockLogRepository.addLog(any)).called(1);
      verify(mockResponseHandler.next(mockResponse)).called(1);
    });

    test('onError should call LoggerNetworkSettings.onError', () {
      when(mockDioException.requestOptions).thenReturn(mockRequestOptions);
      when(mockErrorHandler.reject(mockDioException)).thenReturn(null);

      LoggerNetworkSettings.onError(
        mockDioException,
        mockErrorHandler,
        mockLogRepository,
      );

      verify(mockLogRepository.addLog(any)).called(1);
      verify(mockErrorHandler.reject(mockDioException)).called(1);
    });

    test('should add a new log at the beginning of the list', () {
      final log1 = LogRepositoryModel(
        type: 'GET',
        response: '200 OK',
        queryparameter: 'id=1',
        header: 'application/json',
        data: '{}',
        responseData: '{"status": "success"}',
        path: '/api/v1/resource',
        message: 'Request successful',
        curl: 'curl -X GET /api/v1/resource',
      );

      final log2 = LogRepositoryModel(
        type: 'POST',
        response: '400 Bad Request',
        queryparameter: 'id=2',
        header: 'application/json',
        data: '{"name": "John"}',
        responseData: '{"status": "error"}',
        path: '/api/v1/resource',
        message: 'Request failed',
        curl: 'curl -X POST /api/v1/resource',
      );

      logRepository.addLog(log1);
      logRepository.addLog(log2);

      expect(logRepository.logsNotifier.value[0], log2);
      expect(logRepository.logsNotifier.value[1], log1);
    });
    test('addInterceptor should add a single interceptor', () {
      dioLogger.addInterceptor(mockInterceptor);

      expect(dioLogger.interceptors.length, 4);
      expect(dioLogger.interceptors[3], mockInterceptor);
    });

    test('addListInterceptor should add multiple interceptors', () {
      dioLogger.addListInterceptor([mockInterceptor, mockInterceptor2]);
 
      expect(dioLogger.interceptors.length, 6);
      expect(dioLogger.interceptors[4], mockInterceptor);
      expect(dioLogger.interceptors[5], mockInterceptor2);
    });
  });
}
