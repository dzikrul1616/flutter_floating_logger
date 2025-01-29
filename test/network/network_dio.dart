import 'package:floating_logger/src/network/network.dart';
import '../test.dart';

void networkDio() {
  group('Network Dio', () {
    late DioLogger dio;
    late MockDioLogger mockDio;

    setUp(() { 
      mockDio = MockDioLogger();
 
      when(mockDio.options).thenReturn(BaseOptions(
        connectTimeout: Duration(milliseconds: 50000),
        receiveTimeout: Duration(milliseconds: 30000),
        contentType: 'application/json; charset=utf-8',
      ));

      final mockLogRepository = MockLogRepository();
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
  });
}
