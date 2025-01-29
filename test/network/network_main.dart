import 'package:floating_logger/src/network/network.dart';
import '../test.dart';

@GenerateNiceMocks([
  MockSpec<DioLogger>(),
  MockSpec<LogRepository>(),
  MockSpec<RequestInterceptorHandler>(),
  MockSpec<ResponseInterceptorHandler>(),
  MockSpec<ErrorInterceptorHandler>(),
  MockSpec<FlutterClipboard>(),
])
// ignore: unnecessary_import

class NetworkTestMain {
  static void main() {
    networkDio();
    networkModel();
  }
}
