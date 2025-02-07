import 'package:floating_logger/src/network/network.dart';
import 'package:floating_logger/src/pages/pages.dart';
import 'package:floating_logger/src/widgets/widgets.dart';

import '../test.dart';

class PagesTestMain {
  static void main() {
    group('Page Test', () {
      testWidgets('Displays list when logsFiltered is not empty',
          (WidgetTester tester) async {
        final logs = [
          LogRepositoryModel(
            type: 'RESPONSE',
            method: 'GET',
            path: '/api/test',
            response: '200',
            queryparameter: 'id=123',
            message: 'Success',
            header: '{"content":"app/json"}',
            data: '{"sadasdas" : "sdada"}',
            responseData: '{"status":"ok"}',
            curl: 'curl -X GET /api/test',
          )
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  PagesFloatingLogger(
                    logsFiltered: logs,
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(ListView), findsOneWidget);
        expect(find.byType(FloatingLoggerItem), findsNWidgets(logs.length));
      });
      testWidgets('Displays log list with widgetBuilder',
          (WidgetTester tester) async {
        final logs = [
          LogRepositoryModel(
            type: 'RESPONSE',
            method: 'GET',
            path: '/api/test',
            response: '200',
            queryparameter: 'id=123',
            message: 'Success',
            header: '{"content":"app/json"}',
            data: '{"sadasdas" : "sdada"}',
            responseData: '{"status":"ok"}',
            curl: 'curl -X GET /api/test',
          )
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  PagesFloatingLogger(
                    logsFiltered: logs,
                    widgetItemBuilder: (a, s) {
                      return const SizedBox();
                    },
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(ListView), findsOneWidget);
      });
    });
  }
}
