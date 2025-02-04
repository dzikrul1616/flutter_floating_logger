import 'package:floating_logger/src/network/network.dart';
import 'package:floating_logger/src/widgets/widgets.dart';
import '../test.dart';

void widgetFloatingLoggerItemTest() {
  group('FloatingLoggerItem Widget Test', () {
    testWidgets('Should display log details correctly',
        (WidgetTester tester) async {
      final logData = LogRepositoryModel(
        type: 'RESPONSE',
        method: 'GET',
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

      expect(find.text('RESPONSE'), findsOneWidget);
      expect(find.text('GET'), findsOneWidget);

      expect(find.text('200 SUCCESS'), findsOneWidget);
    });

    testWidgets('Should display log details Error 500',
        (WidgetTester tester) async {
      final logData = LogRepositoryModel(
        type: 'ERROR',
        method: 'POST',
        path: '/api/test',
        response: '500',
        queryparameter: 'id=123',
        message: 'Error',
        data: '{}',
        responseData: '{"status":"Error"}',
        curl: 'curl -X POST /api/test',
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

      expect(find.text('POST'), findsOneWidget);
      expect(find.text('ERROR'), findsOneWidget);

      expect(find.text('500 ERROR'), findsOneWidget);
    });

    testWidgets('Should display log details Response 500',
        (WidgetTester tester) async {
      final logData = LogRepositoryModel(
        type: 'Invalid',
        method: 'PUT',
        path: '/api/test',
        response: '500',
        queryparameter: 'id=123',
        message: 'Error',
        data: '{}',
        responseData: '{"status":"Error"}',
        curl: 'curl -X PUT /api/test',
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

      expect(find.text('PUT'), findsOneWidget);
      expect(find.text('Invalid'), findsOneWidget);
    });

    testWidgets('Should display OPTIONS request', (WidgetTester tester) async {
      final logData = LogRepositoryModel(
        type: 'Invalid',
        method: 'OPTIONS',
        path: '/api/test',
        response: '500',
        queryparameter: 'id=123',
        message: 'Error',
        data: '{}',
        responseData: '{"status":"Error"}',
        curl: 'curl -X OPTIONS /api/test',
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

      expect(find.text('OPTIONS'), findsOneWidget);
      expect(find.text('Invalid'), findsOneWidget);
    });

    testWidgets('Should display HEAD request', (WidgetTester tester) async {
      final logData = LogRepositoryModel(
        type: 'REQUEST',
        method: 'HEAD',
        header: '{"header" : "value"}',
        path: '/api/test',
        response: '500',
        queryparameter: 'id=123',
        message: 'Error',
        data: '{ada isinya}',
        responseData: '{"status":"Error"}',
        curl: 'curl -X HEAD /api/test',
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

      expect(find.text('HEAD'), findsOneWidget);
      expect(find.text('REQUEST'), findsOneWidget);
    });

    testWidgets('Should toggle expanded details when tapped',
        (WidgetTester tester) async {
      final logData = LogRepositoryModel(
        type: 'Response',
        method: 'PATCH',
        path: '/api/test',
        response: '200',
        queryparameter: 'id=123',
        message: 'Success',
        data: '{}',
        responseData: '{"status":"ok"}',
        curl: 'curl -X PATCH /api/test',
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
  testWidgets('Test onLongPress gesture on FloatingLoggerItem',
      (WidgetTester tester) async {
    final mockData = LogRepositoryModel(
      curl: 'curl example',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FloatingLoggerItem(
            data: mockData,
            index: 0,
          ),
        ),
      ),
    );

    final gestureDetectorFinder = find.byType(GestureDetector);

    expect(gestureDetectorFinder, findsOneWidget);

    await tester.longPress(gestureDetectorFinder);
    await tester.pump();
  });
  testWidgets('Shows success toast when copying cURL data', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    LoggerToast.successToast(
                      "Successfully copied cURL data",
                      context: context,
                    );
                  },
                  child: const Text('Show Toast'),
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('Show Toast'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('Shows error toast when copying empty cURL data', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    LoggerToast.errorToast(
                      "Failed to copy, no data available",
                      context: context,
                    );
                  },
                  child: const Text('Show Error Toast'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Show Error Toast'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('Test GestureDetector onTap in _codeFieldCopy',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: FloatingLoggerItem(
          data: LogRepositoryModel(
            curl: 'Example cURL data',
          ),
          index: 0,
        ),
      ),
    ));
    final gestureDetectorFinder = find.byType(GestureDetector);
    expect(gestureDetectorFinder, findsAtLeast(1));
    await tester.tap(gestureDetectorFinder);
    await tester.pump();
  });
}
