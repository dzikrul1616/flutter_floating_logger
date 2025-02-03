import 'package:floating_logger/src/network/network.dart';
import 'package:floating_logger/src/widgets/widgets.dart';
import '../test.dart';

void widgetFloatingLoggerItemTest() {
  group('FloatingLoggerItem Widget Test', () {
    testWidgets('Should display log details correctly',
        (WidgetTester tester) async {
      final logData = LogRepositoryModel(
        type: 'Response',
        path: '/api/test',
        response: '200',
        queryparameter: 'id=123',
        message: 'Success',
        data: '{}',
        responseData: '{"status":"ok"}',
        curl: 'curl -X GET /api/test',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FloatingLoggerItem(
              data: logData,
              index: 0,
            ),
          ),
        ),
      );

      expect(find.text('/api/test'), findsOneWidget);

      expect(find.text('[Response]'), findsOneWidget);
      expect(find.text('[200]'), findsOneWidget);

      expect(find.text('Success'), findsOneWidget);
    });

    testWidgets('Should display log details Error 500',
        (WidgetTester tester) async {
      final logData = LogRepositoryModel(
        type: 'Error',
        path: '/api/test',
        response: '500',
        queryparameter: 'id=123',
        message: 'Error',
        data: '{}',
        responseData: '{"status":"Error"}',
        curl: 'curl -X GET /api/test',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FloatingLoggerItem(
              data: logData,
              index: 0,
            ),
          ),
        ),
      );

      expect(find.text('/api/test'), findsOneWidget);

      expect(find.text('[Error]'), findsOneWidget);
      expect(find.text('[500]'), findsOneWidget);

      expect(find.text('Error'), findsOneWidget);
    });

    testWidgets('Should display log details Response 500',
        (WidgetTester tester) async {
      final logData = LogRepositoryModel(
        type: 'Invalid',
        path: '/api/test',
        response: '500',
        queryparameter: 'id=123',
        message: 'Error',
        data: '{}',
        responseData: '{"status":"Error"}',
        curl: 'curl -X GET /api/test',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FloatingLoggerItem(
              data: logData,
              index: 0,
            ),
          ),
        ),
      );

      expect(find.text('/api/test'), findsOneWidget);

      expect(find.text('[Invalid]'), findsOneWidget);
      expect(find.text('[500]'), findsOneWidget);

      expect(find.text('Error'), findsOneWidget);
    });

    testWidgets('Should toggle expanded details when tapped',
        (WidgetTester tester) async {
      final logData = LogRepositoryModel(
        type: 'Response',
        path: '/api/test',
        response: '200',
        queryparameter: 'id=123',
        message: 'Success',
        data: '{}',
        responseData: '{"status":"ok"}',
        curl: 'curl -X GET /api/test',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FloatingLoggerItem(
              data: logData,
              index: 0,
            ),
          ),
        ),
      );

      expect(find.text('Data'), findsNothing);

      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      expect(find.text('Data'), findsOneWidget);
    });
  });
}
