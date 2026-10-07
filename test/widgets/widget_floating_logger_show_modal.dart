import 'package:flutter/services.dart';
import 'package:floating_logger/src/widgets/widgets.dart';

import '../test.dart';

void widgetFloatingLoggerShowModalTest() {
  group('FloatingLoggerShowModal Widget Test', () {
    late FloatingLoggerModalBottomWidget widget;
    late FloatingLoggerModalBottomWidgetState state;

    setUp(() {
      widget = const FloatingLoggerModalBottomWidget();
      NetworkSimulator.instance.setSimulation(NetworkSimulation.normal);
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

      final applyButton = find.text('Apply Filters');
      expect(applyButton, findsOneWidget);

      await tester.tap(applyButton);
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

      await tester.tap(find.byIcon(Icons.delete_outline));
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

      final postTextFinder = find.text('POST (0)');
      expect(postTextFinder, findsOneWidget);

      await tester.tap(postTextFinder);
      await tester.pumpAndSettle();

      final state = tester.state<FloatingLoggerModalBottomWidgetState>(
        find.byType(FloatingLoggerModalBottomWidget),
      );

      expect(state.activeFilters.value, contains('POST'));

      await tester.tap(postTextFinder);
      await tester.pumpAndSettle();

      expect(state.activeFilters.value, isNot(contains('POST')));
    });

    testWidgets('Verify logCount rendering in filter dialog',
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

      final statusTypes = ['REQUEST', 'RESPONSE', 'ERROR'];
      for (final entry in statusTypes) {
        final expectedCount = logs.where((log) => log.type == entry).length;
        expect(find.text('$entry ($expectedCount)'), findsOneWidget);
      }

      final methodTypes = ['GET', 'POST', 'PUT', 'PATCH', 'OPTIONS', 'HEAD', 'DELETE'];
      for (final entry in methodTypes) {
        final expectedCount = logs.where((log) => log.method == entry).length;
        expect(find.text('$entry ($expectedCount)'), findsOneWidget);
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

    testWidgets('Speed Control interaction', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatingLoggerModalBottomWidget(),
          ),
        ),
      );

      expect(find.byIcon(Icons.speed), findsOneWidget);

      await tester.tap(find.byIcon(Icons.speed));
      await tester.pumpAndSettle();

      expect(find.text('Network Simulation'), findsOneWidget);
      expect(find.text('Slow 3G'), findsWidgets);

      await tester.tap(find.text('Slow 3G').first);
      await tester.pumpAndSettle();

      expect(find.text('Network Simulation'), findsNothing);

      expect(find.byIcon(Icons.network_check), findsOneWidget);
    });

    testWidgets('Should pass isSimulationActive parameter correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MediaQuery(
              data: const MediaQueryData(size: Size(800, 800)),
              child: const FloatingLoggerModalBottomWidget(
                isSimulationActive: false,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final widget = tester.widget<FloatingLoggerModalBottomWidget>(
        find.byType(FloatingLoggerModalBottomWidget),
      );

      expect(widget.isSimulationActive, false);

      // Clean up
      DioLogger.instance.logs.clearLogs();
    });

    testWidgets('Search navigation functionality and looping',
        (WidgetTester tester) async {
      DioLogger.instance.logs.clearLogs();
      DioLogger.instance.logs.logsNotifier.value = [
        LogRepositoryModel(path: '/api/test1', message: 'test'),
        LogRepositoryModel(path: '/api/test2', message: 'test'),
        LogRepositoryModel(path: '/api/other', message: 'other'),
      ];

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'test');
      await tester.pumpAndSettle();

      final state = tester.state<FloatingLoggerModalBottomWidgetState>(
        find.byType(FloatingLoggerModalBottomWidget),
      );
      expect(state.searchQuery.value, 'test');

      // Should find 2 matches
      expect(find.textContaining('1/2'), findsOneWidget);

      // Navigate down to match 2
      await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      expect(find.textContaining('2/2'), findsOneWidget);

      // Loop back to 1
      await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      expect(find.textContaining('1/2'), findsOneWidget);

      // Navigate up to loop to bottom (2)
      await tester.tap(find.byIcon(Icons.keyboard_arrow_up));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      expect(find.textContaining('2/2'), findsOneWidget);

      // Navigate up from 2 to 1 (covers dec path)
      await tester.tap(find.byIcon(Icons.keyboard_arrow_up));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      expect(find.textContaining('1/2'), findsOneWidget);
    });

    testWidgets('Verifies all network simulation icons and interactions',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

      await tester.tap(find.byIcon(Icons.speed));
      await tester.pumpAndSettle();

      final simulations = {
        'Offline': Icons.wifi_off,
        'Socket Error': Icons.error_outline,
        'Server Error': Icons.cloud_off,
        'Timeout': Icons.timer_off,
        'Normal': Icons.speed,
      };

      for (var entry in simulations.entries) {
        expect(find.text(entry.key), findsWidgets);
        // Tap to change and verify icon changes in main list
        await tester.tap(find.text(entry.key).first);
        await tester.pumpAndSettle();
        expect(find.byIcon(entry.value), findsOneWidget);

        // Re-open dialog for next iteration
        await tester.tap(find.byIcon(entry.value));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Clear logs functionality', (WidgetTester tester) async {
      DioLogger.instance.logs.clearLogs();
      DioLogger.instance.logs.logsNotifier.value = [
        LogRepositoryModel(path: '/api/test')
      ];
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
      expect(find.text('/api/test'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(DioLogger.instance.logs.logsNotifier.value, isEmpty);
      expect(find.text('/api/test'), findsNothing);
    });

    testWidgets('Tapping laptop icon shows Web Inspector dialog and toggles switch',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatingLoggerModalBottomWidget(),
          ),
        ),
      );

      final laptopIconFinder = find.byIcon(Icons.laptop_mac_rounded);
      expect(laptopIconFinder, findsOneWidget);

      WebInspectorServer.instance.currentPort = 21616;
      WebInspectorServer.instance.currentIp = '127.0.0.1';
      WebInspectorServer.instance.isRunningNotifier.value = true;

      await tester.tap(laptopIconFinder);
      await tester.pumpAndSettle();

      expect(find.text('Web Inspector'), findsOneWidget);
      expect(find.text('Server Status'), findsOneWidget);
      expect(find.text('ACCESS URL'), findsOneWidget);

      // Close dialog
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      WebInspectorServer.instance.isRunningNotifier.value = false;
    });

    testWidgets('Filter by HTTP method only works correctly', (WidgetTester tester) async {
      DioLogger.instance.logs.clearLogs();
      DioLogger.instance.logs.logsNotifier.value = [
        const LogRepositoryModel(method: 'GET', path: '/api/get_only'),
        const LogRepositoryModel(method: 'POST', path: '/api/post_only'),
      ];

      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: FloatingLoggerModalBottomWidget())));
      final modalState = tester.state<FloatingLoggerModalBottomWidgetState>(
          find.byType(FloatingLoggerModalBottomWidget));

      // Filter only by method GET
      modalState.toggleFilter('GET');
      await tester.pumpAndSettle();

      expect(find.text('/api/get_only'), findsOneWidget);
      expect(find.text('/api/post_only'), findsNothing);
    });

    testWidgets('Header dark mode toggle button toggles theme', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: FloatingLoggerModalBottomWidget())));

      FloatingLoggerTheme.setThemeMode(ThemeMode.light);
      final themeBtn = find.byTooltip("Toggle Dark/Light Mode");
      expect(themeBtn, findsOneWidget);

      await tester.tap(themeBtn);
      await tester.pumpAndSettle();

      expect(FloatingLoggerTheme.themeModeNotifier.value, ThemeMode.dark);
    });

    testWidgets('Filter dialog close button and status chip toggle work', (WidgetTester tester) async {
      DioLogger.instance.logs.clearLogs();
      DioLogger.instance.logs.logsNotifier.value = [
        const LogRepositoryModel(type: 'REQUEST', path: '/api/req'),
      ];

      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: FloatingLoggerModalBottomWidget())));

      // Open filter dialog
      await tester.tap(find.byTooltip("Detailed Filters"));
      await tester.pumpAndSettle();

      expect(find.text('Filter Logs'), findsOneWidget);

      // Close filter dialog
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.text('Filter Logs'), findsNothing);

      // Re-open and toggle status chip
      await tester.tap(find.byTooltip("Detailed Filters"));
      await tester.pumpAndSettle();

      final requestChip = find.descendant(
        of: find.byType(Dialog),
        matching: find.textContaining('REQUEST'),
      );
      await tester.tap(requestChip);
      await tester.pumpAndSettle();

      final modalState = tester.state<FloatingLoggerModalBottomWidgetState>(
          find.byType(FloatingLoggerModalBottomWidget));
      expect(modalState.activeFilters.value.contains('REQUEST'), isTrue);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
    });

    testWidgets('Simulation dialog close button works', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatingLoggerModalBottomWidget(isSimulationActive: true),
          ),
        ),
      );

      // Open simulation dialog by tapping speed icon
      await tester.tap(find.byIcon(Icons.speed));
      await tester.pumpAndSettle();

      expect(find.text('Network Simulation'), findsOneWidget);

      // Tap close button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Network Simulation'), findsNothing);
    });

    testWidgets('Web Inspector dialog inactive state, switch toggle, and copy URL',
        (WidgetTester tester) async {
      // Mock clipboard
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall methodCall) async => null,
      );

      WebInspectorServer.mockStart = ({port = 21616, maxAttempts = 10}) async => true;
      WebInspectorServer.mockStop = () async {};

      WebInspectorServer.instance.isRunningNotifier.value = false;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatingLoggerModalBottomWidget(),
          ),
        ),
      );

      // 1. Open dialog when stopped
      await tester.tap(find.byIcon(Icons.laptop_mac_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Inactive (Stopped)'), findsOneWidget);

      // 2. Toggle switch on then off
      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);

      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Close dialog
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      // 3. Open dialog when running to test Copy URL button
      WebInspectorServer.instance.currentPort = 21616;
      WebInspectorServer.instance.currentIp = '127.0.0.1';
      WebInspectorServer.instance.isRunningNotifier.value = true;

      await tester.tap(find.byIcon(Icons.laptop_mac_rounded));
      await tester.pumpAndSettle();

      final copyBtn = find.text('Copy');
      expect(copyBtn, findsOneWidget);
      await tester.tap(copyBtn);
      await tester.pump();

      expect(find.text('URL copied to clipboard!'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      // Clear toast timers
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      WebInspectorServer.instance.isRunningNotifier.value = false;
      WebInspectorServer.mockStart = null;
      WebInspectorServer.mockStop = null;
    });

    testWidgets('scrollToMatch jumps to approxOffset when target key context is null',
        (WidgetTester tester) async {
      DioLogger.instance.logs.clearLogs();
      for (int i = 0; i < 40; i++) {
        DioLogger.instance.logs.addLog(LogRepositoryModel(path: '/api/item_$i'));
      }

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatingLoggerModalBottomWidget(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final modalState = tester.state<FloatingLoggerModalBottomWidgetState>(
          find.byType(FloatingLoggerModalBottomWidget));

      expect(modalState.itemKeys, isNotEmpty);

      // Item 25 is outside initial viewport, so targetKey context is null initially
      modalState.currentMatchIndex.value = 25;
      modalState.scrollToMatch();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      expect(modalState.scrollController.hasClients, isTrue);
    });
  });
}

void main() {
  widgetFloatingLoggerShowModalTest();
}
