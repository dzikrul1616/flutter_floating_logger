import 'package:floating_logger/src/network/network.dart';
import 'package:floating_logger/src/widgets/widgets.dart';

import '../test.dart';

void widgetFloatingLoggerShowModalTest() {
  group('FloatingLoggerShowModal Widget Test', () {
    late FloatingLoggerModalBottomWidget widget;
    late FloatingLoggerModalBottomWidgetState state;

    setUp(() {
      widget = const FloatingLoggerModalBottomWidget();
    });

    testWidgets('Toggle filter functionality', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
      state = tester.state(find.byType(FloatingLoggerModalBottomWidget));

      state.showAllLogs();

      state.toggleFilter('REQUEST');
      expect(state.activeFilters.value.contains('REQUEST'), isTrue);
      state.toggleFilter('REQUEST');
      expect(state.activeFilters.value.contains('REQUEST'), isFalse);
    });

    testWidgets('Search query updates on input', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
      state = tester.state(find.byType(FloatingLoggerModalBottomWidget));

      expect(state.searchQuery.value, "");

      state.toggleSearch();
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'test query');
      await tester.pump();

      expect(state.searchQuery.value, "test query");

      state.toggleSearch();
      await tester.pump();

      expect(state.searchQuery.value, "");
      expect(state.searchController.text, "");

      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('FloatingLoggerModalBottomWidget renders correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatingLoggerModalBottomWidget(),
          ),
        ),
      );

      expect(find.byType(Container), findsWidgets);

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('Tapping search button shows search field',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatingLoggerModalBottomWidget(),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('Tapping filter button shows filter dialog',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatingLoggerModalBottomWidget(),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('Filter Logs'), findsOneWidget);

      final closeButton = find.text('Close');
      expect(closeButton, findsOneWidget);

      await tester.tap(closeButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('Filter Logs'), findsNothing);
    });

    testWidgets('Tapping clear button clears logs',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatingLoggerModalBottomWidget(),
          ),
        ),
      );

      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();
    });

    testWidgets('Toggle filter adds/removes filter from activeFilters',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FloatingLoggerModalBottomWidget(),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      expect(find.text('Filter Logs'), findsOneWidget);

      find.byType(ElevatedButton);

      final postTextFinder = find.text('POST (0)');
      expect(postTextFinder, findsOneWidget);

      final postButton = find.ancestor(
        of: postTextFinder,
        matching: find.byType(ElevatedButton),
      );
      expect(postButton, findsOneWidget);

      await tester.tap(postButton);
      await tester.pumpAndSettle();

      final state = tester.state<FloatingLoggerModalBottomWidgetState>(
        find.byType(FloatingLoggerModalBottomWidget),
      );

      expect(state.activeFilters.value, contains('POST'));

      await tester.tap(postButton);
      await tester.pumpAndSettle();

      expect(state.activeFilters.value, isNot(contains('POST')));
    });

    testWidgets('Verify logCount and ElevatedButton rendering in filter dialog',
        (WidgetTester tester) async {
      final logs = [
        LogRepositoryModel(type: 'POST', method: 'POST', path: '/api/test'),
        LogRepositoryModel(type: 'GET', method: 'GET', path: '/api/test'),
        LogRepositoryModel(type: 'ERROR', method: 'ERROR', path: '/api/test'),
      ];

      DioLogger.instance.logs.logsNotifier.value = logs;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FloatingLoggerModalBottomWidget(),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      expect(find.text('Filter Logs'), findsOneWidget);

      final logTypes = [
        'REQUEST',
        'RESPONSE',
        'ERROR',
        'GET',
        'POST',
        'PUT',
        'PATCH',
        'OPTIONS',
        'HEAD',
        'DELETE',
      ];

      for (final entry in logTypes) {
        final expectedLogCount = logs
            .where(
              (log) => log.type == entry || log.method == entry,
            )
            .length;

        final buttonTextFinder = find.text('$entry ($expectedLogCount)');
        expect(buttonTextFinder, findsOneWidget);

        final buttonFinder = find.ancestor(
          of: buttonTextFinder,
          matching: find.byType(ElevatedButton),
        );
        expect(buttonFinder, findsOneWidget);

        final button = tester.widget<ElevatedButton>(buttonFinder);
        expect(
          button.style?.backgroundColor?.resolve({}),
          equals(Colors.grey[200]),
        );

        await tester.tap(buttonFinder);
        await tester.pumpAndSettle();
        tester.widget<ElevatedButton>(buttonFinder);

        await tester.tap(buttonFinder);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('UI displays filtered logs based on search and filter',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FloatingLoggerModalBottomWidget(),
          ),
        ),
      );

      final logs = [
        LogRepositoryModel(
          type: 'REQUEST',
          method: 'GET',
          path: '/api/test',
          response: '200',
          queryparameter: 'id=123',
          message: 'Success',
          header: '{"content":"app/json"}',
          data: '{"sadasdas" : "sdada"}',
          responseData: '{"status":"ok"}',
          curl: 'curl -X GET /api/test',
        ),
        LogRepositoryModel(
          type: 'RESPONSE',
          method: 'POST',
          path: '/api/another',
          response: '200',
          queryparameter: 'id=456',
          message: 'Success',
          header: '{"content":"app/json"}',
          data: '{"sadasdas" : "sdada"}',
          responseData: '{"status":"ok"}',
          curl: 'curl -X POST /api/another',
        ),
      ];

      DioLogger.instance.logs.logsNotifier.value = logs;

      final state = tester.state<FloatingLoggerModalBottomWidgetState>(
        find.byType(FloatingLoggerModalBottomWidget),
      );
      state.searchQuery.value = 'test';

      state.activeFilters.value = {'REQUEST'};

      await tester.pump();

      expect(find.text('/api/test'), findsOneWidget);
      expect(find.text('/api/another'), findsNothing);
    });
  });
}
