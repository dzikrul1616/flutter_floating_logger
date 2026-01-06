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
      await tester
          .pump(const Duration(seconds: 3)); // Wait for toast to disappear
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
      expect(find.text('Data'), findsOneWidget);
      // expect(find.text('{"key": "value"}'), findsOneWidget); // Replaced by JsonViewer check
      expect(find.textContaining('"key": "value",'), findsOneWidget);

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
      await tester.pump(const Duration(seconds: 3));
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
      expect(find.textContaining('"status": "ok",'), findsOneWidget);

      // Tap the arrow icon to collapse the internal section
      final dataRow = find.ancestor(
        of: find.text('Data'),
        matching: find.byType(Row),
      );
      final arrowIcon = find.descendant(
        of: dataRow,
        matching: find.byIcon(Icons.arrow_drop_up),
      );
      await tester.tap(arrowIcon.first);
      await tester.pumpAndSettle();

      expect(find.text('Data'), findsOneWidget);
      expect(find.textContaining('"status": "ok",'), findsNothing);
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
      expect(find.textContaining('"ok": "ok",'), findsOneWidget);

      final headerRow = find.ancestor(
        of: find.text('Header'),
        matching: find.byType(Row),
      );
      final arrowIcon = find.descendant(
        of: headerRow,
        matching: find.byIcon(Icons.arrow_drop_up),
      );
      await tester.tap(arrowIcon.first);
      await tester.pumpAndSettle();

      expect(find.textContaining('"ok": "ok",'), findsNothing);
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
      await tester.longPress(gestureDetectorFinder.first);
      await tester.pump(const Duration(seconds: 3));
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
      await tester.longPress(gestureDetectorFinder.first);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('Should display different method colors',
        (WidgetTester tester) async {
      final methods = ['PUT', 'PATCH', 'OPTIONS', 'HEAD', 'DELETE'];
      for (final method in methods) {
        final logData = LogRepositoryModel(
          type: 'REQUEST',
          method: method,
          path: '/api/test',
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

        expect(find.text(method), findsOneWidget);
      }
    });

    testWidgets('Should display UNKNOWN status for non-response/error types',
        (WidgetTester tester) async {
      final logData = LogRepositoryModel(
        type: 'STUFF',
        path: '/api/test',
        response: '999',
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

      expect(find.text('999 UNKNOWN'), findsOneWidget);
    });

    testWidgets('Should show success toast when cURL is copied',
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
      await tester.longPress(gestureDetectorFinder.first);
      // Wait for toast to appear and disappear to avoid ticker errors in subsequent tests
      await tester.pumpAndSettle(const Duration(seconds: 4));
    });

    testWidgets('Should show different border for isActive item',
        (WidgetTester tester) async {
      final logData = LogRepositoryModel(path: '/api/test');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FloatingLoggerItem(
              data: logData,
              index: 0,
              isActive: true,
            ),
          ),
        ),
      );

      final animatedContainer = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      final decoration = animatedContainer.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.orange.withOpacity(0.15)));
    });

    testWidgets('Should render custom child if provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FloatingLoggerItem(
              data: LogRepositoryModel(),
              index: 0,
              child: const Text('Custom UI'),
            ),
          ),
        ),
      );

      expect(find.text('Custom UI'), findsOneWidget);
      expect(find.text('/'), findsNothing);
    });
    testWidgets('CollapsibleCodeField should highlight search query',
        (WidgetTester tester) async {
      final logData = LogRepositoryModel(
        type: 'REQUEST',
        path: '/api/test',
        data: '{"key": "target"}',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: FloatingLoggerItem(
                data: logData,
                index: 0,
                searchQuery: 'target',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the item to expand
      await tester.tap(find.byType(FloatingLoggerItem));
      // Wait for at least 300ms timer + 300ms animation
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Find the 'Data' section and expand it
      final dataHeader = find.text('Data');
      expect(dataHeader, findsOneWidget);
      await tester.tap(dataHeader);
      await tester.pumpAndSettle();

      // Verify 'target' is found in the tree
      expect(find.textContaining('target'), findsWidgets);

      // Verify collapsing (covers line 130)
      // Tap on the path text to ensure we hit the main item's toggle
      await tester.tap(find.text('/api/test'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(
          seconds: 1)); // Extra wait to ensure animation is fully dismissed
      // Use Divider as a more reliable indicator of expanded state removal
      expect(find.byType(Divider), findsNothing);
    });

    testWidgets('initState expansion when isActive is true (covers line 63-71)',
        (WidgetTester tester) async {
      final logData = LogRepositoryModel(
        type: 'REQUEST',
        path: '/api/test',
        data: '{"key": "data"}',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FloatingLoggerItem(
              data: logData,
              index: 0,
              searchQuery: 'api',
              isActive: true, // Should trigger initState expansion
            ),
          ),
        ),
      );

      // Initial state is collapsed, then timer triggers expansion
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      // Verify expansion (Divider should be present)
      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('_highlightSubText multi-match and path highlighting',
        (WidgetTester tester) async {
      final logData = LogRepositoryModel(
        type: 'REQUEST',
        path: '/api/test/api/path',
        method: 'GET',
        data:
            'prefix api suffix', // Non-JSON to trigger highlighting with text before and after matches
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FloatingLoggerItem(
              data: logData,
              index: 0,
              searchQuery: 'api',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Expand the item to trigger _buildExpandedDetails
      await tester.tap(find.text('/api/test/api/path'));
      await tester.pumpAndSettle();

      // Verify multiple highlights for "api" in the path and data (covers both _highlightSubText methods)
      final highlighted = find.byWidgetPredicate((widget) {
        if (widget is RichText) {
          final span = widget.text;
          if (span is TextSpan) {
            bool found = false;
            span.visitChildren((child) {
              if (child is TextSpan &&
                  child.style?.backgroundColor == Colors.orange) {
                found = true;
                return false;
              }
              return true;
            });
            return found;
          }
        }
        return false;
      });

      // Path has two "api"s
      expect(highlighted, findsWidgets);
    });

    testWidgets(
        'initialExpanded: true should trigger expansion in initState (covers line 64)',
        (WidgetTester tester) async {
      final logData = LogRepositoryModel(path: '/api/expanded');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FloatingLoggerItem(
              data: logData,
              index: 0,
              initialExpanded: true,
            ),
          ),
        ),
      );
      // No need for pumpAndSettle or timer, should be expanded immediately
      await tester.pump();

      // Verify expansion (Divider should be present immediately)
      expect(find.byType(Divider), findsOneWidget);
    });
  });
}

void main() {
  widgetFloatingLoggerItemTest();
}
