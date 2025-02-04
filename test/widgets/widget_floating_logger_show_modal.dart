import 'package:floating_logger/src/network/network.dart';
import 'package:floating_logger/src/widgets/widgets.dart';

import '../test.dart';

void widgetFloatingLoggerShowModalTest() {
  group('FloatingLoggerShowModal Widget Test', () {
    testWidgets('should render FloatingLoggerModalBottomWidget correctly',
        (WidgetTester tester) async {
      final logs = [
        LogRepositoryModel(message: 'Test log 1'),
        LogRepositoryModel(message: 'Test log 2'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FloatingLoggerModalBottomWidget(
              widgetItemBuilder: (index, data) {
                return ListTile(
                  title: Text(data[index].message ?? ""),
                );
              },
            ),
          ),
        ),
      );

      DioLogger.instance.logs.logsNotifier.value = logs;
      await tester.pump();

      expect(find.byType(FloatingLoggerModalBottomWidget), findsOneWidget);
      expect(find.text('2 Request'), findsOneWidget);
      expect(find.text('Clear'), findsOneWidget);
      expect(find.text('Test log 1'), findsOneWidget);
      expect(find.text('Test log 2'), findsOneWidget);
    });

    testWidgets('should clear logs when "Clear" button is tapped',
        (WidgetTester tester) async {
      final logs = [
        LogRepositoryModel(message: 'Test log 1'),
        LogRepositoryModel(message: 'Test log 2'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FloatingLoggerModalBottomWidget(
              widgetItemBuilder: (index, data) {
                return ListTile(
                  title: Text(data[index].message ?? ""),
                );
              },
            ),
          ),
        ),
      );

      DioLogger.instance.logs.logsNotifier.value = logs;
      await tester.pump();

      await tester.tap(find.text('Clear'));
      await tester.pump();

      expect(DioLogger.instance.logs.logsNotifier.value, isEmpty);
      expect(find.text('0 Request'), findsOneWidget);
    });

    testWidgets('should display the handle at the top of the modal',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FloatingLoggerModalBottomWidget(),
          ),
        ),
      );

      final handleFinder = find.byWidgetPredicate((widget) {
        return widget is Container && widget.constraints?.maxHeight == 5;
      });

      expect(handleFinder, findsOneWidget);
    });
  });
}
