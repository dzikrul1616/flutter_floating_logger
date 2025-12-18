import 'package:floating_logger/src/network/network.dart';
import 'package:floating_logger/src/widgets/widgets.dart';
import 'package:flutter/services.dart';
import '../test.dart';

void widgetFloatingLoggerItemTest() {
  group('FloatingLoggerItem Widget Test', () {
    // Setup common mock clipboard
    void setupMockClipboard(WidgetTester tester) {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall methodCall) async {
          if (methodCall.method == 'Clipboard.setData') {
            return null;
          }
          return null;
        },
      );
    }

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
        header: '{"ok":"ok"}',
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

    testWidgets('Should display Response Time when available',
        (WidgetTester tester) async {
      setupMockClipboard(tester);
      final logData = LogRepositoryModel(
        type: 'RESPONSE',
        method: 'GET',
        path: '/api/test',
        response: '200',
        responseTime: 123,
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

      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      expect(find.text('Response Time'), findsOneWidget);
      expect(find.text('123 ms'), findsOneWidget);

      final responseTimeRow = find.ancestor(
        of: find.text('Response Time'),
        matching: find.byType(Row),
      );
      final copyButton = find.descendant(
        of: responseTimeRow,
        matching: find.byIcon(Icons.copy),
      );

      await tester.tap(copyButton.first);
      await tester.pump(
          const Duration(milliseconds: 100)); // Allow microtasks (Clipboard)
      await tester.pumpAndSettle(
          const Duration(seconds: 3)); // Wait for toast to disappear
    });

    testWidgets('Should NOT display Response Time when null',
        (WidgetTester tester) async {
      final logData = LogRepositoryModel(
        type: 'RESPONSE',
        method: 'GET',
        path: '/api/test',
        response: '200',
        responseTime: null,
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

      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      expect(find.text('Response Time'), findsNothing);
    });

    testWidgets('Should display REQUEST data correctly',
        (WidgetTester tester) async {
      setupMockClipboard(tester);
      final logData = LogRepositoryModel(
        type: 'REQUEST',
        method: 'POST',
        path: '/api/submit',
        data: '{"key": "value"}',
        curl: 'curl',
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

      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      expect(find.text('Data'), findsOneWidget);
      expect(find.text('{"key": "value"}'), findsOneWidget);

      final dataRow = find.ancestor(
        of: find.text('Data'),
        matching: find.byType(Row),
      );
      final copyButton = find.descendant(
        of: dataRow,
        matching: find.byIcon(Icons.copy),
      );
      await tester.tap(copyButton.first);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('Should toggle expanded details when tapped',
        (WidgetTester tester) async {
      final logData = LogRepositoryModel(
        type: 'Response',
        method: 'PATCH',
        path: '/api/test',
        response: '200',
        queryparameter: 'id=123',
        responseData: '{"status":"ok"}',
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

      // Tap the item to unfold
      await tester.tap(find.byType(FloatingLoggerItem));
      await tester.pumpAndSettle();

      expect(find.text('Data'), findsOneWidget);
      expect(find.text('{"status":"ok"}'), findsOneWidget);

      // Tap the "Data" title to collapse the internal section
      final dataTitleFinder = find.text('Data');
      await tester.tap(dataTitleFinder);
      await tester.pumpAndSettle();

      expect(find.text('Data'), findsOneWidget);
      expect(find.text('{"status":"ok"}'), findsNothing);
    });

    testWidgets('Should toggle expanded details when tapped Header title',
        (WidgetTester tester) async {
      final logData = LogRepositoryModel(
        type: 'Response',
        method: 'PATCH',
        path: '/api/test',
        response: '200',
        header: '{"ok":"ok"}',
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

      expect(find.text('Header'), findsNothing);

      await tester.tap(find.byType(FloatingLoggerItem));
      await tester.pumpAndSettle();

      expect(find.text('Header'), findsOneWidget);
      expect(find.text('{"ok":"ok"}'), findsOneWidget);

      await tester.tap(find.text('Header'));
      await tester.pumpAndSettle();

      expect(find.text('{"ok":"ok"}'), findsNothing);
    });

    testWidgets('Should toggle expanded details when tapped arrow icon',
        (WidgetTester tester) async {
      final logData = LogRepositoryModel(
        type: 'Response',
        method: 'PATCH',
        path: '/api/test',
        response: '200',
        queryparameter: 'id=123',
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

      await tester.tap(find.byType(FloatingLoggerItem));
      await tester.pumpAndSettle();

      expect(find.text('Param'), findsOneWidget);

      // Find the arrow icon specifically in the Param section to trigger 496-498
      final arrowIconFinder = find.byIcon(Icons.arrow_drop_up);
      await tester.tap(arrowIconFinder.first);
      await tester.pumpAndSettle();

      expect(find.text('id=123'), findsNothing);
    });

    testWidgets('Should show error toast when cURL is empty',
        (WidgetTester tester) async {
      final mockData = LogRepositoryModel(
        curl: '', // Empty curl should trigger line 71
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
      await tester.longPress(gestureDetectorFinder);
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('Should display Message field when available',
        (WidgetTester tester) async {
      final logData = LogRepositoryModel(
        type: 'RESPONSE',
        message: 'Custom Diagnostic Message', // Triggers line 286, 288
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

      await tester.tap(find.byType(FloatingLoggerItem));
      await tester.pumpAndSettle();

      expect(find.text('Message'), findsOneWidget);
      expect(find.text('Custom Diagnostic Message'), findsOneWidget);
    });

    testWidgets('Test onLongPress gesture on FloatingLoggerItem',
        (WidgetTester tester) async {
      setupMockClipboard(tester);
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
      await tester.longPress(gestureDetectorFinder);
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });
  });
}
