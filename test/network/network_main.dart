import 'package:floating_logger/src/network/network.dart';
import '../test.dart';

@GenerateNiceMocks([
  MockSpec<Response>(),
  MockSpec<DioLogger>(),
  // MockSpec<LoggerToast>(),
  MockSpec<Interceptor>(),
  MockSpec<DioException>(),
  MockSpec<LogRepository>(),
  MockSpec<RequestOptions>(),
  MockSpec<ErrorInterceptorHandler>(),
  MockSpec<RequestInterceptorHandler>(),
  MockSpec<ResponseInterceptorHandler>(),
])
// ignore: unnecessary_import

class NetworkTestMain {
  static void main() {
    networkDio();
    networkModel();
  }
}
