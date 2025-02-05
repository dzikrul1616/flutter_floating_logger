import 'package:floating_logger/src/widgets/widgets.dart';

import '../test.dart';

void widgetFloatingLoggerToastTest() {
  group('FloatingLoggerToast Widget Test', () {
    testWidgets('Success toast appears and disappears',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => LoggerToast.successToast(context, 'Success!'),
                child: Text('Show Success Toast'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Success Toast'));
      await tester.pump();

      expect(find.text('Success!'), findsOneWidget);

      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('Success!'), findsNothing);
    });

    testWidgets('Error toast appears and disappears',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => LoggerToast.errorToast(context, 'Error!'),
                child: Text('Show Error Toast'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Error Toast'));
      await tester.pump();

      expect(find.text('Error!'), findsOneWidget);

      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('Error!'), findsNothing);
    });
  });
}
