import 'package:floating_logger/floating_logger.dart';
import 'package:flutter/foundation.dart';
import 'pages/home_page.dart';
import 'utils/route.dart';

void main() {
  /// Example to add List custom interceptor
  // DioLogger.instance.addInterceptor(
  //   InterceptorsWrapper(
  //     onResponse: (response, handler) {
  //       // add interceptor condition
  //       if (kDebugMode) {
  //         print('Custom onResponse interceptor');
  //       }
  //       handler.next(response);
  //     },
  //     onError: (error, handler) {
  //       // add interceptor condition
  //       if (kDebugMode) {
  //         print('Custom onError interceptor');
  //       }
  //       handler.next(error);
  //     },
  //   ),
  // );

  /// Example to add List custom interceptor
  // DioLogger.instance.addListInterceptor(
  //   [
  //     InterceptorsWrapper(
  //       onResponse: (response, handler) {
  //         // add interceptor condition
  //         if (kDebugMode) {
  //           print('Custom onResponse interceptor');
  //         }
  //         handler.next(response);
  //       },
  //       onError: (error, handler) {
  //         // add interceptor condition
  //         if (kDebugMode) {
  //           print('Custom onError interceptor');
  //         }
  //         handler.next(error);
  //       },
  //     ),

  //     /// Another interception
  //   ],
  // );
  // runApp(
  //   const MyApp(),
  // );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Floating Logger',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: MyHomePage.routeName,
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
